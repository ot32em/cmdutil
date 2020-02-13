#!/bin/bash
full_path_cmd="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename $0)"


git stash
git svn rebase
git stash pop

ls_git_svn_externals.sh 4 | 
	while read clone_dir; do 
		pushd $clone_dir > /dev/null
		eval $full_path_cmd
		popd > /dev/null
	done

