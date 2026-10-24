{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.ollama-cuda;
  };

  services.open-webui = {
    package = pkgs.open-webui;
    enable = true;
    host = "0.0.0.0";
    port = 8083;
  };

  # Temp fix for build error
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