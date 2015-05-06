#!/bin/bash

set -e -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

git config --global user.email "robot@concourse.ci"
git config --global user.name "Concourse"

git add cf-cli-release

new_version_tag=$(cat cf-cli-release/tag)
git commit -m "Bumping installer to ${new_version_tag} of traveling-cf-admin"
