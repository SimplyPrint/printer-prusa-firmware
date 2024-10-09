#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update && apt install -y git curl wget software-properties-common jq
apt install -y libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7 libtiff5 libwebp-dev tcl-dev tk-dev

add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y python3.12 python3.12-distutils python3.12-venv python3.12-dev

python3.12 -m venv venv
source venv/bin/activate

pip3 install pipenv setuptools wheel

rm -rf Prusa-Firmware-Buddy

mkdir Prusa-Firmware-Buddy
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git Prusa-Firmware-Buddy
scripts/build.sh $1 mk4

  if [ $? -eq 0 ]; then
    echo "Built successfully"
  else
    echo "Build failed"
    exit 1
  fi

PACKAGE_URL="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${output_name}/$1"
while true; do
    # Get the package details (handling single and array responses)
    # shellcheck disable=SC2154
    PACKAGE_INFO=$(curl --header "PRIVATE-TOKEN: ${package_registry_delete_token}" --silent "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages?package_name=${output_name}&package_version=$1")

    # Check if the package exists (handling object vs array response)
    PACKAGE_ID=$(echo "$PACKAGE_INFO" | jq -r 'if type=="array" and length > 0 then .[0].id else null end')

    if [ -n "$PACKAGE_ID" ] && [ "$PACKAGE_ID" != "null" ]; then
      echo "Deleting existing package version: ${VERSION} (Package ID: ${PACKAGE_ID})"
      # Attempt to delete the package
      curl --request DELETE --header "PRIVATE-TOKEN: $package_registry_delete_token" --silent "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/${PACKAGE_ID}"

      # Sleep for a short time to avoid overloading the server
      sleep 2
    else
      # Exit the loop if no package exists
      echo "Package version ${VERSION} has been successfully deleted or does not exist."
      break
    fi
  done


# Upload the built file in the background
input=$1
stripped=${input:1}
curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" --upload-file "build/mk4_release_boot/firmware.bbf" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/$1/$stripped/mk4_firmware.bbf"

# Wait for all background jobs to complete
echo "Build and upload process completed."
