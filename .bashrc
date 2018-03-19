if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi

_Z_NO_PROMPT_COMMAND=1
. ~/z/z.sh

source <(npx --shell-auto-fallback bash)

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
