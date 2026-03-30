{ config, pkgs, ... }:

let
  ntfyTokenFile = config.sops.secrets.ntfy_token.path;

  obsidianUri = "obsidian://advanced-uri?vault=Journal&commandname=Mood%20Tracker:%20Open%20Tracker";

  thoughtRecordScript = pkgs.writeShellApplication {
    name = "send-mood-tracker-notification";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      TOKEN=$(cat "${ntfyTokenFile}")
      
      curl \
        -H "Tags: performing_arts" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Title: How are you feeling?" \
        -H "Click: ${obsidianUri}" \
        -d "Tap to open Obsidian." \
        https://ntfy.nullspace.lol/misc
    '';
  };
in
{
  sops.secrets.ntfy_token.owner = "jason";

  systemd.services.obsidian-mood-notifier = {
    description = "Send daily ntfy notification for tracking mood";
    serviceConfig = {
      Type = "oneshot";
      User = "jason";
      ExecStart = "${thoughtRecordScript}/bin/send-mood-tracker-notification";
    };
  };

  systemd.timers.obsidian-mood-notifier = {
    description = "Run three times daily at random intervals (9-12, 12-3, 3-6)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = [ "09:00:00" "12:00:00" "15:00:00" ];
      RandomizedDelaySec = "10800"; # 3 hours
      # Ensure it runs if the machine was off at 9am
      Persistent = true;
    };
  };
}