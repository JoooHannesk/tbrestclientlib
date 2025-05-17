#!/bin/zsh
#
# Build, convert and deploy your DocC-Documentation to webserver using SCP
# Build for static hosting
#
# Script by Johannes Kinzig | mail@johanneskinzig.com | https://johanneskinzig.com
#
# Use 'export SCPUSER=YourScpUsername' in your shell to set your SCP username for deployment

# Define Script variables
BUILD_SCHEME_NAME=TBRESTClientLib
SCP_DESTINATION_URL=scp://$SCPUSER@kinzigdoccserver:22/kinzig-developer-docs_com/tbrestclientlib/
WWW_URL=https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib

# check if SCPUSER is set
if [ -z ${SCPUSER+x} ]
then
echo "Warning: Your scp login is not set. Script will abort! Please set login to deploy documentation to the webserver. Use the following format: export SCPUSER=YourScpUsername"
exit 1
fi

# build .doccarchive
xcodebuild docbuild -scheme $BUILD_SCHEME_NAME -derivedDataPath ./.doccbuilds/build -destination platform=macOS 

# convert documentation for static hosting
xcrun docc process-archive transform-for-static-hosting ./.doccbuilds/build/Build/Products/Debug/$BUILD_SCHEME_NAME.doccarchive --output-path ./.doccbuilds/publish

# scp to destination
scp -rp ./.doccbuilds/publish/* $SCP_DESTINATION_URL
# cleanup local files
rm -r ./.doccbuilds

# refer to published documentation
echo "Documentation now available at:\n$WWW_URL"
echo "(CMD+2*click on URL to open in your default browser)"
