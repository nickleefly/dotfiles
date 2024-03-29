# Load our dotfiles like ~/.bash_prompt, etc…
#   ~/.extra can be used for settings you don’t want to commit,
#   Use it to configure your PATH, thus it being first in line.
for file in ~/.{extra,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

DOT_PROFILE_LOADED=1
if [ -n "$BASH_VERSION" ]; then
	[ -f ~/.bashrc ] && ! [ "$DOT_BASHRC_LOADED" == "1" ] && . ~/.bashrc
	[ -f ~/.extra.bashrc ] && . ~/.extra.bashrc
fi

_Z_NO_PROMPT_COMMAND=1
. ~/z/z.sh
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export PATH=/usr/local/go/bin:$PATH
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$HOME/go/bin
export PATH=$GOPATH/bin:$PATH
export PATH=$GOROOT/bin:$PATH

# Terraform & Packer Paths.
export PATH=~/terraform:~/packer:$PATH
export PATH=~/.emacs.d/bin:$PATH
export PATH="~/.local/bin:$PATH"
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
