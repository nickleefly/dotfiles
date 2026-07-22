#!/bin/bash
######
# .extra.bashrc - Xiuyu's Bash Extras
# This file is designed to be a drop-in for any machine that I log into.
# Currently, that means it has to work under Darwin, Ubuntu, and yRHEL
######
main () {
if [ "${BASH_EXTRAS_LOADED}" = "" ] && [ "$TERM_PROGRAM" != "DTerm" ] && [ "$PS1" != "" ]; then
  echo "loading bash extras..."
fi

# I actually frequently forget this.
# (see also .functions for the node-free version)
age () {
  node -pe 'var ms = Date.now() - new Date("1985-12-14T19:10:00.000Z").getTime(); (ms / (1000 * 60 * 60 * 24 * 365.25)).toFixed(2)'
}

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

alias lsd='ls -l | grep "^d"' # only directories
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

gpa () {
  git push --all "$@"
}

gpl () {
  git pull "$@"
}

gpt () {
  git push --tags "$@"
}

gps () {
  gpa "$@"
  gpt "$@"
}

# Look up any ref's sha, and also copy it for pasting into bugs and such
gsh () {
  local c="${1:-HEAD}"
  git show --no-patch --pretty=%H "$c" | tee >(xargs echo -n | pbcopy)
}

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

gf () {
  git fetch -a "$1"
}

# Open or create a GitHub remote repo and bind it as origin
gho () {
  local me
  me="$(git config --get github.user)"
  if [ -z "$me" ]; then
    echo "Error: set your GitHub username first."
    echo "Run: git config --global github.user \"your-username\""
    return 1
  fi

  if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) not found."
    echo "Install from https://cli.github.com and run 'gh auth login'."
    return 1
  fi

  local name="${1:-${PWD##*/}}"
  local repo="git@github.com:${me}/${name}.git"

  echo "Checking if remote repo ${me}/${name} exists..."

  if gh repo view "${me}/${name}" &> /dev/null; then
    echo "Remote repo exists, binding..."
    if ! git remote | grep -q "^origin$"; then
      git remote add origin "$repo"
    else
      echo "Warning: origin remote already exists."
    fi
    echo "Fetching remote branches..."
    git fetch --all origin
  else
    echo "Remote repo does not exist, creating..."

    if [ ! -d ".git" ]; then
      echo "Initializing local Git repo..."
      git init
    fi

    # Create private repo, bind origin, and push
    gh repo create "${me}/${name}" --private --source=. --remote=origin --push

    if [ $? -eq 0 ]; then
      echo "GitHub repo created and bound."
    else
      echo "Repo creation failed, check network or gh auth status."
      return 1
    fi
  fi
}

# Open the GitHub URL for the current repo/branch in browser
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

# Add a GitHub user's fork as a remote and fetch
ghadd () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && echo "Set github.user git config first." && return 1
  local mine="$( git config --get remote.origin.url )"
  local repo="${mine/git@github.com:$me\//}"
  local nick="$1"
  local who="$2"
  [ "$who" == "" ] && who="$nick"
  [ "$who" == "" ] && ( echo "usage: ghadd [nick] <who>" >&2 ) && return 1
  local theirs="git://github.com/$who/$repo"
  git remote add "$nick" "$theirs"
  git fetch -a "$nick"
}

# Checkout a PR by URL or number
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

gv () {
  local v=$(npm ls -pl | head -1 | awk -F: '{print $2}' | awk -F@ '{print $2}')
  git ci -am $v && git tag -sm $v $v
}

travis () {
  cat > .travis.yml <<YML
sudo: false
language: node_js
node_js:
  - '18'
  - '20'
  - '22'
YML
}

nresolve () {
  node -p 'require.resolve("'$1'")'
}

npmgit () {
  local name=$1
  git clone $(npm view $name repository.url) $name
}

nsp () {
  npm explore $1 -- git pull origin master
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
# git checkout somebranch
# gp someuser    # similar to "git pull someuser somebranch"

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

# set the bash prompt and the title function
# NOTE: This block must live OUTSIDE main() so __prompt is defined at top-level scope.

PS1="\n\\$ "

# view processes.
alias processes="ps axMuc | egrep '^[a-zA-Z0-9]'"
pg () {
  ps aux | grep "$@" | grep -v "$( echo grep "$@" )"
}
pga () {
  local filter="grep -v \"$( echo grep "$@" )\""
  # Filter out /Applications on macOS
  [ "$(uname)" = "Darwin" ] && filter="$filter | grep -v '/Applications'"
  eval "ps aux | grep \"$@\" | $filter"
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

type git >&/dev/null && [ -f $HOME/.git-completion ] && . $HOME/.git-completion

complete -cf sudo

export BASH_EXTRAS_LOADED=1
return 0
}
main
unset main

# Prompt setup (must be at top-level scope, not inside main())
if [ "$(type -t __prompt 2>/dev/null)" != "function" ]; then
  __prompt () {
    echo -ne "\033[m";history -a
    echo ""
    [ -d .git ] && git stash list
    if [ $SHLVL -gt 1 ]; then
      { local i=$SHLVL; while [ $i -gt 1 ]; do echo -n '.'; let i--; done; }
    fi

    local DIR=${PWD/$HOME/\~}
    local HOST=${HOSTNAME:-$(uname -n)}
    HOST=${HOST%.local}
    local OS_LABEL="$(uname)"
    echo -ne "\033]0;$(__git_ps1 "%s - " 2>/dev/null)host $HOST : dir$DIR\007"
    echo -ne "$(__git_ps1 "\033[41;31m[\033[41;37m%s\033[41;31m]\033[0m" 2>/dev/null)"
    echo -ne "\033[44;37m$OS_LABEL\033[0m:$DIR"
    if [ "$NAVE" != "" ]; then echo -ne " \033[44m\033[37mnode$NAVE\033[0m"
    else echo -ne " \033[32mnode$(node -v 2>/dev/null)\033[0m"
    fi
  }
  export PROMPT_COMMAND='__prompt'
fi

pres () {
  export PROMPT_COMMAND=''
  PS1='\n$ '
  clear
}
