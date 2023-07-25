#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$( cd "${SCRIPTDIR}/.." && pwd )"

# Ensure submodules are initialized
git submodule update --init --recursive

# Go into submodule directory
cd "${ROOTDIR}/Prusa-Firmware-Buddy"

# Ensure tags are fetched
git fetch --tags

# Checkout the version specified in the args
if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Format (SemVer): v<major>.<minor>.<patch>"
    exit 1
fi

# Checkout the version specified in the args
git checkout tags/$1