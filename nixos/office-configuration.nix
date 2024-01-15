{ config, pkgs, ... }:

{
  imports =
    [
      ./common.nix
      ./flatpak.nix
      #./musnix.nix
      ./nvidia.nix
      ./office-hardware-configuration.nix
      ./plasma.nix
      ./steam.nix
      ./tailscale.nix
    ];

  #~Networking~
  networking.hostName = "office"; # Define your hostname -- this is important for flakes
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #~Sound~
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    #alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  #~Users~
  # Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    isNormalUser = true;
    description = "Jason Crevier";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
