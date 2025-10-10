{ config, pkgs, ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        "thinkpad" = { id = "ZYUMO4O-YCWCXF7-LIH7DDZ-7XDHXVW-A6P4FZD-XQVER3U-QIGAVCO-7V36XQL"; };
        "tower" = { id = "QMSNAMC-4WPXC3P-SGVM42Z-IT3E3TD-DTMXTIN-QCX42SW-PI4IEWB-TDWXYQU"; };
      };
      folders = {
        "home_dot_BitwigStudio" = {
          path = "/home/jason/.BitwigStudio";
          devices = [ "thinkpad" "tower" ];
        };
        "home_Bitwig_Studio" = {
          path = "/home/jason/Bitwig Studio";
          devices = [ "thinkpad" "tower" ];
        };
      };
    };
  };
}