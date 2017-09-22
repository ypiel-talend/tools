#!/bin/bash

########################################
#
# Git pull all sub-directories
#
########################################

export root=$(dirname $0)
export curdir=$(pwd)


echo "Git pull on subfolders of : $root"

dirs=$(find ${root} -maxdepth 2 -type d -name ".git")
for d in $dirs
do
	gitstatus=""
	pmaster=""

	d=$(dirname "$d")
	echo
	echo "**************************  Pull : $d"
	echo
	cd "$d"

	while [ "$gitstatus" != "y" ] && [ "$gitstatus" != "n" ]
	do
		read -p "Git status first ? [y/n] : " gitstatus
	done
	[ $gitstatus = "y" ] && git status && echo "Continue..." && read

	while [ "$pmaster" != "y" ] && [ "$pmaster" != "n" ]
	do
		read -p "Checkout master ? [y/n] : " pmaster
	done
	[ "$pmaster" = "y" ] && echo "Checkout master..." && git checkout master
	git pull
	cd "$curdir"
	echo
done
