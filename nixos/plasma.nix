# KDE Plasma settings

{ pkgs, ... }:

{
  # Enable SDDM and Plasma
  services = {
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
  };

  # Exclude some default KDE packages and add some additional ones
  environment = {
    systemPackages = with pkgs; [
      kdePackages.kalk
      kdePackages.packagekit-qt
      #libportal-qt6 #Broken 19-04-25
      kdePackages.discover
      kdePackages.kcolorchooser
      kdePackages.krdc
      kdePackages.kolourpaint
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
