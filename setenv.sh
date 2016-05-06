SCRIPT_SOURCE="$_"
if [ -n "$BASH_SOURCE" ]; then
  SCRIPT_SOURCE="${BASH_SOURCE[0]}"
fi
export LENV="$(cd "$(dirname "${SCRIPT_SOURCE:-$0}")" > /dev/null && pwd)/$(uname -s)-$(uname -m)"
PREFIX=$LENV/$LUA
export PATH=$PREFIX/bin:$LENV/luvit-2/bin:$PATH
if [[ "$LUA" != luvit-* ]]; then
  if [[ "$LUA" == luajit-* ]]; then VER=5.1; fi
  if [[ "$LUA" == lua-5.1* ]]; then VER=5.1; fi
  if [[ "$LUA" == lua-5.2* ]]; then VER=5.2; fi
  if [[ "$LUA" == lua-5.3* ]]; then VER=5.3; fi
  LUAROOT=$LENV/$LUA
  export LUA_PATH="./?.lua;$LUAROOT/share/lua/$VER/?.lua;$LUAROOT/share/lua/$VER/?/init.lua;"
  export LUA_CPATH="./?.so;$LUAROOT/lib/lua/$VER/?.so;$LUAROOT/share/lua/$VER/?.so;"
fi
