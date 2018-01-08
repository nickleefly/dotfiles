#!/bin/bash
dirs=(
"z"
)
for dir in "${dirs[@]}"; do
  if [ -e ~/$dir ]; then
    if ! (rm ~/$dir/* || unlink ~/$dir); then
      echo "Failed on $dir" > /dev/stderr
    fi
  else
    mkdir ~/$dir
  fi
  if ln -sfn $(pwd)/$dir/* ~/$dir; then
    echo "Linked: $dir" > /dev/stderr
  fi
done

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

exit 0
