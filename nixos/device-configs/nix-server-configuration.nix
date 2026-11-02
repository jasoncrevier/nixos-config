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
    ../minecraft.nix
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
  ];

  # The TV logs in as tv, which has no sudo
  users.users.tv = {
    isNormalUser = true;
    description = "TV";
  };

  home-manager.users.tv = ../../home-manager/device-configs/nix-server-tv-home.nix;

  services.displayManager.autoLogin = {
    enable = true;
    user = "tv";
  };

  # Sunshine streams the TV session, so start it with tv's desktop
  services.sunshine.autoStart = true;

  # Disable Wayland for SDDM. Relogin puts tv straight back into Big Picture after a logout
  services = {
    displayManager.sddm.wayland.enable = false;
    displayManager.sddm.autoLogin.relogin = true;
  };

  # tv autologins into regular Plasma (Bigscreen was too unreliable)
  services.displayManager.defaultSession = "plasma";

  # Remote builds for the machines that offload here (see remote-builder.nix). These keys
  # log in as nix-ssh, which can only run nix-daemon: no shell, no forwarding.
  # trusted is needed so clients can upload their unsigned build inputs.
  nix.sshServe = {
    enable = true;
    protocol = "ssh-ng";
    write = true;
    trusted = true;
    # Root's remote-build keys on the clients
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZkNWP4k2SUAFTXadWUnx0Fpu4HQ0EAzwEbDv7+m5UT nix-builder@thinkpad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbZZ85vml0wCwXZf90pUL6sBypIbVJRtvo5etn5bwjo nix-builder@grunt"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6EfMXZgZbss6Vld8Jjy77xaHDswiXplMjFttjmQxcV nix-builder@surface"
    ];
  };

  # ntfy alert when any of these fail (see failure-alerts.nix)
  failureAlerts.services = [
    "jellyfin"
    "karakeep-web"
    "karakeep-workers"
    "minecraft-server"
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
