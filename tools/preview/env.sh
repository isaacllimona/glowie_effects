PREVIEW_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
PREVIEW_DIR="$( realpath -e -- "$PREVIEW_DIR" )"

LUADIR="$PREVIEW_DIR/lua-5.5.1"
GLWLIBDIR="$PREVIEW_DIR/previewlib"

echo "Building preview tool..."
bash $PREVIEW_DIR/build.sh

export PATH="$LUADIR/install/bin:$PATH"
export LUA_CPATH="$LUA_CPATH;$GLWLIBDIR/build/?.so"

echo "Use \"lua -lpreviewlib\" to launch the lua interpreter with the preview library"
