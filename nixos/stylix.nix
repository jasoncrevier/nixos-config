{ pkgs, lib, options, ... }: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";

    targets = lib.mkMerge [
      (lib.optionalAttrs (options.stylix.targets ? kmscon) { kmscon.enable = false; })
      (lib.optionalAttrs (options.stylix.targets ? plymouth) { plymouth.enable = false; })
    ];

    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Mono";
      };
      sansSerif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Sans";
      };
      serif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
      };
    };
  };
}
