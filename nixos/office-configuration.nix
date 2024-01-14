{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan
      ./office-hardware-configuration.nix
      ./steam.nix
      ./plasma.nix
      ./nvidia.nix
      ./tailscale.nix
      ./flatpak.nix
    ];

  #~Bootloader~
  # Systemd:
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #~Networking~
  networking.hostName = "office"; # Define your hostname -- this is important for flakes
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable firewall and open SSH port
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 22 ];
  allowedUDPPorts = [ 80 443 22 ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  #~Localization~
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  #~Keymapping~
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
  };

  #~Sound~
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    #alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  #~Musnix~
  musnix.enable = true;
  musnix.kernel.packages = true;

  #~Graphics~
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  #~Users~
  # Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "Jason Crevier";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };
  
  # Enable basic applications
  environment.systemPackages = with pkgs; [
    git
  ];
  programs.fish.enable = true;

  # Remove the manual
  documentation.nixos.enable = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
