#!/bin/bash
apk add python3 py3-pip
python3 -m venv venv
source venv/bin/activate
pip3 install pipenv

rm -rf Prusa-Firmware-Buddy

mkdir Prusa-Firmware-Buddy
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy

scripts/build.sh $1 mk4
# Upload the built file in the background
curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" --upload-file "build/mk4_release_boot/firmware.bbf" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/$1/mk4_firmware.bbf"

# Wait for all background jobs to complete
echo "Build and upload process completed."
