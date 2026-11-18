# Nightly copy of the Pis' config into /var/lib/private/pi-config-pull, which restic → B2
# picks up at 03:00. The Pis aren't NixOS and have no backup of their own, so nix-server
# pulls from them over the tailnet with a key that can do nothing but this:
#
#   octoprint      ~/.octoprint (settings, plugins, users; not uploads, timelapses or logs)
#                  and Klipper's printer.cfg, its dated copies and Moonraker's database
#   orangepizero3  ~/cloudflared (compose.yml and the tunnel tokens in .env), and Nginx
#                  Proxy Manager's /data (minus logs) and /etc/letsencrypt
#
# Each Pi's ~/.ssh/authorized_keys pins the key (pi_config_pull_key in server-secrets.yaml)
# to a fixed read-only tar command, and only from nix-server's tailnet address:
#
# octoprint:
#   from="100.123.35.99",restrict,command="tar -czf - -C /home/jason --exclude=.octoprint/uploads --exclude=.octoprint/timelapse --exclude=.octoprint/logs --exclude=.octoprint/generated .octoprint printer_data/config printer_data/database; test $? -le 1" ssh-ed25519 AAAA… nix-server-pi-config-pull
# orangepizero3 (the word after the host picks the archive):
#   from="100.123.35.99",restrict,command="case \"$SSH_ORIGINAL_COMMAND\" in npm) docker exec nginx_proxy_manager tar -czf - -C / --exclude=data/logs data etc/letsencrypt;; *) tar -czf - -C /home/jason cloudflared;; esac; test $? -le 1" ssh-ed25519 AAAA… nix-server-pi-config-pull
#
# `test $? -le 1`: tar exits 1 when a file changes while it reads it (OctoPrint's and NPM's
# live files), and the archive is still whole. To restore, copy files back from the snapshot.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # name, tailnet address, and the word sent to the Pi's forced command
  pulls = [
    "octoprint 100.68.145.116 config"
    "orangepizero3 100.83.188.65 cloudflared"
    "orangepizero3 100.83.188.65 npm"
  ];

  # Pinned rather than learned on first connect; the same keys office has in known_hosts
  knownHosts = pkgs.writeText "pi-config-pull-known-hosts" ''
    100.68.145.116 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBcaZJa/CAi11xqKi6M85TMhdu/Jl4JagFTptmOZ+ia
    100.83.188.65 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBJSe/vALK6bIx8YG0VzPASIqdznaArNiA431Zat8LJ
  '';

  pullScript = pkgs.writeShellApplication {
    name = "pi-config-pull";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnutar
      pkgs.gzip
      pkgs.openssh
    ];
    text = ''
      out="$STATE_DIRECTORY"
      failed=()

      for pull in ${lib.escapeShellArgs pulls}; do
        read -r name host what <<< "$pull"
        dest="$out/$name/$what"
        tmp="$dest.new"
        rm -rf "$tmp"
        mkdir -p "$tmp"
        # The Pi decides what's in the archive; "$what" only picks which one
        if ssh -n -F /dev/null -i "$CREDENTIALS_DIRECTORY/key" \
          -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=30 \
          -o StrictHostKeyChecking=yes -o UserKnownHostsFile=${knownHosts} \
          "jason@$host" "$what" | tar -xzf - -C "$tmp"; then
          # Swap in the new copy only once it's complete; the last good one stays otherwise
          if [ -e "$dest" ]; then chmod -R u+rwX "$dest" && rm -rf "$dest"; fi
          mv "$tmp" "$dest"
          echo "$name $what: $(du -sh "$dest" | cut -f1)"
        else
          echo "$name $what: pull failed, keeping the previous copy" >&2
          chmod -R u+rwX "$tmp" && rm -rf "$tmp"
          failed+=("$name $what")
        fi
      done

      if [ ''${#failed[@]} -gt 0 ]; then
        echo "Failed: ''${failed[*]}" >&2
        exit 1
      fi
    '';
  };
in
{
  imports = [ ../nixos/backups.nix ];

  # nix-server only: it reads the Pis' tunnel tokens and TLS keys
  sops.secrets.pi_config_pull_key.sopsFile = ../server-secrets.yaml;

  backups.paths = [ "/var/lib/private/pi-config-pull" ];

  systemd.services.pi-config-pull = {
    description = "Copy the Pis' config for the restic backup";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pullScript}/bin/pi-config-pull";
      DynamicUser = true;
      StateDirectory = "pi-config-pull";
      LoadCredential = "key:${config.sops.secrets.pi_config_pull_key.path}";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  # Before the 03:00 backup; Persistent catches up a night the server was off
  systemd.timers.pi-config-pull = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:15";
      Persistent = true;
    };
  };
}
