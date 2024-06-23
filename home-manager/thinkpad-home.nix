{ config, pkgs, ... }:

{
  imports =
    [
      ./ai.nix
      ./audio.nix
      ./chat.nix
      ./fish.nix
      ./git.nix
      ./gnome-home.nix
      ./graphics.nix
      ./misc.nix
      ./theme.nix
      ./vscode.nix
      ./web.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
