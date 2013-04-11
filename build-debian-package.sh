#!/bin/bash

PACKAGE_NAME=pharo-vm

# if confirm "Do you want to do that?"; then
#   ...
# fi
function confirm {
    read -p "$1 (Y/n) " answer
    answer=${answer:-"Y"}
    if [ "$answer" = "Y" ]; then
        return 0;
    else
        return 1;
    fi
}


function extract_source_package() {
    upstream_version="$1"
    echo "Extract ${PACKAGE_NAME}_${upstream_version}.orig.tar.gz"
    rm -rf ${PACKAGE_NAME}-${upstream_version}/
    tar xfz ${PACKAGE_NAME}_${upstream_version}.orig.tar.gz
}

function build() {
    upstream_version="$1"
    package_version="$2"
    distribution="$3"
    want_to_package_sources="$4"

    echo "Copy debian/ directory to source package"
    root_directory="${PACKAGE_NAME}-${upstream_version}/"
    cp -R debian "${root_directory}"
    cd "${root_directory}"

    echo "Update changelog"
    dch --distribution ${distribution} --newversion ${upstream_version} "Upstream release"
    dch --distribution ${distribution} --local "-${package_version}~ppa1~${distribution}" "Build for ${distribution}"

    # Use this if you want to build a binary deb package directly
    #       -sa    Forces the inclusion of the original source.
    #       -sd    Forces the exclusion of the original source and includes only the diff.
    #       -us    Do not sign the source package.
    #       -uc    Do not sign the .changes file.
    #       -b     Specifies a binary-only build, limited to architecture dependent packages.  Passed to dpkg-genchanges.
    #       -S     Specifies a source-only build, no binary packages need to be made.  Passed to dpkg-genchanges.

    if [ $want_to_package_sources -eq 0 ]; then
        upload_sources="-sa"
    else
        upload_sources="-sd"
    fi

    # echo "Create a binary package for immediate installation"
    # debuild -b ${upload_sources} -uc -us --changes-option="-DDistribution=${distribution}"

    echo "Create a source package to delegate the build (to PPA for example)"
    debuild -S ${upload_sources} --changes-option="-DDistribution=${distribution}"
    cd ..
}

upstream_version=$1
package_version=$2
distribution=$3

if [ -z "$upstream_version" -o -z "$package_version" -o -z "$distribution" ]; then
    echo "$0 <upstream_version> <package_version> <distribution>"
    exit 1
else

    # Ask questions early in the process

    confirm "Do you want to upload the source package as well?"
    want_to_package_sources=$?

    confirm "Do you want to upload the resulting debian package to PPA?"
    want_ppa_upload=$?

    extract_source_package $upstream_version
    build $upstream_version $package_version $distribution $want_to_package_sources

    if [ $want_ppa_upload -eq 0 ]; then
        dput ppa:cassou/pharo ${PACKAGE_NAME}_${upstream_version}-${package_version}~ppa1~${distribution}1_source.changes
    fi
fi
