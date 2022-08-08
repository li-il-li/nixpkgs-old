{ config, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
rec {
  home = rec {
    username = "dario"; 
    homeDirectory = "/Users/dario";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "22.05";
  };

  # Load neovim configuration
  xdg.configFile."nvim/init.lua".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/init.lua";
  xdg.configFile."nvim/colors".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/colors";
  xdg.configFile."nvim/lua".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/lua";

  programs = {
    # scd daemon / smart card
    # https://github.com/NixOS/nixpkgs/issues/155629
    gpg.scdaemonSettings.disable-ccid = true;
    gpg.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # Alacritty
    alacritty = {
      enable = true;
  
      settings = {
       # Window decorations
       #
       # Values for `decorations`:
       #     - full: Borders and title bar
       #     - none: Neither borders nor title bar
       #
       # Values for `decorations` (macOS only):
       #     - transparent: Title bar, transparent background and title bar buttons
       #     - buttonless: Title bar, transparent background and no title bar buttons
        window.decorations = "buttonless";
        window.padding = {
          x = 10;
          y = 10;
        };
        window.dimensions = {
          lines = 30;
          columns = 150;
        };
        key_bindings = [
          {
            key = "K";
            mods = "Control";
            chars = "\\x0c";
          }
          #{
          #  key = "Escape";
          #  mods = "Shift";
          #  mode = "~Search";
          #  action = "ToggleViMode";
          #}
        ];

        font = {
          normal = {
            family = "FiraCode Nerd Font";
          };
          size = 13;
          offset = {
            y = 5;
          };
        };
        # Moonfly Theme
        # https://github.com/bluz71/vim-moonfly-colors/blob/master/terminal_themes/alacritty.yml
        draw_bold_text_with_bright_colors = true;
        colors = {
          # Default colors
          primary = {
            background = "#080808";
            foreground = "#b2b2b2";
            bright_foreground = "#eeeeee";
          };
          # Cursor colors
          cursor = {
            text = "#080808";
            cursor = "#9e9e9e";
          };
          # Selection colors
          selection = {
            text = "#080808";
            background = "#b2ceee";
          };
          # Normal colors
          normal = {
            black = "#323437";
            red = "#ff5454";
            green = "#8cc85f";
            yellow = "#e3c78a";
            blue = "#80a0ff";
            magenta = "#d183e8";
            cyan = "#79dac8";
            white = "#c6c6c6";
          };
          bright = {
            black = "#949494";
            red = "#ff5189";
            green = "#36c692";
            yellow = "#c2c292";
            blue =  "#74b2ff";
            magenta = "#ae81ff";
            cyan = "#85dc85";
            white = "#e4e4e4";
          };
        };
      };
    };

    # Direnv, load and unload environment variables depending on the current directory.
    # https://direnv.net
    # https://rycee.gitlab.io/home-manager/options.html#opt-direnv.enable
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    # Starship (Shell prompt)
    starship = {
      enable = true;
      # Configuration written to ~/.config/starship.toml
      settings = {
        # Disable the blank line at the start of the prompt
        add_newline = false;

        # character = {
        #   success_symbol = "[➜](bold green)";
        #   error_symbol = "[➜](bold red)";
        # };

        # package.disabled = true;

        directory = {
	  truncation_length = 8;
	  truncation_symbol = "…/";
        };
      };
    };

    zsh.enable = true;
    zsh.autocd = false;
    #zsh.cdpath = [ "~/State/Projects/Code/" ];


    # Plugins
    zsh.plugins = [
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
      }
    ];

    #zsh.dirHashes = {
    #  Code = "$HOME/State/Projects/Code";
    #  Config = "$HOME/State/Projects/Code/nixos-config";
    #  Downloads = "$HOME/State/Inbox/Downloads";
    #  Screenshots = "$HOME/State/Inbox/Screenshots";
    #  Wallpaper = "$HOME/State/Resources/Wallpaper";
    #};

    zsh.initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi
      export PATH=$HOME/.npm-packages/bin:$PATH
      export PATH=$NIX_USER_PROFILE_DIR/profile/bin:$PATH
      export PATH=$HOME/bin:$PATH

      # GPG
      export GPG_TTY=$(tty)
      #export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      #gpgconf --launch gpg-agent

      # Openstack
      export OS_AUTH_URL=https://keystone.cloud.switch.ch:5000/v3
      export OS_IDENTITY_API_VERSION=3
      export OS_USERNAME="dario.wirtz@sdsc.ethz.ch"
      export OS_PROJECT_NAME="renku_personal-dario-wirtz"
      export OS_REGION_NAME=ZH
      export OS_PROJECT_DOMAIN_NAME=Default
      export OS_USER_DOMAIN_NAME=Default

      # bat is a better cat
      alias cat=bat

      # Always color ls
      alias ls='ls --color'

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      # Zsh-autocompletion
      # https://nixos.wiki/wiki/Zsh#Zsh-autocomplete_not_working
      # bindkey "''${key[Up]}" up-line-or-search

      # Enable zoxide
      eval "$(zoxide init zsh)"
    '';

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = "Dario Wirtz";
      userEmail = "dario.wirtz@sdsc.ethz.ch";
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = { 
          editor = "vim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;
  };
}
