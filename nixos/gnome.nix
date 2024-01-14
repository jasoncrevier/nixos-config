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
    epiphany
    gnome-connections
    gnome-text-editor
    gnome-tour
    gnome.geary
    gnome.gnome-characters
    gnome.gnome-clocks
    gnome.gnome-font-viewer
    gnome.gnome-maps
    gnome.gnome-music
    gnome.gnome-nettool
    gnome.gnome-weather
    gnome.totem
    gnome.yelp
    kgx
  ]);
}