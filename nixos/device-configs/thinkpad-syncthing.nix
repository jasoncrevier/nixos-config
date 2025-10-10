{ config, pkgs, ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        "office" = { id = "3BUNMEZ-TWPP4MZ-Z2G7BAO-ZY5ZLSX-ENN5YON-AINIIGZ-CG4LHSI-VUESUQ2"; };
      };
      folders = {
        "home_dot_BitwigStudio" = {
          path = "/home/jason/.BitwigStudio";
          devices = [ "office" ];
        };
        "home_Bitwig_Studio" = {
          path = "/home/jason/Bitwig Studio";
          devices = [ "office" ];
        };
      };
    };
  };
}