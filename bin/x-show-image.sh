#!/bin/sh
set -x
viewit()
{
    exec $viewer "$@"
}


viewer=`$HOST_INFO -n '' x_image_viewer`

if [ -n "$viewer" ]
then
    viewit "$viewer" "$@"
fi

image_viewers='blahgh
lergh
xli
xloadimage
xv
ee'				# try this last since it can
				# also be the icky bsd editor

for x in $image_viewers
do
    viewer=`sp $x | head -1`
    if [ -n "$viewer" ]
    then
	viewit "$viewer" "$@"
    fi
done

echo 1>&2 'No viewers found.'
exit 1

