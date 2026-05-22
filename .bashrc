if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi

export HISTSIZE=10000
export HISTFILESIZE=1000000000
export HISTCONTROL=ignoreboth:erasedups
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"
export PATH="$HOME/.npm-global/bin:/opt/homebrew/bin:$PATH"

# Simple Claude wrapper - uses default settings.json
claude() { command claude "$@"; }

# Claude Model Switcher
ccg() { ~/.claude/claude-with-model.sh glm; }
cco() { ~/.claude/claude-with-model.sh official; }
cll() { ~/.claude/claude-with-model.sh llama-local; }
clh() { ~/.claude/claude-with-model.sh llama-huihui; }
clu() { ~/.claude/claude-with-model.sh llama-unsloth-qwen; }
cor() { ~/.claude/claude-with-model.sh openrouter; }
