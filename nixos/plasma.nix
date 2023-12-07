# KDE Plasma settings

{ pkgs, ... }:

{
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # Exclude some default KDE packages
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
  ];
  environment.systemPackages = with pkgs; [
    libsForQt5.discover
    libsForQt5.packagekit-qt
    libportal-qt5
  ];
  # Extra programs
  programs.gnome-disks.enable = true; # I just like gnome-disks
  programs.kdeconnect.enable = true;
}