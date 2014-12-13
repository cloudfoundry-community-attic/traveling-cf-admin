Traveling BOSH CLI
==================

This project packages the BOSH CLI (with plugins) into self-contained packages that can be downloaded and used by anyone without requiring Ruby and native extensions.

Download
--------

To download the latest release https://github.com/cloudfoundry-community/traveling-bosh/releases

Background
----------

This project uses http://phusion.github.io/traveling-ruby/

Create releases
---------------

Anyone in the @cloudfoundry-community can create new releases whenever new BOSH CLI versions are released. This section contains the instructions.

You are required to use Ruby 2.1 to create releases as this is what traveling-ruby uses.

The release version number is directly taken from the BOSH CLI to be packaged. First, upgrade to latest BOSH CLI.

```
bundle update
rake package:bundle_install
```

To create the new release:

```
rake package
```

This will create three packages:

```
$ ls bosh_cli*
bosh_cli-1.2788.0-linux-x86.tar.gz
bosh_cli-1.2788.0-linux-x86_64.tar.gz
bosh_cli-1.2788.0-osx.tar.gz
```
