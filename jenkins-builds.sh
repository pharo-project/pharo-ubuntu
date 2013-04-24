#! /bin/bash

distrib=$(lsb_release -c | awk '{print $2;}')
vm_version=$(./get-upstream-sources.sh | tee get-sources.log \
    | grep "^New version is:" \
    | sed -e "s/^New version is: \([[:digit:].]\+\)$/\1/")

cat get-sources.log

if [[ -z $vm_version ]]; then
    echo "Nothing to do"
else
    exec ./build-debian-package.sh $vm_version 1 $distrib --binary --no-sources
fi
