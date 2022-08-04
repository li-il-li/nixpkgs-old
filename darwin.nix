{ config, pkgs, nixpkgs, ... }:
{
  # Its me
  users.users.dario = {
    name = "dario";
    home = "/Users/dario";
    isHidden = false;
    shell = pkgs.zsh;
  };

  nix = {
    trustedUsers = [ "@admin" "dario" ];
    package = pkgs.nixUnstable;
    gc.user = "root";
    # Highly recommend adding these to save keystrokes
    # at the command line
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services = {
    # Make sure the nix daemon always runs
    nix-daemon.enable = true;
    activate-system.enable = true;

    # Yabai window manager
    #yabai = {
    #  enable = true;
    #  config = {
    #    focus_follows_mouse = "autoraise";
    #    mouse_follows_focus = "off";
    #    window_placement    = "second_child";
    #    window_opacity      = "off";
    #    top_padding         = 36;
    #    bottom_padding      = 10;
    #    left_padding        = 10;
    #    right_padding       = 10;
    #    window_gap          = 10;
    #  };
    #};

  };

  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  # bash is enabled by default

  # GPG
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;

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
