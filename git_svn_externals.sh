if [ -z $1 ]; then exit; fi
if [ -z $2 ]; then exit; fi

full="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename $0)"

# clone main
main_repo=$1
main_path=$2

git svn clone $main_repo $main_path
pushd $main_path > /dev/null

# clone externals
dir_regex=[a-zA-Z0-9/]+
repo_regex=http://[-a-zA-Z0-9@:%._+~#=/]+
external_path_regex=[a-zA-Z0-9/]+

git svn show-externals | 
while read line; do
	if [[ $line =~ ^($dir_regex)($repo_regex)[[:space:]]($external_path_regex) ]]; then
		dir=${BASH_REMATCH[1]}
		repo=${BASH_REMATCH[2]}
		path=${BASH_REMATCH[3]}
		
		pushd .$dir > /dev/null
		eval "$full $repo ${path}"
		popd > /dev/null
	fi
done

popd > /dev/null
