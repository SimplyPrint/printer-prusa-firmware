#!/bin/bash

# Ensure submodules are initialized

#rm -rf Prusa-Firmware-Buddy

#mkdir Prusa-Firmware-Buddy
#git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy


#scripts/build.sh v5.0.0 mk4,xl
#scripts/build.sh v5.1.0-alpha1 mini
#scripts/build.sh v5.1.0-alpha2 xl
#scripts/build.sh v5.0.0 mk4,xl
#scripts/build.sh v5.1.0-alpha1 mini
#scripts/build.sh v6.1.0 mk4
#./make_patches.sh v6.1.4 mk4 && ./local_build.sh v6.1.4 mk4

#./make_patches.sh v6.3.4 && ./local_build.sh v6.3.4 coreone,mk4

# ./local_build.sh v6.2.6 mk4
# ./local_build.sh v6.3.4 coreone

./local_build.sh v6.4.0 mk4,coreone,xl