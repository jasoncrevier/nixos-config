{ config, pkgs, ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        "office" = { id = "UQ5JITA-OXCRVTH-ZASHRVT-7L7MOQX-UO6VYI2-CDTIQLD-VYKUOMI-QMMPDQP"; };
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