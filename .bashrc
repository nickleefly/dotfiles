if [ "$PS1" != "" ]; then
  DOT_BASHRC_LOADED=1
  [ "$DOT_PROFILE_LOADED" != "1" ] && . ~/.profile
fi
source ~/.nvm/nvm.sh
export N_PREFIX=$HOME/.n
export PATH=$HOME/local/bin:$PATH
export PATH=~/npm-global/bin:$PATH

function mkdir()
{
  command mkdir $1 && cd $1
}

function x () {
  local dir
  dir=$(ls -R | grep '[a-zA-Z0-9]:' | sed 's/://g' | fzf +m) &&
  cd "$dir"
}

function f () {
  find . -name '.git' -type d -prune -o -type f -print0 |\
  xargs -0 grep --color -n -H "$1" |\
  awk '{split($0,a,":"); printf("\033[1;33m%s\033[m: %s\n\033[1;31m%s\033[m\n\n", a[2], a[1], a[3]) }' |\
  less -R
}

ch() {
  local cols sep
  export cols=$(( COLUMNS / 3 ))
  export sep='{::}'

  cp -f ~/Library/Application\ Support/Google/Chrome/Default/History /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select title, url from urls order by last_visit_time desc" |
  ruby -ne '
    cols = ENV["cols"].to_i
    title, url = $_.split(ENV["sep"])
    len = 0
    puts "\x1b[36m" + title.each_char.take_while { |e|
      if len < cols
        len += e =~ /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/ ? 2 : 1
      end
    }.join + " " * (2 + cols - len) + "\x1b[m" + url' |
  fzf --ansi --multi --no-hscroll --tiebreak=index |
  sed 's#.*\(https*://\)#\1#' | xargs open
}

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

export HISTIGNORE="cd [a-zA-Z0-9_.*]*:mv [a-zA-Z0-9_.*]*"

_Z_NO_PROMPT_COMMAND=1
. ~/z/z.sh
export ANDROID_HOME=/usr/local/opt/android-sdk

alias tmux="tmux -2"
[ -f $HOME/.git-completion ] && . $HOME/.git-completion
source ~/.git-prompt

# A little hack to add forward-and-back traversal with cd
c () {
  local a
  alias cd="cd"
  a="$(godir.php "$@")"
  [ "$a" != "" ] && eval $a
  [ -f .DS_Store ] && rm .DS_Store
  alias cd="c"
}
alias cd="c"
alias ..="c .."
alias -- -="c -1"
alias -- _="c +1"
alias s="c --show"
