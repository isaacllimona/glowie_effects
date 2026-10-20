# get the parent directory of this script
GLW_EFFECTS_ROOT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
GLW_EFFECTS_ROOT_DIR="$( realpath -e -- "$GLW_EFFECTS_ROOT_DIR" )"

# set up preview library
source "$GLW_EFFECTS_ROOT_DIR/tools/preview/env.sh" > /dev/null

# add the effects lua library to the lua path
EFFECT_LIB_PATH="$GLW_EFFECTS_ROOT_DIR/scripts/lib/?.lua"
export LUA_PATH="$LUA_PATH;$EFFECT_LIB_PATH"

# create alias to launch lua interpreter with the preview and the effect library
alias glwlua="lua -lpreviewlib -leffect_engine"

echo "Use \"glwlua path/to/script.lua\" to preview a script"
echo "Use \"glwlua\" to enter an interactive session"
echo ""

# create alias for the loader tool
alias glwload="bash $GLW_EFFECTS_ROOT_DIR/tools/loader/run.sh"

echo "Use \"glwload path/to/script.lua\" to load a script to a device"
