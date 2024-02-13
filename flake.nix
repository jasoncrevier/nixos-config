{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    catppuccin-vsc.url = "github:catppuccin/vscode";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { nixpkgs, home-manager, catppuccin-vsc, musnix, vscode-server, ... }:

  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [catppuccin-vsc.overlays.default];
      config.allowUnfree = true;
      # Workaround to get Obsidian working until it's updated. Not a good idea to have this.
      config.permittedInsecurePackages = [ "electron-25.9.0" ]; 
    };
  in
  {
    nixosConfigurations = {
      thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          musnix.nixosModules.musnix
          ./nixos/thinkpad-configuration.nix
        ];
      };
      surface = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          musnix.nixosModules.musnix
          ./nixos/surface-configuration.nix
        ];
      };
      office = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          musnix.nixosModules.musnix
          ./nixos/office-configuration.nix
        ];
      };
      nixos-server = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          ./nixos/server-configuration.nix
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
          ./home-manager/thinkpad-home.nix
        ];
      };
      "jason@surface" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/surface-home.nix
        ];
      };
      "jason@office" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/office-home.nix
        ];
      };
      "jason@nixos-server" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/server-home.nix
        ];
      };
    };
  };
}
