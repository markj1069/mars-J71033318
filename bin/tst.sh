#! /usr/bin/env bash

cat >tmp.tmp <<"/*"
9999 filename-end
3000 middle-filename-1
6000 middle-filename-2
9000 middle-filename-3
0010 filename-start
/*
sort --sort=general-numeric < tmp.tmp >tmp2.tmp

cut --delimiter=' ' --fields=2 < tmp2.tmp
