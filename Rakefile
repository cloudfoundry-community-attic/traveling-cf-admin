# For Bundler.with_clean_env
require 'bundler/setup'

PACKAGE_NAME = "bosh_cli"

RELEASE_NAME = "Self-contained BOSH CLI"
RELEASE_DESCRIPTION = <<-EOS
It is now easier than ever to install and use BOSH CLI.

Install for local user with:

```
curl -k -s https://raw.githubusercontent.com/cloudfoundry-community/bosh_cli_install/master/binscripts/installer | bash
```

Visit http://bosh-cli.cfapps.io/ for one-line installation instructions. Alternately manually download, unpack, add path to `$PATH` and use `bosh`, `terraform`, `spiff`.

Bootstrapping your first BOSH:

```
bosh bootstrap deploy
```
EOS

# http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html
TRAVELING_RUBY_VERSION = "20141224-2.1.5"
SPIFF_VERSION = "1.0.3"
TERRAFORM_VERSION = "0.3.6"

# Must match Gemfile
NOKOGIRI_VERSION = "1.6.5"
SQLITE3_VERSION = "1.3.9"
YAJL_VERSION = "1.2.1"
THIN_VERSION = "1.6.3"
EVENTMACHINE_VERSION = "1.0.4"
NATIVE_GEMS = {
  "nokogiri" => NOKOGIRI_VERSION,
  "sqlite3" => SQLITE3_VERSION,
  "yajl-ruby" => YAJL_VERSION,
  "thin" => THIN_VERSION,
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
    tag = "v#{bosh_cli_version}"
    sh "git commit -a -m 'Releasing #{tag}'"
    sh "git tag #{tag}"
    sh "git push origin master"
    sh "git push --tag"
    sh "github-release release \
      --user cloudfoundry-community --repo traveling-bosh --tag #{tag} \
      --name '#{RELEASE_NAME} #{tag}' \
      --description '#{RELEASE_DESCRIPTION}'"
  end

  desc "Upload files to github release"
  task :upload_files do
    tag = "v#{bosh_cli_version}"

    files = Dir["*#{bosh_cli_version}*.tar.gz"]
    if files.size == 0
      $stderr.puts "Run `rake package` to create packages first"
      exit 1
    end
    files.each do |file|
      sh "github-release upload \
        --user cloudfoundry-community --repo traveling-bosh --tag #{tag} \
        --name #{file} --file #{file}"
    end
  end
end

namespace :package do
  namespace :linux do
    desc "Package your app for Linux x86"
    task :x86 => [:bundle_install,
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-yajl-ruby-#{YAJL_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-thin-#{THIN_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-eventmachine-#{EVENTMACHINE_VERSION}.tar.gz",
      "packaging/terraform-#{TERRAFORM_VERSION}-linux-x86.zip",
      ] do
      create_package("linux-x86")
    end

    desc "Package your app for Linux x86_64"
    task :x86_64 => [:bundle_install,
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-yajl-ruby-#{YAJL_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-thin-#{THIN_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-eventmachine-#{EVENTMACHINE_VERSION}.tar.gz",
      "packaging/spiff-#{SPIFF_VERSION}-linux-x86_64.zip",
      "packaging/terraform-#{TERRAFORM_VERSION}-linux-x86_64.zip",
    ] do
      create_package("linux-x86_64")
    end
  end

  desc "Package your app for OS X"
  task :osx => [:bundle_install,
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-sqlite3-#{SQLITE3_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-yajl-ruby-#{YAJL_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-thin-#{THIN_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-eventmachine-#{EVENTMACHINE_VERSION}.tar.gz",
    "packaging/spiff-#{SPIFF_VERSION}-osx.zip",
    "packaging/terraform-#{TERRAFORM_VERSION}-osx.zip",
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

  task :backport_nokogiri_version do
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

  file "packaging/spiff-#{SPIFF_VERSION}-#{target}.zip" do
    download_spiff(target)
  end

  file "packaging/terraform-#{TERRAFORM_VERSION}-#{target}.zip" do
    download_terraform(target)
  end
end

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{bosh_cli_version}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  # sh "cp hello.rb #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  sh "unzip packaging/spiff-#{SPIFF_VERSION}-#{target}.zip -d #{package_dir}; true"
  sh "unzip packaging/terraform-#{TERRAFORM_VERSION}-#{target}.zip -d #{package_dir}; true"

  sh "cp packaging/wrappers/bosh.sh #{package_dir}/bosh"
  sh "chmod +x packaging/wrappers/bosh.sh #{package_dir}/bosh"
  sh "cp packaging/wrappers/bosh-registry.sh #{package_dir}/bosh-registry"
  sh "chmod +x packaging/wrappers/bosh-registry.sh #{package_dir}/bosh-registry"

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

def download_spiff(target)
  if target == "linux-x86"
    puts "spiff not supported on 32-bit linux, skipping..."
  else
    url = if target =~ /linux/
      "https://github.com/cloudfoundry-incubator/spiff/releases/download/v#{SPIFF_VERSION}/spiff_linux_amd64.zip"
    else
      "https://github.com/cloudfoundry-incubator/spiff/releases/download/v#{SPIFF_VERSION}/spiff_darwin_amd64.zip"
    end
    sh "curl -L --fail -o packaging/spiff-#{SPIFF_VERSION}-#{target}.zip #{url}"
  end
end

def download_terraform(target)
  terraform_target = case target
  when "linux-x86_64"
    "linux_amd64"
  when "linux-x86"
    "linux_386"
  when "osx"
    "darwin_amd64"
  end
  url = "https://bintray.com/artifact/download/mitchellh/terraform/terraform_#{TERRAFORM_VERSION}_#{terraform_target}.zip"
  sh "curl -L --fail -o packaging/terraform-#{TERRAFORM_VERSION}-#{target}.zip #{url}"
end

def bosh_cli_version
  @bosh_cli_version ||= begin
    if `bundle list | grep bosh_cli` =~ /(\d+\.\d+\.\d+)/
      $1
    end
  end
end
