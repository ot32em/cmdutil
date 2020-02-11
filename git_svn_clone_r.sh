#!/bin/bash
# Author: ot_chen
# Description: `git svn clone` and recursively follow external repo urls by `git svn show-externals`
# Date: 2020/02/11

if [ -z $1 ] || [ -z $2 ]; then 
	echo "Usage: git_svn_clone_r.sh REPO_URL CLONE_DIR"
	exit;
fi

# clone main
git svn clone $1 $2


# clone externals
pushd $main_path > /dev/null
script_abs="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename $0)"

# git svn show-externals output layout example:
# >>> /YOUR/SUB/FOLDER/http://YOUR.SVN.REPO/repos/to/module/ SUBFOLDER/IN/EXTERNAL <<<
dir_regex=[a-zA-Z0-9/]+
repo_regex=http[s]?://[-a-zA-Z0-9@:%._+~#=/]+
external_path_regex=[a-zA-Z0-9/]+

git svn show-externals | 
while read line; do
	if [[ $line =~ ^($dir_regex)($repo_regex)[[:space:]]($external_path_regex) ]]; then
		dir=${BASH_REMATCH[1]}
		repo=${BASH_REMATCH[2]}
		path=${BASH_REMATCH[3]}
		
		pushd .$dir > /dev/null
		eval "$script_abs $repo ${path}"
		popd > /dev/null
	fi
done

popd > /dev/null # resume folder position changed in line 13

