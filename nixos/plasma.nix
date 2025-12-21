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
    systemPackages = with pkgs; [
      adwaita-icon-theme
      mariadb
    ] 
    ++ (with pkgs.kdePackages; [
      akonadi
      discover
      filelight
      kalk
      kcolorchooser
      kolourpaint
      kontact
      kdepim-addons
      kdepim-runtime
      krdc
      packagekit-qt
    ]);
    plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
      oxygen
    ];
  };
  
  programs.kde-pim.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # Extra programs
  programs = {
    gnome-disks.enable = true; # I just like gnome-disks
    kdeconnect.enable = true;
  };
}
