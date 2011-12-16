#!/bin/sh
set -x

TUN_FILE=/var/tmp/tunnel.log
digital_net=16
hp_net=15
CRL_GW=192.58.206.62		# callahan


start_if()
{
    started=n
    echo "Find CRL gateway"
    while :
    do
	my_gw=`/usr/yokel/bin/ppp-info itn0`
	set -- $my_gw
	my_gw=$4
	if [ "$my_gw" != "" ]
	then
	    echo ""
	    echo "Found it."
	    break
	fi
	if [ "$started" = "n" ]
	then
	    started='y'
	    crl-on
	fi
    done
}

fix_routes()
{
    for net in $digital_net $hp_net
    do
	route add -net $net $my_gw || {
	    echo 1>&2 "Could not add route to $digital_net."
	}
    done
}

wait_for_crl_gw()
{
    while ! ping -c 4 $CRL_GW
    do
	echo '$CRL_GW not ping-able... sleeping'
	sleep 10
    done
}

# ensure there's somthing to tunnel to
wait_for_crl_gw

# ensure tunnel is up
crl-on
rc=$?
my_gw=`/usr/yokel/bin/ppp-info itn0`
set -- $my_gw
my_gw=$4
fix_routes

echo "Enter route fixing loop..."
while :
do
    # wait for tunnel to rekey and clobber the routes
    date
    fwritten "$TUN_FILE"
    rc=$?
    date
    ls -l "$TUN_FILE"
    
    sleep 5
    
    # check tunnel status w/ping
    if  ping -c 2 crladmin.crl.dec.com >/dev/null
    then
	echo 'tunnel is still up'
	continue
    else
	crl-off
    fi

    # make sure if is still up and running, 
    # the write may have been an obituary.
    wait_for_crl_gw
    crl-on

    echo "$TUN_FILE changed, renewing routes."
    netstat -rn
    # now fix 'em up again
    my_gw=`/usr/yokel/bin/ppp-info itn0`
    set -- $my_gw
    my_gw=$4
    fix_routes
done

