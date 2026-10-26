# Template for a new machine. To add one:
#   1. Install NixOS, then copy /etc/nixos/hardware-configuration.nix to
#      nixos/device-configs/<host>-hardware-configuration.nix
#   2. Copy this file to nixos/device-configs/<host>-configuration.nix
#   3. Copy one of home-manager/device-configs/*-home.nix to <host>-home.nix
#   4. Add the host to nixosConfigurations in flake.nix
#   5. git add -A, then: sudo nixos-rebuild switch --flake ~/nixos-config#<host>
#   6. Set a password with `passwd` (base.nix doesn't set one)

{ ... }:

{
  imports = [
    ./HOST-hardware-configuration.nix

    # Desktops: ../desktop.nix (includes base.nix). Headless servers: ../base.nix
    ../desktop.nix
    ../systemd-boot.nix # BIOS machines use GRUB instead, see grunt-configuration.nix
    ../ssh.nix
    ../tailscale.nix
    # Add others as needed: ../gnome.nix or ../plasma.nix, ../steam.nix, ../audio.nix ...
  ];

  networking.hostName = "HOST"; # Same name as in flake.nix

  # The NixOS release this machine was first installed with, copied from the
  # installer's /etc/nixos/configuration.nix. Never change it without reading
  # the release notes: it controls how existing state is handled.
  system.stateVersion = "XX.XX";
}
