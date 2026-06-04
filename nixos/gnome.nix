# Gnome settings

{ pkgs, ... }:

{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
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
      tilix
      errands
    ];
    gnome.excludePackages = (with pkgs; [
      epiphany
      decibels
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
      gnome-console
      totem
      showtime
      yelp
    ]);
  };

  # Global patch -- using to fix blurry electron apps when using fractional scaling
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

}
