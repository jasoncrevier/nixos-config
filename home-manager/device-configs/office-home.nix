{ config, pkgs, ... }:

{
  imports = [
    ../3d-printing.nix
    ../arduino.nix
    ../audio.nix
    ../chat.nix
    ../fish.nix
    ../games.nix
    ../git.nix
    ../graphics.nix
    ../misc.nix
    ../plasma.nix
    ../tempopad.nix
    ../theme.nix
    ../video.nix
    ../vscode.nix
    ../web.nix
    ../wine.nix
  ];

  programs.plasma = {
    kwin.effects.wobblyWindows.enable = true;

    # Region screenshot on Meta+Shift+S, same as on GNOME
    shortcuts."services/org.kde.spectacle.desktop".RectangularRegionScreenShot = [
      "Meta+Shift+S"
      "Meta+Shift+Print"
    ];

    configFile = {
      kwinrc.Plugins.kwin4_effect_geometry_changeEnabled = true;
      kwinrc.Effect-overview.BorderActivate = 9; # No hot corner for the overview
      kwinrc.Xwayland.Scale = 1;

      # Ask before running scripts opened from Dolphin, don't confirm moving to trash
      kiorc."Executable scripts".behaviourOnLaunch = "alwaysAsk";
      kiorc.Confirmations.ConfirmTrash = false;
      dolphinrc."Notification Messages".warnAboutRisksBeforeActingAsAdmin = false;

      # Input devices. Trailing spaces are part of the device names.
      kcminputrc."Libinput/13364/53311/Keychron Keychron M6  Keyboard".NaturalScroll = true;
      kcminputrc."Libinput/13364/53311/Keychron Keychron M6 ".NaturalScroll = true;
      kcminputrc."Libinput/1133/50504/Logitech USB Receiver Mouse".PointerAcceleration = "0.000";
      kcminputrc."Libinput/1386/221/Wacom Bamboo Connect Pen".TabletToolRelativeMode = true;
      kcminputrc."Libinput/1386/891/Wacom One by Wacom M Pen" = {
        MapToWorkspace = false;
        TabletToolRelativeMode = false;
      };

      # Chat apps open in the top or bottom half of the portrait monitor.
      # Written as raw keys because this KWin orders rules with "Order",
      # which plasma-manager's window-rules option doesn't write.
      kwinrulesrc =
        let
          halfScreen = position: {
            inherit position;
            positionrule = 3;
            size = "1080,960";
            sizerule = 3;
            wmclassmatch = 1;
          };
        in
        {
          General.Order = "steam,5d5db7da-4e2f-4ff2-8774-91b23c010827,78c37000-8e39-4e75-ba75-c8aaf9920c54,796c357a-9e9d-4389-b24e-f1b5a2ce1ad9,ad4c7066-a9bf-4ce2-938f-1737a0d898c1,444f06f6-d95b-4b48-a559-c74631c2c89b";
          "ad4c7066-a9bf-4ce2-938f-1737a0d898c1" = halfScreen "0,0" // {
            Description = "Settings for Element";
            types = 1;
            wmclass = "Element";
          };
          "444f06f6-d95b-4b48-a559-c74631c2c89b" = halfScreen "0,960" // {
            Description = "Settings for tutanota-desktop";
            wmclass = "tutanota-desktop";
          };
          "5d5db7da-4e2f-4ff2-8774-91b23c010827" = halfScreen "0,960" // {
            Description = "Window settings for info.mumble.Mumble";
            title = "Mumble";
            types = 1;
            wmclass = "mumble info.mumble.Mumble";
            wmclasscomplete = true;
          };
          "78c37000-8e39-4e75-ba75-c8aaf9920c54" = halfScreen "0,960" // {
            Description = "Window settings for Zulip";
            title = "Zulip - PieFed";
            types = 1;
            wmclass = "electron Zulip";
            wmclasscomplete = true;
          };
          "796c357a-9e9d-4389-b24e-f1b5a2ce1ad9" = halfScreen "0,960" // {
            Description = "Discord";
            wmclass = "discord";
          };
        };
    };
  };
}
