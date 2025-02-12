#!/bin/bash

source /venv/bin/activate

./local_build.sh $1

input=$1
stripped=${input:1}

while true; do

    # Get the package details (handling single and array responses)
    # shellcheck disable=SC2154
    PACKAGE_INFO=$(curl --header "PRIVATE-TOKEN: ${package_registry_delete_token}" --silent "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages?package_name=$1&package_version=$stripped")

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

curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" --upload-file "build/mk4_release_boot/firmware.bbf" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/$1/$stripped/mk4_firmware.bbf"
curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" --upload-file "build/coreone_release_boot/firmware.bbf" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/$1/$stripped/coreone_firmware.bbf"

# Wait for all background jobs to complete
echo "Build and upload process completed."
