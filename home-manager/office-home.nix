{ config, pkgs, ... }:

{
  imports =
    [
      ./audio.nix
      ./chat.nix
      ./fish.nix
      ./git.nix
      ./graphics.nix
      ./misc.nix
      ./plasma-home.nix
      ./vscode.nix
      ./web.nix
      ./theme.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
