{ config, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
rec {
  home = rec {
    username = "dario"; 
    homeDirectory = "/Users/dario";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "22.11";
  };

  # Load neovim configuration
  xdg.configFile."nvim/init_lua.lua".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/init.lua";
  xdg.configFile."nvim/colors".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/colors";
  xdg.configFile."nvim/lua/configs".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/lua/configs";
  xdg.configFile."nvim/lua/core".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/lua/core";
  xdg.configFile."nvim/lua/default_theme".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/AstroNvim/lua/default_theme";
  xdg.configFile."nvim/lua/user".source = mkOutOfStoreSymlink "${home.homeDirectory}/nixpkgs/configs/nvim/user";

#  services = {
#    gpg-agent ={
#      enable = true;
#      enableExtraSocket = true;
#    };
#  };


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

    # nushell
    nushell = {
      enable = true;
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

            # vim style tmux config
            # https://gist.github.com/tsl0922/d79fc1f8097dde660b34
            # use C-a, since it's on the home row and easier to hit than C-b
            set-option -g prefix C-a
            unbind-key C-a
            bind-key C-a send-prefix
            set -g base-index 1

            # Easy config reload
            bind-key R source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."

            # vi is good
            setw -g mode-keys vi

            # mouse behavior
            setw -g mouse on

            # https://www.reddit.com/r/vim/comments/75zvux/why_is_vim_background_different_inside_tmux/
            set -g terminal-overrides ',xterm-256color:Tc'
            set -g default-terminal "screen-256color"
            set -as terminal-overrides ',xterm*:sitm=\E[3m'

            bind-key : command-prompt
            bind-key r refresh-client
            bind-key L clear-history

            bind-key space next-window
            bind-key bspace previous-window
            bind-key enter next-layout

            # use vim-like keys for splits and windows
            bind-key v split-window -h
            bind-key s split-window -v
            bind-key h select-pane -L
            bind-key j select-pane -D
            bind-key k select-pane -U
            bind-key l select-pane -R

            # smart pane switching with awareness of vim splits
            #bind -n C-h run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-h) || tmux select-pane -L"
            #bind -n C-j run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-j) || tmux select-pane -D"
            #bind -n C-k run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-k) || tmux select-pane -U"
            #bind -n C-l run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-l) || tmux select-pane -R"
            bind -n 'C-\' run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys 'C-\\') || tmux select-pane -l"
            bind C-l send-keys 'C-l'

            # resize panes
            # Resize the current pane using Alt + direction
            bind-key -n M-k resize-pane -U 5
            bind-key -n M-j resize-pane -D 5
            bind-key -n M-h resize-pane -L 5
            bind-key -n M-l resize-pane -R 5

            bind-key C-o rotate-window

            bind-key + select-layout main-horizontal
            bind-key = select-layout main-vertical

            set-window-option -g other-pane-height 25
            set-window-option -g other-pane-width 80
            set-window-option -g display-panes-time 1500
            set-window-option -g window-status-current-style fg=magenta

            bind-key a last-pane
            bind-key q display-panes
            bind-key c new-window
            bind-key t next-window
            bind-key T previous-window

            bind-key [ copy-mode
            bind-key ] paste-buffer

            # Setup 'v' to begin selection as in Vim
            bind-key -T copy-mode-vi v send -X begin-selection
            bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"

            # Update default binding of `Enter` to also use copy-pipe
            unbind -T copy-mode-vi Enter
            bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"

            # Status Bar
            set-option -g status-interval 1
            set-option -g status-style bg=black
            set-option -g status-style fg=white
            set -g status-left '#[fg=green]#H #[default]'
            set -g status-right '%a%l:%M:%S %p#[default] #[fg=blue]%Y-%m-%d'

            set-option -g pane-active-border-style fg=yellow
            set-option -g pane-border-style fg=cyan

            # Set window notifications
            setw -g monitor-activity on
            set -g visual-activity on

            # Enable native Mac OS X copy/paste
            set-option -g default-command "/bin/bash -c 'which reattach-to-user-namespace >/dev/null && exec reattach-to-user-namespace $SHELL -l || exec $SHELL -l'"

            # Allow the arrow key to be used immediately after changing windows
            set-option -g repeat-time 0
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
      forwardAgent = true;

      # https://github.com/rancher/rke/issues/2290
      controlMaster = "auto";
      #controlPath = "~/.ssh/%r@%h:%p";
      controlPath = "/tmp/%r@%h:%p";
      controlPersist = "10m";

      extraConfig = ''
        # Add pub-key to ssh-agent
        AddKeysToAgent yes

        #Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"

        # Automatically add server fingerprint
        StrictHostKeyChecking no

        # secretive
        IdentityAgent /Users/dario/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

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

      # nnn
      # exit on quit: https://github.com/jarun/nnn/wiki/Basic-use-cases#configure-cd-on-quit
      n ()
      {
          # Block nesting of nnn in subshells
          if [[ "$(NNNLVL:-0)" -ge 1 ]]; then
              echo "nnn is already running"
              return
          fi
      
          # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
          # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
          # see. To cd on quit only on ^G, remove the "export" and make sure not to
          # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
          NNN_TMPFILE="$HOME/.config/nnn/.lastd"
          #export NNN_TMPFILE="$(XDG_CONFIG_HOME:-$HOME/.config)/nnn/.lastd"
      
          # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
          # stty start undef
          # stty stop undef
          # stty lwrap undef
          # stty lnext undef
      
          # The backslash allows one to alias n to nnn if desired without making an
          # infinitely recursive alias
          \nnn "$@"
      
          if [ -f "$NNN_TMPFILE" ]; then
                  . "$NNN_TMPFILE"
                  rm -f "$NNN_TMPFILE" > /dev/null
          fi
      }
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
