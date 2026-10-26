# Basics shared by every machine, including headless servers.
# Desktop machines import desktop.nix, which pulls this in.

{ config, pkgs, ... }:

{
  #~Localization~
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  #~Networking~
  networking.networkmanager.enable = true;

  #~Users~
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "kvm" ];
  };

  #~Housekeeping~
  environment.systemPackages = with pkgs; [
    age
    bat
    cifs-utils
    cowsay
    git
    jq
    sops
  ];

  programs.fish.enable = true;

  programs.nix-ld.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
    '';
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

  security.sudo.execWheelOnly = true;

  system.stateVersion = "23.05";
}
