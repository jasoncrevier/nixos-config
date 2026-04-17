{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      credential.helper = "${pkgs.github-cli}/bin/gh auth git-credential";
      user = {
        name = "Jason Crevier";
        email = "jason@jasoncrevier.com";
      };
    };
    signing = {
      format = null;
    };
  };
}
