#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
ROOTDIR="`cd \"$SELFDIR\"/.. && pwd`"

cd $ROOTDIR/lib/vendor/ruby/2.1.0/gems/bosh_cli_plugin_micro*
patch -p1 < $ROOTDIR/patches/*

cd $ROOTDIR
