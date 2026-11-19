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

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# kubectl completion, also for the `k` alias
if command -v kubectl >/dev/null; then
  eval "$(kubectl completion bash)"
  complete -o default -F __start_kubectl k
fi

# tmux completion: subcommands + aliases, and session names after -t/-s
if command -v tmux >/dev/null; then
  _tmux_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]} prev=${COMP_WORDS[COMP_CWORD-1]}
    case $prev in
      -t|-s) COMPREPLY=($(compgen -W "$(tmux ls -F '#S' 2>/dev/null)" -- "$cur")); return ;;
    esac
    [ "$COMP_CWORD" -eq 1 ] && COMPREPLY=($(compgen -W "$(tmux list-commands -F '#{command_list_name} #{command_list_alias}' 2>/dev/null)" -- "$cur"))
  }
  complete -o default -F _tmux_complete tmux
fi
