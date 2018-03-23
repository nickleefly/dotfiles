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

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

_Z_NO_PROMPT_COMMAND=1
. ~/z/z.sh
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source <(npx --shell-auto-fallback bash)
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

export PATH=/usr/local/go/bin:$PATH
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$HOME/go/bin
export PATH=$GOPATH/bin:$PATH
export PATH=$GOROOT/bin:$PATH

# Terraform & Packer Paths.
export PATH=~/terraform:~/packer:$PATH
