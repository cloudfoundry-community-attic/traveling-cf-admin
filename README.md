Traveling BOSH CLI
==================

This project packages the BOSH CLI (with plugins) into self-contained packages that can be downloaded and used by anyone without requiring Ruby and native extensions.

![clam](http://cl.ly/image/1q323l2V2Q3S/bosh-clam.png)

In addition, if you act now, it also includes:

-	`bosh bootstrap deploy` and `bosh micro` commands to create, update and delete Micro BOSH VMs
-	`spiff` tool for merging deployment manifests together
-	`terraform` CLI and plugins (thanks @mitchellh for permission) that are increasingly being used to provision networking & bootstrap deployment of BOSH, Cloud Foundry, etc
-	`bosh update cli` command to upgrade to a newer BOSH CLI version

Dependencies
------------

The goal of traveling-bosh is to have very few dependencies. `curl` is the only dependency for the simple installation process; and for `bosh bootstrap deploy` command.

Some use cases of BOSH itself might require/desire `git` CLI to be installed too.

For Linux:

```
sudo apt-get update
sudo apt-get install curl -y
```

For OS X:

```
brew install curl
```

Simple installation
-------------------

From any OS X or Linux terminal run the following command to download, unpack, and setup your `$PATH`:

```
curl -s https://raw.githubusercontent.com/cloudfoundry-community/traveling-bosh/master/scripts/installer | bash
```

Alternately see [step-by-step instructions](#step-by-step-installation) below.

Getting started
---------------

It takes about 5 minutes to bootstrap your first BOSH.

To bootstrap your first BOSH (known as a micro BOSH), on either AWS, OpenStack or vSphere:

```
mkdir workspace; cd workspace
bosh bootstrap deploy
```

You will then select an IaaS, enter your credentials, and follow the minimalistic prompts.

For AWS, if you have any VPCs you will be prompted to select one or to deploy into legacy EC2.

Once the Q&A has completed the remainder of the installation will proceed to completion without further prompting.

For AWS/Openstack, this process will create the following resources:

-	1 keypair
-	3 security groups (ssh, dns-server, bosh)
-	1 `m1.medium` VM with an attached 16G disk (to run micro BOSH)
-	1 elastic/floating IP (to access the VM) - if AWS EC2 or OpenStack Nova networking

Locally, the following files are created within the current folder (hence we changed to a `workspace` folder in the example command above):

```
.
├── deployments
│   ├── bosh-deployments.yml
│   ├── bosh-registry.log
│   └── firstbosh
│       ├── bosh_micro_deploy.log
│       ├── light-bosh-stemcell-2798-aws-xen-ubuntu-trusty-go_agent.tgz
│       └── micro_bosh.yml
├── settings.yml
└── ssh
    └── firstbosh
```

Summary of files:

-	`settings.yml` is the summary of all the prompts you answered, plus any values generated from the IaaS. You can stop `bosh bootstrap deploy` prompting for answers by pre-creating this file.
-	`deployments/firstbosh/micro_bosh.yml` the configuration file for the `bosh micro deploy` command that is automatically run for you. You can subsequently make changes (enlarge the disk for example), and re-run `bosh micro deploy` from within the `deployments` folder.
-	`ssh/firstbosh` is the private key for the keypair; and is to be used to SSH into the Micro BOSH if ever necessary for debugging

### Next steps

At the end of the `bosh bootstrap deploy` output is the following:

```
Deployed `firstbosh/micro_bosh.yml' to `https://54.243.234.204:25555', took 00:04:33 to complete
```

You can now target the BOSH with the BOSH CLI using this URL:

```
$ bosh target https://54.243.234.204:25555
Target set to `firstbosh'
Your username: admin
Enter password: admin
Logged in as `admin'
```

Answer `admin` to the username/password prompts. If you ever need to login again, run `bosh login`.

Confirm that you are targeting the new BOSH:

```
$ bosh status
Config
  /home/vagrant/.bosh_config

Director
  Name       firstbosh
  URL        https://54.243.234.204:25555
  Version    1.2798.0 (00000000)
  User       admin
  UUID       2c591a3f-e489-4739-99da-ba147162ee4a
  CPI        aws
  dns        enabled (domain_name: microbosh)
  compiled_package_cache disabled
  snapshots  disabled

Deployment
  not set
```

Next you need to upload a "stemcell" (the base image for VMs). We have already downloaded one during bootstrapping, so run:

```
bosh upload stemcell deployments/firstbosh/*bosh-stemcell*
```

### Deleting your BOSH

First you need to delete any BOSH deployments (running VMs). To delete each one you need its name:

```
bosh deployments
```

For each deployment, delete with:

```
bosh delete deployment NAME
```

Finally, you can delete the micro BOSH VM and its attached disk.

```
cd deployments
bosh micro delete
```

You will need to delete the elastic/floating IP, security group and keypair manually via your IaaS web console/API.

### Reusing IaaS configuration

`bosh bootstrap deploy` can look up existing IaaS configuration via a `~/.fog` configuration file. It will be detected and these credentials will be easily reusable.

You can specify multiple AWS accounts and OpenStack accounts/tenants:

```yaml
:my_aws:
  :aws_access_key_id: XXXXXXXXX
  :aws_secret_access_key: YYYYYYYYYYYY
:my_openstack:
  :openstack_auth_url: https://my.openstack.com:5000/v2.0/tokens
  :openstack_username: XXXXXXXXX
  :openstack_api_key: YYYYYYYYYYYY
  :openstack_tenant: my-tenant
```

Running `bosh bootstrap deploy` would now look like:

```
$ bosh bootstrap deploy
Auto-detected infrastructure API credentials at ~/.fog (override with $FOG)
1. AWS (my_aws)
2. OpenStack (my_openstack)
3. Alternate credentials
Choose an auto-detected infrastructure
```

Very convenient if you are booting BOSH multiple times, or tearing it down/rebuilding for dev/test work.

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
