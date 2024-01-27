{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
    (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  ];

  #~Fish~
  # Run: fish_config theme save "Catppuccin Mocha"
  home.file."/.config/fish/themes/Catppuccin Mocha.theme".source = ./catpuccin-mocha-fish-theme;
  
  #~Gnome/GTK~
  # Pick this theme manually in Gradience
  home.file."/.config/presets/user/catppuccin-mocha.json".source = ./catppuccin-mocha-gradience-theme;
  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
  };
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    #iconTheme.name = "Papirus-Dark";
    #iconTheme.package = pkgs.papirus-icon-theme;
    #theme.name = "Catppuccin-Mocha-Teal-dark";
    #theme.package = pkgs.catppuccin-gtk.override {
    #  accents = [ "lavender" ];
    #  variant = "mocha";
    #};
  };
}