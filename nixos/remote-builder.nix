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
