{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.ollama-cuda;
  };
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8083;
  };
}
