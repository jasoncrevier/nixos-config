# ntfy reminders that open Obsidian when tapped

{
  config,
  pkgs,
  lib,
  ...
}:

let
  ntfyTokenFile = config.sops.secrets.ntfy_token.path;

  # A oneshot service that sends one notification, plus the timer that runs it
  mkNtfyNotifier =
    {
      name,
      scriptName,
      description,
      tag,
      title,
      uri,
      timerDescription,
      timerConfig,
    }:
    let
      script = pkgs.writeShellApplication {
        name = scriptName;
        runtimeInputs = [ pkgs.curl ];
        text = ''
          TOKEN=$(cat "${ntfyTokenFile}")

          curl \
            -H "Tags: ${tag}" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Title: ${title}" \
            -H "Click: ${uri}" \
            -d "Tap to open Obsidian." \
            https://ntfy.nullspace.lol/misc
        '';
      };
    in
    {
      systemd.services.${name} = {
        inherit description;
        serviceConfig = {
          Type = "oneshot";
          User = "jason";
          ExecStart = "${script}/bin/${scriptName}";
        };
      };

      systemd.timers.${name} = {
        description = timerDescription;
        wantedBy = [ "timers.target" ];
        timerConfig = timerConfig // {
          # Ensure it runs if the machine was off at the scheduled time
          Persistent = true;
        };
      };
    };
in
lib.mkMerge [
  { sops.secrets.ntfy_token.owner = "jason"; }

  (mkNtfyNotifier {
    name = "obsidian-mood-notifier";
    scriptName = "send-mood-tracker-notification";
    description = "Send daily ntfy notification for tracking mood";
    tag = "performing_arts";
    title = "How are you feeling?";
    uri = "obsidian://advanced-uri?vault=Journal&commandname=QuickAdd:%20Log%20mood";
    timerDescription = "Run three times daily at random intervals (9-12, 12-3, 3-6)";
    timerConfig = {
      OnCalendar = [
        "09:00:00"
        "12:00:00"
        "15:00:00"
      ];
      RandomizedDelaySec = "10800"; # 3 hours
    };
  })

  (mkNtfyNotifier {
    name = "obsidian-thought-notifier";
    scriptName = "send-thought-record-notification";
    description = "Send daily ntfy notification for recording thoughts";
    tag = "notebook";
    title = "Any thoughts to record?";
    uri = "obsidian://advanced-uri?vault=Journal&filepath=Thought%20records/Untitled&commandname=Templates:%20Insert%20template";
    timerDescription = "Run once daily at a random time between 9am and 5pm EST";
    timerConfig = {
      OnCalendar = "9:00:00";
      RandomizedDelaySec = "28800"; # 8 hours
    };
  })
]
