{ config, pkgs, ... }:

let
  common-programs = import ./programs.nix { pkgs = pkgs; };
in {

  home = {
    username = "dario-nix"; 
    homeDirectory = "/Users/dario-nix";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "22.05";
    useGlobalPkgs = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs = common-programs // {};
 };
}
