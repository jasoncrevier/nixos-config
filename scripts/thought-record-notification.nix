{ config, pkgs, ... }:

let
  ntfyTokenFile = config.sops.secrets.ntfy_token.path;

  obsidianUri = "obsidian://advanced-uri?vault=Journal&filepath=Thought%20records/Untitled&commandname=Templates:%20Insert%20template";

  thoughtRecordScript = pkgs.writeShellApplication {
    name = "send-thought-record-notification";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      TOKEN=$(cat "${ntfyTokenFile}")
      
      curl \
        -H "Tags: notebook" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Title: Any thoughts to record?" \
        -H "Click: ${obsidianUri}" \
        -d "Tap to open Obsidian." \
        https://ntfy.nullspace.lol/misc
    '';
  };
in
{
  sops.secrets.ntfy_token.owner = "jason";

  systemd.services.obsidian-thought-notifier = {
    description = "Send daily ntfy notification for recording thoughts";
    serviceConfig = {
      Type = "oneshot";
      User = "jason";
      ExecStart = "${thoughtRecordScript}/bin/send-thought-record-notification";
    };
  };

  systemd.timers.obsidian-thought-notifier = {
    description = "Run once daily at a random time between 9am and 5pm EST";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Start the window at 09:00:00 US Eastern time
      OnCalendar = "9:00:00";
      # Add an 8-hour random delay (8 hours = 28800 seconds)
      RandomizedDelaySec = "28800";
      # Ensure it runs if the machine was off at 9am
      Persistent = true;
    };
  };
}