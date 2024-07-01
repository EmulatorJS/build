#!/bin/sh

cd /workspaces/build
git clone https://github.com/emscripten-core/emsdk.git .emsdk
cd .emsdk
git checkout 3.1.54
./emsdk install 3.1.54
./emsdk activate 3.1.54
source ./emsdk_env.sh
wget https://raw.githubusercontent.com/EmulatorJS/build/main/emscripten.patch
patch -u -p0 -i ../emscripten.patch
cd ../
