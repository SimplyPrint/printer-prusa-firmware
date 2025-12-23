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
git clean -fd
# Checkout the version specified in the args
git checkout tags/$version

# Apply patches from patches/ directory into Prusa-Firmware-Buddy directory
for patch in "${ROOTDIR}/patches/"*.patch; do
    echo "Applying patch: ${patch}"
    git apply -p1 < "${patch}"
done

# Apply version-specific patches
for patch in "${ROOTDIR}/patches/$version/"*.patch; do
    echo "Applying patch: ${patch}"
    git apply -p1 < "${patch}"
done

for patch in "${ROOTDIR}/patches/$version/png_patches/"*.patch; do
    echo "Applying patch: ${patch}"
    git apply -p1 < "${patch}"
done

pipenv --python 3.12 install requests

# Use the existing Pipenv environment
export BUDDY_NO_VIRTUALENV=1
pipenv run python utils/build.py --preset $presets --build-type release --signing-key "${ROOTDIR}/firmware_signing_key.pem" --final --build-dir "${ROOTDIR}/build" --bootloader yes -D WEBSOCKET:BOOL=OFF

if [ $? -eq 0 ]; then
  cd "${ROOTDIR}"
  exit 0
else
  exit 1
fi
