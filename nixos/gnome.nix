# Gnome settings

{ pkgs, ... }:

{
  services = {
    xserver.displayManager.gdm.enable = true;
    xserver.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [ pkgs.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };
  };
  environment = {
    systemPackages = with pkgs; [
      remmina
    ];
    gnome.excludePackages = (with pkgs; [
      epiphany
      geary
      gnome-connections
      gnome-font-viewer
      gnome-tour
      gnome-characters
      gnome-clocks
      gnome-maps
      gnome-nettool
      gnome-music
      gnome-weather
      kgx
      totem
      yelp
    ]);
  };
}