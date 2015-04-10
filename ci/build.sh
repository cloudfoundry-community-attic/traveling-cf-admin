#!/bin/bash

set -e -x

export GEM_HOME=$HOME/.gems
export PATH=$GEM_HOME/bin:$PATH

gem install bundler --no-document

bundle install

bundle exec rake package
