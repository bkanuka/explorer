#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/..

version=$2
previous=$(jq -r .version package.json)

if [ ! -d bower_components ]; then
  echo "Run bower"
  exit 1
fi

if [ ! -d node_modules ]; then
  echo "Run npm"
  exit 1
fi

if [ ! -f client/css/app.css ]; then
  echo "Run gulp"
  exit 1
fi

if [ -z $version ]; then
  version='patch'
fi

npm config set git-tag-version false
tag=$(npm version $version)

git add package.json 

git commit -m $tag

git tag -a $tag -m $tag

npm config set git-tag-version true
git push --tags

# Pack
git checkout -b deploy

npm dedupe

jq -r '.dependencies|keys[]|.|= "node_modules/" + .' package.json|xargs git add -f
git add .
git add client/css -f
git commit -q -m 'Pack dependencies'

git archive --format=tar --prefix=explorer/ HEAD > "$tag.tar.gz"

git reset -q HEAD~1

git checkout master
git branch -D deploy
