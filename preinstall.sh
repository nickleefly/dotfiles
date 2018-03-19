#!/bin/bash

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

formulas=(
  reattach-to-user-namespace
  bash
  vim --override-system-vi
)
brew install ${formulas[@]}

brew bundle --file=- <<EOF
tap "homebrew/services"
tap "universal-ctags/universal-ctags"
tap "caskroom/cask"
tap "caskroom/versions"

# Unix
brew "universal-ctags", args: ["HEAD"]
brew "ag"
brew "ripgrep"
brew "git"
brew "bash-completion"
brew "nodejs"
brew "wget"
brew "ipv6toolkit"
brew "the_silver_searcher"
brew "wifi-password"
brew "tmux"
brew "cmake"
brew "emacs"
brew "reattach-to-user-namespace"
brew "git-extras"
brew "youtube-dl"
EOF

brew install wireshark --with-qt
casks=(
  unicodechecker
  dropbox
  1password
  google-cloud-sdk
  go2shell
  macdown
  sublime-text
  visual-studio-code
  spectacle
  alfred
  flux
)
brew cask install --appdir="/Applications" ${casks[@]}

update_shell() {
  local shell_path;
  shell_path="$(which bash)"

  fancy_echo "Changing your shell to bash ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    fancy_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

case "$SHELL" in
  */bash)
    if [ "$(which bash)" != '/usr/local/bin/bash' ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

brew cleanup
brew cask cleanup

# Install shell extensions
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
  alfred-npms
  uglify-js
  serve
  dat
  standard
  node-gyp
  nave
  n
  node-static
  npm-check
  git-open
)

npm install -g ${npmglobals[@]}
