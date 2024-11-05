#!/bin/bash


if [ $# -ne 1 ] ; then
    echo "Usage: $0 <version>"
    echo "Version: v6.1.3"
    exit 1
fi
version=$1
repo_path=Prusa-Firmware-Buddy-DEV ./generate_patches.sh


# Check if smartcopy exists
if ! command -v smartcopy &> /dev/null
then
    echo "smartcopy not found, running the download script."
    curl -L --silent -o update_smartcopy.sh "https://gitlab.rylanswebsite.com/rylan-meilutis/smartcopy/-/raw/master/update_smartcopy.sh?ref_type=heads" && chmod +x update_smartcopy.sh && ./update_smartcopy.sh && rm update_smartcopy.sh

else
    echo "smartcopy found."
fi

smartcopy -o ./new_patches/* ./patches/$version