{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kosync = {
      url = "git+https://codeberg.org/cmooon/kosync";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      home-manager,
      catppuccin,
      musnix,
      vscode-server,
      sops-nix,
      stylix,
      kosync,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # For the flake's own outputs (packages, dev shells, formatter)
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ inputs.nix-index-database.nixosModules.nix-index ] ++ modules;
          specialArgs = { inherit inputs; };
        };

      vscodeServerModules = [
        (import (inputs.vscode-server + "/modules/vscode-server"))
        { services.vscode-server.enable = true; }
      ];

      theme-modules = [
        catppuccin.nixosModules.catppuccin
        stylix.nixosModules.stylix
        ./nixos/stylix.nix
      ];

      workstation-modules = [
        musnix.nixosModules.musnix
      ]
      ++ theme-modules;

      mkHome =
        {
          name,
          shared ? [ ],
        }:
        [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs; };
              sharedModules = [ { home.stateVersion = "24.05"; } ] ++ shared;
              users.jason = ./home-manager/device-configs + "/${name}-home.nix";
            };
          }
        ];

      themed-home-modules = [
        catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
      ];

      hostConfig = name: ./nixos/device-configs + "/${name}-configuration.nix";
    in
    {
      # nix build .#amplitude
      packages.${system} = {
        amplitude = pkgs.callPackage ./pkgs/amplitude/default.nix { };
        bitwig-studio6 = pkgs.callPackage ./pkgs/bitwig-studio6.nix { };
      };

      # nix develop .#patch-vst
      devShells.${system}.patch-vst = import ./misc/patch-vst.nix { inherit pkgs; };

      # nix fmt (formats every .nix file in the repo)
      formatter.${system} = pkgs.nixfmt-tree;

      nixosConfigurations = {
        thinkpad = mkSystem (
          workstation-modules
          ++ [
            (hostConfig "thinkpad")
            nixos-hardware.nixosModules.lenovo-thinkpad
          ]
          ++ mkHome {
            name = "thinkpad";
            shared = themed-home-modules;
          }
        );

        surface = mkSystem (
          workstation-modules
          ++ [
            (hostConfig "surface")
            nixos-hardware.nixosModules.microsoft-surface-common
          ]
          ++ mkHome {
            name = "surface";
            shared = themed-home-modules;
          }
        );

        office = mkSystem (
          workstation-modules
          ++ [ (hostConfig "office") ]
          ++ mkHome {
            name = "office";
            shared = themed-home-modules;
          }
        );

        nix-server = mkSystem (
          [
            sops-nix.nixosModules.sops
          ]
          ++ theme-modules
          ++ vscodeServerModules
          ++ [ (hostConfig "nix-server") ]
          ++ mkHome {
            name = "nix-server";
            shared = themed-home-modules;
          }
        );

        grunt = mkSystem (
          [
            sops-nix.nixosModules.sops
            catppuccin.nixosModules.catppuccin
          ]
          ++ vscodeServerModules
          ++ [
            kosync.nixosModules.${system}.default
            (hostConfig "grunt")
          ]
          ++ mkHome { name = "grunt"; }
        );
      };
    };
}
