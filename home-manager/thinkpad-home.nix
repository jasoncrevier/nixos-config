{ config, pkgs, ... }:

{
  imports =
    [
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

  # Enable Syncthing on this machine
  services.syncthing.enable = true;
  home.packages = with pkgs; [
    syncthing-tray
  ];

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
