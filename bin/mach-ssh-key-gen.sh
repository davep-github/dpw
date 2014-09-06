#!/bin/bash
if [ -x /usr/bin/ssh-keygen ]; then
    if [ ! -f /etc/ssh/ssh_host_key ]; then
	echo ' creating ssh1 RSA host key';
        /usr/bin/ssh-keygen -t rsa1 -N "" \
	    -f /etc/ssh/ssh_host_key
    fi
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
	echo ' creating ssh2 RSA host key';
        /usr/bin/ssh-keygen -t rsa -N "" \
	    -f /etc/ssh/ssh_host_rsa_key
    fi
    if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
	echo ' creating ssh2 DSA host key';
        /usr/bin/ssh-keygen -t dsa -N "" \
	    -f /etc/ssh/ssh_host_dsa_key
    fi
fi
