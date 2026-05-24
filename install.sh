#!/bin/bash

# Detect OS
OS="$(uname)"
IS_MACOS="$([ "$OS" = "Darwin" ] && echo "true" || echo "false")"

! [ -d ~/.dotfile_backup ] && mkdir ~/.dotfile_backup

# Symlink dotfiles
for i in .*; do
  if ! [ "$i" == "." ] && ! [ "$i" == ".." ] && ! [ "$i" == ".git" ]; then
    # Skip .ghostty-config on Linux
    if [ "$i" == ".ghostty-config" ] && [ "$IS_MACOS" = "false" ]; then
      continue
    fi
    if [ -e ~/$i ]; then
      if ! ( cp ~/$i ~/.dotfile_backup/$i ) || ! ( rm ~/$i || unlink ~/$i ); then
        echo "Failed on $i" > /dev/stderr
        exit 1
      fi
    fi
    if ln -s $(pwd)/$i ~/$i; then
      echo "Linked: $i" > /dev/stderr
    else
      echo "Failed on $i" > /dev/stderr
      exit 1
    fi
  fi
done

# Ghostty: symlink config to ~/.config/ghostty/config (macOS only)
if [ "$IS_MACOS" = "true" ]; then
  mkdir -p ~/.config/ghostty
  if [ -e ~/.config/ghostty/config ]; then
    cp ~/.config/ghostty/config ~/.dotfile_backup/ghostty-config
    rm ~/.config/ghostty/config
  fi
  if ln -s $(pwd)/.ghostty-config ~/.config/ghostty/config; then
    echo "Linked: .ghostty-config -> ~/.config/ghostty/config" > /dev/stderr
  else
    echo "Failed on ghostty config" > /dev/stderr
    exit 1
  fi
fi

# Symlink bin/ scripts to ~/bin
mkdir -p ~/bin
for i in bin/*; do
  if [ -e ~/bin/$(basename "$i") ]; then
    cp ~/bin/$(basename "$i") ~/.dotfile_backup/$(basename "$i")
    rm ~/bin/$(basename "$i")
  fi
  if ln -s $(pwd)/$i ~/bin/$(basename "$i"); then
    echo "Linked: $i -> ~/bin/$(basename "$i")" > /dev/stderr
  else
    echo "Failed on $i" > /dev/stderr
    exit 1
  fi
done

exit 0
