#!/usr/bin/env bash

{
    echo "=== $(date) === in $0 ==="
    echo "USER>$USER<"
    echo "DISPLAY>$DISPLAY<"
    echo "XAUTHORITY>$XAUTHORITY<"
    export XAUTHORITY=/home/davep/.Xauthority
    xset -display :0.0 m 20/31 10
    rc=$?
    xset -display :0.0 q
    echo "=== rc: $rc: $(date) === outta $0 ==="
} 1>> /home/davep/log/xset.log 2>&1

exit 0
