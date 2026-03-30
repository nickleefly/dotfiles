#!/bin/bash

! [ -d ~/.dotfile_backup ] && mkdir ~/.dotfile_backup
for i in .*; do
	if ! [ "$i" == "." ] && ! [ "$i" == ".." ] && ! [ "$i" == ".git" ]; then
		if [ -e ~/$i ]; then
			if ! ( cp ~/$i ~/.dotfile_backup/$i ) || ! ( rm ~/$i || unlink ~/$i ); then
				echo "Failed on $i" > /dev/stderr
				exit 1
			fi
		fi
		if ln -s $(pwd)/$i ~/$i; then
			echo "Linked: $i" > /dev/stderr
		else
			echo "Failed on $i" > /dev/stderr
			exit 1
		fi
	fi
done

# Ghostty: symlink config to ~/.config/ghostty/config
mkdir -p ~/.config/ghostty
if [ -e ~/.config/ghostty/config ]; then
	cp ~/.config/ghostty/config ~/.dotfile_backup/ghostty-config
	rm ~/.config/ghostty/config
fi
if ln -s $(pwd)/.ghostty-config ~/.config/ghostty/config; then
	echo "Linked: .ghostty-config -> ~/.config/ghostty/config" > /dev/stderr
else
	echo "Failed on ghostty config" > /dev/stderr
	exit 1
fi

exit 0
