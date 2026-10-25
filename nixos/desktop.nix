# Applications and configuration shared by the desktop/workstation machines.
# Headless machines (grunt) import base.nix directly instead.

{ config, pkgs, ... }:

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
  hardware.bluetooth.powerOnBoot = true;

  #~Users~
  users.users.jason.extraGroups = [ "audio" "dialout" "uucp" "scanner" "lp" ];

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

  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
}
