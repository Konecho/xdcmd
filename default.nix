{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage ./xdcmd.nix { }
