#!/usr/bin/env sh

initialPath="$PWD"
outPath="RetroArch/dist-scripts"

compileProject() {
    name=$1
    downloadLink=$2
    makefilePath=$3
    makefileName=$4

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
    emmake make -f "$makefileName" platform=emscripten || exit 1
    linkerfilename=( *.bc )
    if [ -f "$initialPath/$outPath/$linkerfilename" ] ; then
        rm "$initialPath/$outPath/$linkerfilename"
    fi
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
rm *.bc
cd "$initialPath"

if [ ! -d "EmulatorJS" ]; then
    git clone "https://github.com/EmulatorJS/EmulatorJS.git" "EmulatorJS"
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

cd "RetroArch/dist-scripts"

emmake ./dist-cores.sh emscripten

cd "$initialPath"
