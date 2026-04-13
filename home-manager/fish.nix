{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
    set fish_greeting # Disable greeting
    '';
    shellAliases = {
      update = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake . && nix run home-manager -- switch --flake .";
      upgrade = "cd ~/nixos-config && git add . && nix flake update && sudo nixos-rebuild switch --flake . && nix run home-manager -- switch --flake .";
      home-update = "cd ~/nixos-config && git add . && nix run home-manager -- switch --flake .";
      flake-repair = "rm -rf ~/.cache/nix && sudo rm -rf /root/.cache/nix && cd ~/nixos-config && git add . && nix flake update --refresh";
    };
  };
}
