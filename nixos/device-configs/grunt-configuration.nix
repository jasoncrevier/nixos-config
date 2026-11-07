# Configuration for the server: Grunt

{
  ...
}:

{
  imports = [
    ./grunt-hardware-configuration.nix
    (import ../media-mount.nix { })

    ../base.nix
    ../failure-alerts.nix
    ../remote-builder.nix
    ../binary-cache.nix
    ../kosync.nix
    ../sops.nix
    ../ssh.nix
    ../tailscale.nix
    ../wallabag.nix

    ../../scripts/obsidian-notifications.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 10; # Keep /boot from filling up

  # The Wi-Fi card fails to initialise on every boot and grunt is wired (enp0s25)
  boot.blacklistedKernelModules = [ "iwlwifi" ];

  #~Hostname~
  networking.hostName = "grunt";

  services.logind.settings.Login.HandleLidSwitch = "ignore"; # Disable sleep when laptop lid is closed

  # Nightly restic backup to B2 of what the service modules list (see backups.nix)
  backups = {
    enable = true;
    sopsFile = ../../grunt-secrets.yaml;
  };

  # ntfy alert when any of these fail (see failure-alerts.nix)
  failureAlerts.services = [
    "kosync"
    "podman-wallabag-db"
    "podman-wallabag-redis"
    "podman-wallabag-wallabag"
  ];

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
