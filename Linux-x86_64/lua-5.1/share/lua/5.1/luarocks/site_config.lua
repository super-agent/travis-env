local site_config = {}
site_config.LUAROCKS_PREFIX=[[/home/tim/msgpack/.travis/Linux-x86_64/lua-5.1]]
site_config.LUA_INCDIR=[[/home/tim/msgpack/.travis/Linux-x86_64/lua-5.1/include]]
site_config.LUA_LIBDIR=[[/home/tim/msgpack/.travis/Linux-x86_64/lua-5.1/lib]]
site_config.LUA_BINDIR=[[/home/tim/msgpack/.travis/Linux-x86_64/lua-5.1/bin]]
site_config.LUAROCKS_SYSCONFDIR=[[/home/tim/msgpack/.travis/Linux-x86_64/lua-5.1/etc/luarocks]]
site_config.LUAROCKS_ROCKS_TREE=[[/home/tim/msgpack/.travis/Linux-x86_64/lua-5.1]]
site_config.LUAROCKS_ROCKS_SUBDIR=[[/lib/luarocks/rocks]]
site_config.LUA_DIR_SET=true
site_config.LUAROCKS_UNAME_S=[[Linux]]
site_config.LUAROCKS_UNAME_M=[[x86_64]]
site_config.LUAROCKS_DOWNLOADER=[[curl]]
site_config.LUAROCKS_MD5CHECKER=[[md5sum]]
site_config.LUAROCKS_EXTERNAL_DEPS_SUBDIRS={ bin="bin", lib={ "lib", [[lib/x86_64-linux-gnu]] }, include="include" }
site_config.LUAROCKS_RUNTIME_EXTERNAL_DEPS_SUBDIRS={ bin="bin", lib={ "lib", [[lib/x86_64-linux-gnu]] }, include="include" }
return site_config
