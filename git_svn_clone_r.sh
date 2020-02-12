#!/bin/bash
# Author: ot_chen
# Description: `git svn clone` and recursively follow external repo urls by `git svn show-externals`
# Date: 2020/02/11

if [ -z $1 ] || [ -z $2 ]; then 
	echo "Usage: git_svn_clone_r.sh REPO_URL CLONE_DIR"
	exit;
fi
git svn clone $1 $2 || exit

# clone externals
cmd="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename $0)"
pushd $2> /dev/null
ls_git_svn_externals.sh | 
	while read line; do 
		eval "$cmd $2 $4";
	done
popd > /dev/null # resume folder position changed in line 13

