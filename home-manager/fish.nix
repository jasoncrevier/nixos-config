{ ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      # Pull first so this machine matches main (and nix-server's cache). --ff-only works over
      # uncommitted changes, and stops without touching anything if the pull would conflict.
      # Flakes ignore untracked files, so mark new ones intent-to-add (changes stay unstaged)
      update = "git -C ~/nixos-config pull --ff-only && git -C ~/nixos-config add -AN && nh os switch ~/nixos-config";
      upgrade = "git -C ~/nixos-config pull --ff-only && git -C ~/nixos-config add -AN && nh os switch --update ~/nixos-config";
      flake-repair = "rm -rf ~/.cache/nix && sudo rm -rf /root/.cache/nix && git -C ~/nixos-config add -AN && nix flake update --refresh --flake ~/nixos-config";
    };
  };
}
