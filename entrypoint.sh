#!/bin/bash

function incrementVersion {
  cmpt=0

  IFS='.'
  read -ra ADDR <<< "$1"
  for i in "${ADDR[@]}"; do
    if [ $cmpt == 0 ];
    then
      major="$i"
    elif [ $cmpt == 1 ];
    then
      minor="$i"
    else
      patch="$i"
    fi

    cmpt=$((cmpt+1))
  done

  if [ $2 == 'major' ];
  then
    major=$((major+1))
    minor=0
    patch=0
  elif [ $2 == 'patch' ];
  then
    patch=$((patch+1))
  else
    minor=$((minor+1))
    patch=0
  fi
  tag=$major"."$minor"."$patch

  IFS=''
}

semvar=${DEFAULT_BUMP:-minor}

cd ${GITHUB_WORKSPACE}

git fetch --tags

# get latest tag
gitTag=$(git describe --tags `git rev-list --tags --max-count=1`)

if [ -z "$gitTag" ]
then
  # If we have no tag, then we start at 0.0.0
  tag=0.0.0
else
  # Else we remove the v in front of the existing tag
  tag=${gitTag#"v"}
fi

incrementVersion $tag $semvar

# get the npm version
npmVersion=$(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')

# print latest
echo "Next release minor version: $tag"
echo "NPM version: $npmVersion"

if [ $tag != $npmVersion ];
then
  # echo "NPM version has been bumped"
  # bumpedVersion=$(npm version ${tag} --no-git-tag-version)

  echo "::set-output name=npmVersion::$tag"
else
  echo "NPM version is the same as next release"
fi
