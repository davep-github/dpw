#!/bin/sh

tar -c -v -f /dev/null --exclude '.svn*' --exclude '*.pyc' --exclude 'cscope*' --exclude TAGS pkt-sim
