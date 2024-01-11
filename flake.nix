{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    catppuccin-vsc.url = "github:catppuccin/vscode";
  };

  outputs = { nixpkgs, home-manager, catppuccin-vsc, musnix, ... }:

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
          ./nixos/thinkpad-configuration.nix
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
    };

    homeConfigurations = {
      "jason@thinkpad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/thinkpad-home.nix
        ];
      };
      "jason@office" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/office-home.nix
        ];
      };
    };
  };
}