{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pull the master branch specifically for the yabridge fix
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    catppuccin.url = "github:catppuccin/nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { nixpkgs, nixpkgs-master, home-manager, catppuccin, musnix, vscode-server, ... }@inputs:
    let
      system = "x86_64-linux";

      # Define the overlay to swap yabridge
      yabridge-overlay = final: prev: {
        yabridge = (import nixpkgs-master {
          inherit system;
          config.allowUnfree = true;
        }).yabridge;
      };

      nixpkgs-config = {
        inherit system;
        config.allowUnfree = true;
        overlays = [ yabridge-overlay ];
      };

      pkgs-hm = import nixpkgs nixpkgs-config;
    in
    {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Apply nixpkgs config and overlay via a module to avoid scope issues
            {
              nixpkgs.overlays = [ yabridge-overlay ];
              nixpkgs.config.allowUnfree = true;
            }
            musnix.nixosModules.musnix
            catppuccin.nixosModules.catppuccin
            ./nixos/device-configs/thinkpad-configuration.nix
          ];
        };

        office = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [ yabridge-overlay ];
              nixpkgs.config.allowUnfree = true;
            }
            musnix.nixosModules.musnix
            catppuccin.nixosModules.catppuccin
            ./nixos/device-configs/office-configuration.nix
          ];
        };

        nix-server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            ./nixos/device-configs/nix-server-configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "jason@thinkpad" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          modules = [
            catppuccin.homeModules.catppuccin
            ./home-manager/device-configs/thinkpad-home.nix
          ];
        };

        "jason@office" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          modules = [
            catppuccin.homeModules.catppuccin
            ./home-manager/device-configs/office-home.nix
          ];
        };

        "jason@nix-server" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          modules = [
            ./home-manager/device-configs/nix-server-home.nix
          ];
        };
      };
    };
}