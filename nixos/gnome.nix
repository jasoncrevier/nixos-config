# Gnome settings

{ pkgs, lib, ... }:

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
    ];
    gnome.excludePackages = with pkgs; [
      epiphany
      decibels
      geary
      gnome-connections
      gnome-font-viewer
      gnome-tour
      gnome-characters
      gnome-clocks
      gnome-maps
      gnome-music
      gnome-weather
      gnome-console
      totem
      showtime
      yelp
    ];
  };

  programs.firefox.policies.ExtensionSettings =
    lib.mapAttrs
      (id: slug: {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      })
      {
        "chrome-gnome-shell@gnome.org" = "gnome-shell-integration";
        "gsconnect@andyholmes.github.io" = "gsconnect";
      };

  # Global patch -- using to fix blurry electron apps when using fractional scaling
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

}
