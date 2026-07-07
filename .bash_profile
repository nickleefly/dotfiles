# Login shell entry point.
# Load order: .bash_profile -> .profile -> (.exports, .aliases, .functions) -> .bashrc -> .extra.bashrc
#
# Homebrew is set up FIRST so that PATH prepends done later (e.g. ~/.npm-global/bin
# in .bashrc) land in front of /opt/homebrew/bin and win over Homebrew's binaries.
if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
  [[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi
export BASH_SILENCE_DEPRECATION_WARNING=1
export LC_ALL=en_US.UTF-8

. ~/.profile

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# Add mysql-client if installed via Homebrew
if brew --prefix mysql-client >/dev/null 2>&1; then
  export PATH="$(brew --prefix mysql-client)/bin:$PATH"
fi
