{
  pkgs,
  ...
}:

{
  imports = [ ./backups.nix ];

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.ollama-cuda;
    # Pulled at every start if missing (Karakeep's gemma2:2b and llava were pulled by hand).
    # qwen3:4b: Home Assistant's fallback conversation agent. Needs tool calling for Assist
    # to control devices, which gemma2 lacks; ~3 GB of VRAM on the 1660 Ti next to Whisper.
    loadModels = [ "qwen3:4b" ];
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8083;
  };

  # Tailnet only: Karakeep and Open WebUI reach Ollama on localhost,
  # everything else (including Home Assistant) goes over Tailscale
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    11434 # Ollama
    8083 # Open WebUI
  ];

  # Chats, users and uploads. Ollama's models can be pulled again, so they're left out.
  # DynamicUser: /var/lib/open-webui is a symlink into /var/lib/private.
  backups.paths = [ "/var/lib/private/open-webui" ];
  # Downloaded embedding and Whisper models (~2 GB), fetched again when missing
  backups.exclude = [
    "/var/lib/private/open-webui/hf_home"
    "/var/lib/private/open-webui/transformers_home"
    "/var/lib/private/open-webui/data/cache"
  ];
}
