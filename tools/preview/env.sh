PREVIEW_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
PREVIEW_DIR="$( realpath -e -- "$PREVIEW_DIR" )"

LUA_BINDIR="$PREVIEW_DIR/lua-5.5.1/install/bin"
PREVIEWLIB_BINDIR="$PREVIEW_DIR/build"

echo "Building preview tool..."
make -C "$PREVIEW_DIR" all

export PATH="$LUADIR:$PATH"
export LUA_CPATH="$LUA_CPATH;$PREVIEWLIB_BINDIR/?.so"

echo "Use \"lua -lpreviewlib\" to launch the lua interpreter with the preview library"
