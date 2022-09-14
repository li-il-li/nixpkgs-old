{
  description = "I DONT REALLY KNOW WHAT I AM DOING";
  
  # https://github.com/dustinlyons/nixos-config/blob/main/flake.nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.utils.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.utils.follows = "nixpkgs";
  };

  outputs = { self, darwin, home-manager, nixpkgs, flake-utils, ... }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config = { 
          allowUnfree = true;
          allowBroken = true;
        };
      };

    in {
      darwinConfigurations = {
        staff-net-nw-1634 = darwin.lib.darwinSystem {
          inherit system pkgs;
          modules = [
            ./darwin.nix
            # home-manager module
            home-manager.darwinModules.home-manager
            {
              # home-manager config
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dario = import ./home.nix;            
            }
          ];
          inputs = { inherit darwin home-manager nixpkgs; };
        };
      };

      #homeConfigurations.dario-nix = home-manager.lib.homeManagerConfiguration {
      #  inherit system;
      #  pkgs = nixpkgs.legacyPackages.${system};

      #  # Specify your home configuration modules here, for example,
      #  # the path to your home.nix.
      #  modules = [
      #    ./home.nix
      #  ];
      #};
    };
}
