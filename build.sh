#!/bin/bash

initialPath="$PWD"
buildPath="$PWD/compile"
outPath="RetroArch/dist-scripts"
tempPath="RetroArch/dist-scripts/core-temp"

build() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$buildPath/$tempPath/normal/"
}
buildThreads() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten EMULATORJS_THREADS=1 $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$buildPath/$tempPath/threads/"
}
buildLegacy() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten EMULATORJS_LEGACY=1 $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$buildPath/$tempPath/legacy/"
}
buildThreadsLegacy() {
    rm -f *.bc
    emmake make -f "$makefileName" clean
    emmake make -j$(nproc) -f "$makefileName" platform=emscripten EMULATORJS_THREADS=1 EMULATORJS_LEGACY=1 $makefileArg || exit 1
    linkerfilename=( *.bc )
    mv $linkerfilename "$buildPath/$tempPath/legacyThreads/"
}

# create compile directory
mkdir -p $buildPath
cd $buildPath

# start pulling sources and compile
if [ ! -d "RetroArch" ]; then
    git clone "https://github.com/EmulatorJS/RetroArch.git" "RetroArch" || exit 1
fi

cd "$outPath"
rm -f *.bc
cd "$buildPath"

rm -fr $tempPath
mkdir -p $tempPath/
cd $tempPath
mkdir -p normal/
mkdir -p threads/
mkdir -p legacy/
mkdir -p legacyThreads/
cd $buildPath

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

    cd "$buildPath"
}

if [ ! -d "EmulatorJS" ]; then
    git clone "https://github.com/EmulatorJS/EmulatorJS.git" "EmulatorJS" || exit 1
fi
cd EmulatorJS
git pull
cd ../

for row in $(jq -r '.[] | @base64' ../cores.json); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    name=`echo $(_jq '.') | jq -r '.name'`
    repo=`echo $(_jq '.') | jq -r '.repo'`
    buildpath=`echo $(_jq '.') | jq -r '.makeoptions.buildpath'`
    makescript=`echo $(_jq '.') | jq -r '.makeoptions.makescript'`
    arguments=`echo $(_jq '.') | jq -r '.makeoptions.arguments[] | @base64'`

    argumentstring=""
    for rowarg in $(echo "${arguments}"); do
        argumentstring="$argumentstring `echo $rowarg | base64 --decode`"
    done

    echo "Starting compile of core $name"

    compileProject "$name" "$repo.git" "$buildpath" "$makescript" "$argumentstring"
done

cd "RetroArch"
git pull
cd "dist-scripts"

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
