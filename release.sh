#!/bin/bash

# Ensure submodules are initialized
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git

scripts/build.sh v5.0.0 mk4 xl
scripts/build.sh v5.1.0-alpha1 mini
