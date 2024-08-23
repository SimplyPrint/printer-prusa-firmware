#!/bin/bash

# Ensure submodules are initialized

rm -rf Prusa-Firmware-Buddy

mkdir Prusa-Firmware-Buddy
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy


#scripts/build.sh v5.0.0 mk4,xl
#scripts/build.sh v5.1.0-alpha1 mini
#scripts/build.sh v5.1.0-alpha2 xl
#scripts/build.sh v5.0.0 mk4,xl
#scripts/build.sh v5.1.0-alpha1 mini
scripts/build.sh v6.1.0 mk4
