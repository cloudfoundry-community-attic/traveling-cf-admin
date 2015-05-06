#!/bin/bash

set -e -x

usage() {
  echo "USAGE: CF_CLI_VERSION=X.Y.Z ./ci/build.sh"
  exit 1
}

if [[ "${CF_CLI_VERSION}X" == "X" ]]; then
  usage
fi


export GEM_HOME=$HOME/.gems
export PATH=$GEM_HOME/bin:$PATH
gem install bundler --no-document -v "1.7.6"
bundle install

PACKAGE_NAME="cf-admin"
GITHUB_REPO="traveling-cf-admin"

RELEASE_NAME="CLIs for Cloud Foundry administrators"

# http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html
TRAVELING_RUBY_VERSION="20141224-2.1.5"

# RELEASE_PATCH="1" # if we're releasing a patch to the original CF_CLI_VERSION release; else ""
RELEASE_PATCH="" # normal; not patching/re-releasing with an existing CF CLI
NATS_CLI_VERSION="1.0.0"
EVENTMACHINE_VERSION="1.0.4"

if [[ "${RELEASE_PATCH}X" == "X" ]]; then
  release_version=$CF_CLI_VERSION
else
  release_version="${CF_CLI_VERSION}.${RELEASE_PATCH}"
fi

function bundle_traveling_ruby {
  mkdir -p packaging/tmp
  cp Gemfile* packaging/tmp/
  pushd packaging/tmp
    env BUNDLE_IGNORE_CONFIG=1 BUNDLE_APP_CONFIG=. bundle install --path ../vendor --without development
  popd
  rm -rf packaging/tmp
  rm -rf packaging/vendor/*/*/cache/*
  rm -rf packaging/vendor/ruby/*/extensions
  for file in $(packaging/vendor/ruby/*/gems -name '*.{so,bundle}'); do
    rm ${file}
  done
}

function download_runtime {
  target=$1
  pushd packaging
    curl -L -O --fail \
      http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-${TRAVELING_RUBY_VERSION}-${target}.tar.gz
  popd
}

function download_native_extension {
  target=$1
  gem_name_and_version=$2
  curl -L --fail -o packaging/traveling-ruby-${TRAVELING_RUBY_VERSION}-${target}-${gem_name_and_version}.tar.gz \
    http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-${TRAVELING_RUBY_VERSION}-${target}/${gem_name_and_version}.tar.gz
}

function download_cf_cli {
  target=$1
  if [[ "${target}" == "linux-x86" ]]; then
    url="https://cli.run.pivotal.io/stable?release=linux32-binary&version=${CF_CLI_VERSION}&source=traveling-cf-admin"
  elif [[ "${target}" == "linux-x86_64" ]]; then
    url="https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=traveling-cf-admin"
  elif [[ "${target}" == "osx" ]]; then
    url="https://cli.run.pivotal.io/stable?release=macosx64-binary&version=${CF_CLI_VERSION}&source=traveling-cf-admin"
  fi
  curl -L -o packaging/cf-${CF_CLI_VERSION}-${target}.tgz ${url}
}

function download_nats_cli {
  target=$1
  url="https://github.com/soutenniza/nats/releases/download/${NATS_CLI_VERSION}/nats-${NATS_CLI_VERSION}-${target}.tar.gz"
  curl -L -o packaging/nats-${NATS_CLI_VERSION}-${target}.tgz ${url}
}

function create_package {
  target=$1
  package_dir="${PACKAGE_NAME}-${release_version}-${target}"
  mkdir -p ${package_dir}/lib/app
  mkdir -p ${package_dir}/lib/ruby
  tar xzf packaging/traveling-ruby-${TRAVELING_RUBY_VERSION}-${target}.tar.gz -C ${package_dir}/lib/ruby
  tar xzf packaging/cf-${CF_CLI_VERSION}-${target}.tgz -C ${package_dir}
  tar xzf packaging/nats-${NATS_CLI_VERSION}-${target}.tgz -C ${package_dir}
  mv ${package_dir}/nats* ${package_dir}/nats
  cp packaging/wrappers/uaac.sh ${package_dir}/uaac
  chmod +x packaging/wrappers/uaac.sh ${package_dir}/uaac
  cp -pR packaging/helpers ${package_dir}/
  cp -pR packaging/vendor ${package_dir}/lib/
  cp Gemfile* ${package_dir}/lib/vendor/
  mkdir ${package_dir}/lib/vendor/.bundle
  cp packaging/bundler-config ${package_dir}/lib/vendor/.bundle/config

  # native gems
  tar -xzf packaging/traveling-ruby-${TRAVELING_RUBY_VERSION}-${target}-eventmachine-1.0.4.tar.gz -C ${package_dir}/lib/vendor/ruby
}

function build_package {
  target=$1
  package_dir="${PACKAGE_NAME}-${release_version}-${target}"
  mkdir -p release
  tar -czf release/${package_dir}.tar.gz ${package_dir}
}

function build_release_assets {
  mkdir -p release
  cp ci/release_notes.md release/notes.md
  echo "${RELEASE_NAME} v${release_version}" > release/name
  echo "v${release_version}" > release/tag
}

bundle_traveling_ruby
targets=( linux-x86 linux-x86_64 osx )
for target in "${targets[@]}"; do
  echo packaging ${target}
  download_runtime ${target}
  download_native_extension ${target} "eventmachine-${EVENTMACHINE_VERSION}"
  download_cf_cli ${target}
  download_nats_cli ${target}
  create_package ${target}

  build_package ${target}
done
build_release_assets
