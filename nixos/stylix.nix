{ pkgs, lib, inputs, ... }: {
  stylix = {
    enable = true;
    image = lib.mkDefault ../wallpaper.png;
    base16Scheme = "${inputs.tinted-theming}/base24/catppuccin-mocha.yaml";
    polarity = "dark";

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
        applications = 12;
      };
    };
  };
}
