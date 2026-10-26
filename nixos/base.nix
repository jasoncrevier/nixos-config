# Basics shared by every machine, including headless servers.
# Desktop machines import desktop.nix, which pulls this in.

{ pkgs, ... }:

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
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
    ];
  };

  #~Housekeeping~
  environment.systemPackages = with pkgs; [
    age
    bat
    cifs-utils
    cowsay
    git
    jq
    nixd # Nix language server for VS Code, including Remote-SSH sessions
    nixfmt
    smartmontools # smartctl, for checking disks by hand
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

  nixpkgs.config.allowUnfree = true;

  # Remove the manual
  documentation.nixos.enable = false;

  # Enable flakes
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "jason"
    ];
  };

  # Deduplicate the store on a weekly timer rather than during every build
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Catppuccin system-wide settings to silence enrollment warnings
  catppuccin.enable = true;
  catppuccin.autoEnable = true;

  # Fix for command-not-found
  # Prebuilt database from the nix-index-database flake input
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  # nh: nicer rebuilds (`nh os switch`) and weekly garbage collection
  programs.nh = {
    enable = true;
    flake = "/home/jason/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  # Disk health monitoring (SMART) on every drive smartd can find; warnings go to `wall` for now
  services.smartd.enable = true;

  security.sudo.execWheelOnly = true;
}
