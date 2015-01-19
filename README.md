Traveling Cloud Foundry Admin CLIs
==================================

This project packages the CLIs used by Cloud Foundry administrators - the `cf` CLI and useful admin plugins, and the `uaac` CLI (a Ruby gem). They can be downloaded and used by anyone without requiring Ruby and native extensions.

Support for including useful admin plugins requires:

-	[![#332](https://github-shields.cfapps.io/github/cloudfoundry/cli/issues/332.svg?style=flat)](https://github-shields.cfapps.io/github/cloudfoundry/cli/issues/332)

And some people to start writing admin plugins... hint hint.

See below for the one-line installation instructions.

Dependencies
------------

The goal of traveling-cf-admin is to have very few dependencies. `curl` is the only dependency for the simple installation process; and for `bosh bootstrap deploy` command.

For Linux:

```
sudo apt-get update
sudo apt-get install curl -y
```

For OS X:

```
brew install curl
```

One user - simple installation
------------------------------

From any OS X or Linux terminal run the following command. It will download, unpack, and setup your `$PATH`:

```
curl -s https://raw.githubusercontent.com/cloudfoundry-community/traveling-cf-admin/master/scripts/installer | bash
```

All users - simple installation
-------------------------------

From any OS X or Linux terminal run the following command. It will globally download, unpack, and setup your `$PATH`:

```
curl -s https://raw.githubusercontent.com/cloudfoundry-community/traveling-cf-admin/master/scripts/installer | sudo bash
```

Alternately see [step-by-step instructions](#step-by-step-installation) below.

Step-by-step installation
-------------------------

To download the latest release https://github.com/cloudfoundry-community/traveling-cf-admin/releases

For example:

```
rm -rf tar xfz cf-admin*.tar.gz
wget https://github.com/cloudfoundry-community/traveling-cf-admin/releases/download/v6.8.0/cf-admin-6.8.0-linux-x86_64.tar.gz
tar xfz cf-admin*.tar.gz
rm cf-admin*.tar.gz
```

Rewrite the internal shebangs of ruby-installed binaries:

```
./cf-admin*/helpers/rewrite-shebangs.sh
```

To check that `cf` and `uaac` are runnable:

```
./cf-admin-*/cf
./cf-admin-*/uaac
```

You could now create a symlink:

```
rm -f cf-admin
ln -s $PWD/$(ls -d cf-admin* | head -n1) cf-admin
```

Check that its runnable via the symlink:

To check that the CLIs are runnable:

```
./cf-admin/cf
./cf-admin/uaac
```

Finally, add the `cf-admin` path into your `$PATH`:

```
export PATH=$PATH:/path/to/cf-admin
```

Background
----------

This project uses http://phusion.github.io/traveling-ruby/

Create & publish releases
-------------------------

Anyone in the @cloudfoundry-community can be responsible for create new releases whenever new CF CLI or UAAC versions are released. This section contains the instructions.

You are required to use Ruby 2.1 to create releases as this is what traveling-ruby uses.

You will also need to install https://github.com/aktau/github-release to share the releases on Github.

The release version number is directly taken from the CF CLI to be packaged.

To upgrade the uaac version (via `cf-uaac` rubygem):

```
bundle update
```

To create the new release, create new commit & git tag, and upload the packages:

```
rake release
```

This will create three packages:

```
$ ls cf-admin*
cf-admin-6.8.0-linux-x86.tar.gz
cf-admin-6.8.0-linux-x86_64.tar.gz
cf-admin-6.8.0-osx.tar.gz
```

It will then create a GitHub release and upload these assets to the release. For example, for [v1.1788.0](https://github.com/cloudfoundry-community/traveling-bosh/releases/tag/v1.2788.0).

Finally, update `scripts/installer` with the new CF CLI version.
