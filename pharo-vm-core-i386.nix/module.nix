{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };
  
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  
  self = rec {
    pharo = callPackage ./pharo.nix { };
  };
in
self