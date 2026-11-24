# Nginx Proxy Manager: the internal (LAN + tailnet only) reverse proxy, moved here from the
# Orange Pi on 2026-11-24 because the Pi hung pulling new images. The proxy hosts, the
# certificate and the allowlist live in NPM's own database and data dir, not in this repo,
# so the public repo doesn't name the domain or the services behind it.
#
# Host networking instead of published ports: netavark DNATs published ports before
# nixos-fw sees them, so the firewall below couldn't gate them, and NPM's allowlist would
# see podman's gateway instead of the real client. On the host network nginx binds the
# host's own sockets: nixos-fw decides who reaches it, the allowlist sees real addresses,
# and upstreams on this machine are reachable at 127.0.0.1.
#
# Admin UI: port 81, tailnet only. Data: /var/lib/nginx-proxy-manager (backed up).

{ lib, ... }:

let
  lanInterface = "enp0s25";
  dataDir = "/var/lib/nginx-proxy-manager";
in
{
  imports = [
    ./backups.nix
    ./podman.nix
  ];

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/data 0750 root root -"
    "d ${dataDir}/letsencrypt 0750 root root -"
  ];

  # SQLite database (copied safely by backups.nix), nginx config, custom snippets and the
  # certificates. Certificates can be reissued, but keeping them avoids a rate limit on restore
  backups.paths = [ dataDir ];

  # 80/443 for the proxied names on the LAN and the tailnet; the admin UI on the tailnet only.
  # NPM's own allowlist (data/nginx/custom/server_proxy.conf) also limits the proxied names
  # to 192.168.0.0/16 and 100.64.0.0/10.
  networking.firewall.interfaces.${lanInterface}.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    80
    443
    81
  ];

  # Pinned like the other NPMs; bump with a backup of dataDir first (migrations are one-way)
  virtualisation.oci-containers.containers."nginx-proxy-manager" = {
    image = "docker.io/jc21/nginx-proxy-manager:2.17.1";
    volumes = [
      "${dataDir}/data:/data:rw"
      "${dataDir}/letsencrypt:/etc/letsencrypt:rw"
    ];
    log-driver = "journald";
    extraOptions = [ "--network=host" ];
  };
  systemd.services."podman-nginx-proxy-manager" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = 10;
    };
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };
}
