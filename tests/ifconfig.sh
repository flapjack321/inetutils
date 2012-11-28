#!/bin/sh

# Copyright (C) 2011, 2012 Free Software Foundation, Inc.
#
# This file is part of GNU Inetutils.
#
# GNU Inetutils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# GNU Inetutils is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see `http://www.gnu.org/licenses/'.

# Tests to establish functionality of ifconfig utility.
#
# Written by Mats Erik Andersson.

# Prerequisites:
#
#  * Shell: SVR4 Bourne shell, or newer.

# Is usage explanation in demand?
#
if test "$1" = "-h" || test "$1" = "--help" || test "$1" = "--usage"; then
    cat <<HERE
Test utility for ifconfig.

The following environment variables are used:

VERBOSE		Be verbose, if set.
FORMAT		Test only these output formats.  A list of
		formats is excepted.

HERE
    exit 0
fi

# Step into `tests/', should the invokation
# have been made outside of it.
#
[ -d src ] && [ -f tests/syslogd.sh ] && cd tests/

. ./tools.sh

# Executable uder test.
#
IFCONFIG=${IFCONFIG:-../ifconfig/ifconfig$EXEEXT}


if test ! -x "$IFCONFIG"; then
    echo >&2 "Missing executable '$IFCONFIG'.  Skipping test."
    exit 77
fi

if test -z "${VERBOSE+set}"; then
    silence=:
    bucket='>/dev/null'
fi

if test -n "$VERBOSE"; then
    set -x
    $IFCONFIG --version | $SED '1q'
fi

# Locate the loopback interface.
#
IF_LIST=`$IFCONFIG -l`
LO=`expr "$IF_LIST" : '.*\(lo0\{0,\}\).*'`

if test -z "$LO"; then
    echo >&2 'Unable to locate loopback interface.  Failing.'
    exit 1
fi

find_lo_addr () {
   $IFCONFIG ${1+--format=$1} -i $LO | \
   eval $GREP '"inet .*127\.0\.0\.1"' $bucket 2>/dev/null
}

errno=0

for fmt in ${FORMAT:-gnu gnu-one-entry net-tools osf unix}; do
    $silence echo "Checking format $fmt."
    find_lo_addr $fmt || { errno=1; echo >&2 "Failed with format '$fmt'."; }
done

test $errno -ne 0 || $silence echo "Successful testing".

exit $errno
