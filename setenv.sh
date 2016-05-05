SCRIPT_SOURCE="$_"
if [ -n "$BASH_SOURCE" ]; then
  SCRIPT_SOURCE="${BASH_SOURCE[0]}"
fi
export LENV="$(cd "$(dirname "${SCRIPT_SOURCE:-$0}")" > /dev/null && \pwd)"
LUVIT=$LENV/luvit/2.10.1
if [[ "$LUA" == luajit/* ]]; then VER=5.1; fi
if [[ "$LUA" == lua/5.1* ]]; then VER=5.1; fi
if [[ "$LUA" == lua/5.2* ]]; then VER=5.2; fi
if [[ "$LUA" == lua/5.3* ]]; then VER=5.3; fi
LUA=$LENV/$LUA
export PATH=$LUVIT:$LUA/bin:$PATH
export LUA_PATH="./?.lua;$LUA/share/lua/$VER/?.lua;$LUA/share/lua/$VER/?/init.lua;;"
export LUA_CPATH="./?.so;$LUA/lib/lua/$VER/?.so;$LUA/share/lua/$VER/?.so;;"

#echo PATH=$PATH
#echo LUA_PATH=$LUA_PATH
#echo LUA_CPATH=$LUA_CPATH
