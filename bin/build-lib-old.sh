#! /usr/bin/env bash

PGMID=OLSBLD
OLSLIBPATH=''
OLSLIBSRC=''
BUILDAPPEND=''


# Build the Olaus Shell Library from it individual components

printf "\n%s\n" "Build the Olaus Shell Library."

# Append the lib/*.sh files into lib/olaus.

printf "%s\n" "#-------------------------- Olaus Bash Shell Library ---------------------------" >lib/OLSLIB

# Make the modification time for this filename
timestamp=$( stat --printf="%y" "lib/OLSLIB" )
timestamp=${timestamp/ /T}   # Insert a "T" in the timestamp.
timestamp=${timestamp:0:19}  # Strip off the nanoseconds.

printf "%s\n" "# Created: $timestamp" >> lib/OLSLIB

version=$(cat lib/VERSION)

printf "%s\n" "# Version: $version" >> lib/OLSLIB
printf "%s\n" "#-------------------------------------------------------------------------------"

sort lib/ols_lib/FILENAME | cut --delimiter=' ' --fields=2 | xargs -I % -n 1 ./bin/build-append % lib/olslib

