# Configuration for my home server

{ ... }:

{
  imports = [
    ./nix-server-hardware-configuration.nix
    (import ../media-mount.nix { })

    ../ai.nix
    ../desktop.nix
    ../failure-alerts.nix
    ../jellyfin.nix
    ../karakeep.nix
    ../music-assistant.nix
    ../navidrome.nix
    ../nvidia.nix
    ../plasma.nix
    ../project-zomboid.nix
    ../sops.nix
    ../ssh.nix
    ../steam.nix
    ../sunshine.nix
    ../systemd-boot.nix
    ../tailscale.nix
    ../valheim.nix
    ../wyoming.nix

    ../../scripts/navidrome-likes-to-listenbrainz.nix
    ../../scripts/obsidian-notifications.nix
  ];

  # Autologin
  services.displayManager.autoLogin = {
    enable = true;
    user = "jason";
  };

  # Disable Wayland for SDDM
  services = {
    displayManager.sddm.wayland.enable = false;
  };

  services.displayManager.defaultSession = "plasma";

  # Root's remote-build keys on the machines that offload builds here (see remote-builder.nix)
  users.users.jason.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZkNWP4k2SUAFTXadWUnx0Fpu4HQ0EAzwEbDv7+m5UT nix-builder@thinkpad"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbZZ85vml0wCwXZf90pUL6sBypIbVJRtvo5etn5bwjo nix-builder@grunt"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6EfMXZgZbss6Vld8Jjy77xaHDswiXplMjFttjmQxcV nix-builder@surface"
  ];

  # ntfy alert when any of these fail (see failure-alerts.nix)
  failureAlerts.services = [
    "jellyfin"
    "karakeep-web"
    "karakeep-workers"
    "music-assistant"
    "navidrome"
    "navidrome-listenbrainz-sync"
    "ollama"
    "open-webui"
    "podman-project-zomboid"
    "steam@"
    "valheim"
    "wyoming-faster-whisper-knight"
    "wyoming-piper-knight"
  ];

  #~Hostname~
  networking.hostName = "nix-server";

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
