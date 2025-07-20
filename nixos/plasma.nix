# KDE Plasma settings

{ pkgs, ... }:

{
  # Enable SDDM and Plasma
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  # Exclude some default KDE packages and add some additional ones
  environment = {
    systemPackages = with pkgs.kdePackages; [
      discover
      kalk
      kcolorchooser
      kolourpaint
      korganizer
      krdc
      packagekit-qt
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
      oxygen
    ];
  };
  
  # Extra programs
  programs = {
    gnome-disks.enable = true; # I just like gnome-disks
    kdeconnect.enable = true;
  };
}
