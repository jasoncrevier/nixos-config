{ config, pkgs, ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        "thinkpad" = { id = "HO7DLPQ-6OETWCK-VNR2AIG-YT3O4GN-R4SOQ7D-LG7FBX5-OXDXUQG-NGL4RAB"; };
      };
      folders = {
        "home_dot_BitwigStudio" = {
          path = "/home/jason/.BitwigStudio";
          devices = [ "thinkpad" ];
        };
        "home_Bitwig_Studio" = {
          path = "/home/jason/Bitwig Studio";
          devices = [ "thinkpad" ];
        };
      };
    };
  };
}