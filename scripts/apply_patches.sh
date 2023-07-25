#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$( cd "${SCRIPTDIR}/.." && pwd )"

# Ensure submodules are initialized
git submodule update --init

# Apply patches from patches/ directory into Prusa-Firmware-Buddy directory
for patch in "${ROOTDIR}/patches/"*.patch; do
    echo "Applying patch: ${patch}"
    patch -d "${ROOTDIR}/Prusa-Firmware-Buddy" -p1 < "${patch}"
done