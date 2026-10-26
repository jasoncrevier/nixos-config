# Configuration for my Surface

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./surface-hardware-configuration.nix

    ../desktop.nix
    ../remote-builder.nix
    ../flatpak.nix
    ../intel.nix
    #../musnix.nix
    ../gnome.nix
    ../ssh.nix
    ../steam.nix
    ../systemd-boot.nix
    ../tailscale.nix
    ../workstation.nix
  ];

  #~Hostname~
  networking.hostName = "surface";

  zramSwap.enable = true;

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
