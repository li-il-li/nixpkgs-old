{ config, pkgs, ... }: {

  home = {
    username = "dario"; 
    homeDirectory = "/Users/dario";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "22.05";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # Direnv, load and unload environment variables depending on the current directory.
    # https://direnv.net
    # https://rycee.gitlab.io/home-manager/options.html#opt-direnv.enable
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

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

      # bat is a better cat
      alias cat=bat

      # Always color ls
      alias ls='ls --color'

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"
    '';

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = "Dario Wirtz";
      userEmail = "dario.wirtz@hey.com";
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
  };
}
