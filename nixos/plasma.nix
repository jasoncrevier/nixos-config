# KDE Plasma settings

{ pkgs, ... }:

{
  # Enable SDDM and Plasma
  services.xserver = {
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };
  
  # Exclude some default KDE packages
  environment = {
    systemPackages = with pkgs; [
      libsForQt5.discover
      libsForQt5.packagekit-qt
      libportal-qt5
      krdc
    ];
    plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      oxygen
      khelpcenter
    ];
  };
  
  # Extra programs
  programs = {
    gnome-disks.enable = true; # I just like gnome-disks
    kdeconnect.enable = true;
  };
}