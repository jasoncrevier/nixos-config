{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    chromium
    (pkgs.feishin.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/feishin --add-flags "--ozone-platform=x11"
      '';
    }))
    heynote
    kdePackages.kasts
    micro
    obsidian
    onlyoffice-desktopeditors
    tutanota-desktop
    vlc
  ];
}
