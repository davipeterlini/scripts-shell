#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null
then
    echo "gsutil could not be found. Please install the Google Cloud SDK."
    exit 1
fi

# Check if the force update argument is provided
FORCE_UPDATE=false
UPDATE_VERSION_FILE=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --force-update) FORCE_UPDATE=true ;;
        --update-version-file) UPDATE_VERSION_FILE=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Ensure the script is running on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "You are not on the main branch. Please switch to the main branch to release."
    exit 1
fi

# Ensure the script is running on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "You are not on the main branch. Please switch to the main branch to release."
    exit 1
fi

# Ensure the script is running on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "You are not on the main branch. Please switch to the main branch to release."
    exit 1
fi

BUCKET_NAME="gs://flow-coder"
HTTP_BASE_URL="https://storage.googleapis.com/flow-coder"
DIST_DIR="dist"
BUILD_DIR="build"
VERSION_FILE="$BUILD_DIR/update_info.json"

# Get the current version from setup.cfg
CURRENT_VERSION=$(sed -n 's/^version = //p' setup.cfg)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Could not find the current version in setup.cfg."
    exit 1
fi

# Find the wheel file in the dist directory
WHEEL_FILE=$(find $DIST_DIR -name "*.whl" | head -n 1)

if [ -z "$WHEEL_FILE" ]; then
    echo "Could not find the wheel file in the dist directory."
    exit 1
fi

# Upload the current version to the bucket
gsutil cp $WHEEL_FILE $BUCKET_NAME/

if [ "$UPDATE_VERSION_FILE" = true ]; then
    # Create the JSON version control file
    mkdir -p $BUILD_DIR
    cat <<EOF > $VERSION_FILE
{
  "version": "$CURRENT_VERSION",
  "force_update": $FORCE_UPDATE,
  "url": "$HTTP_BASE_URL/$(basename $WHEEL_FILE)"
}
EOF

    # Upload the JSON version control file to the bucket
    gsutil cp $VERSION_FILE $BUCKET_NAME

    # Print the permalink for the version control file
    echo "Version control file: $HTTP_BASE_URL/$(basename $VERSION_FILE)"
fi

# Print the permalink for the wheel file
echo "Wheel file: $HTTP_BASE_URL/$(basename $WHEEL_FILE)"