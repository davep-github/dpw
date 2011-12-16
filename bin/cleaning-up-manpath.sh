manpath | sed "s/:/\n/g" | while read p; do   realpath "$p"; done | sort | uniq
