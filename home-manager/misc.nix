{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    chromium
    feishin
    freetube
    heynote
    kdePackages.kasts
    micro
    nicotine-plus
    obsidian
    onlyoffice-desktopeditors
    tutanota-desktop
    vlc
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
