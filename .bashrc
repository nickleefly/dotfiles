if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi
source ~/.nvm/nvm.sh
export PATH=$HOME/local/bin:$PATH

function cleanfile () {
  if [ -z "$1" ]; then
    echo "Usage: remove duplicated lines without sortdt"
    echo "  cleanfile ~/.bash_history"
  else
      local bkfile="$1.backup"
      # \+ does not work in OSX sed
      # delte short commands, delete git related commands
      sed 's/ *$//g;' $1 | sed '/^.\{1,4\}$/d' | sed '/^g[nlabcdusfp]\{1,5\} .*/d' | sed '/^git [nr] /d' | sed '/^rm /d' | sed '/^cgnb /d' | sed '/^touch /d' > $bkfile
      # @see Page on stack Overflow/questions/11532157/unix-removing-duplicate-lines-without-sorting
      cat $bkfile | awk ' !x[$0]++' > $1
      rm $bkfile
  fi
}

_Z_NO_PROMPT_COMMAND=1
. ~/z/z.sh
