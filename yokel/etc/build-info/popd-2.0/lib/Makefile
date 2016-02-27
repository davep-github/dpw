# $Id: Makefile,v 1.1 2012/01/08 18:28:20 root Exp $

LIB=poputil
SRCS=  funcs.c lockfile.c mailbox.c mbox_maildir.c mbox_mailidx.c mbox_mbf.c
INCS=poputil.h
CFLAGS   = -g -Wall -O -pipe -fPIC -shared -DUSE_SSL
SHLIB_MAJOR=    1
SHLIB_MINOR=    0
DESTDIR=/usr/yokel/
LIBDIR=lib
INCDIR=include

.include <bsd.lib.mk>
