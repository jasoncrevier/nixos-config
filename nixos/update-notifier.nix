# Desktop notification when nix-server's cache has a newer build of this machine than the
# one it's running (see the manifest in binary-cache-server.nix). "Update now" opens a
# terminal and runs the same steps as the update alias.

{ config, pkgs, ... }:

let
  host = config.networking.hostName;
  manifestUrl = "http://nix-server:5001/manifest.json";

  # Same steps as the update alias in fish.nix, plus a pause so the result stays on screen.
  # It's started from the systemd user service, whose PATH has none of the system's programs,
  # so use the login PATH: sudo's setuid wrapper first, then git, nh and nix.
  apply = pkgs.writeShellScript "fleet-update-apply" ''
    export PATH="/run/wrappers/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

    git -C ~/nixos-config pull --ff-only \
      && git -C ~/nixos-config add -AN \
      && nh os switch ~/nixos-config
    echo
    read -rp "Press Enter to close. "
  '';

  terminal =
    if config.services.desktopManager.plasma6.enable then
      "${pkgs.kdePackages.konsole}/bin/konsole -e ${apply}"
    else
      "${pkgs.tilix}/bin/tilix -e ${apply}";

  # notify-send --action blocks until the notification is clicked or closed (on Plasma a
  # notification that moves to the history never counts as closed), so it runs in its own
  # transient unit. Inside the check it kept the oneshot 'activating' and the timer stopped.
  prompt = pkgs.writeShellScript "fleet-update-prompt" ''
    choice=$(${pkgs.libnotify}/bin/notify-send --app-name=NixOS --icon=system-software-update \
      --action=update="Update now" \
      "Update ready" "nix-server has a new build for ${host}.") || exit 0
    if [ "$choice" = update ]; then
      ${terminal}
    fi
  '';

  check = pkgs.writeShellApplication {
    name = "fleet-update-check";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
      pkgs.systemd
    ];
    text = ''
      # nix-server off or Tailscale down: try again next time
      manifest=$(curl --fail --silent --max-time 5 "${manifestUrl}") || exit 0
      want=$(jq -r --arg h "${host}" '.hosts[$h] // empty' <<< "$manifest")
      [ -n "$want" ] || exit 0
      [ "$want" = "$(readlink /run/current-system)" ] && exit 0

      # One notification per new build. Without this, a machine with uncommitted changes
      # (which never matches main) would be nagged every time the timer runs.
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/fleet-update-notified"
      mkdir -p "$(dirname "$state")"
      [ "$(cat "$state" 2>/dev/null)" = "$want" ] && exit 0
      echo "$want" > "$state"

      # One unit per build. An older prompt is left alone: it may be running an update
      # the user started from it, and its button still updates to the current main.
      systemd-run --user --collect --quiet \
        --unit="fleet-update-prompt-$(basename "$want" | cut -c1-12)" ${prompt} || true
    '';
  };
in
{
  systemd.user.services.fleet-update-check = {
    description = "Check nix-server's cache for a newer build of this machine";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${check}/bin/fleet-update-check";
    };
  };

  systemd.user.timers.fleet-update-check = {
    description = "Check for a newer build a little after login, then every few hours";
    wantedBy = [ "graphical-session.target" ];
    timerConfig = {
      OnActiveSec = "2min";
      OnUnitActiveSec = "4h";
    };
  };
}
