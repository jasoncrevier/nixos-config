{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  gradience
  gnome3.gnome-tweaks
  tilix
  gnomeExtensions.just-perfection
  ];

dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "just-perfection-desktop@just-perfection"
      ];
    };
    "org/gnome/interface" = {
      icon-theme = "Papirus-Dark";
      gtk-theme = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-format = "12h";
      cursor-theme = "Catppuccin-Mocha-Dark-Cursors";
      icon-theme = "Papirus-Dark";
      gtk-theme = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "terminal";
      command = "tilix";
      binding = "<Control><Alt>t";
    };
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = "<Shift><Super>s";
    };
    "org/gnome/shell/extensions/just-perfection" = {
      panel-size = 27;
    };
    "org/gnome/shell/extensions/gsnap" = {
      show-icon = false;
      use-modifer = true;
    };
    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
    "org/gnomeStandard/shell/extensions/user-theme" = {
      name = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
    
    #Tilix
    "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      background-transparency-percent = 10;
    };
    "com/gexperts/Tilix" = {
      terminal-title-show-when-single = false;
      window-style = "disable-csd-hide-toolbar";
    };
  };

  #~Theme~
  gtk = {
    enable = true;
    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;
    theme.name = "Catppuccin-Mocha-Standard-Teal-Dark";
    theme.package = pkgs.catppuccin-gtk.override {
      accents = [ "teal" ];
      variant = "mocha";
    };
  };

  # Pick this theme manually in Gradience
  home.file."/.config/presets/user/catppuccin-mocha.json".source = ./catppuccin-mocha-gradience-theme;
}
