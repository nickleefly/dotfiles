if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi

export HISTSIZE=10000
export HISTFILESIZE=1000000000
export HISTCONTROL=ignoreboth:erasedups
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Claude Model Switcher
ccg() { ~/.claude/claude-with-model.sh glm; }
ccd() { ~/.claude/claude-with-model.sh ds; }
cco() { ~/.claude/claude-with-model.sh off; }
