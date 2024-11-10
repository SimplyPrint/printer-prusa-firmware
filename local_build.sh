#!/bin/bash

# Ensure submodules are initialized
ready_to_build=true
cd Prusa-Firmware-Buddy || (mkdir Prusa-Firmware-Buddy && git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy && cd Prusa-Firmware-Buddy && ready_to_build=false)

git stash
cd .. || exit

# Check if ready to build
if [ "$ready_to_build" == true ]; then
    scripts/build_local.sh v6.1.4 mk4
else
    scripts/build.sh v6.1.4 mk4
fi
