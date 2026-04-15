{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jason Crevier";
        email = "jason@jasoncrevier.com";
      };
    };
    signing = {
      format = null;
    };
    extraConfig = {
      credential.helper = "${pkgs.github-cli}/bin/gh auth git-credential";
    };
  };
}
