#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

ls $SELFDIR/lib/vendor/ruby/2.1.0/bin/* | xargs perl -pi -e "s{^#\!/usr/bin/env ruby}{#\!$SELFDIR/lib/ruby/bin/ruby}"
