{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    catppuccin.url = "github:catppuccin/nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, catppuccin, musnix, vscode-server, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";

      nixpkgs-config = {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-hm = import nixpkgs nixpkgs-config;
    in
    {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
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
              nixpkgs.config.allowUnfree = true;
            }
            musnix.nixosModules.musnix
            catppuccin.nixosModules.catppuccin
            ./nixos/device-configs/office-configuration.nix
          ];
        };

        nix-server = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
            {
              nixpkgs.config.allowUnfree = true;
              services.vscode-server.enable = true;
            }
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
