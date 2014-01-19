#!/bin/bash

function usage() {
    echo "Usage: $0 <upstream_version> <package_version> [OPTIONS]"
    echo "Upload the *.deb files to the Ubuntu PPA"
    echo ""
    echo -e "  --no-sources\t if you already uploaded the orig.tar.gz package"
}

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

declare -a distros=(trusty saucy raring quantal precise lucid)

if [ $want_to_package_sources -eq 0 ]; then
    sources_option=''
else
    sources_option='--no-sources'
fi

for distro in "${distros[@]}"; do
    ./build-debian-package.sh $upstream_version $package_version $distro $sources_option --upload
    # Once sources have been uploaded, there is no need to upload them again
    sources_option='--no-sources'
done
