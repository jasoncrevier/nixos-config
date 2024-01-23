{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
    set fish_greeting # Disable greeting
    '';
    shellAliases = {
      update = "cd ~/nixos-config && sudo nix flake update && sudo nixos-rebuild switch --flake './' && home-manager switch --flake './'";
      home-update = "cd ~/nixos-config && home-manager switch --flake './'";
    };
  };
}
