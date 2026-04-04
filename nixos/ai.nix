{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = (pkgs.callPackage ../pkgs/ollama.nix {});
  };
  services.open-webui = {
    package = pkgs.open-webui;
    enable = true;
    host = "0.0.0.0";
    port = 8083;
  };
}
