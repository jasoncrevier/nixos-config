# Enable Valheim server

{ config, pkgs, lib, utils, ... }:

let
  steam-app = "896660";
  valheim_env = config.sops.secrets.valheim_env.path;
  
  steamcmd-downloader = pkgs.writeShellScript "steamcmd-downloader" ''
    set -eux
    
    instance="$1"
    if [ -z "$instance" ]; then
      echo "Error: Instance parameter missing."
      exit 1
    fi

    IFS='-' read -r app beta betapass <<< "$instance"

    if [ -z "$app" ]; then
      echo "Error: App ID missing."
      exit 1
    fi

    dir="/var/lib/steam-app-$instance"
    
    cmds=(
      "+force_install_dir" "$dir"
      "+login" "anonymous"
      "+app_update" "$app" "validate"
    )

    if [ -n "$beta" ]; then
      cmds+=("-beta" "$beta")
      if [ -n "$betapass" ]; then
        cmds+=("-betapassword" "$betapass")
      fi
    fi

    cmds+=("+quit")

    ${pkgs.steamcmd}/bin/steamcmd "''${cmds[@]}"
  '';

  # Script to expand SOPS environment variables and launch the binary
  valheim-runner = pkgs.writeShellScript "valheim-runner" ''
    exec ${pkgs.steam.run}/bin/steam-run /var/lib/steam-app-${steam-app}/valheim_server.x86_64 \
      -nographics \
      -batchmode \
      -savedir /var/lib/valheim/save \
      -name "$VALHEIM_NAME" \
      -ip 0.0.0.0 \
      -port 2456 \
      -world "$VALHEIM_WORLD" \
      -password "$VALHEIM_PASSWORD" \
      -public 1 \
      -backups 4
  '';
in
{
  # ---------------------------------------------------------------------------
  # SOPS Secrets Configuration
  # ---------------------------------------------------------------------------
  sops.secrets.valheim_env = {
    owner = "valheim";
    group = "valheim";
  };

  # ---------------------------------------------------------------------------
  # User & Group Configuration
  # ---------------------------------------------------------------------------
  users.users.valheim = {
    isSystemUser = true;
    home = "/var/lib/valheim";
    createHome = true;
    homeMode = "750";
    group = "valheim";
  };
  users.groups.valheim = {};

  networking.firewall.allowedUDPPorts = [ 2456 2457 2458 ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 2456; to = 2458; }
  ];

  # ---------------------------------------------------------------------------
  # Systemd Services
  # ---------------------------------------------------------------------------
  
  # 1. Parameterized Steam Downloader Service
  systemd.services."steam@" = {
    unitConfig = {
      StopWhenUnneeded = true;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${steamcmd-downloader} %i";
      PrivateTmp = true;
      Restart = "on-failure";
      RestartSec = "10s";
      StateDirectory = "steam-app-%i";
      StateDirectoryMode = "0755";
      TimeoutStartSec = 3600;
      User = "valheim";
      Group = "valheim";
      WorkingDirectory = "/var/lib/valheim";
    };
  };

  # 2. Valheim Server Service
  systemd.services.valheim = {
    wantedBy = [ "multi-user.target" ];

    requires = [ "steam@${steam-app}.service" ];
    after = [ "steam@${steam-app}.service" ];

    serviceConfig = {
      # Load decrypted secret variables from SOPS into environment
      EnvironmentFile = valheim_env;

      # Execute the dedicated script runner directly
      ExecStart = "${valheim-runner}";
      Nice = "-5";
      PrivateTmp = true;
      Restart = "on-failure";
      RestartSec = "10s";
      User = "valheim";
      Group = "valheim";
      WorkingDirectory = "/var/lib/steam-app-${steam-app}";
    };
    
    environment = {
      LD_LIBRARY_PATH = "./linux64";
      SteamAppId = "892970";
    };
  };
}