#!/bin/env luvit

local spawn = require 'coro-spawn'
local fs = require 'coro-fs'
local uv = require 'uv'
local exec2 = require 'exec'


local archives = {
  "src/lua-5.1.5.tar.gz",
  "src/lua-5.2.4.tar.gz",
  "src/lua-5.3.2.tar.gz",
  "src/LuaJIT-2.0.4.tar.gz",
  "src/LuaJIT-2.1.0-beta2.tar.gz",
  rock = "src/luarocks-2.3.0.tar.gz"
}
local function exec(command, ...)
  print("Exec:", table.concat({command, ...}, " "))
  local child = spawn(command, {
    args = {...},
    -- Tell spawn to create coroutine pipes for stdout and stderr only
    stdio = {nil, 1, 2}
  })

  -- Split the coroutine into three sub-coroutines and wait for all three.
  local code = child.waitExit()

  if code ~= 0 then
    os.exit(code)
  end
end

local function replace(file, from, to)
  print("Patching file", file, from, to)
  return assert(fs.writeFile(file,
    assert(fs.readFile(file)):gsub(from, to))
  )
end
coroutine.wrap(function ()

  local base = uv.cwd()
  local root = base .. '/' .. exec2("uname", "-s", "-m"):gsub(" ", "-"):gsub("\n","")
  fs.mkdir(root)

  print("Installing luvit")
  local luvitprefix = root .. '/luvit-2'
  fs.mkdir(luvitprefix)
  local luvitbindir = luvitprefix .. "/bin"
  fs.mkdir(luvitbindir)
  exec("lit", "make", "lit://luvit/luvit", luvitbindir .. "/luvit")
  exec("lit", "make", "lit://luvit/lit", luvitbindir .. "/lit")
  exec(luvitbindir .. "/lit", "update")
  uv.fs_symlink("luvit", luvitbindir .. "/lua")

  local srcdir = root .. "/src"
  fs.mkdir(srcdir)
  local PATH = process.env.PATH
  for i = 1, #archives do
    local archive = archives[i]
    print("Opening " .. archive .. "...")
    exec("tar", "-C", srcdir, "-xvf", archive)
    local version = archive:match("^src/([^-]+-[0-9]+.[0-9]+)"):lower()
    local target = root .. '/' .. version

    local dir = root .. "/" .. archive:gsub(".tar.gz", "")
    if version:match("luajit") then
      replace(dir .. "/Makefile", "PREFIX= /usr/local", "PREFIX= " .. target)
    else
      replace(dir .. "/Makefile", "INSTALL_TOP= /usr/local", "INSTALL_TOP= " .. target)
      replace(dir .. "/Makefile", "PLAT= none", "PLAT= " .. ({
        OSX="macosx",
        Linux="linux",
      })[jit.os])
    end
    print("Building " .. dir .. "...")
    exec("make", "-C", dir, "-j4")
    print("Installing " .. dir .. "...")
    exec("make", "-C", dir, "install")
    if version:match("luajit") then
      local bin
      for entry in fs.scandir(target .. "/bin") do
        if entry.type == "file" then
          bin = entry.name
          break
        end
      end
      print("Creating symlink", target .. "/bin/lua")
      assert(uv.fs_symlink(bin, target .. "/bin/lua"))
    end
    print("Opening " .. archives.rock .. "...")
    exec("tar", "-C", dir, "-xvf", archives.rock)
    dir = dir .. "/" .. archives.rock:gsub("^src/", ""):gsub(".tar.gz$", "")
    local cwd = uv.cwd()
    process.env.PATH = target.."/bin:" .. PATH
    uv.chdir(dir)
    print("Configuring luarocks...")
    local extrainclude = ""
    if version:match("luajit") then
      extrainclude = "/" .. version
    end
    exec("./configure",
      "--prefix=" .. target,
      "--with-lua=" .. target,
      "--with-lua-include=" .. target .. "/include" .. extrainclude
    )
    print("Building luarocks...")
    exec("make", "build")
    print("Installing luarocks...")
    exec("make", "install")
    uv.chdir(cwd)

    print("Installing luv...")
    exec(target .. "/bin/luarocks", "install", "luv")
    if not version:match("luajit") then
      print("Installing luacov...")
      exec(target .. "/bin/luarocks", "install", "luacov")
      if not version:match("5.3") then
        print("Installing bit...")
        exec(target .. "/bin/luarocks", "install", "luabitop")
        print("Installing ffi...")
        exec(target .. "/bin/luarocks", "install", "--server=http://luarocks.org/dev", "luaffi")
      end
    end
    local ver = "5.1"
    if target:match("-5.2") then
      ver = "5.2"
    elseif target:match("-5.3") then
      ver = "5.3"
    end

    exec("cp",
      base .. "/lit-loader/lit-loader.lua",
      target .. "/share/lua/" .. ver .. "/")
    exec("cp",
      base .. "/lit-loader/uv.lua",
      target .. "/share/lua/" .. ver .. "/")

    process.env.PATH = PATH
  end
  exec("rm", "-rf", srcdir)
  print("\nDONE!\n")
end)()
