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
  };
}