#!/bin/sh

suffix2n()
{
    for n in "$@"; do
        x=$(echo "$n" | sed -rn "s/([0-9]+)([^0-9]|$)/\1 \2/p")
        set -- $x
        case "$2" in
            [Kk]) m=1000 ;;
            [Mm]) m=1000000;;
            [Cc]) m=100;;
            *) m=1;;
        esac
        echo $(($1 * $m))
    done
}

suffix2n "$@"
