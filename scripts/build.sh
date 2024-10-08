#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$( cd "${SCRIPTDIR}/.." && pwd )"

# Assert that neither are empty
if [ -z "$SCRIPTDIR" ] || [ -z "$ROOTDIR" ]; then
    echo "Could not determine script directory or root directory"
    exit 1
fi

# Clean build directory
rm -rf "${ROOTDIR}/build"

# Go into submodule directory
cd "${ROOTDIR}/Prusa-Firmware-Buddy"

git remote set-url --push origin DISABLED

# Ensure tags are fetched
git fetch --tags

if [ $# -ne 2 ] ; then
    echo "Usage: $0 <version> <presets>"
    echo "Version: v5.0.0"
    echo "Presets: mk4,xl,mini"
    exit 1
fi

version=$1
presets=$2

git reset --hard HEAD
# Checkout the version specified in the args
git checkout tags/$version

# Apply patches from patches/ directory into Prusa-Firmware-Buddy directory
for patch in "${ROOTDIR}/patches/"*.patch; do
    echo "Applying patch: ${patch}"
    git apply -p1 < "${patch}"
done

# Apply version specific patches
for patch in "${ROOTDIR}/patches/$version/"*.patch; do
    echo "Applying patch: ${patch}"
    git apply -p1 < "${patch}"
done


# Create new pipenv environment 
pipenv update

export BUDDY_NO_VIRTUALENV=1 

# Source shell into current shell
pipenv run python utils/build.py --preset $presets --build-type release --final --build-dir "${ROOTDIR}/build" --generate-bbf --bootloader yes

cd "${ROOTDIR}"
