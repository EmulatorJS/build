#!/usr/bin/env sh

initialPath="$PWD"

compileProject() {
    outPath="RetroArch/dist-scripts"
    name=$1
    downloadLink=$2
    makefilePath=$3
    makefileName=$4

    if [ ! -d "$name" ]; then
        git clone "$downloadLink" "$name"
    fi
    cd "$name"
    cd "$makefilePath"
    emmake make -f "$makefileName" platform=emscripten || (echo "If the error is \"unknown argument: -no-undefined\", please go into $makefileName and remove the flag from the make options" && exit 1)
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

compileProject "libretro-fceumm" "https://github.com/libretro/libretro-fceumm.git" "./" "Makefile.libretro"
compileProject "nestopia" "https://github.com/EmulatorJS/nestopia.git" "./libretro" "Makefile"
compileProject "snes9x" "https://github.com/EmulatorJS/snes9x.git" "./libretro" "Makefile"
compileProject "gambatte-libretro" "https://github.com/libretro/gambatte-libretro.git" "./" "Makefile.libretro"
compileProject "mgba" "https://github.com/libretro/mgba.git" "./libretro-build" "Makefile.common"
compileProject "beetle-vb-libretro" "https://github.com/EmulatorJS/beetle-vb-libretro.git" "./" "Makefile"
compileProject "mupen64plus-libretro-nx" "https://github.com/EmulatorJS/mupen64plus-libretro-nx.git" "./" "Makefile"
compileProject "melonDS" "https://github.com/EmulatorJS/melonDS.git" "./" "Makefile"
compileProject "desmume2015" "https://github.com/libretro/desmume2015.git" "./desmume" "Makefile.libretro"
compileProject "a5200" "https://github.com/EmulatorJS/a5200.git" "./" "Makefile"
compileProject "mame2003-libretro" "https://github.com/libretro/mame2003-libretro.git" "./" "Makefile"
compileProject "fbalpha2012_cps1" "https://github.com/libretro/fbalpha2012_cps1.git" "./" "makefile.libretro"
compileProject "fbalpha2012_cps2" "https://github.com/libretro/fbalpha2012_cps2.git" "./" "makefile.libretro"

cd "RetroArch/dist-scripts"

emmake ./dist-cores.sh emscripten

cd "$initialPath"
