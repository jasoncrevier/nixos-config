{ ... }:

{
  imports = [
    ../fish.nix
    ../games.nix
    ../git.nix
    ../plasma.nix
    ../theme.nix
    ../vscode.nix
  ];

  programs.plasma = {
    kscreenlocker.lockOnResume = false;

    configFile = {
      kwinrc.Xwayland.Scale = 1.35;
      kcminputrc."Libinput/13364/53311/Keychron M6 Mouse".NaturalScroll = true;
    };
  };
}
