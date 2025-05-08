# This config houses most of the basic 
# applications and configurations that are 
# shared between my machines

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
    kernelPackages = pkgs.linuxPackages_zen;
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
    videoDrivers = [ "amdgpu" ];
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
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "adbusers" "kvm" ];
  };

  #~Housekeeping~
  # Enable some basic applications:
  # git, fish, tmux, firefox, adb
  environment.systemPackages = with pkgs; [
    arp-scan
<<<<<<< HEAD
=======
    bat
>>>>>>> b750c041c15c2d6f9bf7f696d23a302404376773
    cifs-utils
    git
    ipscan
    samba
    unrar
    wl-clipboard
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

  programs.adb.enable = true;

  # Remove the manual
  documentation.nixos.enable = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Fix for command-not-found
  # I don't really understand it
  # but it works on some machines.
  # On others, nix-index just crashes
  # the terminal.
  programs.nix-index = {
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
