#!/bin/bash

ARTIFACT="https://ci.inria.fr/pharo-contribution/job/PharoLauncherFinalUserImage/lastSuccessfulBuild/artifact/PharoLauncher.zip"

cd debian/pharo-launcher-resources/usr/share/pharo-launcher
rm -f pharo-launcher.changes pharo-launcher.image
wget $ARTIFACT -O launcher.zip
unzip launcher.zip
rm launcher.zip
mv *.image pharo-launcher.image
mv *.changes pharo-launcher.changes
