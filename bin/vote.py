#!/usr/bin/env python

from httplib import HTTP
import sys

if len(sys.argv) >1:
	episode = sys.argv[1]
else:
	episode = 704

n = 50

while n > 0:
	headers = [('Host', 'www.comcentral.com'),
		('Accept', 'application/x-dvi, application/postscript, video/*, video/mpeg, image/*, audio/*, application/applefile, application/x-metamail-patch, sun-deskset-message, mail-file, default, postscript-file, audio-file, x-sun-attachment, text/enriched, text/richtext, application/andrew-inset, x-be2, application/postscript, message/external-body, message/partial, image/x-xwd, image/gif, image/*, image/jpeg, audio/basic, audio/*, text/html, text/plain, application/x-wais-source, application/html, video/mpeg, image/jpeg, image/x-tiff, image/x-rgb, image/x-png, image/x-xbm, image/gif, application/postscript, */*;q=0.001'),
		('Accept-Encoding', 'gzip, compress'),
		('Accept-Language', 'en'),
		('Pragma', 'no-cache'),
		('Cache-Control', 'no-cache'),
		('User-Agent', 'Lynx/2.6  libwww-FM/2.14'),
		('From', '"a-fan" <a-fax@period.com>'),
		('Referer', 'http://www.comcentral.com/mst/mstpoll.htm'),
		('Content-type', 'application/x-www-form-urlencoded'),
		('Content-length', '8')]

	text='vote=' + str(episode)

	n = n - 1
	h = HTTP('www.comcentral.com')
	h.debuglevel = 1
	h.putrequest('POST', '/cgi-bin/rbox/pollboy.pl')
	for (hn, hv) in headers:
		if (hn == 'From'):
			hv = 'user' + str(n) + '@blah.com'
		h.putheader(hn, hv)
		#print "hn:", hn, "hv:", hv

	h.endheaders()

	h.send(text)

	errcode, errmsg, headers = h.getreply()
	if errcode == 200:
		f = h.getfile()
		print f.read() # Print the raw HTML

