# Enable KitchenOwl (shopping lists and recipes), tailnet only

{
  config,
  lib,
  ...
}:

{
  imports = [
    ./backups.nix
    ./podman.nix
  ];

  # JWT_SECRET_KEY=<random>
  sops.secrets.kitchenowl_env = { };

  # SQLite database (copied safely by backups.nix) and uploaded images
  backups.paths = [ "/var/lib/kitchenowl" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/kitchenowl 0750 root root -"
  ];

  # Published on grunt's Tailscale IP only. Podman's port publishing bypasses nixos-fw,
  # so the bind address is what keeps it off the LAN; no allowedTCPPorts entry needed.
  virtualisation.oci-containers.containers."kitchenowl" = {
    image = "docker.io/tombursch/kitchenowl:v0.8.1";
    volumes = [
      "/var/lib/kitchenowl:/data:rw"
    ];
    ports = [
      "100.114.139.101:8080:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--env-file=${config.sops.secrets.kitchenowl_env.path}"
    ];
  };
  systemd.services."podman-kitchenowl" = {
    # The bind fails until tailscale0 has its address; Restart retries until it does
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = 10;
    };
  };
}
