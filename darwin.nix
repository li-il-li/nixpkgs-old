{ config, lib, pkgs, ... }:
# Yabai v4.0.1 not in nixpkgs
# https://discourse.nixos.org/t/nixpkgs-aarch64-darwin-build-m1-uses-wrong-old-clang-how-to-fix/18368/2
let
  yabai = let
    replace = {
      "aarch64-darwin" = "--replace '-arch x86_64' ''";
      "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
    }.${pkgs.stdenv.system};
  in pkgs.yabai.overrideAttrs(
    o: rec {
      version = "4.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "koekeishiya";
        repo = "yabai";
        rev = "v${version}";
        sha256 = "sha256-H1zMg+/VYaijuSDUpO6RAs/KLAAZNxhkfIC6CHk/xoI=";
      };
      postPatch = ''
        substituteInPlace makefile ${replace};
      '';
      buildPhase = ''
        PATH=/usr/bin:/bin /usr/bin/make install
      '';
    }
  );
in
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

  programs.nix-index.enable = true;

  # Networking
  # DNS Quad9
  #networking.dns = [
  #  "9.9.9.9"
  #  "149.112.112.112"
  #  "2620:FE::FE"
  #];

  services = {
    # Make sure the nix daemon always runs
    nix-daemon.enable = true;
    activate-system.enable = true;

    # Yabai window manager
    yabai = {
      enable = true;
      package = yabai;
      enableScriptingAddition = true;
      config = {
        # global settings
        mouse_follows_focus = "off";
        focus_follows_mouse = "autoraise";
        window_origin_display = "default";
        window_placement    = "second_child";
        window_shadow = "off";
        window_opacity      = "off";
        window_opacity_duration = 0.0;
        active_window_opacity = 1.0;
        normal_window_opacity = 0.95;
        window_border = "off";
        window_border_width = 1;
        active_window_border_color = "#ECF408";
        normal_window_border_color = "0xff555555";
        insert_feedback_color = "0xffd75f5f";
        split_ratio = 0.5;
        auto_balance = "off";
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";

        # general space settings
        layout = "bsp";
        top_padding         = 12;
        bottom_padding      = 12;
        left_padding        = 12;
        right_padding       = 12;
        window_gap          = 12;
      };
      extraConfig = ''
        # float rules
        yabai -m rule --add app="^Finder$" sticky=on layer=above manage=off
        yabai -m rule --add app="^System Preferences$" sticky=on layer=above manage=off
        yabai -m rule --add app="^Telegram$" sticky=on layer=above manage=off
        yabai -m rule --add app="^Spotify$" sticky=on layer=above manage=off
      '';
    };

    # skhd -> Yabai shortcuts
    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = ''
        # Navigation
        alt - h : yabai -m window --focus west
        alt - j : yabai -m window --focus south
        alt - k : yabai -m window --focus north
        alt - l : yabai -m window --focus east
        
        # Moving windows
        shift + alt - h : yabai -m window --warp west
        shift + alt - j : yabai -m window --warp south
        shift + alt - k : yabai -m window --warp north
        shift + alt - l : yabai -m window --warp east
        
        # Move focus container to workspace
        shift + alt - m : yabai -m window --space last; yabai -m space --focus last
        shift + alt - p : yabai -m window --space prev; yabai -m space --focus prev
        shift + alt - n : yabai -m window --space next; yabai -m space --focus next
        shift + alt - 1 : yabai -m window --space 1; yabai -m space --focus 1
        shift + alt - 2 : yabai -m window --space 2; yabai -m space --focus 2
        shift + alt - 3 : yabai -m window --space 3; yabai -m space --focus 3
        shift + alt - 4 : yabai -m window --space 4; yabai -m space --focus 4
        
        # Resize windows
        lctrl + alt - h : yabai -m window --resize left:-50:0; \
                          yabai -m window --resize right:-50:0
        lctrl + alt - j : yabai -m window --resize bottom:0:50; \
                          yabai -m window --resize top:0:50
        lctrl + alt - k : yabai -m window --resize top:0:-50; \
                          yabai -m window --resize bottom:0:-50
        lctrl + alt - l : yabai -m window --resize right:50:0; \
                          yabai -m window --resize left:50:0
        
        # Equalize size of windows
        lctrl + alt - e : yabai -m space --balance
        
        # Enable / Disable gaps in current workspace
        lctrl + alt - g : yabai -m space --toggle padding; yabai -m space --toggle gap
        
        # Rotate windows clockwise and anticlockwise
        alt - r         : yabai -m space --rotate 270
        shift + alt - r : yabai -m space --rotate 90
        
        # Rotate on X and Y Axis
        shift + alt - x : yabai -m space --mirror x-axis
        shift + alt - y : yabai -m space --mirror y-axis
        
        # Set insertion point for focused container
        shift + lctrl + alt - h : yabai -m window --insert west
        shift + lctrl + alt - j : yabai -m window --insert south
        shift + lctrl + alt - k : yabai -m window --insert north
        shift + lctrl + alt - l : yabai -m window --insert east
        
        # Float / Unfloat window
        shift + alt - space : \
            yabai -m window --toggle float; \
            yabai -m window --toggle border
        
        # Make window native fullscreen
        alt - f         : yabai -m window --toggle zoom-fullscreen
        shift + alt - f : yabai -m window --toggle native-fullscreen
      '';
    };

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
  fonts.fonts = [ pkgs.nerdfonts ];


  system = {
    stateVersion = 4;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };
    };
  };

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  environment = {
    systemPackages = with pkgs; [
      alacritty 
    ];
    variables = {
      TERMINFO_DIRS = "${pkgs.alacritty.terminfo.outPath}/share/terminfo";
    };
  };
}
