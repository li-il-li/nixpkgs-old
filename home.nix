{ config, pkgs, lib, ... }:

let
  common-programs = import ./programs.nix { pkgs = pkgs; };
in {
  useGlobalPkgs = true;
  users.dario-nix = { pkgs, lib, ... }: {
    home.enableNixpkgsReleaseCheck = false;
    home.packages = pkgs.callPackage ./packages.nix {};
    programs = common-programs // {};
  };
}
