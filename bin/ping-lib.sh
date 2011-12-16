#-*-shell-script-*-

prog=`basename $0`
echo $prog: $* 1>&2

Usage()
{
   echo "${prog}: usage: [-$option_str]" 1>&2
   exit 1
}

# init optional vars to defaults here...
ECHO=
ECHO="echo $prog: "

# see the man page of getopt for inadequacies.

option_str='vi:'
args=` getopt $option_str $* `

[ $? != 0 ] && Usage

set -- $args
for i in $*
do
    case $1 in
	-v) verbose=y;;
	-i) ISP=$2; shift;;
	--) shift ; break ;;
	*) 
	    echo 1>&2 "Unsupported option>$1<";
	    exit 1 ;;
    esac
    shift
done

if [ "$verbose" = "y" ]
then
    REDIR=
    NEWLINE=
else
    verbose=
    REDIR="> /dev/null"
    NEWLINE='-n'
fi

pingit()
{
    s=$1
    extra=$2
    rc=1
# let caller specify spacing
#     if [ -z "$extra" ]
#     then
#     	sep=''
#     else
#         sep=' '
#     fi
    ###echo $NEWLINE "Pinging $extra$s"
    echo $NEWLINE "${extra}ping $s"
    if eval ping -c 2 $s $REDIR
    then
	if [ "$verbose" != 'y' ]
	then
	    echo " ...ok."
            rc=0
	fi
    else
	echo " ...ping failed"
        rc=1
    fi

    return $rc
}

find_nameservers ()
{
    servers=$(grep '^nameserver' /etc/resolv.conf | while read line
		do
		    #echo 1>&2 "line>$line<"
		    set -- $line
		    #echo 1>&2 "\$2>$2<"
		    if [ "$2" != "127.0.0.1" ]
		    then
			echo $2
		    fi
		done)

    #echo 1>&2 "out servers>$servers<"
    echo "$servers"
}
