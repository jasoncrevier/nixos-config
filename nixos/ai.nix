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
    openFirewall = true;
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8083;
    openFirewall = true;

    # Temp fix: 0.12.3 imports a function that mcp 2.x renamed, so it crashes on
    # startup. Applies upstream's fix (open-webui commit 8151826) until nixpkgs updates.
    package = pkgs.open-webui.overridePythonAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/open-webui/open-webui/commit/8151826483163877cec837b35ba7c1affdd1fb5a.patch";
          includes = [ "backend/open_webui/utils/mcp/client.py" ];
          hash = "sha256-/1Oo60GaQ6gek/zJdBS9EQxAqpn4V1+nK+TiXPwizGc=";
        })
      ];
    });
  };

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
  warnings =
    lib.optional (!(pkgs.python3Packages.posthog.meta.broken or false))
      "nixos/ai.nix: posthog is no longer marked broken in nixpkgs. The posthog workaround can probably be removed."
    ++
      lib.optional (pkgs.open-webui.version != "0.12.3")
        "nixos/ai.nix: open-webui is no longer 0.12.3 in nixpkgs. The mcp import patch can probably be removed.";

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
