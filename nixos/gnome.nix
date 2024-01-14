# Enable the GNOME Desktop Environment.

{ pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
  enable = true;
   extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
   extraGSettingsOverrides = ''
     [org.gnome.mutter]
     experimental-features=['scale-monitor-framebuffer']
   '';
  };
  environment.systemPackages = with pkgs; [
    remmina
  ];
  environment.gnome.excludePackages = (with pkgs; [
    kgx
    gnome.gnome-music
    gnome-connections
    gnome.gnome-maps
    gnome-text-editor
    gnome.gnome-weather
    gnome.gnome-characters
    gnome.gnome-clocks
    gnome.gnome-nettool
    gnome-tour
    gnome.gnome-font-viewer
    epiphany
    gnome.yelp
    gnome.geary
    gnome.totem
  ]);
}