#!/bin/sh
set -x

BUP_GROUP=backup
BUP_FILE_PERMS='g+rw'
BUP_DIR_PERMS='g+rwx'


                                      dst=/media/dumps/2004-05-01
if [ -n "$BUP_GROUP" ]
then
    chgrp -R $BUP_GROUP $dst
    find $dst -type d | xargs chmod $BUP_DIR_PERMS
    find $dst -type f | xargs chmod $BUP_FILE_PERMS
fi
