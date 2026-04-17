{ config, pkgs, ... }:

{
  imports =
    [
      ../fish.nix
      ../git.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Don't change this (I think)
  home.stateVersion = "24.05";
}