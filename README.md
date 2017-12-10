# Pre install

```
brew install reattach-to-user-namespace
brew install fzf
brew install ag
brew install ripgrep
brew install ctags
```
# how to install

```
git submodule init
git submodule update
./install.sh
```
## Update bash

```
brew update && brew install bash
# Add the new shell to the list of allowed shells
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
# Change to the new shell
chsh -s /usr/local/bin/bash
```

Released under the DWTFPL
No rights reserved.

NO WARRANTEE EXPRESSED OR IMPLIED
(SERIOUSLY, NOT EVEN A LITTLE)

If you use my dot files without modification you'd better
damn fucking well know that you're running code written by
someone else in a VERY personal place.

I do not recommend this. Instead, what you should do is fork
this repo, and read through the files carefully and
understand each piece, changing it to suit your personal
needs. Remove anything you won't use or don't understand.
Dotfiles are the most powerful things in the world, and can
give your terminal wings, or cripple it completely.

I will not support you if you use these files and it sets
your computer on fire, disables your terminal, doesn't work,
or eats your kitten. You're on your own, and I hope that the
pain is a useful lesson in why you should understand every
line in your bashrc.

If you come up with something interesting or clever or make
something work better, send me a pull request or drop a line
to i at foo hack dot com.
