#!/bin/bash

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

# Detect OS
OS="$(uname)"
IS_MACOS="$([ "$OS" = "Darwin" ] && echo "true" || echo "false")"

# Check for Homebrew, install if we don't have it
# Homebrew works on both macOS and Linux now
if test ! $(which brew); then
  echo "Installing homebrew..."
  if [ "$IS_MACOS" = "true" ]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Install all brew packages from Brewfile
brew bundle --file="$(dirname "$0")/Brewfile"

# Shell setup (skip on Linux if using system bash)
update_shell() {
  local shell_path
  shell_path="$(which bash)"

  fancy_echo "Changing your shell to bash ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    fancy_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

# Only change shell on macOS, or on Linux if using Homebrew bash
if [ "$IS_MACOS" = "true" ]; then
  case "$SHELL" in
    */bash)
      if [ "$(which bash)" != '/usr/local/bin/bash' ] && [ "$(which bash)" != '/opt/homebrew/bin/bash' ]; then
        update_shell
      fi
      ;;
    *)
      update_shell
      ;;
  esac
else
  # On Linux, only update if using Homebrew bash
  if [ "$(which bash)" = '*/homebrew/*' ]; then
    update_shell
  fi
fi

# NPM global packages
npmglobals=(
  http-server
  json
  rimraf
  trash-cli
  mkdirp
  serve
  node-gyp
  git-open
)

# Add macOS-only npm packages
if [ "$IS_MACOS" = "true" ]; then
  npmglobals+=(alfred-npms)
fi

npm install -g ${npmglobals[@]}
