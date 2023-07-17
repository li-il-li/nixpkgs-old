{ pkgs }:

with pkgs; [
  azure-cli
  bat # A cat(1) clone with syntax highlighting
  bottom
  broot
  cz-cli
  cachix
  cargo
  #convco
  coreutils
  colima
  direnv
  docker
  dsq
  du-dust
  duf
  exa
  fd
  fluxcd
  font-awesome
  gh
  #gh-dash
  git-filter-repo
  glances
  gnupg
  gpg-tui
  graphviz
  hack-font
  highlight
  home-manager
  htop
  iftop
  innernet
  jc
  jq
  jupyter
  kubectl
  kubernetes-helm
  kustomize
  k6
  k9s
  lazydocker
  lazygit
  libiconv
  lima
  lua
  lsd
  navi
  ncdu_2
  ncspot
  #neovim
  #vimPlugins.packer-nvim
  nixos-generators
  nodejs
  noti # notifications
  openstackclient
  openssh
  packer
  pandoc
  pass
  pinentry # Insert pin for pgp key
  pinentry_mac
  popeye
  pre-commit
  procs
  python3
  ripgrep
  rsync
  rustc
  slack
  sops
  telegram-cli
  terraform
  terraform-ls
  texlive.combined.scheme-full
  tree
  tree-sitter
  tmux
  unzip
  vim
  visidata # heavy weight
  watch
  wget
  wireguard-tools
  #watchexec
  xh
  xplr
  yubikey-agent
  zip
  # vim dependencies
  # markdown preview
  nodePackages.live-server


  ## Python
  python310Packages.jupyter_core.out
  python310Packages.python
  python310Packages.poetry
  python310Packages.pandas
  python310Packages.numpy


]
