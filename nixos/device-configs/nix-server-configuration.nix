# Configuration for my home server

{ pkgs, ... }:

{
  imports = [
    ./nix-server-hardware-configuration.nix
    (import ../media-mount.nix { })

    ../ai.nix
    ../binary-cache-server.nix
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

  # Disable Wayland for SDDM. Relogin puts tv straight back into Bigscreen after a logout
  services = {
    displayManager.sddm.wayland.enable = false;
    displayManager.sddm.autoLogin.relogin = true;
  };

  # tv autologins into Plasma Bigscreen, the TV-style Plasma shell
  services.displayManager = {
    sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
    defaultSession = "plasma-bigscreen-wayland";
  };
  environment.systemPackages = [ pkgs.kdePackages.plasma-bigscreen ];

  # Bigscreen's input handler (remote, gamepad and CEC navigation) injects keys through
  # /dev/uinput; the package's udev rule gives the logged-in user access to it
  hardware.uinput.enable = true;
  services.udev.packages = [ pkgs.kdePackages.plasma-bigscreen ];

  # AXGear MS-AIR-DM air mouse (its dongle shows up as "XING WEI 2.4G", 1915:1025).
  # Most buttons already match Bigscreen: OK is Enter, Home is Home Page (home screen),
  # Menu is the Menu key (task overview). Fixes for the rest:
  # - Back sends KEY_BACK, which most apps ignore, so make it Esc
  # - Power and Sleep would shut down or suspend the server, so they do nothing
  services.udev.extraHwdb = ''
    evdev:input:b0003v1915p1025*
     KEYBOARD_KEY_c0224=esc
     KEYBOARD_KEY_10081=reserved
     KEYBOARD_KEY_10082=reserved
     KEYBOARD_KEY_c0030=reserved
     KEYBOARD_KEY_c0032=reserved
  '';
  # Belt and braces: logind ignores power/sleep keys from the remote even if it
  # sends them under some other scancode
  services.udev.extraRules = ''
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="1915", ATTRS{idProduct}=="1025", TAG-="power-switch"
  '';

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

  # Nightly restic backup to B2 of what the service modules list (see backups.nix)
  backups = {
    enable = true;
    sopsFile = ../../server-secrets.yaml;
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

  # Jellyfin's metadata (~14 GB of artwork, fetched again on a rescan) lives on the HDD:
  # the root SSD needs the room for the weekly flake.lock update's builds
  fileSystems."/var/lib/jellyfin/metadata" = {
    device = "/mnt/Main_storage/jellyfin-metadata";
    fsType = "none";
    options = [
      "bind"
      "nofail"
      "x-systemd.requires-mounts-for=/mnt/Main_storage"
    ];
  };
  systemd.services.jellyfin.unitConfig.RequiresMountsFor = [ "/var/lib/jellyfin/metadata" ];

  #~Hostname~
  networking.hostName = "nix-server";

  # The NixOS release this machine was first installed with. Don't change it
  # without reading the release notes: it controls how existing state is handled.
  system.stateVersion = "23.05";
}
