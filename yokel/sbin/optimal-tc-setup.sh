#!/bin/bash 
#set -x

progname=$(basename $0)

# The Ultimate Setup For Your Internet Connection At Home
# 
#
# Set the following values to somewhat less than your actual download
# and uplink speed. In kilobits
: ${DOWNLINK:=15000}
: ${UPLINK:=2000}
: ${DEV:=eth0}
: ${AVPKT:=1000}
: ${BANDWIDTH:=10mbit}
: ${ALLOT:=1500}
: ${ALLOT2:=1600}

if [ -z "$1" ]
then
    echo 1>&2 "$progname: [-r] [-z]
-r: Really do it (must be first)
-z: Zap (clear) config.

Options must be separate, eg -r -z."
    exit 1
fi

if [ "$1" != '-r' ]             # As in Really do it.
then
    tc()
    {
        echo "[not]tc: $@"
    }
else
    shift
fi
if [ "$1" = '-z' ]
then
    zap_config=y
    shift
fi

# clean existing down- and uplink qdiscs, hide errors
tc qdisc del dev $DEV root    2> /dev/null > /dev/null
tc qdisc del dev $DEV ingress 2> /dev/null > /dev/null

[ -n "$zap_config" ] && {
    echo 1>&2 "config cleared."
    exit 0
}

###### uplink

# install root CBQ

tc qdisc add dev $DEV root handle 1: cbq avpkt ${AVPKT} bandwidth ${BANDWIDTH} 

# shape everything at $UPLINK speed - this prevents huge queues in your
# DSL modem which destroy latency:
# main class

tc class add dev $DEV parent 1: classid 1:1 cbq rate ${UPLINK}kbit \
    allot ${ALLOT} prio 5 bounded isolated 

# high prio class 1:10:

tc class add dev $DEV parent 1:1 classid 1:10 cbq rate ${UPLINK}kbit \
   allot ${ALLOT2} prio 1 avpkt ${AVPKT}

# bulk and default class 1:20 - gets slightly less traffic, 
#  and a lower priority:

tc class add dev $DEV parent 1:1 classid 1:20 cbq rate $[9*$UPLINK/10]kbit \
   allot ${ALLOT2} prio 2 avpkt ${AVPKT}

# both get Stochastic Fairness:
tc qdisc add dev $DEV parent 1:10 handle 10: sfq perturb 10
tc qdisc add dev $DEV parent 1:20 handle 20: sfq perturb 10

# start filters
# TOS Minimum Delay (ssh, NOT scp) in 1:10:
tc filter add dev $DEV parent 1:0 protocol ip prio 10 u32 \
      match ip tos 0x10 0xff  flowid 1:10

# ICMP (ip protocol 1) in the interactive class 1:10 so we 
# can do measurements & impress our friends:
tc filter add dev $DEV parent 1:0 protocol ip prio 11 u32 \
	match ip protocol 1 0xff flowid 1:10

# To speed up downloads while an upload is going on, put ACK packets in
# the interactive class:

tc filter add dev $DEV parent 1: protocol ip prio 12 u32 \
   match ip protocol 6 0xff \
   match u8 0x05 0x0f at 0 \
   match u16 0x0000 0xffc0 at 2 \
   match u8 0x10 0xff at 33 \
   flowid 1:10

# rest is 'non-interactive' ie 'bulk' and ends up in 1:20

tc filter add dev $DEV parent 1: protocol ip prio 13 u32 \
   match ip dst 0.0.0.0/0 flowid 1:20

########## downlink #############
# slow downloads down to somewhat less than the real speed  to prevent 
# queuing at our ISP. Tune to see how high you can set it.
# ISPs tend to have *huge* queues to make sure big downloads are fast
#
# attach ingress policer:

tc qdisc add dev $DEV handle ffff: ingress

# filter *everything* to it (0.0.0.0/0), drop everything that's
# coming in too fast:

tc filter add dev $DEV parent ffff: protocol ip prio 50 u32 match ip src \
   0.0.0.0/0 police rate ${DOWNLINK}kbit burst 10k drop flowid :1
