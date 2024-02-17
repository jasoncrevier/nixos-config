{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
  gradience
  gnome3.gnome-tweaks
  tilix
  gnomeExtensions.just-perfection
  gnomeExtensions.gsnap
  ];

dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "just-perfection-desktop@just-perfection"
        "gSnap@micahosborne"
      ];
    };
    "org/gnome/interface" = {
      icon-theme = "Papirus-Dark";
      gtk-theme = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      clock-format = "12h";
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
  };
}