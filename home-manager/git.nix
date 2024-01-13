{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Jason Crevier";
    userEmail = "jason@jasoncrevier.com";
  };
}