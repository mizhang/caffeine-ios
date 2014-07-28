#!/bin/bash
#require teamcitify

set -e
set -x
DESTINATION="platform=iOS Simulator,name=iPhone Retina (4-inch),OS=latest"
SCHEME="caffeine-ios-unit"
WORKSPACE="caffeine-ios.xcodeproj/project.xcworkspace"

#analyze
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk iphonesimulator clean analyze | teamcitify
#test
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" test | teamcitify
#production 
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "generic/platform=iOS" -derivedDataPath "built" build | teamcitify
echo "##teamcity[publishArtifacts 'built/Build/Products/Release-iphoneos']" #configure products