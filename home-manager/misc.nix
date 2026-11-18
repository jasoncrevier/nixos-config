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
    #onlyoffice-desktopeditors
    tutanota-desktop
    vlc
  ];

  # Claude Desktop (installed in nixos/workstation.nix) reads extra Electron flags from here.
  # Same colour fix as VS Code: stay on Wayland but skip Chromium's colour management.
  xdg.configFile."claude-desktop-flags.conf".text = ''
    --disable-features=WaylandWpColorManagerV1
  '';
}
