#!/bin/bash

# VAR

VERSION="3.0.1-SNAPSHOT"
DOCKER_FILE="Dockerfile"
IMAGE_NAME="storm-dev:local"

# CONST

RED='\033[0;31m'
GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # reset

# SCRIPT

echo -e "$BLUE [*] Building the project with Maven...$NC"
if ! mvn clean install -DskipTests=true; then
    echo -e "$RED [-] Maven build failed. Please check the output for errors.$NC"
    exit 1
fi
echo -e "$GREEN [+] Maven build completed successfully!$NC\n"


echo -e "$BLUE [*] Create the binary distribution for this build...$NC"
if ! mvn -f storm-dist/binary/pom.xml clean package; then
    echo -e "$RED [-] Failed to create package.$NC"
    exit 1
fi
echo -e "$GREEN [+] Package successfully created!$NC\n"

echo -e "$BLUE [*] Building docker image...$NC"
if ! docker build --build-arg STORM_VERSION=$VERSION -f $DOCKER_FILE -t $IMAGE_NAME .; then
    echo -e "$RED [-] Failed to create docker image.$NC"
    exit 1
fi
echo -e "$GREEN [+] Docker image : '$IMAGE_NAME' successfully created!$NC\n"
