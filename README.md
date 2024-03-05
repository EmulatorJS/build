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

# Adding new cores
To add a new core, add a stanza like the below:
```json
{
    "name": "mame2003-libretro",
    "makeoptions": {
        "buildpath": "./",
        "makescript": "Makefile",
        "arguments": []
    },
    "options": {
        "file": "MAME 2003 (0.78)/MAME 2003 (0.78).opt",
        "settings": {
            "mame2003_skip_disclaimer": "enabled",
            "mame2003_skip_warnings": "enabled"
        }
    },
    "license": "https://github.com/EmulatorJS/mame2003-libretro/blob/master/LICENSE.md",
    "repo": "https://github.com/EmulatorJS/mame2003-libretro"
}
```

| Attribute | Definition |
| --------- | ---------- |
| ``name``      | The name of the core - usually the core project name |
| ``license``   | A link to the projects license file |
| ``repo``      | A link to the project repository |
| ``makeoptions`` | Settings and options for building the core (see makeoptions table below) |
| ``options``   | Options to be set by the emulator (see options table below) |

### makeoptions
| Attribute | Definition |
| --------- | ---------- |
| ``buildpath`` | The path within the repo to the make script |
| ``makescript`` | The name of the make script |
| ``arguments`` | An array of command line options to pass to the make script |

### options
| Attribute | Definition |
| --------- | ---------- |
| ``file``      | The relative path and file name for the core options file |
| ``settings``  | A hash table of attributes and their values to write to the core options file |