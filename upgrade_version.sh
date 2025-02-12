#!/bin/bash

set -e  # Exit on error

# Usage check
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <target_version> <patch_version>"
    exit 1
fi

TARGET_VERSION=$1
PATCH_VERSION=$2
REPO_PATH="Prusa-Firmware-Buddy-DEV"
PATCH_DIR="patches/$PATCH_VERSION"
FAILED_PATCHES=()
CONFLICT_FILES=()

# Navigate to repo
cd "$REPO_PATH" || { echo "Error: Repository '$REPO_PATH' not found"; exit 1; }

# Ensure it's a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not a Git repository"
    exit 1
fi

# Fetch and checkout target version
git fetch --tags
git checkout "$TARGET_VERSION" || { echo "Error: Failed to checkout $TARGET_VERSION"; exit 1; }

# Ensure patches exist
if [ ! -d "../$PATCH_DIR" ]; then
    echo "Error: No patches found in '../$PATCH_DIR/'"
    exit 1
fi

# Find all patches recursively and sort them
PATCH_FILES=($(find "../$PATCH_DIR" -type f -name "*.patch" | sort))

if [ ${#PATCH_FILES[@]} -eq 0 ]; then
    echo "Error: No patches found in '$PATCH_DIR' or its subdirectories."
    exit 1
fi

# Apply patches
echo "Applying patches from '../$PATCH_DIR/'..."
for patch in "${PATCH_FILES[@]}"; do
    if git am --3way "$patch"; then
        echo "✅ Applied: $(basename "$patch")"
    else
        echo "❌ Failed: $(basename "$patch")"
        FAILED_PATCHES+=("$patch")

        # Check if `git am` is in progress before aborting
        if git am --show-current-patch >/dev/null 2>&1; then
            git am --abort
        fi

        # Try applying with conflicts
        if git apply --reject "$patch"; then
            echo "⚠️  Applied with conflicts: $(basename "$patch")"
            # Collect files with conflicts
            CONFLICT_FILES+=($(git status --short | grep '^UU' | awk '{print $2}'))
        else
            echo "❌ Could not apply patch even with conflicts: $(basename "$patch")"
        fi
    fi
done

# Report failed patches
if [ ${#FAILED_PATCHES[@]} -gt 0 ]; then
    echo -e "\n⚠️  Some patches failed to apply:"
    for patch in "${FAILED_PATCHES[@]}"; do
        echo " - $(basename "$patch")"
    done
fi

# Report conflicted files
if [ ${#CONFLICT_FILES[@]} -gt 0 ]; then
    echo -e "\n⚠️  Files with conflicts:"
    for file in "${CONFLICT_FILES[@]}"; do
        echo " - $file"
    done
    echo "Resolve conflicts manually and continue."
fi

echo "✅ Patch application process completed."
