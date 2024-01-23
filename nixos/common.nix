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
    layout = "us";
    xkbVariant = "";
    enable = true;
  };

  #~Graphics~
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  #~Sound~
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  
  #~Housekeeping~
  # Enable basic applications
  environment.systemPackages = with pkgs; [
    git
    catppuccin-plymouth
    tmux
  ];
  programs.fish.enable = true;

  # Remove the manual
  documentation.nixos.enable = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
