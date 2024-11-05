#!/usr/bin/bash

if [ $# -ne 1 ] ; then
    echo "Usage: $0 <version>"
    echo "Version: v6.1.3"
    exit 1
fi
rm -rf Prusa-Firmware-Buddy-DEV

mkdir Prusa-Firmware-Buddy-DEV
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy-DEV

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$( cd "${SCRIPTDIR}" && pwd )"

# Go into submodule directory
cd "${ROOTDIR}/Prusa-Firmware-Buddy-DEV" || exit

git remote set-url --push origin DISABLED

# Ensure tags are fetched
git fetch --tags

version=$1

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