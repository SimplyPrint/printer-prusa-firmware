#!/bin/bash

if [ -z "$repo_path" ]; then

  echo "Enter the path of the repo where there are changes"
  read repo_path

fi

cd "$repo_path" || exit

# Ensure the script is run from within a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This script must be run from within a Git repository."
    exit 1
fi

# Create a directory to store the patch files
PATCH_DIR="../new_patches"

rm -rf "$PATCH_DIR"
mkdir -p "$PATCH_DIR"

# Get the list of modified files
MODIFIED_FILES=$(git diff --name-only)

# Check if there are any modified files
if [ -z "$MODIFIED_FILES" ]; then
    echo "No modified files found."
    exit 0
fi

# Generate a patch for each modified file
for FILE in $MODIFIED_FILES; do
    PATCH_FILE="$PATCH_DIR/$(basename "$FILE").patch"
    git diff --binary "$FILE" > "$PATCH_FILE"
    echo "Patch file created: $PATCH_FILE"
done

PNG_PATCH_DIR="$PATCH_DIR/png_patches"
mkdir -p "$PNG_PATCH_DIR"

# Move all .png.patch files to the png_patches directory
find "$PATCH_DIR" -name "*.png.patch" ! -path "$PNG_PATCH_DIR/*" -exec mv {} "$PNG_PATCH_DIR/" \;

echo "All patches have been generated in the '$PATCH_DIR' directory."
