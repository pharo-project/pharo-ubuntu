debian/ directory and scripts for building [pillar](http://www.smalltalkhub.com/#!/~Pier/Pillar) packages for Ubuntu.

To download and create the debian files:

```bash
cd pillar
./get-upstream-sources.sh
 # at this point you have to update debian/changelog
./build-debian-package.sh 2014.01.19 1 saucy
```
