#!/bin/bash

########################################
#
# Git pull all sub-directories
#
########################################

export root=$(dirname $0)
export curdir=$(pwd)

[ "$1" = "-h" ] && echo "Usage : $0 [branch to checkout]" && echo "If no branch is given master will be checkouted." && exit 0

co_branch="$1"
[ -z "${co_branch}" ] && co_branch="master"

echo "Checkouted branch will be : ${co_branch}"
echo

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
		read -p "Checkout '$co_branch' ? [y/n] : " pmaster
	done
	[ "$pmaster" = "y" ] && echo "Checkout '${co_branch}'..." && git checkout $co_branch
	git pull
	
	echo
done
