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
ret=$?
if [ $ret -ne 0 ] && [ $ret -ne 1 ]; then 
	echo "Failed: git svn clone $1 $2, ret: $ret"
	exit;
fi


# clone externals
pushd $2> /dev/null
git_svn_clone_r_path="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename $0)"

# git svn show-externals output layout example:
# >>> /YOUR/SUB/FOLDER/http://YOUR.SVN.REPO/repos/to/module/ SUBFOLDER/IN/EXTERNAL <<<
dir_regex=[a-zA-Z0-9/]+
repo_regex=http[s]?://[-a-zA-Z0-9@:%._+~#=/]+
external_path_regex=[a-zA-Z0-9/]+

git svn show-externals | 
while read line; do
	if [[ $line =~ ^($dir_regex)($repo_regex)[[:space:]]($external_path_regex) ]]; then
		sub_dir=".${BASH_REMATCH[1]}"
		repo_url=${BASH_REMATCH[2]}
		clone_dir=${BASH_REMATCH[3]}
		
		pushd $sub_dir > /dev/null
		eval "${git_svn_clone_r_path} ${repo_url} ${clone_dir}"
		popd > /dev/null
	fi
done

popd > /dev/null # resume folder position changed in line 13

