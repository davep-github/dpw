sig_handler()
{
    local sig=$1
    echo 1>&2 "sig_handler(), sig: $sig"
    rm -f "$TOUCH_REF_FILE"     # ???
}

for sig in 2 3 4 5 6 7 8 15
do
  trap "echo ; echo $0: Got sig $sig, handling...; sig_handler $sig; exit $sig" $sig
done

# test this template
ZZZ=100
echo "Hit ^C after < $ZZZ seconds"
sleep $ZZZ
echo "Buzzz! Too late, but thanks for playing."
