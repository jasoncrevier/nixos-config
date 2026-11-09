{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./backups.nix ];

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

  # Temp fixes warn on rebuild once they're probably no longer needed,
  # so the matching block (and its warning) can be deleted.
  warnings = lib.optional (!(pkgs.python3Packages.posthog.meta.broken or false))
    "nixos/ai.nix: posthog is no longer marked broken in nixpkgs. The posthog workaround can probably be removed.";

  nixpkgs.config.problems.handlers = {
    posthog.broken = "warn";
  };
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          posthog = python-prev.posthog.overridePythonAttrs (old: {
            doCheck = false;
          });
        })
      ];
    })
  ];
}
