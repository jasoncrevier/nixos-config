{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    chromium
    (pkgs.feishin.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/feishin --add-flags "--ozone-platform=x11"
      '';
    }))
    freetube
    heynote
    kdePackages.kasts
    micro
    nicotine-plus
    obsidian
    onlyoffice-desktopeditors
    tutanota-desktop
    vlc
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
