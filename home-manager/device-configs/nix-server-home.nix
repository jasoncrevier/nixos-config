{ config, pkgs, ... }:

{
  imports =
    [
      ../fish.nix
      ../games.nix
      ../git.nix
      ../plasma.nix
      ../vscode.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
