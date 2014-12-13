# For Bundler.with_clean_env
require 'bundler/setup'

PACKAGE_NAME = "bosh_cli"
INTERNAL_BIN = "bosh"
VERSION = "1.2788.0" # TODO: get from bosh_cli gem version

# http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html
TRAVELING_RUBY_VERSION = "20141209-2.1.5"
NOKOGIRI_VERSION = "1.6.5"  # Must match Gemfile
SQLITE3_VERSION = "1.3.9"  # Must match Gemfile
MYSQL2_VERSION = "0.3.17"  # Must match Gemfile
PG_VERSION = "0.17.1"  # Must match Gemfile
NATIVE_GEMS = {"nokogiri" => NOKOGIRI_VERSION}
# , "sqlite3" => SQLITE3_VERSION,
#               "mysql2" => MYSQL2_VERSION, "pg" => PG_VERSION}

desc "Package your app"
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx']

namespace :package do
  namespace :linux do
    desc "Package your app for Linux x86"
    task :x86 => [:bundle_install,
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-mysql2-#{MYSQL2_VERSION}.tar.gz",
      # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-pg-#{PG_VERSION}.tar.gz"
    ] do
      create_package("linux-x86")
    end

    desc "Package your app for Linux x86_64"
    task :x86_64 => [:bundle_install,
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-mysql2-#{MYSQL2_VERSION}.tar.gz",
      # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-pg-#{PG_VERSION}.tar.gz"
    ] do
      create_package("linux-x86_64")
    end
  end

  desc "Package your app for OS X"
  task :osx => [:bundle_install,
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
    # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-sqlite3-#{SQLITE3_VERSION}.tar.gz",
    # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-mysql2-#{MYSQL2_VERSION}.tar.gz",
    # "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-pg-#{PG_VERSION}.tar.gz"
  ] do
    create_package("osx")
  end

  desc "Install gems to local directory"
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.1\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end
    sh "rm -rf packaging/tmp"
    sh "mkdir packaging/tmp"
    sh "cp Gemfile Gemfile.lock packaging/tmp/"
    Bundler.with_clean_env do
      sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
    end
    sh "rm -rf packaging/tmp"
    sh "rm -f packaging/vendor/*/*/cache/*"
    sh "rm -rf packaging/vendor/ruby/*/extensions"
    sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm"
    sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm"
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
end

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  # sh "cp hello.rb #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  sh "cp packaging/wrapper.sh #{package_dir}/#{INTERNAL_BIN}"
  sh "chmod +x packaging/wrapper.sh #{package_dir}/#{INTERNAL_BIN}"
  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp Gemfile Gemfile.lock #{package_dir}/lib/vendor/"
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
