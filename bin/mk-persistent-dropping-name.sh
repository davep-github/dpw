#!/bin/bash

# what a terrible way to pass parameters.  I should be ashamed.
# I am.
# No wait, it's dynamic scoping.  It's keyword args.
#
: ${DOT=}; export DOT
: ${creat_p=true}; export creat_p
: ${persist_p=true}; export persist_p
: ${mkdir_only_p=false}; export mkdir_only_p

mk-dropping-name.sh "$@"
