#! /usr/bin/env bash

# Build the Olaus Shell Test Library

PGMID=OLSBLD
library="lib/OLSTST"
source_lib="lib/ols_tst"
library_title="Olaus Shell Test Library"


# Build the library from it individual components

printf "\n%s\n" "Build the $library_title."

# Append the FILELIST files into the library.

printf "%s\n" "# Library: $library_title" > $library

# Make the modification time for this filename
timestamp=$( stat --printf="%y" "$library" )
timestamp=${timestamp/ /T}   # Insert a "T" in the timestamp.
timestamp=${timestamp:0:19}  # Strip off the nanoseconds.

printf "%s\n" "# Created: $timestamp" >> $library

version=$(cat lib/VERSION)

printf "%s\n" "# Version: $version" >> $library
printf "%s\n" "#-----------------------------------------------------------------------"

list_file=$(mktemp)

sort $source_lib/FILELIST | cut --delimiter=' ' --fields=2 > $list_file

sed -e "s'^'$source_lib/'" $list_file | xargs -I % -n 1 -t bin/build-append % $library

rm $list_file
