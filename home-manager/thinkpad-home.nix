{ config, pkgs, ... }:

{
  imports =
    [
      ./audio.nix
      ./chat.nix
      ./fish.nix
      ./git.nix
      ./gnome-home.nix
      ./graphics.nix
      ./misc.nix
      ./theme.nix
      ./vscode.nix
      ./web.nix
    ];
  home.username = "jason";
  home.homeDirectory = "/home/jason";

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
