#!/bin/sh

# a line:
# 1      2 3          4 5     6    7 8   9  10   11         12 13     14...
# 353431 0 lrwxrwxrwx 1 davep root 3 Apr 30 2004 ./bin/oxns -> xns
# shift 5
# 1    2 3   4 5     6          7  8   9...
# root 3 Apr 30 2004 ./bin/oxns -> xns
#
# We want access to $9 to see if there are too many words resulting from
# set --

REJ="$HOME/tmp/re-symlink.sh.rej.$$"
echo "-------" >> $REJ
date >> $REJ

echo "#!/bin/sh"
echo

start_dir="$PWD"
while read line
do
    cd "$start_dir"
    set -- $line
    [ -z "$1" ] && continue
    shift 5
    link="$6"
    arrow="$7"
    target="$8"
    extra="$9"

    if [ "$arrow" != "->" ]
    then
        echo "#!!!!! Malformed input !!!!!"
        echo "#! $line"
        echo "#! arrow [$arrow]"
        echo "#!!!!!"
        continue
    fi

    link_dir=$(dirname "$link")
    link_base=$(basename "$link")
    link_file=$(realpath "$link")
    if [ -L "$6" ]
    then
        echo "#$6 isa link, skipping."
        continue
    fi
    if [ -f "$6" ]
    then
        cd "$link_dir"
        if cmp "$link_file" "$target"
        then
            echo '#files are the same, replace with symlink'
            echo "# $6 $7 $8 $9"
            echo "(cd ~/$link_dir; rm $dash_i $link_base && ln -s $target $link_base)"
        else
            echo '#files differ.'
            echo >>$REJ "files differ, line:"
            echo >>$REJ "$line"
            echo >>$REJ "-------"
        fi
    fi
done
        
        

    
    
