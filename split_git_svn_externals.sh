#!/bin/bash

# git svn show-externals output layout example:
# >>> /YOUR/SUB/FOLDER/http://YOUR.SVN.REPO/repos/to/module/ SUBFOLDER/IN/EXTERNAL <<<

dir_regex=[a-zA-Z0-9/]+
repo_regex=http[s]?://[-a-zA-Z0-9@:%._+~#=/]+
external_path_regex=[a-zA-Z0-9/]+

while read -r line; do
	if [[ $line =~ ^($dir_regex)($repo_regex)[[:space:]]($external_path_regex) ]]; then
		sub_dir=".${BASH_REMATCH[1]}"
		repo_url=${BASH_REMATCH[2]}
		clone_dir=${BASH_REMATCH[3]}
		
		echo "$sub_dir $repo_url $clone_dir"
	fi
done

