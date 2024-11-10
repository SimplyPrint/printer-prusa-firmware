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
MODIFIED_FILES=$(git diff --name-only --diff-filter=ACMR)

# Check if there are any modified files
if [ -z "$MODIFIED_FILES" ]; then
    echo "No modified files found."
    exit 0
fi

# Generate a patch for each modified file, including new files
for FILE in $MODIFIED_FILES; do
    # Ensure the patch filename reflects the full path for uniqueness
    PATCH_FILE="$PATCH_DIR/$(echo "$FILE" | sed 's/\//_/g').patch"
    # Create patches that include added files using format-patch
    if [ -f "$FILE" ]; then
        git diff --binary --full-index "$FILE" > "$PATCH_FILE"
    else
        echo "Creating patch for new file: $FILE"
        # Use git format-patch to ensure new files are included correctly
        git format-patch -1 --stdout HEAD -- "$FILE" > "$PATCH_FILE"
    fi
    echo "Patch file created: $PATCH_FILE"
done

PNG_PATCH_DIR="$PATCH_DIR/png_patches"
mkdir -p "$PNG_PATCH_DIR"

# Move all .png.patch files to the png_patches directory
find "$PATCH_DIR" -name "*.png.patch" ! -path "$PNG_PATCH_DIR/*" -exec mv {} "$PNG_PATCH_DIR/" \;

echo "All patches have been generated in the '$PATCH_DIR' directory."
