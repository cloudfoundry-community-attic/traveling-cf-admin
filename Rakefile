# For Bundler.with_clean_env
require 'bundler/setup'

PACKAGE_NAME = "cf-admin"
GITHUB_REPO = "traveling-cf-admin"

RELEASE_NAME = "CLIs for Cloud Foundry administrators"
RELEASE_DESCRIPTION = <<-EOS
All the CLIs and plugins for Cloud Foundry administrators.

* `cf` (useful administrator plugins coming soon)
* `uaac`
EOS

# http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html
TRAVELING_RUBY_VERSION = "20141224-2.1.5"

CF_CLI_VERSION = "6.9.0"
NATS_CLI_VERSION = "1.0.0"

# Must match Gemfile
EVENTMACHINE_VERSION = "1.0.4"
NATIVE_GEMS = {
  "eventmachine" => EVENTMACHINE_VERSION,
}

desc "Package and upload"
task :publish => ['package', 'release']

desc "Create release & upload files"
task :release => ['release:create', 'release:upload_files']

desc "Package your app"
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx']

namespace :release do
  desc "Create a release on github and upload"
  task :create do
    tag = "v#{release_version}"
    sh "git commit -a -m 'Releasing #{tag}'; true"
    sh "git push origin master"
    sh "github-release release \
      --user cloudfoundry-community --repo #{GITHUB_REPO} --tag #{tag} \
      --name '#{RELEASE_NAME} #{tag}' \
      --description '#{RELEASE_DESCRIPTION}'"
    sh "git pull origin master" # to get tag created
  end

  desc "Upload files to github release"
  task :upload_files do
    tag = "v#{release_version}"

    files = Dir["*#{release_version}*.tar.gz"]
    if files.size == 0
      $stderr.puts "Run `rake package` to create packages first"
      exit 1
    end
    files.each do |file|
      sh "github-release upload \
        --user cloudfoundry-community --repo #{GITHUB_REPO} --tag #{tag} \
        --name #{file} --file #{file}"
    end
  end
end

namespace :package do
  namespace :linux do
    desc "Package your app for Linux x86"
    task :x86 => [:bundle_install,
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-eventmachine-#{EVENTMACHINE_VERSION}.tar.gz",
      "packaging/cf-#{CF_CLI_VERSION}-linux-x86.tgz",
      "packaging/nats-#{NATS_CLI_VERSION}-linux-x86.tgz",
      ] do
      create_package("linux-x86")
    end

    desc "Package your app for Linux x86_64"
    task :x86_64 => [:bundle_install,
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-eventmachine-#{EVENTMACHINE_VERSION}.tar.gz",
      "packaging/cf-#{CF_CLI_VERSION}-linux-x86_64.tgz",
      "packaging/nats-#{NATS_CLI_VERSION}-linux-x86_64.tgz",
      ] do
      create_package("linux-x86_64")
    end
  end

  desc "Package your app for OS X"
  task :osx => [:bundle_install,
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-eventmachine-#{EVENTMACHINE_VERSION}.tar.gz",
    "packaging/cf-#{CF_CLI_VERSION}-osx.tgz",
    "packaging/nats-#{NATS_CLI_VERSION}-osx.tgz",
    ] do
    create_package("osx")
  end

  desc "Install gems to local directory"
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.1\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end
    sh "rm -rf packaging/tmp"
    sh "mkdir -p packaging/tmp"
    sh "cp Gemfile* packaging/tmp/"

    sh "rm -rf packaging/vendor/ruby/2.1.0/bundler" # if multiple clones of same repo, may load in wrong one

    Bundler.with_clean_env do
      sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
    end

    sh "rm -rf packaging/tmp"
    sh "rm -rf packaging/vendor/*/*/cache/*"
    sh "rm -rf packaging/vendor/ruby/*/extensions"
    sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm"
    sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm"
  end

  desc "Clean up created releases"
  task :clean do
    sh "rm -f #{PACKAGE_NAME}*.tar.gz"
    sh "rm -rf packaging/vendor"
    sh "rm -rf packaging/*.tar.gz"
  end
end

%w[linux-x86 linux-x86_64 osx].each do |target|
  file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz" do
    download_runtime(target)
  end

  NATIVE_GEMS.each do |gem, version|
    file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem}-#{version}.tar.gz" do
      download_native_extension(target, "#{gem}-#{version}")
    end
  end

  file "packaging/cf-#{CF_CLI_VERSION}-#{target}.tgz" do
    download_cf_cli(target)
  end

  file "packaging/nats-#{NATS_CLI_VERSION}-#{target}.tgz" do
    download_nats_cli(target)
  end
end

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{release_version}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  # sh "cp hello.rb #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  sh "tar xzf packaging/cf-#{CF_CLI_VERSION}-#{target}.tgz -C #{package_dir}"
  sh "tar xzf packaging/nats-#{NATS_CLI_VERSION}-#{target}.tgz -C #{package_dir}"
  sh "mv #{package_dir}/nats* #{package_dir}/nats"

  sh "cp packaging/wrappers/uaac.sh #{package_dir}/uaac"
  sh "chmod +x packaging/wrappers/uaac.sh #{package_dir}/uaac"

  sh "cp -pR packaging/helpers #{package_dir}/"

  sh "cp -pR packaging/vendor #{package_dir}/lib/"

  sh "cp Gemfile* #{package_dir}/lib/vendor/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"
  NATIVE_GEMS.each do |gem, version|
    sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem}-#{version}.tar.gz " +
      "-C #{package_dir}/lib/vendor/ruby"
  end

  if !ENV['DIR_ONLY']
    sh "tar -czf #{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  sh "cd packaging && curl -L -O --fail " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end

def download_native_extension(target, gem_name_and_version)
  sh "curl -L --fail -o packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz"
end

def download_cf_cli(target)
  url = case target
  when "linux-x86"
    "https://cli.run.pivotal.io/stable?release=linux32-binary&version=#{CF_CLI_VERSION}&source=traveling-cf-admin"
  when "linux-x86_64"
    "https://cli.run.pivotal.io/stable?release=linux64-binary&version=#{CF_CLI_VERSION}&source=traveling-cf-admin"
  when "osx"
    "https://cli.run.pivotal.io/stable?release=macosx64-binary&version=#{CF_CLI_VERSION}&source=traveling-cf-admin"
  end
  sh "curl -L --fail -o packaging/cf-#{CF_CLI_VERSION}-#{target}.tgz #{url}"
end

def download_nats_cli(target)
  url = "https://github.com/soutenniza/nats/releases/download/#{NATS_CLI_VERSION}/nats-#{NATS_CLI_VERSION}-#{target}.tar.gz"
  sh "curl -L --fail -o packaging/nats-#{NATS_CLI_VERSION}-#{target}.tgz #{url}"
end

def release_version
  CF_CLI_VERSION
end

def uaac_cli_version
  @uaac_cli_version ||= begin
    if `bundle list | grep uaac` =~ /(\d+\.\d+\.\d+)/
      $1
    end
  end
end
