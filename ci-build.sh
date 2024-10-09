#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update && apt install -y python3 python3-pip python3-venv git curl wget software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt update
apt install -y python3.12 python3.12-distutils

python3.12 -m venv venv

pip3 install pipenv

rm -rf Prusa-Firmware-Buddy

mkdir Prusa-Firmware-Buddy
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy

scripts/build.sh $1 mk4
# Upload the built file in the background
curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" --upload-file "build/mk4_release_boot/firmware.bbf" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/$1/mk4_firmware.bbf"

# Wait for all background jobs to complete
echo "Build and upload process completed."
