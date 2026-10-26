{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
    set fish_greeting # Disable greeting
    '';
    shellAliases = {
      # Flakes ignore untracked files, so stage everything before building
      update = "git -C ~/nixos-config add -A && nh os switch";
      upgrade = "git -C ~/nixos-config add -A && nh os switch --update";
      flake-repair = "rm -rf ~/.cache/nix && sudo rm -rf /root/.cache/nix && cd ~/nixos-config && git add . && nix flake update --refresh";
    };
  };
}
