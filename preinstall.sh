#!/bin/bash

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew tap caskroom/cask
brew tap caskroom/versions

formulas=(
  reattach-to-user-namespace
  fzf
  ag
  ripgrep
  ctags
  git
  bash
  bash-completion
  nodejs
  wget
  unicodechecker
  ipv6toolkit
  ack
  the_silver_searcher
  wifi-password
  tmux
  cmake
  emacs
  reattach-to-user-namespace
  vim --override-system-vi
  macvim --override-system-vim --custom-system-icons
  git-extras
  fzf
  wireshark
  cytopia/tap/ffscreencast
  youtube-dl
)

casks=(
  google-chrome
  docker
  dropbox
  1password
  google-cloud-sdk
  iterm2
  go2shell
  fiddler
  macdown
  sequel-pro
  sublime-text
  visual-studio-code
  spectacle
  alfred
  flux
)
# Add the new shell to the list of allowed shells
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
# Change to the new shell
chsh -s /usr/local/bin/bash

brew install ${formulas[@]}
brew cask install ${casks[@]}

# Install shell extensions
/usr/local/opt/fzf/install
ln -s "/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl

npmglobals=(
  npx
  beefy
  browserify
  http-server
  json
  rimraf
  standard
  vmd
  trash-cli
  mkdirp
  morkdown
  alfred-npms
  uglify-js
  serve
  dat
  level-todo
  standard
  node-gyp
  nave
  n
  node-static
)

npm install -g ${npmglobals[@]}
