#!/bin/bash
######
# .extra.bashrc - Xiuyu's Bash Extras
# This file is designed to be a drop-in for any machine that I log into.
# Currently, that means it has to work under Darwin, Ubuntu, and yRHEL
#
# Per-platform includes at the bottom, but most functionality is included
# in this file, and forked based on resource availability.
#
# Functions are preferred over shell scripts, because then there's just
# a few files to rsync over to a new host for me to use it comfortably.
######
main () {
#echo 'start ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
if [ "${BASH_EXTRAS_LOADED}" = "" ] && [ "$TERM_PROGRAM" != "DTerm" ] && [ "$PS1" != "" ]; then
  echo "loading bash extras..."
fi

# I actually frequently forget this.
age () {
  node -p <<JS
var now = Date.now()
var born = new Date('1985-12-14T19:10:00.000Z').getTime()
age = now - born
age / (1000 * 60 * 60 * 24 * 365.25)
JS
}

# try to avoid polluting the global namespace with lots of garbage.
# the *right* way to do this is to have everything inside functions,
# and use the "local" keyword.  But that would take some work to
# reorganize all my old messes.  So this is what I've got for now.
__garbage_list=""
__garbage () {
  local i
  if [ $# -eq 0 ]; then
    for i in ${__garbage_list}; do
      unset $i
    done
    unset __garbage_list
  else
    for i in "$@"; do
      __garbage_list="${__garbage_list} $i"
    done
  fi
}
__garbage __garbage
__garbage __set_path
#echo '75    ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
__set_path () {
#echo 'sp 0  ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
  local var="$1"
  local orig=$(eval 'echo $'$var)
  orig=" ${orig//:/ } "
  local p="$2"

  local path_elements=" ${p//:/ } "
  p=""
  local i
  for i in $path_elements; do
    if [ -d $i ]; then
      p="$p $i "
      # strip out from the original set.
      orig=${orig/ $i / }
    fi
  done
  for i in $orig; do
    if ! [ -d $i ]; then
      orig=${orig/ $i / }
    fi
  done
  # put the original at the front, but only the ones that aren't already present
  # This preserves the intended ordering, and allows env hijacking tricks like
  # nave and other subshell programs use.
  # p="$orig $p"
  export $var=$(p=$(echo $p); echo ${p// /:})
#echo 'sp 1  ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
}

__garbage __form_paths
#echo '105   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
local path_roots=( $HOME/ $HOME/local/ /usr/local/ /opt/local/ /usr/ /opt/ / )
__form_paths () {
#echo 'fp 0  ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
  local r p paths
  paths=""
  for r in "${path_roots[@]}"; do
    for p in "$@"; do
      paths="$paths:$r$p"
    done
  done
  echo ${paths/:/} # remove the first :
#echo 'fp 1  ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
}
#echo '119   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing

# homebrew="$HOME/.homebrew"
local homebrew="/usr/local"
__set_path PATH "$HOME/bin::$homebrew/share/npm/bin:$(__form_paths bin sbin nodejs/bin libexec include):/usr/local/nginx/sbin:/usr/X11R6/bin:/usr/local/mysql/bin:/usr/X11R6/include:$HOME/Library/Application Support/TextMate/Support/bin"

unset LD_LIBRARY_PATH
__set_path PKG_CONFIG_PATH "$(__form_paths lib/pkgconfig):/usr/X11/lib/pkgconfig:/opt/gnome-2.14/lib/pkgconfig"
__set_path CDPATH ".:..:$HOME/dev/npm:$HOME/dev:$HOME/dev/js:$HOME"

# Go up N directories
goup() {
  str=""
  count=0
  while [ "$count" -lt "$1" ];
  do
    str=$str"../"
    let count=count+1
  done
  cd $str
}

js () {
  local n=node
  if [ -x ./node ] && [ -f ./node ]; then
    echo "using ./node "$(./node --version)
    n=./$n
  fi
  NODE_READLINE_SEARCH=1 $n "$@"
}

if ! [ -z "$BASH" ]; then
  __garbage __shopt
  __shopt () {
    local i
    for i in "$@"; do
      shopt -s $i 2>/dev/null
    done
  }
  # see http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
  __shopt \
    histappend histverify histreedit \
    cdspell expand_aliases cmdhist globasciiranges \
    hostcomplete no_empty_cmd_completion nocaseglob \
    checkhash extglob globstar extdebug dirspell
fi

#echo '250   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
export SVN_RSH=ssh
export RSYNC_RSH=ssh
export INPUTRC=$HOME/.inputrc
export JOBS=1

# list of editors, by preference.
# eg ew node
ew () {
  vim $(which $1)
}

# shebang <file> <program> [<args>]
shebang () {
  local sb="shebang"
  if [ $# -lt 2 ]; then
    echo "usage: $sb <file> <program> [<arg string>]"
    return 1
  elif ! [ -f "$1" ]; then
    echo "$sb: $1 is not a file."
    return 1
  fi
  if ! [ -w "$1" ]; then
    echo "$sb: $1 is not writable."
    return 1
  fi
  local prog="$2"
  ! [ -f "$prog" ] && prog="$(which "$prog" 2>/dev/null)"
  if ! [ -x "$prog" ]; then
    echo "$sb: $2 is not executable, or not in path."
    return 1
  fi
  chmod ogu+x "$1"
  prog="#!$prog"
  [ "$3" != "" ] && prog="$prog $3"
  if ! [ "$(head -n 1 "$1")" == "$prog" ]; then
    local tmp=$(mktemp shebang.XXXX)
    ( echo $prog; cat $1 ) > $tmp && cat $tmp > $1 && rm $tmp && return 0 || \
      echo "Something fishy happened!" && return 1
  fi
  return 0
}

local lscolor=""
__garbage lscolor
if [ "$TERM" != "dumb" ] && [ -f "$(which gdircolors 2>/dev/null)" ]; then
  eval "$(gdircolors -b)"
  lscolor=" --color=auto"
fi
local ls_cmd="ls$lscolor"
alias ls='gls --color=auto'
alias lsd='ls -l | grep "^d"' # only directories
alias la="$ls_cmd -Fla"
alias lah="$ls_cmd -Flah"
alias lal="$ls_cmd -FLlash"
alias ll="$ls_cmd -Flsh"
alias alg="alias | grep"

# domain sniffing
wi () {
  whois $1 | egrep -i '(registrar:|no match|record expires on|holder:)'
}

prof () {
  unset BASH_EXTRAS_LOADED
  . $HOME/.extra.bashrc
}

editprof () {
  s=""
  if [ "$1" != "" ]; then
    s="_$1"
  fi
  $EDITOR $HOME/.extra$s.bashrc
  prof
}

pushprof () {
  [ "$1" == "" ] && echo "no hostname provided" && return 1
  local failures=0
  local rsync="rsync --copy-links -v -a -z"
  for each in "$@"; do
    if [ "$each" != "" ]; then
      if $rsync $HOME/.{inputrc,profile,extra,git}* $each:~ && \
         $rsync --exclude='{.git,src}/' $HOME/.{vim,gvim}* $each:~
      then
        echo "Pushed bash extras and public keys to $each"
      else
        echo "Failed to push to $each"
        let 'failures += 1'
      fi
    fi
  done
  return $failures
}

export GITHUB_TOKEN=$(git config --get github.token)
export GITHUB_USER=$(git config --get github.user)
export GIT_COMMITTER_NAME=$(git config --get user.name)
export GIT_COMMITTER_EMAIL=$(git config --get user.email)
export GIT_AUTHOR_NAME=$(git config --get user.name)
export GIT_AUTHOR_EMAIL=$(git config --get user.email)

grim () {
  local m=${1-master}
  echo "$m"
  git rebase -i $m
}

gam () {
  if [ $# -eq 0 ]; then
    git ci -a
  else
    git ci -am "$@"
  fi
}

ghurl () {
  local r=${1:-"origin"}
  if [ "$r" == "browse" ]; then
    r="origin"
  fi
  local o=$(git remote -v | grep $r | head -1 | awk '{print $2}')
  o=${o/git\:\/\//git@}
  o=${o/:/\/}
  o=${o/git@/https\:\/\/}
  o=${o%.git}
  local b="$(git branch | grep '\*' | awk '{print $2}')"
  if [ "$b" != "master" ]; then
    o=${o}/tree/$b
  fi
  open $o
}

pr () {
  local url="$1"
  if [ "$url" == "" ] && type pbpaste &>/dev/null; then
    url="$(pbpaste)"
  fi
  if [[ "$url" =~ ^[0-9]+$ ]]; then
    local us="$2"
    if [ "$us" == "" ]; then
      us="origin"
    fi
    local num="$url"
    local o="$(git config --get remote.${us}.url)"
    url="${o}"
    url="${url#(git:\/\/|https:\/\/)}"
    url="${url#git@}"
    url="${url#github.com[:\/]}"
    url="${url%.git}"
    url="https://github.com/${url}/pull/$num"
  fi
  url=${url%/commits}
  url=${url%/files}
  url="$(echo $url | perl -p -e 's/#issuecomment-[0-9]+$//g')"

  local p='^https:\/\/github.com\/[^\/]+\/[^\/]+\/pull\/[0-9]+$'
  if ! [[ "$url" =~ $p ]]; then
    echo "Usage:"
    echo "  pr <pull req url>"
    echo "  pr <pull req number> [<remote name>=origin]"
    type pbpaste &>/dev/null &&
      echo "(will read url/id from clipboard if not specified)"
    return 1
  fi
  url="${url/https:\/\/github\.com\//git@github.com:}"
  local root="${url/\/pull\/+([0-9])/}"
  local ref="refs${url:${#root}}/head"
  echo git pull $root $ref
  pullup $root $ref
}

pullup () {
  local me=$(git rev-list HEAD^..HEAD)
  if [ $? -eq 0 ] && [ "$me" != "" ]; then
    git pull "$@" && git rebase $me
  fi
}

ghadd () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && echo "Please enter your github name as the github.user git config." && return 1
  # like: "git@github.com:$me/$repo.git"
  local mine="$( git config --get remote.origin.url )"
  local repo="${mine/git@github.com:$me\//}"
  local nick="$1"
  local who="$2"
  [ "$who" == "" ] && who="$nick"
  [ "$who" == "" ] && ( echo "usage: ghadd [nick] <who>" >&2 ) && return 1
  # eg: git://github.com/isaacs/jack.git
  local theirs="git://github.com/$who/$repo"
  git remote add "$nick" "$theirs"
  git fetch -a "$nick"
}

#echo '504   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
nresolve () {
  node -p 'require.resolve("'$1'")'
}

gho () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && \
    echo "Please enter your github name as the github.user git config." && \
    return 1
  # like: "git@github.com:$me/$repo.git"
  local name="${1:-$(basename "$PWD")}"
  local repo="git@github.com:$me/$name"
  git remote add origin "$repo"
  git fetch -a origin
}

gpa () {
  git push --all "$@"
}

gpt () {
  git push --tags "$@"
}

gps () {
  gpa "$@"
  gpt "$@"
}

# Look up any ref's sha, and also copy it for pasting into bugs and such
# the echo -n bit is to remove the trailing \n
gsh () {
  local c="${1:-HEAD}"
  git show --no-patch --pretty=%H "$c" | tee >(xargs echo -n | pbcopy)
}


travis () {
  cat > .travis.yml <<YML
sudo: false
language: node_js
node_js:
  - '0.10'
  - '4'
  - '5'
  - '6'
YML
}

npmgit () {
  local name=$1
  git clone $(npm view $name repository.url) $name
}

gf () {
  git fetch -a "$1"
}

gv () {
  local v=$(npm ls -pl | head -1 | awk -F: '{print $2}' | awk -F@ '{print $2}')
  git ci -am $v && git tag -sm $v $v
}

nsp () {
  npm explore $1 -- git pull origin master
}

rmnpm () {
  rm -rf /usr/local/{lib/,}{node_modules,node,bin,share/man}/{.npm/,}npm* ~/.npm
}

# I can't type
gi () {
  local c=${1}
  cmd=("$@")
  cmd[1]=${c:1}
  cmd[0]=git
  "${cmd[@]}"
}

# a context-sensitive rebasing git pull.
# usage:
# ghadd someuser  # add the github remote account
# git checkout somebranch
# gpm someuser    # similar to "git pull someuser somebranch"
# Remote branch is rebased, and local changes stashed and reapplied if possible.

gp () {
  local s
  local head
  s=$(git stash 2>/dev/null)
  head=$(basename $(git symbolic-ref HEAD 2>/dev/null) 2>/dev/null)
  if [ "" == "$head" ]; then
    echo "Not on a branch, can't pull" >&2
    return 1
  fi
  git fetch -a $1
  git pull --rebase $1 "$head"
  [ "$s" != "No local changes to save" ] && git stash pop
}

#echo '800   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
#get the ip address of a host easily.
getip () {
  for each in "$@"; do
    echo $each
    echo "nslookup:"
    nslookup $each | grep Address: | grep -v '#' | egrep -o '([0-9]+\.){3}[0-9]+'
    echo "ping:"
    ping -c1 -t1 $each | egrep -o '([0-9]+\.){3}[0-9]+' | head -n1
    echo "dig:"
    dig $each | grep . | egrep -v '^;'
  done
}

# Show the IP addresses of this machine, with each interface that the address is on.
ips () {
  local interface=""
  local types='vmnet|en|eth|vboxnet'
  local i
  for i in $(
    ifconfig \
    | egrep -o '(^('$types')[0-9]|inet (addr:)?([0-9]+\.){3}[0-9]+)' \
    | egrep -o '(^('$types')[0-9]|([0-9]+\.){3}[0-9]+)' \
    | grep -v 127.0.0.1
  ); do
    if ! [ "$( echo $i | perl -pi -e 's/([0-9]+\.){3}[0-9]+//g' 2>/dev/null )" == "" ]; then
      interface="$i":
    else
      echo $interface $i
    fi
  done
}

# Like the ips function, but for mac addrs.
macs () {
  local interface=""
  local i
  local types='vmnet|en|eth|vboxnet'
  for i in $(
    ifconfig \
    | egrep -o '(^('$types')[0-9]:|ether ([0-9a-f]{2}:){5}[0-9a-f]{2})' \
    | egrep -o '(^('$types')[0-9]:|([0-9a-f]{2}:){5}[0-9a-f]{2})'
  ); do
    if [ ${i:(${#i}-1)} == ":" ]; then
      interface=$i
    else
      echo $interface $i
  fi
  done
}
#echo '850   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing

# set the bash prompt and the title function

if [ "$PROMPT_COMMAND" = "" ] || [ "$PROMPT_COMMAND" = "__prompt" ]; then
  __prompt () {
    echo -ne "\033[m";history -a
    echo ""
    [ -d .git ] && git stash list
    if [ $SHLVL -gt 1 ]; then
      { local i=$SHLVL; while [ $i -gt 1 ]; do echo -n '.'; let i--; done; }
    fi

    # Manually load z here, after $? is checked, to keep $? from being clobbered.
    [[ "$(type -t _z)" ]] && _z --add "$(pwd -P 2>/dev/null)" 2>/dev/null

    local DIR=${PWD/$HOME/\~}
    local HOST=${HOSTNAME:-$(uname -n)}
    HOST=${HOST%.local}
    echo -ne "\033]0;$(__git_ps1 "%s - " 2>/dev/null)host $HOST : dir$DIR\007"
    # echo -ne "$(__git_ps1 "%s " 2>/dev/null)"
    echo -ne "$(__git_ps1 "\033[41;31m[\033[41;37m%s\033[41;31m]\033[0m" 2>/dev/null)"
    echo -ne "\033[44;37mOSX\033[0m:$DIR"
    # echo -ne "$USER@$HOST:$DIR"
    if [ "$NAVE" != "" ]; then echo -ne " \033[44m\033[37mnode$NAVE\033[0m"
    else echo -ne " \033[32mnode$(node -v 2>/dev/null)\033[0m"
    fi
  }
  export PROMPT_COMMAND='__prompt'
fi

#this part gets repeated when you tab to see options
#PROMPT_COMMAND=
PS1="\n\\$ "

pres () {
  export PROMPT_COMMAND=''
  PS1='\n$ '
  clear
}

#echo '900   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
# view processes.
alias processes="ps axMuc | egrep '^[a-zA-Z0-9]'"
pg () {
  ps aux | grep "$@" | grep -v "$( echo grep "$@" )"
}
pga () {
  ps aux | grep "$@" | grep -v "$( echo grep "$@" )" | grep -v '/Applications'
}
pid () {
  pg "$@" | awk '{print $2}'
}

# floating-point calculations
calc () {
  local expression="$@"
  [ "${expression:0:6}" != "scale=" ] && expression="scale=16;$expression"
  echo "$expression" | bc
}

#echo '950   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing

type git >&/dev/null && [ -f $HOME/.git-completion ] && . $HOME/.git-completion
[ -f $HOME/.cd-completion ] && . $HOME/.cd-completion

complete -cf sudo

# call in the cleaner.
__garbage
export BASH_EXTRAS_LOADED=1
#echo 'end   ' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
return 0
}
#echo 'main 0' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
main
#echo 'main 1' $(/usr/local/bin/node -p 'Date.now()') >> ~/login_timing
unset main
