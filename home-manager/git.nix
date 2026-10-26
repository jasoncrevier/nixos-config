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
  };

  # gh handles credentials for github.com only; other hosts prompt as usual
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
