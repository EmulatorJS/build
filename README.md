# build
A simple script that will download and build the emulatorjs core files

This script will download and build most of the available retroarch cores.

**Warning**: Some cores do not compile on ARM based systems (such as M series MacBooks and Raspberry Pi). Use only amd64 based systems to compile.

# Set up your build environment

## VSCode and Dev Containers
This repo contains a devcontainer configuration.

Using docker and VSCode, the repo can be started in a container, where all dependencies are installed for you.

## Local
To set up the build environment on an Ubuntu/Debian system, run the enclosed ``build_env.sh`` script to install all required components

# Compiling
Execute the command ``source ./.emsdk/emsdk_env.sh && bash build.sh`` in the repo root to begin compiling.

Compiled assets will be in the ``./compile`` directory.