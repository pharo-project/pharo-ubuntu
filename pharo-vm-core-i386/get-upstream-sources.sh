#!/bin/bash

set -e

PACKAGE_NAME=pharo-vm-core-i386

VM_SOURCES_URL='http://files.pharo.org/vm/src/vm-unix-sources/blessed/pharo-vm-2014.09.20.tar.bz2'

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

function wrong_vm_version_format() {
    vm_version="$1"
    # check that vm_Version is of the form YYYY.MM.DD
    echo ${vm_version} | grep '^[[:digit:]]\{4\}\.[[:digit:]]\{2\}\.[[:digit:]]\{2\}$' > /dev/null
    grep_succeeded=$?
    [ ! $grep_succeeded -eq 0 ]
    return $?
}

function source_package_already_present() {
    vm_version="$1"
    echo "Checking if source package is already there"
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
    vm_version=$1
    echo "Create upstream tarball"
    rm -rf ${PACKAGE_NAME}-${vm_version}
    mv cog ${PACKAGE_NAME}-${vm_version}
    tar cfz ${PACKAGE_NAME}_${vm_version}.orig.tar.gz ${PACKAGE_NAME}-${vm_version}
}

download_sources
extract_sources
vm_version=$(cat cog/build/vmVersionInfo.h | ./extract-vm-version.sh)
if wrong_vm_version_format "$vm_version"; then
    echo "Can't extract the VM version from vmVersionInfo.h"
    exit 1
elif source_package_already_present "$vm_version"; then
    echo "Source package already present"
    exit 1
else
    echo "Source package is not present, creating it now"
    clean_sources
    create_source_package "$vm_version"
    # Don't change this line, it is used in other scripts to extract
    # the vm_version:
    echo "New version is: $vm_version"
    exit 0
fi
