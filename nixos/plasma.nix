# KDE Plasma settings

{ pkgs, ... }:

{
  # Enable SDDM and Plasma
  services = {
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
  };
  
  # Exclude some default KDE packages
  environment = {
    systemPackages = with pkgs; [
      libsForQt5.discover
      libsForQt5.kalk
      libsForQt5.packagekit-qt
      libportal-qt5
      krdc
      kolourpaint
      kwrited
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
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
