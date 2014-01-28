#!/bin/bash

#!/bin/bash

set -e

PACKAGE_NAME=pillar

ARTIFACT_DIR="https://ci.inria.fr/pharo-contribution/job/Pillar/PHARO=30,VERSION=stable,VM=vm/lastSuccessfulBuild/artifact/"
IMAGE="$ARTIFACT_DIR/Pillar-deployment.zip"
SCRIPT="$ARTIFACT_DIR/pillar"

VERSION=0.6

function download_sources() {
    echo "Download sources from ci.inria.fr"

    wget $IMAGE -O Pillar.zip
    wget $SCRIPT -O pillar

}

function extract_sources() {
    echo "Extract Pillar to pillar/"
    rm -rf pillar-source
    mkdir pillar-source
    cd pillar-source
    unzip ../Pillar.zip
    mv ../pillar .
    cd ..
}

function create_source_package() {
    echo "Create upstream tarball"
    rm -rf ${PACKAGE_NAME}-${VERSION}
    mv pillar-source ${PACKAGE_NAME}-${VERSION}
    tar cfz ${PACKAGE_NAME}_${VERSION}.orig.tar.gz ${PACKAGE_NAME}-${VERSION}
    rm -rf ${PACKAGE_NAME}-${VERSION}
}

download_sources
extract_sources
create_source_package
# Don't change this line, it is used in other scripts to extract the
# version:
echo "New version is: $VERSION"
