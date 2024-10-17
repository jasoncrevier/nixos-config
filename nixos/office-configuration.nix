{ config, pkgs, ... }:

{
  imports =
    [
      ./common.nix
      ./flatpak.nix
      ./musnix.nix
      ./office-hardware-configuration.nix
      ./plasma.nix
      ./ssh.nix
      ./steam.nix
      ./tailscale.nix
    ];

  #~Networking~
  networking.hostName = "office"; # Define your hostname -- this is important for flakes
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # For SSH and InvokeAI
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [  80 443 22 9090 ];
    allowedUDPPorts = [ 80 443 22 9090 ];
  };

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
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "adbusers" "kvm" ];
  };

  # Enable binary cache for nixified-ai
  nix.settings.trusted-substituters = ["https://ai.cachix.org"];
  nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
