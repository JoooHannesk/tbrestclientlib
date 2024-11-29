#
# build, convert and upload documentation to webserver using scp
#
# by Johannes Kinzig | johannes@parallelogon-software.com | https://parallelogon-software.com
#


# check if SCPDESTINATION is set
if [ -z ${SCPDESTINATION+x} ]
then
echo "Warning: Your scp destination is not set. Script will abort! Please set destination to deploy documentation to a webserver. Use the following format: export SCPDESTINATION=scp://user@host:port/path/tp/folder"
exit 1
fi

# build .doccarchive
xcodebuild docbuild -scheme TBRESTClientLib -derivedDataPath ./.doccbuilds/build -destination platform=macOS 

# convert documentation for static hosting
xcrun docc process-archive transform-for-static-hosting ./.doccbuilds/build/Build/Products/Debug/TBRESTClientLib.doccarchive --output-path ./.doccbuilds/publish

# scp to destination
scp -rp ./.doccbuilds/publish/* $SCPDESTINATION

# cleanup local files
rm -r ./.doccbuilds

# refer to published documentation
echo "Documentation now available at:\nhttp://tbrestclientlib.parallelogon-software.com/documentation/tbrestclientlib"
