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
	cd "$curdir"
	gitstatus=""
	pmaster=""

	d=$(dirname "$d")
	cd "$d"
	branch=$(git branch)
	echo
	echo "**************************  Pull : $d : on branch : ${branch}"
	echo

	while [ "$gitstatus" != "y" ] && [ "$gitstatus" != "n" ] && [ "$gitstatus" != "s" ]
	do
		read -p "Git status first ? [y/n/s(kip)] : " gitstatus
	done
	[ $gitstatus = "s" ] && echo "skipping..." && continue
	[ $gitstatus = "y" ] && git status && echo "Continue..." && read

	while [ "$pmaster" != "y" ] && [ "$pmaster" != "n" ]
	do
		read -p "Checkout master ? [y/n] : " pmaster
	done
	[ "$pmaster" = "y" ] && echo "Checkout master..." && git checkout master
	git pull
	
	echo
done
