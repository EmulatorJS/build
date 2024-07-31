#!/bin/bash

initialPath="$PWD"
buildPath="$PWD/compile"
outputPath="$PWD/output"
buildReport="$outputPath/reports"
logPath="$outputPath/logs"
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

# create output path
mkdir -p $outputPath
cp $initialPath/cores.json $outputPath
mkdir -p $buildReport
mkdir -p $logPath

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
    branch=$3
    makefilePath=$4
    makefileName=$5
    makefileArg=$6
    legacy=$7
    thread=$8

    if [ ! -d "$name" ]; then
        git clone "$downloadLink" "$name"
        cd "$name"
        git submodule update --init --recursive
        cd ../
    fi
    cd "$name"
    if [ $branch != 'null' ]; then
        echo "Checking out branch $branch"
        git checkout "$branch"
    fi
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
    git clone "https://github.com/EmulatorJS/EmulatorJS.git" "EmulatorJS" --depth 1 || exit 1
fi
cd EmulatorJS
git pull
cd ../

compileStartPath="$PWD"
for row in $(jq -r '.[] | @base64' ../cores.json); do
    startTime=`date -u -Is`

    cd $compileStartPath

    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    name=`echo $(_jq '.') | jq -r '.name'`
    repo=`echo $(_jq '.') | jq -r '.repo'`
    branch=`echo $(_jq '.') | jq -r '.branch'`
    license=`echo $(_jq '.') | jq -r '.license'`
    buildpath=`echo $(_jq '.') | jq -r '.makeoptions.buildpath'`
    makescript=`echo $(_jq '.') | jq -r '.makeoptions.makescript'`
    arguments=`echo $(_jq '.') | jq -r '.makeoptions.arguments[] | @base64'`

    argumentstring=""
    for rowarg in $(echo "${arguments}"); do
        argumentstring="$argumentstring `echo $rowarg | base64 --decode`"
    done

    echo "Starting compile of core $name"
    echo "Working dir $PWD"

    compileProject "$name" "$repo.git" "$branch" "$buildpath" "$makescript" "$argumentstring" >> "$logPath/$name-compile.log"

    # write JSON stanza for this core to disk
    echo ${row} | base64 --decode > "./core.json"

    if [ ! -z "$license" -a "$license" != " " ]; then
        # license file is provided - copy it
        echo "License file: $name/$license"
        cp $name/$license "./license.txt"
    fi

    echo "Building wasm's for core $name"
    cd "RetroArch"
    cd "dist-scripts"

    mv core-temp/normal/*.bc ./
    emmake ./build-emulatorjs.sh emscripten clean no no >> "$logPath/$name-emake.log"
    rm -f *.bc

    mv core-temp/threads/*.bc ./
    emmake ./build-emulatorjs.sh emscripten clean yes no >> "$logPath/$name-emake.log"
    rm -f *.bc

    mv core-temp/legacy/*.bc ./
    emmake ./build-emulatorjs.sh emscripten clean no yes >> "$logPath/$name-emake.log"
    rm -f *.bc

    mv core-temp/legacyThreads/*.bc ./
    emmake ./build-emulatorjs.sh emscripten clean yes yes >> "$logPath/$name-emake.log"
    rm -f *.bc

    echo "Packing core information for $name"
    cd $compileStartPath
    if [ -f "EmulatorJS/data/cores/$name-wasm.data" ]; then
        7z a -t7z EmulatorJS/data/cores/$name-wasm.data ./core.json ./license.txt ../build.json
        cp EmulatorJS/data/cores/$name-wasm.data $outputPath
    fi

    if [ -f "EmulatorJS/data/cores/$name-thread-wasm.data" ]; then
        7z a -t7z EmulatorJS/data/cores/$name-thread-wasm.data ./core.json ./license.txt ../build.json
        cp EmulatorJS/data/cores/$name-thread-wasm.data $outputPath
    fi

    if [ -f "EmulatorJS/data/cores/$name-legacy-wasm.data" ]; then
        7z a -t7z EmulatorJS/data/cores/$name-legacy-wasm.data ./core.json ./license.txt ../build.json
        cp EmulatorJS/data/cores/$name-legacy-wasm.data $outputPath
    fi

    if [ -f "EmulatorJS/data/cores/$name-thread-legacy-wasm.data" ]; then
        7z a -t7z EmulatorJS/data/cores/$name-thread-legacy-wasm.data ./core.json ./license.txt ../build.json
        cp EmulatorJS/data/cores/$name-thread-legacy-wasm.data $outputPath
    fi

    # clean up to make sure the next build in the json gets the right license and core file
    rm ./license.txt
    rm ./core.json
    
    # write report to report file
    endTime=`date -u -Is`
    reportString="{ \"core\": \"$name\", \"buildStart\": \"$startTime\", \"buildEnd\": \"$endTime\" }"
    buildReportFile="$buildReport/$name.json"
    echo $reportString > $buildReportFile
done

# delete all compile files
if [[ -z "$DEPLOY_ENV" ]]; then
    echo "Not deleting build path"
else
    rm -fR $buildPath
fi

cd "$initialPath"
