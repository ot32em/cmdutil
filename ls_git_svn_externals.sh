#!/bin/bash

if [ -z $1 ]; then 
	git svn show-externals | sh split_git_svn_externals.sh
elif [[ $1 =~ ^[0-9] ]]; then
	git svn show-externals | sh split_git_svn_externals.sh | cut -d ' ' -f $1
fi

