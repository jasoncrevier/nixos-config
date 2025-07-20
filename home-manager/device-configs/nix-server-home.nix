{ config, pkgs, ... }:

{
  imports =
    [
      ../ai.nix
      ../fish.nix
      ../git.nix
      ../plasma.nix
      ../vscode.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
