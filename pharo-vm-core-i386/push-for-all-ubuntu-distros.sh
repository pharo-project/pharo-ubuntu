#!/bin/bash

set -e

declare -a distros=(utopic trusty saucy precise lucid)

export DEBFULLNAME="Damien Cassou"
export DEBEMAIL="damien.cassou@gmail.com"
PPA=pharo/unstable
PACKAGE_NAME=$(basename $PWD)

function usage() {
    echo "Usage: $0 <upstream_version> <package_version> [OPTIONS]"
    echo "Upload the *.deb files to the Ubuntu PPA"
    echo ""
    echo -e "  --no-sources\t if you already uploaded the orig.tar.gz package"
}

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

upstream_version=$1
package_version=$2

shift 2

if [ -z "$upstream_version" -o -z "$package_version" ]; then
    usage
    exit 1
fi

want_to_package_sources=0
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --no-sources)
            want_to_package_sources=1
            ;;
        *)
            echo "Unknown option: " $1
            usage
            exit 1
            ;;
    esac
    shift
done


if [ $want_to_package_sources -eq 0 ]; then
    sources_option=''
else
    sources_option='--no-sources'
fi


# We take the first distribution in distros and build for it
distro=${distros[0]}
./build-debian-package.sh $PACKAGE_NAME $upstream_version $package_version $distro $sources_option

# We take the remaining distributions (i.e., the one from index 1 to
# the last item)
all_but_first_distros=(${distros[@]:1})

folder=$PACKAGE_NAME-$upstream_version
cd $folder

for distro in "${all_but_first_distros[@]}"; do
    tail -n +7 debian/changelog > debian/changelog.new
    mv debian/changelog.new debian/changelog

    dch --distribution ${distro} --local "-${package_version}~ppa1~${distro}" "Build for ${distro}"
    debuild -S -sd
done
cd ..

for distro in "${distro[@]}"; do
    dput ppa:$PPA ${PACKAGE_NAME}_${upstream_version}-${package_version}\~ppa1\~${distro}1_*.changes
done
