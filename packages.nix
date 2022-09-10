{ pkgs }:

with pkgs; [
  bat # A cat(1) clone with syntax highlighting
  bottom
  broot
  cz-cli
  cargo
  #convco
  coreutils
  direnv
  dsq
  du-dust
  duf
  exa
  fd
  fluxcd
  font-awesome
  fzf
  gh
  #gh-dash
  git-filter-repo
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
  kubectl
  kubernetes-helm
  kustomize
  lazydocker
  lazygit
  libiconv
  lua
  lsd
  k9s
  navi
  ncdu_2
  ncspot
  #neovim
  #vimPlugins.packer-nvim
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
  tree
  tree-sitter
  tmux
  unzip
  vim
  visidata # heavy weight
  #watchexec
  xh
  xplr
  zip
  # vim dependencies
  # markdown preview
  nodePackages.live-server
]
