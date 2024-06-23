# Config shared between machines

{ config, pkgs, ... }:

{
  #~Bootloader~
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    plymouth.enable = true;
    initrd.systemd.enable = true;
    kernelParams = ["quiet"];
  };

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
  };

  #~Graphics~
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  #~Bluetooth~
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  #~Housekeeping~
  # Enable basic applications
  environment.systemPackages = with pkgs; [
    catppuccin-plymouth
    git
    mc
  ];
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

  # Enable edg desktop integration
  #xdg = {
  #  portal = {
  #    enable = true;
  #    extraPortals = with pkgs; [
  #      xdg-desktop-portal-wlr
  #      xdg-desktop-portal-gtk
  #    ];
  #  };
  #};

  # Remove the manual
  documentation.nixos.enable = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Fix for command-not-found
  programs.nix-index = {
    #enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
