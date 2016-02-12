#!/bin/bash

set -e -x

new_version_tag=$(cat cf-cli-release/tag)
cp -r traveling-cf-admin version-bumped-repo
cd version-bumped-repo

git config --global user.email "robot@concourse.ci"
git config --global user.name "Concourse"

if [[ "$(git status -s)X" != "X" ]]; then
  git add cf-cli-release
  git commit -m "Bumping installer to ${new_version_tag} of traveling-cf-admin"
else
  echo "Version has not changed. Nothing to commit."
fi
