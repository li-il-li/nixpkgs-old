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
  xdg.configFile."nvim/init_lua.lua".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/init.lua";
  xdg.configFile."nvim/colors".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/colors";
  xdg.configFile."nvim/lua/configs".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/lua/configs";
  xdg.configFile."nvim/lua/core".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/lua/core";
  xdg.configFile."nvim/lua/default_theme".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/lua/default_theme";
  xdg.configFile."nvim/lua/user".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/user";


  programs = {
    # scd daemon / smart card
    # https://github.com/NixOS/nixpkgs/issues/155629
    gpg.scdaemonSettings.disable-ccid = true;
    gpg.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # neovim
    # plugins are installed through nix
    # configuration imperatively
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;

      extraConfig =
      ''
      luafile ~/.config/nvim/init_lua.lua
      '';

      plugins = with pkgs.vimPlugins; [
        plenary-nvim
        packer-nvim
      ];
    };

    # nnn
    nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      bookmarks = {
        d = "~/Downloads";
        s = "~/SDSC";
        n = "~/nixpkgs";
      };
    };

    # tmux
    tmux = {
      enable = true;
      #keyMode = "vi";
      clock24 = true;
      disableConfirmationPrompt = true;
      newSession = true;
      # https://www.reddit.com/r/vim/comments/40257u/delay_on_esc_with_tmux_and_vim/
      escapeTime = 0;
      sensibleOnTop = true;
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.tmux-thumbs
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes

            # Zenbone theme
            # https://github.com/mcchrish/zenbones.nvim/blob/main/extras/tmux/zenbones_dark.tmux
            set -g status-left ' #[fg=#B279A7,bold]#{s/root//:client_key_table} '
            set -g status-right '#[fg=#B279A7,bold] [#S]#[fg=#B279A7,bold] [%d/%m] #[fg=#B279A7,bold][%I:%M%p] '
            set -g status-style fg='#B279A7',bg='#C6D5CF'
            
            set -g window-status-current-style fg='#B279A7',bg='#C6D5CF',bold
            
            set -g pane-border-style fg='#B279A7'
            set -g pane-active-border-style fg='#B279A7'
            
            set -g message-style fg='#0F191F',bg='#3D4042'
            
            set -g display-panes-active-colour '#B279A7'
            set -g display-panes-colour '#B279A7'
            
            set -g clock-mode-colour '#B279A7'
            
            set -g mode-style fg='#0F191F',bg='#3D4042'
          '';
        }
      ];
    };

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
          x = 15;
          y = 15;
        };
        window.dimensions = {
          lines = 30;
          columns = 150;
        };
        # https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
        env = {
          TERM = "xterm-256color";
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
            #family = "FiraCode Nerd Font";
            #family = "CaskaydiaCove Nerd Font";
            family = "Hack Nerd Font";
          };
          size = 15;
          offset = {
            y = 7;
          };
        };
        # Moonfly Theme
        # https://github.com/bluz71/vim-moonfly-colors/blob/master/terminal_themes/alacritty.yml
        draw_bold_text_with_bright_colors = true;
        colors = {
          # Default colors
          primary = {
            foreground = "#B4BDC3";
            background = "#1C1917";
          };
          # Cursor colors
          cursor = {
            cursor = "#C4CACF";
            text = "#1C1917";
          };
          # Normal colors
          normal = {
            black = "#1C1917";
            red = "#DE6E7C";
            green = "#819B69";
            yellow = "#B77E64";
            blue = "#6099C0";
            magenta = "#B279A7";
            cyan = "#66A5AD";
            white = "#B4BDC3";
          };
          bright = {
            black = "#403833";
            red = "#E8838F";
            green = "#8BAE68";
            yellow = "#D68C67";
            blue =  "#61ABDA";
            magenta = "#CF86C1";
            cyan = "#65B8C1";
            white = "#888F94";
          };
        };
      };
    };

    # Direnv, load and unload environment variables depending on the current directory.
    # https://direnv.net
    # https://rycee.gitlab.io/home-manager/options.html#opt-direnv.enable
    direnv.enable = true;
    direnv.enableZshIntegration = true;
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

        openstack = {
          format = "on [$symbol$cloud(\\($project\\))]($style) ";
          style = "bold yellow";
          symbol = "☁️ ";
        };
      };
    };

    # SSH
    ssh = {
      enable = true;
      # pinentry bug fix, wrong tty:
      # https://unix.stackexchange.com/a/499133
      extraConfig = ''
        Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
        StrictHostKeyChecking no

        # https://github.com/rancher/rke/issues/2290
        ControlMaster auto
        ControlPath ~/.ssh/sockets/%r@%h-%p
        ControlPersist 120
      '';
    };

    zsh.enable = true;
    zsh.autocd = false;
    #zsh.cdpath = [ "~/State/Projects/Code/" ];


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

      # SOPS
      #export SOPS_PGP_FP="9A8F 2B1C 74E0 30CB BA76  8D03 4B82 38C0 BA57 5FAE"
      SOPS_GPG_EXEC="gpg"

      # man pages in nvim
      export MANPAGER='nvim +Man!'

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

      # Quickly setup nix-direnv
      nixify() {
        if [ ! -e ./.envrc ]; then
          echo "use nix" > .envrc
          direnv allow
        fi
        if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
          cat > default.nix <<'EOF'
      with import <nixpkgs> {};
      mkShell {
        nativeBuildInputs = [
          bashInteractive
        ];
      }
      EOF
          vim default.nix
        fi
      }
      flakify() {
        if [ ! -e flake.nix ]; then
          nix flake new -t github:nix-community/nix-direnv .
        elif [ ! -e .envrc ]; then
          echo "use flake" > .envrc
          direnv allow
        fi
        vim flake.nix
      }

      # Enable zoxide
      eval "$(zoxide init zsh)"
    '';

    # zsh plugins through nixpkgs
    zsh.initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      #source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
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
      delta = {
        enable = true;
        options = {
          decorations = { 
            commit-decoration-style = "bold yellow box ul";
            file-decoration-style = "none";
            file-style = "bold yellow ul";
          };
          features = "decorations";
          whitespace-error-style = "22 reverse";
          line-numbers = true;
          side-by-side = true;
          navigate = true;
        };

      };
    };
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetCommand = "fd --type d";
      defaultCommand = "fd --type f";
      defaultOptions = [ "--height 40%" "--border" ];
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [ "--preview 'head {}'" ];
      historyWidgetOptions = [ "--sort" "--exact" ];
      tmux = {
        enableShellIntegration = true;
      };
    };

  };
}
