#!/bin/bash

#!/bin/bash

set -e

PACKAGE_NAME=pharo-launcher


JOB="https://ci.inria.fr/pharo-contribution/job/PharoLauncherFinalUserImage"
VERSION=

function download_sources() {
    echo "Download sources from ci.inria.fr"

    # Using the Jenkins JSON API, extract the version number and URL
    # of the latest build
    wget "$JOB/api/json?tree=lastSuccessfulBuild[number,url]" -O jenkins.json
    VERSION=$(cat jenkins.json | jq .lastSuccessfulBuild.number)

    url=$(cat jenkins.json | jq .lastSuccessfulBuild.url | tr -d '"')
    url="$url/artifact/PharoLauncher.zip"

    wget "$url" -O PharoLauncher.zip
}

function extract_sources() {
    echo "Extract PharoLauncher to launcher/"
    rm -rf launcher
    mkdir launcher
    cd launcher
    unzip ../PharoLauncher.zip
    cd ..
}

function create_source_package() {
    echo "Create upstream tarball"
    rm -rf ${PACKAGE_NAME}-${VERSION}
    mv launcher ${PACKAGE_NAME}-${VERSION}
    tar cfz ${PACKAGE_NAME}_${VERSION}.orig.tar.gz ${PACKAGE_NAME}-${VERSION}
}

download_sources
extract_sources
create_source_package
# Don't change this line, it is used in other scripts to extract the
# version:
echo "New version is: $VERSION"
