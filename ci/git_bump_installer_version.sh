#!/bin/bash

set -e -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

git add cf-cli-release

new_version_tag=$(cat cf-cli-release/tag)
git commit -m "Bumping installer to ${new_version_tag} of traveling-cf-admin"
