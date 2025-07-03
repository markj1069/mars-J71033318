#! /usr/bin/env bash

PGMID=OLSBLD

# Build the Olaus Shell Test Library from it individual components

printf "\n%s\n" "Build the Olaus Shell Test Library."

# Append the lib/*.sh files into lib/olaus.

printf "%s\n" "# *** Olaus Shell Test Library ***" >lib/olstst

# Make the modification time for this filename
timestamp=$( stat --printf="%y" "lib/olstst" )
timestamp=${timestamp/ /T}   # Insert a "T" in the timestamp.
timestamp=${timestamp:0:19}  # Strip off the nanoseconds.

printf "%s\n" "# Created: $timestamp" >> lib/olslib

version=$(cat lib/VERSION)

printf "%s\n" "# Version: $version" >> lib/olslib

bin/ols-append lib/ols_tst/olstst.sh lib/olstst
bin/ols-append lib/ols_tst/tst_plan.sh lib/ols_tst
bin/ols-append lib/ols_tst/
for file in $( /usr/bin/ls -1 lib/*.sh )
do
    bin/ols-append "$file" "lib/olslib"
done
