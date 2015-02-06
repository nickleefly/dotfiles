if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi
source ~/.nvm/nvm.sh
export PATH=$HOME/local/bin:$PATH
