#!/bin/bash

set -e
rm -rf Prusa-Firmware-Buddy
scripts/checkout_version.sh v4.7.0
scripts/apply_patches.sh
scripts/build.sh
