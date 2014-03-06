#!/bin/bash
#require sonar-runner, teamcitify


set -e
set -x
source ~/.profile
DESTINATION="platform=iOS Simulator,name=iPhone Retina (4-inch),OS=latest"
SCHEME="caffeine-ios"
WORKSPACE="caffeine-ios.xcodeproj/project.xcworkspace"
set +e
echo "server install is"
cat CAFFEINE_SERVER
SERVER_HOSTNAME=`cat CAFFEINE_SERVER | grep -oE '^[A-Za-z\.]+'`
SERVER_PORT=`cat CAFFEINE_SERVER | grep -oE '[0-9]+$'`
echo $SERVER_HOSTNAME
echo $SERVER_PORT
nc -z $SERVER_HOSTNAME $SERVER_PORT
if [ $? -ne 0 ]; then
	echo "Server isn't running.  Run it before analysis."
	exit 27
fi
set -e

#this works around an unfiled issue
rm -rf ~/Library/Developer/Xcode/DerivedData

#analyze
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk iphonesimulator clean analyze | teamcitify
#test
ZEROMQ_URL="tcp://"$(cat CAFFEINE_SERVER)
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" GCC_PREPROCESSOR_DEFINITIONS="\$(value) CAFFEINE_OVERRIDE_URL=@\\\"${ZEROMQ_URL}\\\"" test | teamcitify
#sonar-runner
#work around rdar://15489119
rm -rf ~/Library/Developer/Xcode/DerivedData
bash run-sonar.sh -v