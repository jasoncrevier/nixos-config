{ config, pkgs, ... }:

{
  imports =
    [
      ../fish.nix
      ../git.nix
    ];

  # Don't change this (I think)
  home.stateVersion = "24.05";
}