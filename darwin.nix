{ config, pkgs, nixpkgs, ... }:
{
  # Its me
  users.users.dario-nix = {
    name = "dario-nix";
    home = "/Users/dario-nix";
    isHidden = false;
    shell = pkgs.zsh;
  };

  nix = {
    trustedUsers = [ "@admin" "dario-nix" ];
    package = pkgs.nixUnstable;
    gc.user = "root";
    # Highly recommend adding these to save keystrokes
    # at the command line
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;
  services.activate-system.enable = true;

  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  # bash is enabled by default

  # We use Homebrew to install impure software only (Mac Apps)
  homebrew.enable = true;
  homebrew.autoUpdate = true;
  homebrew.cleanup = "uninstall";
  homebrew.casks = pkgs.callPackage ./casks.nix {};

  # Enable fonts dir
  fonts.fontDir.enable = true;


  system = {
    stateVersion = 4;

    defaults = {
      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };
    };
  };
}
