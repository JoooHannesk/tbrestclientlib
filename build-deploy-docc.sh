#!/bin/zsh
#
# Build, convert and deploy your DocC documentation to a webserver using SCP
# Suitable for local use or CI/CD pipelines
#
# Script by Johannes Kinzig | mail@johanneskinzig.com | https://johanneskinzig.com
#
# Usage:
#   ./build-deploy-docc.sh
#
# Requires: xcodebuild, xcrun (DocC), scp

# --- Config ---
BUILD_SCHEME_NAME=TBRESTClientLib
SCP_DESTINATION_URL=scp://$SCPUSER@kinzigdoccserver:22/kinzig-developer-docs_com/tbrestclientlib/
WWW_URL=https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib

# --- Check prerequisites ---
if [ -z ${SCPUSER+x} ]; then
  echo "Error: SCPUSER is not set. Please run:"
  echo "  export SCPUSER=YourScpUsername"
  exit 1
fi

# --- Safety settings ---
set -euo pipefail

command -v xcodebuild >/dev/null 2>&1 || { echo "Error: xcodebuild not found."; exit 1; }
command -v xcrun >/dev/null 2>&1 || { echo "Error: xcrun not found."; exit 1; }
command -v scp >/dev/null 2>&1 || { echo "Error: scp not found."; exit 1; }

# --- Build paths ---
BUILD_DIR="./.doccbuilds"
ARCHIVE_DIR=$BUILD_DIR/build/Build/Products/Debug/$BUILD_SCHEME_NAME.doccarchive
PUBLISH_DIR=$BUILD_DIR/publish

# --- Functions ---
function cleanup {
  echo "Cleaning up..."
  rm -rf -- $BUILD_DIR
}
trap cleanup EXIT

# --- Build documentation archive ---
echo "🔨 Building DocC archive for scheme: $BUILD_SCHEME_NAME"
xcodebuild docbuild -scheme $BUILD_SCHEME_NAME -derivedDataPath $BUILD_DIR/build -destination platform=macOS

# --- Convert for static hosting ---
echo "📦 Transforming archive for static hosting..."
xcrun docc process-archive transform-for-static-hosting $ARCHIVE_DIR --output-path $PUBLISH_DIR

# --- Deploy via SCP ---
echo "🚀 Uploading to $SCP_DESTINATION_URL ..."
scp -rp $PUBLISH_DIR/* $SCP_DESTINATION_URL

# --- Done ---
echo "✅ Documentation now available at: $WWW_URL"
echo "(CMD+double-click on URL to open in your default browser)"