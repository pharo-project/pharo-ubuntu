debian/ directory and scripts for building pharo-launcher packages for Ubuntu.

To download and create the debian files:

```bash
cd pharo-launcher
./get-upstream-sources.sh
 # at this point you have to update debian/changelog
./build-debian-package.sh 2013.03.20 1 quantal
```
