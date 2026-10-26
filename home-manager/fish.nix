{ ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      # Flakes ignore untracked files, so stage everything before building
      update = "git -C ~/nixos-config add -A && nh os switch ~/nixos-config";
      upgrade = "git -C ~/nixos-config add -A && nh os switch --update ~/nixos-config";
      flake-repair = "rm -rf ~/.cache/nix && sudo rm -rf /root/.cache/nix && git -C ~/nixos-config add -A && nix flake update --refresh --flake ~/nixos-config";
    };
  };
}
