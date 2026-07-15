#!/bin/bash

# Ensure submodules are initialized
ready_to_build=true
if ! cd Prusa-Firmware-Buddy; then
    mkdir Prusa-Firmware-Buddy
    git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy
    cd Prusa-Firmware-Buddy
    ready_to_build=false
fi

git stash
cd .. || exit

echo "Version:" $1
echo "Presets:" $2
echo "WebSocket:" $3

# Check if ready to build
if [ "$ready_to_build" == true ]; then
    scripts/build_local.sh $1 $2 $3
else
    scripts/build.sh $1 $2 $3
fi
