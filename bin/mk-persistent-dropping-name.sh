#!/bin/bash

# what a terrible way to pass parameters.  I should be ashamed.
# I am.
: ${DOT=}; export DOT
: ${creat_p=t}; export creat_p
: ${persist_p=t}; export persist_p
: ${mkdir_only_p=}; export mkdir_only_p

mk-dropping-name.sh "$@"
