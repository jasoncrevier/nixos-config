# Applications and configuration shared by the desktop/workstation machines.
# Headless machines (grunt) import base.nix directly instead.

{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./base.nix ];

  #~Keymapping~
  services.xserver = {
    enable = true;
    wacom.enable = true;
  };

  #~Graphics~
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable GameMode: optimizations for gaming
  programs.gamemode.enable = true;

  #~Bluetooth~
  hardware.bluetooth.enable = true;

  #~Users~
  users.users.jason.extraGroups = [
    "audio"
    "dialout"
    "uucp"
    "scanner"
    "lp"
  ];

  environment.systemPackages = with pkgs; [
    android-tools
    arp-scan
    libimobiledevice
    qmk
    samba
    steam-run
    unrar
    via
    yad
    wl-clipboard
  ];

  hardware.keyboard.qmk.enable = true;

  services.udev.packages = [ pkgs.via ];

  services.usbmuxd.enable = true;

  # Firmware updates via LVFS (fwupdmgr / GNOME Software / Discover). Plasma already turns this on.
  services.fwupd.enable = true;

  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;

      # Installed from addons.mozilla.org and kept updated; can still be disabled per machine.
      # Keys are extension IDs. Desktop-specific ones are added in plasma.nix and gnome.nix.
      ExtensionSettings =
        lib.mapAttrs
          (id: slug: {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          })
          {
            "uBlock0@raymondhill.net" = "ublock-origin";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            "search@kagi.com" = "kagi-search-for-firefox";
            "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = "styl-us";
            "addon@karakeep.app" = "karakeep";
            "{3f8844e2-3fc1-4104-9773-0f4bb98eab69}" = "catppuccin-mocha-teal";
            "{b9acf540-acba-11e1-8ccb-001fd0e08bd4}" = "easy-youtube-video-download";
          };
    };
  };
}
