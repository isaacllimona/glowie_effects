#!/bin/bash

DIR="$(dirname -- "${BASH_SOURCE[0]}")"
cd $DIR

cd lua-5.5.1
make local

cd ../previewlib
make
