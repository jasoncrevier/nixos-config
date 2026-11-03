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
      # nix-server only: update flake.lock and build every host with it, push the lock to main
      # if they all build (see binary-cache-server.nix), then switch to it like any other machine.
      # Also runs weekly on its own; watch a manual run with journalctl -fu fleet-update
      upgrade = "sudo systemctl start fleet-update && update";
      flake-repair = "rm -rf ~/.cache/nix && sudo rm -rf /root/.cache/nix && git -C ~/nixos-config add -AN && nix flake update --refresh --flake ~/nixos-config";
    };
  };
}
