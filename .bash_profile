. ~/.profile
export LC_ALL=en_US.UTF-8

# Setting PATH for Python 3.11
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:${PATH}"
export PATH

eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
eval $(gdircolors ~/.dircolors/dircolors.256dark)
