{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
    set fish_greeting # Disable greeting
    '';
    shellAliases = {
      update = "cd ~/nixos-config && sudo nix flake update && sudo nixos-rebuild switch --flake './' && nix run home-manager -- switch --flake './'";
      home-update = "cd ~/nixos-config && nix run home-manager -- switch --flake './'";
    };
  };
}
