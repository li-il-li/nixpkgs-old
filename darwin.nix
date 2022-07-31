{ pkgs, ... }:
{
  # Its me
  users.users.dario-nix = {
    name = "dario-nix";
    home = "/Users/dario-nix";
    isHidden = false;
    shell = pkgs.zsh;
  };

  nix.trustedUsers = [ "@admin", "dario-nix" ];

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;
  # Installs a version of nix, that dosen't need "experimental-features = nix-command flakes" in /etc/nix/nix.conf
  services.nix-daemon.package = pkgs.nixFlakes;
  
  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  # bash is enabled by default

  # We use Homebrew to install impure software only (Mac Apps)
  homebrew.enable = true;
  homebrew.autoUpdate = true;
  homebrew.cleanup = "uninstall";
  homebrew.brewPrefix = "/opt/homebrew/bin";
  homebrew.casks = pkgs.callPackage ./casks.nix {};

  # Enable fonts dir
  fonts.fontDir.enable = true;

  system = {
    stateVersion = 1;

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
