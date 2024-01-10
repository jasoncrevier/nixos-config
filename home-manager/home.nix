{ config, pkgs, ... }:

{
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  home.packages = with pkgs; [
  # Audio
  reaper
  mixxx
  yabridge
  yabridgectl
  # Chat
  discord
  element-desktop
  telegram-desktop
  # Development
  micro
  # Graphics
  gimp-with-plugins
  inkscape
  # Theme
  catppuccin-cursors.mochaDark
  (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
  (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  gradience
  # Web
  firefox
  nextcloud-client
  # Misc
  cmatrix
  deluge
  fd
  feh
  gnome3.gnome-tweaks   
  killall
  neofetch
  obsidian
  ollama
  spotify
  tilix
  vlc
  wineWowPackages.staging
  winetricks
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "com.gexperts.Tilix.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
        "obsidian.desktop"
        "org.telegram.desktop.desktop"
        "element-desktop.desktop"
        "discord.desktop"
        "spotify.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    "org/gnome/interface" = {
      icon-theme = "Papirus-Dark";
      gtk-theme = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      text-scaling-factor = 1.2;
      clock-format = "12h";
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Mocha-Standard-Teal-Dark";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "terminal";
      command = "tilix";
      binding = "<Control><Alt>t";
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
  };

  programs.git = {
    enable = true;
    userName = "Jason Crevier";
    userEmail = "jason@jasoncrevier.com";
  };

  programs.nix-index = {
    enable=true;
    enableBashIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      (catppuccin.catppuccin-vsc.override { accent = "teal"; })
      bbenoist.nix
    ];
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jason/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
