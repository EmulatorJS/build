#!/bin/sh

initialPath="$PWD"
outPath="RetroArch/dist-scripts"

compileProject() {
    name=$1
    downloadLink=$2
    makefilePath=$3
    makefileName=$4
    threads=$5

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
    emmake make clean
    if [ "$threads" = "yes" ] ; then
        emmake make -f "$makefileName" platform=emscripten EMULATORJS_THREADS=1 || exit 1
    else
        emmake make -f "$makefileName" platform=emscripten || exit 1
    fi
    linkerfilename=( *.bc )
    rm -f "$initialPath/$outPath/$linkerfilename"
    mv $linkerfilename "$initialPath/$outPath/$linkerfilename"

    cd "$initialPath"
}

if [ ! -d "RetroArch" ]; then
    git clone "https://github.com/EmulatorJS/RetroArch.git" "RetroArch"
fi
cd RetroArch
git pull
cd ../

echo $initialPath

cd "$outPath"
rm -f *.bc
cd "$initialPath"

if [ ! -d "EmulatorJS" ]; then
    git clone "https://github.com/EmulatorJS/EmulatorJS.git" "EmulatorJS"
fi
cd EmulatorJS
git pull
cd ../

compileProject "libretro-fceumm" "https://github.com/EmulatorJS/libretro-fceumm.git" "./" "Makefile.libretro" "no"
compileProject "nestopia" "https://github.com/EmulatorJS/nestopia.git" "./libretro" "Makefile" "no"
compileProject "snes9x" "https://github.com/EmulatorJS/snes9x.git" "./libretro" "Makefile" "no"
compileProject "gambatte-libretro" "https://github.com/EmulatorJS/gambatte-libretro.git" "./" "Makefile.libretro" "no"
compileProject "mgba" "https://github.com/EmulatorJS/mgba.git" "./" "Makefile.libretro" "no"
compileProject "beetle-vb-libretro" "https://github.com/EmulatorJS/beetle-vb-libretro.git" "./" "Makefile" "no"
compileProject "mupen64plus-libretro-nx" "https://github.com/EmulatorJS/mupen64plus-libretro-nx.git" "./" "Makefile" "no"
compileProject "melonDS" "https://github.com/EmulatorJS/melonDS.git" "./" "Makefile" "no"
compileProject "desmume2015" "https://github.com/EmulatorJS/desmume2015.git" "./desmume" "Makefile.libretro" "no"
compileProject "a5200" "https://github.com/EmulatorJS/a5200.git" "./" "Makefile" "no"
compileProject "mame2003-libretro" "https://github.com/EmulatorJS/mame2003-libretro.git" "./" "Makefile" "no"
compileProject "fbalpha2012_cps1" "https://github.com/EmulatorJS/fbalpha2012_cps1.git" "./" "makefile.libretro" "no"
compileProject "fbalpha2012_cps2" "https://github.com/EmulatorJS/fbalpha2012_cps2.git" "./" "makefile.libretro" "no"
compileProject "prosystem" "https://github.com/EmulatorJS/prosystem-libretro.git" "./" "Makefile" "no"
compileProject "stella2014" "https://github.com/EmulatorJS/stella2014-libretro.git" "./" "Makefile" "no"
compileProject "opera" "https://github.com/EmulatorJS/opera-libretro.git" "./" "Makefile" "no"
compileProject "genesis-plus-GX" "https://github.com/EmulatorJS/Genesis-Plus-GX.git" "./" "Makefile.libretro" "no"
compileProject "yabause" "https://github.com/EmulatorJS/yabause.git" "./yabause/src/libretro" "Makefile" "no"
compileProject "handy" "https://github.com/EmulatorJS/libretro-handy.git" "./" "Makefile" "no"
compileProject "virtualjaguar" "https://github.com/EmulatorJS/virtualjaguar-libretro.git" "./" "Makefile" "no"
compileProject "pcsx_rearmed" "https://github.com/EmulatorJS/pcsx_rearmed.git" "./" "Makefile.libretro" "no"
compileProject "picodrive" "https://github.com/EmulatorJS/picodrive.git" "./" "Makefile.libretro" "no"
compileProject "fbneo" "https://github.com/EmulatorJS/FBNeo.git" "./src/burner/libretro" "Makefile" "no"
compileProject "beetle-psx" "https://github.com/EmulatorJS/beetle-psx-libretro.git" "./" "Makefile" "no"
compileProject "parallel-n64" "https://github.com/EmulatorJS/parallel-n64.git" "./" "Makefile" "no"

cd "RetroArch/dist-scripts"

emmake ./dist-cores.sh emscripten clean no

rm -f *.bc
cd "$initialPath"

#now we can build the threaded cores

compileProject "pcsx_rearmed" "https://github.com/EmulatorJS/pcsx_rearmed.git" "./" "Makefile.libretro" "yes"
compileProject "mgba" "https://github.com/EmulatorJS/mgba.git" "./" "Makefile.libretro" "yes"
compileProject "mupen64plus-libretro-nx" "https://github.com/EmulatorJS/mupen64plus-libretro-nx.git" "./" "Makefile" "yes"
compileProject "melonDS" "https://github.com/EmulatorJS/melonDS.git" "./" "Makefile" "yes"
compileProject "opera" "https://github.com/EmulatorJS/opera-libretro.git" "./" "Makefile" "yes"
compileProject "yabause" "https://github.com/EmulatorJS/yabause.git" "./yabause/src/libretro" "Makefile" "yes"
compileProject "beetle-psx" "https://github.com/EmulatorJS/beetle-psx-libretro.git" "./" "Makefile" "yes"
compileProject "parallel-n64" "https://github.com/EmulatorJS/parallel-n64.git" "./" "Makefile" "yes"

cd "RetroArch/dist-scripts"

emmake ./dist-cores.sh emscripten clean yes

cd "$initialPath"
