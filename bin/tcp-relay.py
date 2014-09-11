#!/usr/local/bin/python
# $Id: tcp-relay.py,v 1.1.1.1 2001/01/17 22:22:30 davep Exp $

import sys
from socket import *
from select import *
import string

def main(HOSTNAME="", PORT=8080, 
	 SERVER="panariti.ne.mediaone.net", SPORT=80,
	 BACKLOG=5):
    
    print "want to listen on port %s (%s, %s)" % (PORT, `HOSTNAME`, BACKLOG)
    csock = socket(AF_INET, SOCK_STREAM)
    csock.bind(HOSTNAME, PORT)
    csock.listen(BACKLOG)
    print "listening on port %s (%s, %s)" % (PORT, `HOSTNAME`, BACKLOG)
    
    while 1:
	print "awaiting connection"
	connection = (conn, addr) = csock.accept()
	print "connected from %s at %s" % connection
	    
	ssock = socket(AF_INET, SOCK_STREAM)
	ssock.connect(SERVER, SPORT)

	sock_list = [ ssock, conn ]
	# relay request to real host, reply to client
	eof = 0
	while not eof: #sock_list != []:
	    (readers, dummy, dummy) = select(sock_list, [], [], 0)
	    #print "back from select", sock_list
	    for sock in readers:
		if sock == ssock:
		    dsock = conn
		    print "ssock recv"
		    sname = "ssock"
		elif sock == conn:
		    dsock = ssock
		    print "conn recv"
		    sname = "conn"
		data = sock.recv(2048)

		#if sock == ssock:
		#    print ">>>>>>>>>%s<<<<<<<<" % (data)
		print "len: %d" % (len(data))
		if not data:
		    print "eof seen"
		    #sock_list.remove(sock)
		    #print sock_list
		    eof = 1
		    
		else:
		    #print "press <enter> to send"
		    #x = sys.stdin.readline()
		    n = dsock.send(data)
		    print "n: %d, len: %d" %(n, len(data))
		    if n != len(data):
			print "!!!! didn't write it all!!!"

	ssock.close()
	conn.close()
	
main()
