if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi

export HISTSIZE=10000
export HISTFILESIZE=1000000000
export HISTCONTROL=ignoreboth:erasedups
