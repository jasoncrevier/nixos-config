# Immich
# The app, its database and the ML model
# cache live on nix-server; the library (originals, thumbnails, transcodes, Immich's own DB
# backups) lives on tower's 'immich' share over NFS, which tower exports only to nix-server's LAN
# address (192.168.3.40: keep its DHCP reservation) and backs up to B2 itself.
#
# Public through the Pi's tunnel (route set in Cloudflare's dashboard), so shared links work for
# people off the tailnet. Cloudflare caps uploads at 100 MB, so the phone app should upload over
# the tailnet/LAN (app settings: automatic URL switching, local URL http://nix-server:2283).
# Machine learning (faces, search) runs on the CPU.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  mediaLocation = "/mnt/immich";
  dumpDir = "/var/lib/immich-db-dump";
in
{
  imports = [ ./backups.nix ];

  # tower: all_squash, so every file there is nobody:users (99:100) whoever writes it
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems.${mediaLocation} = {
    device = "192.168.3.101:/mnt/user/immich";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "hard"
      "noatime"
      "nofail" # boot doesn't wait on tower; Immich just won't start without it (and alerts)
      "_netdev"
      "x-systemd.mount-timeout=30s"
    ];
  };

  services.immich = {
    enable = true;
    inherit mediaLocation;
    host = "0.0.0.0"; # the tunnel and the tailnet reach it over the network
    port = 2283;
    openFirewall = true;
    # settings = null: configured in the web UI (Administration → Settings), including
    # Server → External domain (the public address shared links use)
  };

  # nix-server's stateVersion (23.05) would pick PostgreSQL 14, which nixpkgs has dropped. Immich
  # is nix-server's first PostgreSQL user, so there is no old cluster to upgrade. A later major
  # version change needs a dump/restore (or pg_upgrade): don't bump this casually.
  services.postgresql.package = pkgs.postgresql_17;

  # The module's tmpfiles rule chowns the media folder to immich every switch; on the squashed
  # NFS share that chown can only fail (and would fail the deploy). The share's folder is 0777.
  systemd.tmpfiles.settings.immich = lib.mkForce { };

  # Its PrivateMounts would hide a mount that appears after it starts, so wait for the share
  systemd.services.immich-server.unitConfig.RequiresMountsFor = [ mediaLocation ];

  failureAlerts.services = [
    "immich-server"
    "immich-machine-learning"
  ];

  # Database dump for nix-server's restic run (Immich also writes its own nightly dumps into
  # the library's backups/ folder on tower, which tower's backup carries)
  backups.paths = [ dumpDir ];
  backups.prepareCommands = ''
    mkdir -p ${dumpDir}
    ${pkgs.util-linux}/bin/runuser -u postgres -- \
      ${config.services.postgresql.package}/bin/pg_dump --format=custom immich > ${dumpDir}/immich.dump
  '';
}
