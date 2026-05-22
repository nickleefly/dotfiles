# Login shell entry point.
# Load order: .bash_profile -> .profile -> (.exports, .aliases, .functions) -> .bashrc -> .extra.bashrc
. ~/.profile
export LC_ALL=en_US.UTF-8

eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
export BASH_SILENCE_DEPRECATION_WARNING=1

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
