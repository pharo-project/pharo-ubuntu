{ stdenv, fetchurl, cmake, bash, pkgsi686Linux, unzip, python }:

stdenv.mkDerivation rec {
  name = "pharo-vm-core-i386-2014.06.25";
  system = "x86_32-linux";
  src = fetchurl {
    url = http://files.pharo.org/vm/src/vm-unix-sources/pharo-vm-2014.06.25.tar.bz2;
    md5 = "4d80d8169c2f2f0355c43ee90bbad23f";
  };

  # Building
  preConfigure = ''
    cd build/
  '';
  resources = ./resources;
  installPhase = ''
    echo Current directory $(pwd)
    echo Creating prefix "$prefix"
    mkdir -p "$prefix/usr/lib/pharo-vm"

    cd ../../results

    mv vm-display-null vm-display-null.so
    mv vm-display-X11 vm-display-X11.so
    mv vm-sound-null vm-sound-null.so
    mv vm-sound-ALSA vm-sound-ALSA.so
    mv pharo pharo-vm

    cp * "$prefix/usr/lib/pharo-vm"

    cp -R "$resources"/* "$prefix/"

    mkdir $prefix/usr/bin

    chmod u+w $prefix/usr/bin
    cat > $prefix/usr/bin/pharo-vm-x <<EOF
    #!${bash}/bin/bash

    # disable parameter expansion to forward all arguments unprocessed to the VM
    set -f

    exec $prefix/usr/lib/pharo-vm/pharo-vm "\$@"
    EOF

    cat > $prefix/usr/bin/pharo-vm-nox <<EOF
    #!${bash}/bin/bash

    # disable parameter expansion to forward all arguments unprocessed to the VM
    set -f

    exec $prefix/usr/lib/pharo-vm/pharo-vm -vm-display-null "\$@"
    EOF

    chmod +x $prefix/usr/bin/pharo-vm-x $prefix/usr/bin/pharo-vm-nox
  '';

 patches = [ patches/pharo-is-not-squeak.patch patches/fix-executable-name.patch patches/fix-cmake-root-directory.patch ];
 
  buildInputs = [ bash unzip cmake pkgsi686Linux.glibc  pkgsi686Linux.openssl pkgsi686Linux.gcc pkgsi686Linux.mesa pkgsi686Linux.freetype pkgsi686Linux.xlibs.libX11 pkgsi686Linux.xlibs.libICE pkgsi686Linux.xlibs.libSM pkgsi686Linux.alsaLib ];
}