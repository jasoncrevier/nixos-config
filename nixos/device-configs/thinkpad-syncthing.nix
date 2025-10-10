{ config, pkgs, ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        "office" = { id = "UQ5JITA-OXCRVTH-ZASHRVT-7L7MOQX-UO6VYI2-CDTIQLD-VYKUOMI-QMMPDQP"; };
        "tower" = { id = "QMSNAMC-4WPXC3P-SGVM42Z-IT3E3TD-DTMXTIN-QCX42SW-PI4IEWB-TDWXYQU"; };
      };
      folders = {
        "home_dot_BitwigStudio" = {
          path = "/home/jason/.BitwigStudio";
          devices = [ "office" "tower" ];
        };
        "home_Bitwig_Studio" = {
          path = "/home/jason/Bitwig Studio";
          devices = [ "office" "tower" ];
        };
      };
    };
  };
}