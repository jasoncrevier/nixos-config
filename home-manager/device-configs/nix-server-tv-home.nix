# The unprivileged user nix-server logs into on the TV (see nix-server-configuration.nix).

{
  inputs,
  config,
  pkgs,
  ...
}:

let
  steam-bigpicture = pkgs.makeDesktopItem {
    name = "steam-bigpicture";
    desktopName = "Steam Big Picture";
    # -pipewire: on Wayland, Remote Play otherwise falls back to X11 capture and input
    exec = "steam -gamepadui -pipewire";
    icon = "steam";
    # Puts it in Bigscreen's Games row
    categories = [ "Game" ];
  };

  # KWin script: close every app window, leaving the Bigscreen shell itself
  closeAppWindows = pkgs.writeText "tv-standby-close-windows.js" ''
    for (const w of workspace.windowList()) {
      if (w.normalWindow && w.resourceClass !== "plasmashell") {
        w.closeWindow();
      }
    }
  '';

  # The remote's Power button, like a Chromecast going to standby: stop whatever is
  # playing, back to the home screen, then cut the display signal so the TV does its
  # no-signal screensaver and auto-off. The PC keeps running; any button wakes it.
  tv-standby = pkgs.writeShellApplication {
    name = "tv-standby";
    runtimeInputs = with pkgs; [
      coreutils
      procps
      kdePackages.qttools # qdbus
      kdePackages.libkscreen # kscreen-doctor
    ];
    text = ''
      # Closing Big Picture's window only drops Steam back to its desktop window,
      # so shut Steam down properly (this also quits a running game)
      if pgrep -u "$USER" -x steam >/dev/null; then
        steam -shutdown || true
        for _ in $(seq 30); do
          pgrep -u "$USER" -x steam >/dev/null || break
          sleep 1
        done
      fi

      qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript tv-standby >/dev/null || true
      id=$(qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript ${closeAppWindows} tv-standby)
      qdbus org.kde.KWin "/Scripting/Script$id" org.kde.kwin.Script.run
      qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript tv-standby >/dev/null

      # Give apps a moment to close before the screen goes dark
      sleep 2
      kscreen-doctor --dpms off
    '';
  };
in

{
  imports = [
    inputs.battlenet-umu.homeModules.default
    ../games.nix
    ../plasma.nix
    ../theme.nix
  ];

  # The session is Plasma Bigscreen, so its home screen is the launcher and
  # Big Picture is one tile on it rather than autostarting over the top
  home.packages = [
    steam-bigpicture
    pkgs.jellyfin-desktop
    pkgs.vacuum-tube
  ];

  # Battle.net through umu-launcher + Proton-GE, as on office. The prefix is on the
  # games HDD: WoW Forever alone is ~49 GB. Each game gets a tile in Bigscreen's Games row.
  programs.battlenet-umu = {
    enable = true;
    prefix = "/mnt/Games_HDD/battlenet-umu/prefix";
    # Setting games replaces the default list, so Battle.net itself stays in it
    games = [
      { name = "Battle.net"; }
      {
        name = "WoW Forever";
        path = "Program Files (x86)/World of Warcraft/_forever_/Wow.exe";
      }
    ];
  };

  # The flake's desktop entry has no icon; reuse the one Proton extracts into the prefix
  xdg.desktopEntries.battle-net-umu = {
    name = "Battle.net";
    exec = "battle-net-umu";
    icon = "${config.programs.battlenet-umu.prefix}/drive_c/proton_shortcuts/icons/256x256/apps/1AC2_Battle.net Launcher.0.png";
    categories = [ "Game" ];
    settings.StartupWMClass = "battle.net.exe";
  };

  # Shadows the package's own launcher, which opens the mouse-driven desktop UI,
  # so the one Jellyfin tile opens the remote-friendly TV UI full screen.
  # --platform xcb runs it under XWayland: on Wayland with the NVIDIA driver its
  # embedded mpv video shows as a blank white frame while the audio plays.
  xdg.desktopEntries."org.jellyfin.JellyfinDesktop" = {
    name = "Jellyfin";
    exec = "jellyfin-desktop --fullscreen --tv --platform xcb";
    icon = "org.jellyfin.JellyfinDesktop";
    categories = [
      "AudioVideo"
      "Video"
      "Player"
      "TV"
    ];
    settings.StartupWMClass = "org.jellyfin.JellyfinDesktop";
  };

  programs.plasma = {
    kscreenlocker.lockOnResume = false;

    # The remote's Power button is remapped to Launch (1) (see nix-server-configuration.nix)
    hotkeys.commands.tv-standby = {
      name = "TV standby";
      key = "Launch (1)";
      command = "${tv-standby}/bin/tv-standby";
    };

    configFile = {
      kwinrc.Xwayland.Scale = 1.35;
      kcminputrc."Libinput/13364/53311/Keychron M6 Mouse".NaturalScroll = true;
    };
  };
}
