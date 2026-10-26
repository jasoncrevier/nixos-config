# ntfy alerts when a listed systemd service fails, or when smartd sees a disk problem.
# Each host lists its services in failureAlerts.services.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.failureAlerts;
  ntfyTokenFile = config.sops.secrets.ntfy_token.path;
  host = config.networking.hostName;
  topicUrl = "https://ntfy.nullspace.lol/${cfg.topic}";

  # Called by notify-failure@<unit>.service with the failed unit's name; sends its last log lines
  notifyFailure = pkgs.writeShellApplication {
    name = "notify-failure";
    runtimeInputs = [
      pkgs.curl
      pkgs.systemd
    ];
    text = ''
      UNIT="$1"
      TOKEN=$(cat "${ntfyTokenFile}")

      journalctl --unit "$UNIT" --lines 15 --no-pager --output cat \
        | curl --fail --silent --show-error \
            -H "Authorization: Bearer $TOKEN" \
            -H "Title: ${host}: $UNIT failed" \
            -H "Tags: rotating_light" \
            -H "Priority: high" \
            --data-binary @- \
            ${topicUrl}
    '';
  };

  # smartd only knows how to send mail, so this stands in for sendmail. smartd's
  # SMARTD_* variables are inherited, so the message comes from those instead of stdin.
  smartdToNtfy = pkgs.writeShellApplication {
    name = "smartd-to-ntfy";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      cat > /dev/null
      TOKEN=$(cat "${ntfyTokenFile}")

      curl --fail --silent --show-error \
        -H "Authorization: Bearer $TOKEN" \
        -H "Title: ${host}: disk problem on ''${SMARTD_DEVICESTRING:-unknown disk}" \
        -H "Tags: floppy_disk" \
        -H "Priority: high" \
        -d "''${SMARTD_MESSAGE:-smartd reported a problem (no details)}" \
        ${topicUrl}
    '';
  };
in
{
  options.failureAlerts = {
    services = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "valheim" ];
      description = "systemd services (without .service) that send an ntfy alert when they fail.";
    };

    topic = lib.mkOption {
      type = lib.types.str;
      default = "alerts";
      description = "ntfy topic on ntfy.nullspace.lol; the ntfy_token must be allowed to publish to it.";
    };
  };

  config = {
    sops.secrets.ntfy_token = { };

    systemd.services = {
      "notify-failure@" = {
        description = "Send an ntfy alert that %i failed";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${notifyFailure}/bin/notify-failure %i";
        };
      };
    }
    // lib.genAttrs cfg.services (_: {
      onFailure = [ "notify-failure@%n.service" ];
      # systemd's default (5 starts in 10s) never trips for services with a long RestartSec,
      # so a crash loop would never reach "failed". 5 starts in 10 minutes catches those too.
      startLimitIntervalSec = lib.mkDefault 600;
      startLimitBurst = lib.mkDefault 5;
    });

    # Alongside wall, which smartd already uses
    services.smartd.notifications.mail = {
      enable = true;
      mailer = "${smartdToNtfy}/bin/smartd-to-ntfy";
    };
  };
}
