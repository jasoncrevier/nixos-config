# The unprivileged user nix-server logs into on the TV (see nix-server-configuration.nix).

{ pkgs, ... }:

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
in

{
  imports = [
    ../games.nix
    ../plasma.nix
    ../theme.nix
  ];

  # The session is Plasma Bigscreen, so its home screen is the launcher and
  # Big Picture is one tile on it rather than autostarting over the top
  home.packages = [ steam-bigpicture ];

  programs.plasma = {
    kscreenlocker.lockOnResume = false;

    configFile = {
      kwinrc.Xwayland.Scale = 1.35;
      kcminputrc."Libinput/13364/53311/Keychron M6 Mouse".NaturalScroll = true;
    };
  };
}
