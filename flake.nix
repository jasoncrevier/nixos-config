{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    catppuccin.url = "github:catppuccin/nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { nixpkgs, home-manager, catppuccin, musnix, vscode-server, ... }@inputs:

  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations = {
      thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          musnix.nixosModules.musnix
          catppuccin.nixosModules.catppuccin
          ./nixos/device-configs/thinkpad-configuration.nix
        ];
      };

      office = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          musnix.nixosModules.musnix
          catppuccin.nixosModules.catppuccin
          ./nixos/device-configs/office-configuration.nix
        ];
      };

      nixos-server = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          ./nixos/device-configs/server-configuration.nix
          vscode-server.nixosModules.default
          ({config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })
        ];
      };
    };

    homeConfigurations = {
      "jason@thinkpad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          catppuccin.homeModules.catppuccin
          ./home-manager/device-configs/thinkpad-home.nix
        ];
      };

      "jason@office" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          catppuccin.homeModules.catppuccin
          ./home-manager/device-configs/office-home.nix
        ];
      };

      "jason@nixos-server" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/device-configs/server-home.nix
        ];
      };
    };
  };
}
