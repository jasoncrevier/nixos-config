# Offload builds to the home server

{ ... }:

{
  nix = {
    distributedBuilds = true;
    # nix-server fetches build inputs from the binary caches itself,
    # instead of this machine uploading them over SSH
    settings.builders-use-substitutes = true;
    buildMachines = [
      {
        hostName = "nix-server";
        system = "x86_64-linux";
        sshUser = "jason";
        # Root's dedicated key, created once per machine with:
        #   sudo ssh-keygen -t ed25519 -N '' -f /etc/nix/builder_ed25519
        # Its public key goes in nix-server's authorizedKeys (nix-server-configuration.nix)
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };
}
