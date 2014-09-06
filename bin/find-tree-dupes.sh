#!/bin/bash

echo "#!/bin/sh"
echo ""

for f in $(cat /tmp/etc-files)
do
    name=$(basename $f)
    num=$(find /etc-work -name "$name" | wc -l)
    if [ "$num" -gt 1 ]
    then
        find /etc-work -name "$name" | grep -v "^$f$" | while read x
        do
            echo "# $x"
        done
        echo -n "rm "
        find /etc-work -name "$name" | grep "^$f$"

        echo '--'
    fi
done

