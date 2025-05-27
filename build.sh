#!/bin/bash

if [ -z "$(git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD)" ]; then
    if git diff --quiet; then
      git pull origin master --rebase
    fi
else
  echo "${RED}############## There are some unpushed commits. Please push and try again ##############${NC}\n"
  exit 1
fi

. ./set_variables.sh

appHealth=$(curl -s -X POST http://localhost/_app/health)

echo "Application health check response: $appHealth"

if test "$appHealth" = "true" ; then
  	echo  'Going to shutdown tomcat'
  	sh $TOMCAT_APP/build/bin/shutdown.sh
fi

os_name=$(uname)

if [ "$os_name" = "Darwin" ]; then
    echo "Executing build script for MAC"
    exec sh mac_build.sh
fi

set -e
trap '[ $? -eq 0 ] || echo "${RED}######### OPERATION FAILED #########${NC}"' EXIT

echo "############## Build started ##############\n"

GRADLE=/opt/gradle/gradle-$GRADLE_VERSION/bin/gradle

export JAVA_HOME=/opt/java/zulu$JAVA_VERSION

export TOMCAT_APP=$TOMCAT_APP

if [ "$1" != "auto" ]; then
  sudo systemctl stop tomcat
fi

echo "JAVA_HOME : ${JAVA_HOME}"
echo "GRADLE : ${GRADLE}"
echo "TOMCAT_APP : ${TOMCAT_APP}"

$GRADLE cleanBuild

if [ "$1" != "auto" ]; then
  sudo systemctl start tomcat
fi

echo "${GREEN}############## Build completed ##############${NC}\n"
