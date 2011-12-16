#!/bin/sh

daemon="$1"
shift
exec sudo "/etc/init.d/$daemon" "$@"
