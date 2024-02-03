{ config, pkgs, ... }:

{
  imports = [ 
    ./server-hardware-configuration.nix
    ./tailscale.nix
    ./ssh.nix
  ];
  environment.systemPackages = with pkgs; [
    git
  ];

  #~Bootloader~
  # You likely want to keep whatever the installer
  # set here. This is where you can switch bootloaders
  # later if you need to.
  # Grub:
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  # Systemd:
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  #~Networking~
  networking.hostName = "nixos-server"; # Define your hostname -- this is important for flakes
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  #~Users~
  # Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    # Use this to add the user to different groups as needed.
    # You probably want to keep networkmanager and wheel
    extraGroups = [ "networkmanager" "wheel" ];
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
    allowedUDPPorts = [ 80 443 22 ];
  };

}
