#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$( cd "${SCRIPTDIR}/.." && pwd )"

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

for patch in "${ROOTDIR}/patches/$version/png_patches/"*.patch; do
    echo "Applying patch: ${patch}"
    git apply -p1 < "${patch}"
done

# Create new pipenv environment with pip 22.0
pipenv --python 3.12 install pip==22.0
export BUDDY_NO_VIRTUALENV=1
# Source shell into current shell
pipenv run python3.12 utils/build.py --preset $presets --build-type release --final --build-dir "${ROOTDIR}/build" --generate-bbf --bootloader yes

if [ $? -eq 0 ]; then
else
  exit 1
fi
cd "${ROOTDIR}"
