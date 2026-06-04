# This config houses most of the basic 
# applications and configurations that are 
# shared between my machines

{ config, pkgs, ... }:

{
  #~Localization~
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  
  #~Networking~
  networking.networkmanager.enable = true;

  #~Keymapping~
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
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
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "adbusers" "kvm" "dialout" "uucp" ];
  };

  #~Housekeeping~
  # Enable some basic applications:
  # git, fish, tmux, firefox, adb
  environment.systemPackages = with pkgs; [
    age
    android-tools
    arp-scan
    bat
    cifs-utils
    cowsay
    git
    jq
    libimobiledevice
    qmk
    samba
    sops
    steam-run
    unrar
    via
    yad
    wl-clipboard
  ];

  # Enable font discovery and management
  fonts.fontconfig.enable = true;

  hardware.keyboard.qmk.enable = true;

  services.udev.packages = [ pkgs.via ];

  services.usbmuxd.enable = true;

  programs.fish.enable = true;
  
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
    '';
  };
  
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };

  # Remove the manual
  documentation.nixos.enable = false;

  # Enable flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "jason" ];
    auto-optimise-store = true;
  };

  # Catppuccin system-wide settings to silence enrollment warnings
  catppuccin.enable = true;
  catppuccin.autoEnable = true;

  # Fix for command-not-found
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  # Automatically collect garbage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "23.05";

}
