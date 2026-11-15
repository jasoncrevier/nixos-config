# Windows plugins through yabridge. The Wine prefix (~/.wine) stays per machine, since
# installs and license activations don't survive being synced; this keeps the bridging
# in step and warns about anything from the list below that isn't installed yet.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  programFiles = "${config.home.homeDirectory}/.wine/drive_c/Program Files";

  # Windows plugins every audio machine should have, relative to Program Files.
  # Install missing ones with `wine-plugins <installer.exe>`.
  windowsPlugins = [
    "Common Files/VST3/Annulus.vst3"
    "Common Files/VST3/OTT.vst3"
    "Common Files/VST3/ShaperBox 3.vst3"
    "Common Files/VST3/Sonic Charge/Bitspeek.vst3"
    "Common Files/VST3/Sonic Charge/Synplant.vst3"
  ];
  # No 32-bit plugins (e.g. Delay Lama): nixpkgs' yabridge ships without yabridge-host-32.exe

  # The Wine yabridge runs plugins with (pinned in nixpkgs; newer Wine breaks plugin GUIs).
  # wine.nix's newer Wine stays the default `wine` for everything else.
  wine = pkgs.wineWow64Packages.yabridge;
in
{
  home.packages = [
    pkgs.yabridge
    pkgs.yabridgectl
    (pkgs.writeShellScriptBin "wine-plugins" ''exec ${wine}/bin/wine "$@"'')
  ];

  # Read-only on purpose: change plugin folders or the blacklist here, not with yabridgectl
  xdg.configFile."yabridgectl/config.toml".source =
    (pkgs.formats.toml { }).generate "yabridgectl.toml"
      {
        # yabridgectl otherwise finds yabridge through NIX_PROFILES, which activation doesn't have
        yabridge_home = "${pkgs.yabridge}/lib";
        plugin_dirs = map (dir: "${programFiles}/${dir}") [
          "Common Files/VST2"
          "Common Files/VST3"
          "Common Files/CLAP"
          "Steinberg/VSTPlugins"
        ];
        vst2_location = "centralized";
        no_verify = false;
        blacklist = [ ];
      };

  # Re-bridge after every rebuild, so a yabridge update or a plugin installed since
  # the last sync is picked up, and leftovers from uninstalled plugins are removed
  # Activation runs in the home-manager-jason service, so its output only reaches the journal;
  # problems also go to the desktop as a notification
  home.activation.yabridgeSync = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    yabridgeNotify() {
      DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}" \
        run ${pkgs.libnotify}/bin/notify-send --app-name=yabridge --icon=audio-x-generic "$@" \
        || true
    }

    PATH="${pkgs.yabridge}/bin:${wine}/bin:$PATH" run --quiet \
      ${pkgs.yabridgectl}/bin/yabridgectl sync --prune --no-verify \
      || {
        warnEcho "yabridgectl sync failed; run 'yabridgectl sync' to see why"
        yabridgeNotify "yabridge sync failed" "Run 'yabridgectl sync' to see why."
      }

    missing=()
    for plugin in ${lib.escapeShellArgs windowsPlugins}; do
      if [ ! -e "${programFiles}/$plugin" ]; then
        warnEcho "Windows plugin not installed: $plugin (install it with wine-plugins)"
        missing+=("$(basename "$plugin" .vst3)")
      fi
    done
    if [ ''${#missing[@]} -gt 0 ]; then
      yabridgeNotify "Windows plugins not installed" \
        "$(printf '%s\n' "''${missing[@]}")Install them with wine-plugins."
    fi
  '';
}
