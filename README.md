Traveling BOSH CLI
==================

This project packages the BOSH CLI (with plugins) into self-contained packages that can be downloaded and used by anyone without requiring Ruby and native extensions.

In addition, if you act now, it also includes:

-	the `bosh bootstrap deploy` and `bosh micro` commands to create, update and delete Micro BOSH VMs
-	the `spiff` tool for merging deployment manifests together
-	`bosh update cli` command to upgrade to a newer BOSH CLI version

Simple installation
-------------------

From any OS X or Linux terminal run the following command to download, unpack, and setup your `$PATH`:

```
curl -k -s https://raw.githubusercontent.com/cloudfoundry-community/bosh_cli_install/master/binscripts/installer | bash
```

Step-by-step installation
-------------------------

To download the latest release https://github.com/cloudfoundry-community/traveling-bosh/releases

For example:

```
rm -rf tar xfz bosh_cli*.tar.gz
wget https://github.com/cloudfoundry-community/traveling-bosh/releases/download/v1.2788.0/bosh_cli-1.2788.0-linux-x86_64.tar.gz
tar xfz bosh_cli*.tar.gz
rm bosh_cli*.tar.gz
```

Rewrite the internal shebangs of ruby-installed binaries:

```
./traveling-bosh/helpers/rewrite-shebangs.sh
```

To check that its runnable:

```
./bosh_cli-*/bosh
```

You could now create a symlink:

```
rm -f bosh-cli
ln -s $PWD/$(ls -d bosh_cli* | head -n1) bosh-cli
```

Check that its runnable via the symlink:

To check that its runnable:

```
./bosh-cli/bosh
```

Finally, add the `bosh-cli` path into your `$PATH`:

```
export PATH=$PATH:/path/to/bosh-cli
```

Background
----------

This project uses http://phusion.github.io/traveling-ruby/

Create & publish releases
-------------------------

Anyone in the @cloudfoundry-community can be responsible for create new releases whenever new BOSH CLI versions are released. This section contains the instructions.

You are required to use Ruby 2.1 to create releases as this is what traveling-ruby uses.

You will also need to install https://github.com/aktau/github-release to share the releases on Github.

The release version number is directly taken from the BOSH CLI to be packaged. First, upgrade to latest BOSH CLI.

```
bundle update
```

To create the new release, create new commit & git tag, and upload the packages:

```
rake release
```

This will create three packages:

```
$ ls bosh_cli*
bosh_cli-1.2788.0-linux-x86.tar.gz
bosh_cli-1.2788.0-linux-x86_64.tar.gz
bosh_cli-1.2788.0-osx.tar.gz
```

It will then create a GitHub release and upload these assets to the release. For example, for [v1.1788.0](https://github.com/cloudfoundry-community/traveling-bosh/releases/tag/v1.2788.0).

Additional information
----------------------

This traveling-ruby project is made tricky because it is re-entrant. For example, `bosh bootstrap deploy` calls out to `bosh micro deploy`, which in turn calls out to `bosh-registry`.

This requires re-writing the shebang of all the binaries bundled with rubygems to force the use of the exact ruby being bundled.

Other thoughts:

-	The `bosh update cli` command comes from a BOSH CLI plugin https://github.com/cloudfoundry-community/traveling_bosh_cli_plugin
-	The `bosh bootstrap deploy` command comes from the [bosh-bootstrap](https://github.com/cloudfoundry-community/bosh-bootstrap) project
-	`spiff` is only included in the 64-bit Linux & OS X packages because only 64-bit versions are released https://github.com/cloudfoundry-incubator/spiff/releases

Including patched BOSH gems
---------------------------

Currently there are patches required for BOSH gems and dependency gems to use the newer versions of natively compiled gems available from traveling-ruby. We can do this via a Gemfile. But when we package up traveling-bosh it will include the entire BOSH git repository, which inflated the downloadable package from 60M to 1G.

The https://github.com/drnic/flattened_bosh_for_traveling_bosh repository was created to house the smallest version of BOSH repo that contains the patched parts of BOSH.

The result is the distributed packages are about 60M each, rather than 1G. Hurray.

To upgrade to a new base version of BOSH, with the patches reapplied, see https://github.com/drnic/flattened_bosh_for_traveling_bosh

But really, hopefully all the patches are merged and shipped in public gems soon.
