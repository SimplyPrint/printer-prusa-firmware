#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$( cd "${SCRIPTDIR}/.." && pwd )"

# Ensure submodules are initialized
git submodule update --init --recursive

# Go into submodule directory
cd "${ROOTDIR}/Prusa-Firmware-Buddy"

# Create new pipenv environment with pip 22.0
pipenv --python 3.11 install pip==22.0
# Source shell into current shell
pipenv run python3.11 utils/build.py --preset mk4,xl,mini --build-type release --final --build-dir "${ROOTDIR}/build" --generate-bbf

# Cleanup
pipenv --rm