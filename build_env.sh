#!/bin/sh

cd /workspaces/build
rm -fR emsdk
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install 3.1.74
./emsdk activate 3.1.74
source ./emsdk_env.sh
cd ..
