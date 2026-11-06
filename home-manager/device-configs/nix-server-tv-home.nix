# The unprivileged user nix-server logs into on the TV (see nix-server-configuration.nix).

{ pkgs, ... }:

let
  steam-bigpicture = pkgs.makeDesktopItem {
    name = "steam-bigpicture";
    desktopName = "Steam Big Picture";
    # -pipewire: on Wayland, Remote Play otherwise falls back to X11 capture and input
    exec = "steam -gamepadui -pipewire";
    icon = "steam";
  };
in

{
  imports = [
    ../games.nix
    ../plasma.nix
    ../theme.nix
  ];

  # Start Steam in Big Picture on login, like a Steam Machine
  xdg.autostart = {
    enable = true;
    entries = [ "${steam-bigpicture}/share/applications/steam-bigpicture.desktop" ];
  };

  programs.plasma = {
    kscreenlocker.lockOnResume = false;

    configFile = {
      kwinrc.Xwayland.Scale = 1.35;
      kcminputrc."Libinput/13364/53311/Keychron M6 Mouse".NaturalScroll = true;
    };
  };
}
