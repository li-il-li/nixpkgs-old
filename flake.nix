{
  description = "Its guuuccciii";
  
  # https://github.com/dustinlyons/nixos-config/blob/main/flake.nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.utils.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, home-manager, nixpkgs }: 
    let
      system = "x86_64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      darwinConfigurations = {
        "darios-MacBook-Pro" = darwin.lib.darwinSystem {
          inherit system;
          modules = [ ./darwin.nix ];
        };
      };

      homeConfigurations.dario-nix = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
