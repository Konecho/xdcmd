{pkgs ? import <nixpkgs> {}}: let
  source = (import ./_sources/generated.nix) {
    inherit
      (pkgs)
      fetchgit
      fetchurl
      fetchFromGitHub
      dockerTools
      ;
  };
in
  pkgs.callPackage ./xdcmd.nix {source = source.xdcmd;}
