#!/bin/bash
#require teamcitify
set -e
set -x
env
echo ${dep.caffeine_Selftest.system.build.number}

exit 1
source ~/.bash_profile #get python binaries in path
DESTINATION="platform=iOS Simulator,name=iPhone Retina (4-inch),OS=latest"
SCHEME="caffeine-ios-integration"
WORKSPACE="caffeine-ios.xcodeproj/project.xcworkspace"
SERVER_DOCKER_IMAGE="glados/caffeine-dev:12" #todo

#make docker magically work
boot2docker up
DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375 #witchcraft!
docker pull "${SERVER_DOCKER_IMAGE}" #todo
docker stop $(docker ps -a -q) #stop all containers
docker run -p 55555:55555 -t --rm=true "${SERVER_DOCKER_IMAGE}" &
sleep 2
#figure out if job is still up
ps -p $! #raises nonzero exit code if and only if docker has died

NANOMSG_URL="tcp://$(boot2docker ip):55555" #for somewhat mysterious reasons this outputs a lot of junk to stderr, please ignore

xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" GCC_PREPROCESSOR_DEFINITIONS="\$(value) CAFFEINE_OVERRIDE_URL=@\\\"${NANOMSG_URL}\\\"" test | teamcitify

