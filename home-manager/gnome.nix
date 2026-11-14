{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.just-perfection
    gnomeExtensions.pop-shell
    gnomeExtensions.user-themes
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "just-perfection-desktop@just-perfection"
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "element-desktop.desktop"
        "firefox.desktop"
        "code.desktop"
        "heynote.desktop"
      ];
      # Empty layout = app grid sorts alphabetically
      app-picker-layout = with lib.gvariant;
        mkEmptyArray (type.arrayOf (type.dictionaryEntryOf type.string type.variant));
    };
    "org/gnome/desktop/app-folders" = {
      folder-children = [ ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-format = "12h";
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
      panel-size = 28;
    };
    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
    # The GNOME shell theme is set by Stylix ("org/gnome/shell/extensions/user-theme").

    #Tilix
    "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      background-transparency-percent = 10;
    };
    "com/gexperts/Tilix" = {
      terminal-title-show-when-single = false;
      window-style = "disable-csd-hide-toolbar";
    };
  };
}
