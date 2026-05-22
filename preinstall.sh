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

# Install all brew packages from Brewfile
brew bundle --file="$(dirname "$0")/Brewfile"

# Shell setup
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

# NPM global packages
npmglobals=(
  http-server
  json
  rimraf
  trash-cli
  mkdirp
  alfred-npms
  serve
  node-gyp
  git-open
)

npm install -g ${npmglobals[@]}
