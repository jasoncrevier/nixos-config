# Serves nix-server's store as a binary cache over Tailscale, and builds every host's
# system from GitHub main each night so the others download it instead of building.
# Once a week it also updates flake.lock, and pushes the new lock to main only if every
# host builds with it. The clients' side is binary-cache.nix, and update-notifier.nix tells
# the workstations when a new build for them is ready.

{ config, pkgs, ... }:

let
  repo = "jasoncrevier/nixos-config";
  stateDir = "/var/lib/fleet-prebuild";
  # Only the manifest is served; the out-links next to it stay private
  wwwDir = "${stateDir}/www";
  manifestPort = 5001;

  # fleet-build           build main as it is (nightly)
  # fleet-build --update  update flake.lock first, push it if everything builds (weekly)
  fleetBuild = pkgs.writeShellApplication {
    name = "fleet-build";
    runtimeInputs = [
      config.nix.package
      pkgs.coreutils
      pkgs.git
      pkgs.jq
      pkgs.openssh
      pkgs.util-linux
    ];
    text = ''
      update=false
      [ "''${1:-}" = "--update" ] && update=true

      # The nightly and weekly jobs take turns instead of building side by side
      exec 9> "${stateDir}/.lock"
      flock 9

      work=$(mktemp -d)
      trap 'rm -rf "$work"' EXIT
      git clone --quiet --depth 1 "https://github.com/${repo}.git" "$work/repo"
      cd "$work/repo"

      if $update; then
        echo "Updating flake.lock"
        nix flake update
      fi

      hosts=$(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]')

      failed=()
      for host in $hosts; do
        echo "Building $host"
        nix build --print-build-logs \
          --out-link "${stateDir}/$host" \
          ".#nixosConfigurations.$host.config.system.build.toplevel" \
          || failed+=("$host")
      done

      if [ ''${#failed[@]} -gt 0 ]; then
        echo "Failed: ''${failed[*]}"
        if $update; then echo "flake.lock not pushed; main keeps its current lock"; fi
        exit 1
      fi

      if $update && ! git diff --quiet flake.lock; then
        git -c user.name="fleet-prebuild" -c user.email="fleet-prebuild@nix-server" \
          commit --quiet -m "flake.lock: update" flake.lock
        # Someone pushed to main while this ran: skip it, tonight's build picks up their commit
        if ! GIT_SSH_COMMAND="ssh -i ${config.sops.secrets.fleet_prebuild_deploy_key.path} -o IdentitiesOnly=yes" \
          git push --quiet "git@github.com:${repo}.git" HEAD:main; then
          echo "Push rejected (main moved); leaving the manifest as it was"
          exit 0
        fi
        echo "Pushed new flake.lock"
      fi

      # host -> store path of its build on main. Written only now, so a workstation is
      # never told about a build that isn't on main or isn't in the cache.
      rev=$(git rev-parse HEAD)
      for host in $hosts; do
        jq -n --arg h "$host" --arg p "$(readlink "${stateDir}/$host")" '{($h): $p}'
      done | jq -s --arg rev "$rev" '{rev: $rev, hosts: add}' > "${wwwDir}/manifest.json.tmp"
      mv "${wwwDir}/manifest.json.tmp" "${wwwDir}/manifest.json"
    '';
  };

  fleetService = description: args: {
    inherit description;
    serviceConfig = {
      Type = "oneshot";
      User = "fleet-prebuild";
      Group = "fleet-prebuild";
      WorkingDirectory = stateDir;
      ExecStart = "${fleetBuild}/bin/fleet-build ${args}";
      # Stay out of the way of the game servers and the TV
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
in
{
  # Both kept in server-secrets.yaml, which only nix-server can decrypt: either one is enough
  # to push changes onto every machine in the fleet.

  # Created with `nix key generate-secret --key-name nix-server-2`; the public half is in binary-cache.nix
  sops.secrets.harmonia_signing_key.sopsFile = ../server-secrets.yaml;

  # Write-access deploy key for the repo, so the weekly job can push flake.lock
  sops.secrets.fleet_prebuild_deploy_key = {
    sopsFile = ../server-secrets.yaml;
    owner = "fleet-prebuild";
  };

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.harmonia_signing_key.path ];
  };

  # The manifest that the workstations' update-notifier.nix polls
  services.static-web-server = {
    enable = true;
    listen = "[::]:${toString manifestPort}";
    root = wwwDir;
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    5000
    manifestPort
  ];

  # Garbage-collect during builds instead of failing when the disk fills up:
  # starts below 10 GB free and stops once 30 GB is free
  nix.settings = {
    min-free = 10 * 1024 * 1024 * 1024;
    max-free = 30 * 1024 * 1024 * 1024;
  };

  # Its out-links in /var/lib/fleet-prebuild are GC roots, so the latest builds survive nh clean
  users.users.fleet-prebuild = {
    isSystemUser = true;
    group = "fleet-prebuild";
    home = stateDir;
    createHome = true;
    # static-web-server runs as its own user and needs to reach www/
    homeMode = "755";
  };
  users.groups.fleet-prebuild = { };

  systemd.tmpfiles.rules = [ "d ${wwwDir} 0755 fleet-prebuild fleet-prebuild -" ];

  # So the push doesn't stop at an unknown-host prompt
  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

  systemd.services = {
    # By hand after pushing a change: sudo systemctl start --no-block fleet-prebuild
    fleet-prebuild = fleetService "Build every host's system for the binary cache" "" // {
      startAt = "04:00";
    };

    # By hand: the upgrade alias
    fleet-update = fleetService "Update flake.lock, and push it if every host builds" "--update" // {
      startAt = "Sun 02:00";
    };
  };

  # ntfy alert when a build fails (see failure-alerts.nix)
  failureAlerts.services = [
    "fleet-prebuild"
    "fleet-update"
  ];
}
