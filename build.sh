#!/bin/bash

initialPath="$PWD"
outPath="RetroArch/dist-scripts"
tempPath="RetroArch/dist-scripts/core-temp"

build() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$initialPath/$tempPath/normal/"
}
buildThreads() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten EMULATORJS_THREADS=1 $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$initialPath/$tempPath/threads/"
}
buildLegacy() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten EMULATORJS_LEGACY=1 $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$initialPath/$tempPath/legacy/"
}
buildThreadsLegacy() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten EMULATORJS_THREADS=1 EMULATORJS_LEGACY=1 $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$initialPath/$tempPath/legacyThreads/"
}

if [ ! -d "RetroArch" ]; then
    git clone "https://github.com/EmulatorJS/RetroArch.git" "RetroArch" || exit 1
fi
cd RetroArch
git pull
cd ../

cd "$outPath"
rm -f *.bc
cd "$initialPath"

rm -fr $tempPath
mkdir -p $tempPath/
cd $tempPath
mkdir -p normal/
mkdir -p threads/
mkdir -p legacy/
mkdir -p legacyThreads/
cd $initialPath

compileProject() {
    name=$1
    downloadLink=$2
    makefilePath=$3
    makefileName=$4
    makefileArg=$5
    legacy=$6
    thread=$7

    if [ ! -d "$name" ]; then
        git clone "$downloadLink" "$name"
        cd "$name"
        git submodule update --init --recursive
        cd ../
    fi
    cd "$name"
    git pull
    git submodule update --recursive
    cd "$makefilePath"

    build
    if [ "$thread" != "no" ]; then
        buildThreads
    fi
    if [ "$legacy" != "no" ]; then
        buildLegacy
        if [ "$thread" != "no" ]; then
             buildThreadsLegacy
        fi
    fi

    cd "$initialPath"
}

if [ ! -d "EmulatorJS" ]; then
    git clone "https://github.com/EmulatorJS/EmulatorJS.git" "EmulatorJS" || exit 1
fi
cd EmulatorJS
git pull
cd ../

compileProject "libretro-fceumm" "https://github.com/EmulatorJS/libretro-fceumm.git" "./" "Makefile.libretro"
compileProject "nestopia" "https://github.com/EmulatorJS/nestopia.git" "./libretro" "Makefile"
compileProject "snes9x" "https://github.com/EmulatorJS/snes9x.git" "./libretro" "Makefile"
compileProject "gambatte-libretro" "https://github.com/EmulatorJS/gambatte-libretro.git" "./" "Makefile.libretro"
compileProject "mgba" "https://github.com/EmulatorJS/mgba.git" "./" "Makefile.libretro"
compileProject "beetle-vb-libretro" "https://github.com/EmulatorJS/beetle-vb-libretro.git" "./" "Makefile"
compileProject "mupen64plus-libretro-nx" "https://github.com/EmulatorJS/mupen64plus-libretro-nx.git" "./" "Makefile"
compileProject "melonDS" "https://github.com/EmulatorJS/melonDS.git" "./" "Makefile"
compileProject "desmume2015" "https://github.com/EmulatorJS/desmume2015.git" "./desmume" "Makefile.libretro"
compileProject "desmume" "https://github.com/EmulatorJS/desmume.git" "./desmume/src/frontend/libretro" "Makefile.libretro"
compileProject "a5200" "https://github.com/EmulatorJS/a5200.git" "./" "Makefile"
compileProject "mame2003-libretro" "https://github.com/EmulatorJS/mame2003-libretro.git" "./" "Makefile"
compileProject "fbalpha2012_cps1" "https://github.com/EmulatorJS/fbalpha2012_cps1.git" "./" "makefile.libretro"
compileProject "fbalpha2012_cps2" "https://github.com/EmulatorJS/fbalpha2012_cps2.git" "./" "makefile.libretro"
compileProject "prosystem" "https://github.com/EmulatorJS/prosystem-libretro.git" "./" "Makefile"
compileProject "stella2014" "https://github.com/EmulatorJS/stella2014-libretro.git" "./" "Makefile"
compileProject "opera" "https://github.com/EmulatorJS/opera-libretro.git" "./" "Makefile"
compileProject "genesis-plus-GX" "https://github.com/EmulatorJS/Genesis-Plus-GX.git" "./" "Makefile.libretro"
compileProject "yabause" "https://github.com/EmulatorJS/yabause.git" "./yabause/src/libretro" "Makefile"
compileProject "handy" "https://github.com/EmulatorJS/libretro-handy.git" "./" "Makefile"
compileProject "virtualjaguar" "https://github.com/EmulatorJS/virtualjaguar-libretro.git" "./" "Makefile"
compileProject "pcsx_rearmed" "https://github.com/EmulatorJS/pcsx_rearmed.git" "./" "Makefile.libretro"
compileProject "picodrive" "https://github.com/EmulatorJS/picodrive.git" "./" "Makefile.libretro"
compileProject "fbneo" "https://github.com/EmulatorJS/FBNeo.git" "./src/burner/libretro" "Makefile"
compileProject "beetle-psx" "https://github.com/EmulatorJS/beetle-psx-libretro.git" "./" "Makefile"
compileProject "beetle-pce" "https://github.com/EmulatorJS/beetle-pce-libretro.git" "./" "Makefile"
compileProject "beetle-pcfx" "https://github.com/EmulatorJS/beetle-pcfx-libretro.git" "./" "Makefile"
compileProject "beetle-ngp" "https://github.com/EmulatorJS/beetle-ngp-libretro.git" "./" "Makefile"
compileProject "beetle-wswan" "https://github.com/EmulatorJS/beetle-wswan-libretro.git" "./" "Makefile"
compileProject "gearcoleco" "https://github.com/EmulatorJS/Gearcoleco.git" "./platforms/libretro/" "Makefile"
compileProject "parallel-n64" "https://github.com/EmulatorJS/parallel-n64.git" "./" "Makefile"
compileProject "mame2003-plus" "https://github.com/EmulatorJS/mame2003-plus-libretro.git" "./" "Makefile"
compileProject "puae" "https://github.com/EmulatorJS/libretro-uae.git" "./" "Makefile"
compileProject "vice_x64" "https://github.com/EmulatorJS/vice-libretro.git" "./" "Makefile" "EMUTYPE=x64"
compileProject "vice_x64sc" "https://github.com/EmulatorJS/vice-libretro.git" "./" "Makefile" "EMUTYPE=x64sc"
compileProject "vice_x128" "https://github.com/EmulatorJS/vice-libretro.git" "./" "Makefile" "EMUTYPE=x128"
compileProject "vice_xpet" "https://github.com/EmulatorJS/vice-libretro.git" "./" "Makefile" "EMUTYPE=xpet"
compileProject "vice_xplus4" "https://github.com/EmulatorJS/vice-libretro.git" "./" "Makefile" "EMUTYPE=xplus4"
compileProject "vice_xvic" "https://github.com/EmulatorJS/vice-libretro.git" "./" "Makefile" "EMUTYPE=xvic"

cd "RetroArch/dist-scripts"

mv core-temp/normal/*.bc ./
emmake ./dist-cores.sh emscripten clean no no
rm -f *.bc

mv core-temp/threads/*.bc ./
emmake ./dist-cores.sh emscripten clean yes no
rm -f *.bc

mv core-temp/legacy/*.bc ./
emmake ./dist-cores.sh emscripten clean no yes
rm -f *.bc

mv core-temp/legacyThreads/*.bc ./
emmake ./dist-cores.sh emscripten clean yes yes
rm -f *.bc

cd "$initialPath"
