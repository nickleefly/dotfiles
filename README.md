# Installation

## 1. Install packages via Homebrew and npm

```bash
./preinstall.sh
```

This installs:
- All Homebrew packages and casks from `Brewfile` (via `brew bundle`)
- Global npm packages

## 2. Symlink dotfiles and bin scripts

```bash
./install.sh
```

This symlinks:
- All `.*` config files to your home directory (backing up existing files)
- All scripts in `bin/` to `~/bin/`

---

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

## Included Tools

See `Brewfile` for the full list of Homebrew packages and casks installed.
Highlights include:

- **zoxide** - A smarter cd command
- **eza** - Modern replacement for ls
- **bat** - A cat clone with syntax highlighting
- **ripgrep (rg)** - Fast line-oriented search
- **fd** - Fast, user-friendly find alternative
- **fzf** - Command-line fuzzy finder
- **lazygit** - Terminal UI for git
- **delta** - Better git diff pager
- **tmux** - Terminal multiplexer
- **Rectangle** - Window management (cask)
- **Raycast** - Command palette / launcher (cask)
