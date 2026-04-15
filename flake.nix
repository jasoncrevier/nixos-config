{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, catppuccin, musnix, vscode-server, sops-nix, stylix, ... }@inputs:
    let
      system = "x86_64-linux";

      nixpkgs-config = {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-hm = import nixpkgs nixpkgs-config;

      common-home-modules = [
        catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.stylix.homeModules.stylix
        ./nixos/stylix.nix
      ];

      unfree-module = { nixpkgs.config.allowUnfree = true; };

      common-modules = [
        unfree-module
        musnix.nixosModules.musnix
        catppuccin.nixosModules.catppuccin
        stylix.nixosModules.stylix
        ./nixos/stylix.nix
      ];
    in
    {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = common-modules ++ [
            ./nixos/device-configs/thinkpad-configuration.nix
          ];
        };

        surface = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = common-modules ++ [
            ./nixos/device-configs/surface-configuration.nix
          ];
        };

        office = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = common-modules ++ [
            ./nixos/device-configs/office-configuration.nix
          ];
        };

        nix-server = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            unfree-module
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
            {
              services.vscode-server.enable = true;
            }
            ./nixos/device-configs/nix-server-configuration.nix
          ];
        };

        grunt = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            unfree-module
            sops-nix.nixosModules.sops
            ./nixos/device-configs/grunt-configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "jason@thinkpad" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          extraSpecialArgs = { inherit inputs; };
          modules = common-home-modules ++ [
            ./home-manager/device-configs/thinkpad-home.nix
          ];
        };

        "jason@surface" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          extraSpecialArgs = { inherit inputs; };
          modules = common-home-modules ++ [
            ./home-manager/device-configs/surface-home.nix
            { stylix.image = ./wallpaper_portrait.png; }
          ];
        };

        "jason@office" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          extraSpecialArgs = { inherit inputs; };
          modules = common-home-modules ++ [
            ./home-manager/device-configs/office-home.nix
          ];
        };

        "jason@nix-server" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          extraSpecialArgs = { inherit inputs; };
          modules = common-home-modules ++ [
            ./home-manager/device-configs/nix-server-home.nix
          ];
        };

        "jason@grunt" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-hm;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home-manager/device-configs/grunt-home.nix ];
        };
      };
    };
}
