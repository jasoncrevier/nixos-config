{
  pkgs,
  lib,
  ...
}:

{
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
  };

  # Temp fix for build error. Warns on rebuild once nixpkgs stops marking
  # posthog as broken, so this block (and the warning) can be deleted.
  warnings =
    lib.optional (!(pkgs.python3Packages.posthog.meta.broken or false))
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
