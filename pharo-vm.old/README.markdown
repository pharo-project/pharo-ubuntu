debian/ directory and scripts for building pharo-vm packages for Ubuntu.

To download and create the debian files:

```bash
cd pharo-vm
./get-upstream-sources.sh
 # at this point you have to update debian/changelog
./build-debian-package.sh 2013.03.20 1 quantal
```

If you want to build the package on your own computer, you might like
`pbuilder`:

```bash
sudo pbuilder create --debootstrapopts --variant=buildd --distribution quantal
sudo pbuilder build pharo-vm_2013.03.20-1~ppa1~quantal1.dsc
```
