#!/usr/bin/bash

LOADER_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
LOADER_DIR="$( realpath -e -- "$LOADER_DIR" )"

if [ -d $LOADER_DIR/.venv ]
then
    source $LOADER_DIR/.venv/bin/activate
else
    python3 -m venv $LOADER_DIR/.venv
    source $LOADER_DIR/.venv/bin/activate
    python3 -m pip install -r $LOADER_DIR/requirements.txt
fi

python3 $LOADER_DIR/load_script.py "$@"
