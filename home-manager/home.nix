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
  git
  micro
  vscode
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
  inkscape   
  killall
  neofetch
  obsidian
  ollama
  spotify
  tilix
  vlc
  wineWowPackages.staging
  winetricks
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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
  
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  # Don't change this (I think)
  home.stateVersion = "24.05";
}
