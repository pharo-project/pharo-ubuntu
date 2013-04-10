#!/bin/bash

set -e

PACKAGE_NAME=pharo-vm

VM_SOURCES_URL='https://ci.inria.fr/pharo/job/PharoVM/Architecture=32,Slave=vm-builder-linux/lastSuccessfulBuild/artifact/sources.tar.gz'

function download_sources() {
    echo "Download sources from ci.inria.fr"
    rm -f sources.tar.gz
    wget "${VM_SOURCES_URL}" -O sources.tar.gz
}

function extract_sources() {
    echo "Extract sources.tar.gz to cog/"
    rm -rf cog
    mkdir cog
    cd cog
    tar xfz ../sources.tar.gz
    cd ..
}

function source_package_already_present() {
    echo "Checking if source package is already there"
    vm_version=$(cat cog/build/vmVersionInfo.h | ./extract-vm-version.sh)
    read -p "VM Version is $vm_version, is it correct? (CTRL+c to quit) "
    test -f ${PACKAGE_NAME}_${vm_version}.orig.tar.gz
    return $?
}

function clean_sources() {
    echo "Clean the directory to remove unneeded stuff"
    cd cog
    find . '(' -name '*.image' -or -name '*.changes' ')' -exec rm -f '{}' ';'
    find . '(' -name 'config.log' -or -name 'config.status' ')' -exec rm -f '{}' ';'

    rm -rf platforms/win32
    rm -rf platforms/"Mac OS"
    rm -rf platforms/iOS
    rm -rf processors/ARM
    cd ..
}

function create_source_package() {
    echo "Create upstream tarball"
    vm_version=$(cat cog/build/vmVersionInfo.h | ./extract-vm-version.sh)
    mv cog ${PACKAGE_NAME}-${vm_version}
    tar cfz ${PACKAGE_NAME}_${vm_version}.orig.tar.gz ${PACKAGE_NAME}-${vm_version}
}

download_sources
extract_sources
if source_package_already_present; then
    echo "Source package already present"
else
    echo "Source package is not present, creating it now"
    clean_sources
    create_source_package
fi
