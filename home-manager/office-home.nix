{ config, pkgs, ... }:

{
  imports =
    [
      ./ai.nix
      ./audio.nix
      ./chat.nix
      ./graphics.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

  home.packages = with pkgs; [
  # Theme
  catppuccin-cursors.mochaDark
  (catppuccin-papirus-folders.override { flavor = "mocha"; accent = "teal"; })
  (catppuccin-gtk.override { accents = [ "teal" ]; variant = "mocha"; })
  # Web
  firefox
  nextcloud-client
  # Misc
  deluge
  fd
  feh 
  killall
  neofetch
  obsidian
  spotify
  vlc
  wineWowPackages.staging
  winetricks
  ];

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
