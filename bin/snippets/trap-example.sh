
trap_fun()
{
    local sig="${1-}"
    echo "sig>$sig<"
    exit 1
}

for sig in 2 3 4 5 6 7 8 15
do
	trap "trap_fun $sig" $sig
done

