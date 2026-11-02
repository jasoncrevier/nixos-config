# Serves nix-server's store as a binary cache over Tailscale, and builds every host's
# system from GitHub main each night so the others download it instead of building.
# The clients' side is binary-cache.nix.

{ config, pkgs, ... }:

let
  flake = "github:jasoncrevier/nixos-config";
in
{
  # Created with `nix key generate-secret --key-name nix-server-1`; the public half is in binary-cache.nix
  sops.secrets.harmonia_signing_key = { };

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.harmonia_signing_key.path ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5000 ];

  # Its out-links in /var/lib/fleet-prebuild are GC roots, so the latest builds survive nh clean
  users.users.fleet-prebuild = {
    isSystemUser = true;
    group = "fleet-prebuild";
    home = "/var/lib/fleet-prebuild";
    createHome = true;
  };
  users.groups.fleet-prebuild = { };

  # Run by hand after pushing a lock change: sudo systemctl start --no-block fleet-prebuild
  systemd.services.fleet-prebuild = {
    description = "Build every host's system for the binary cache";
    path = [
      config.nix.package
      pkgs.git
      pkgs.jq
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "fleet-prebuild";
      Group = "fleet-prebuild";
      WorkingDirectory = "/var/lib/fleet-prebuild";
      # Stay out of the way of the game servers and the TV
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      hosts=$(nix eval --refresh --json "${flake}#nixosConfigurations" --apply builtins.attrNames | jq -r '.[]')

      failed=()
      for host in $hosts; do
        echo "Building $host"
        nix build --refresh --print-build-logs \
          --out-link "$host" \
          "${flake}#nixosConfigurations.$host.config.system.build.toplevel" \
          || failed+=("$host")
      done

      if [ ''${#failed[@]} -gt 0 ]; then
        echo "Failed: ''${failed[*]}"
        exit 1
      fi
    '';
    startAt = "04:00";
  };

  # ntfy alert when the nightly build fails (see failure-alerts.nix)
  failureAlerts.services = [ "fleet-prebuild" ];
}
