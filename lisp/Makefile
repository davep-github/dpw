ZIPPER = bzip2
ZIP_EXT = bz2
ZIP_ARGS = -c9

ppp_files = \
	/home/davep/bin/pppdialer \
	/home/davep/.ppp/generic.expect \
	/home/davep/.ppp/example.expect \
	/home/davep/bin/xtimer \
	/etc/ppp/ip-up \
	/etc/ppp/ip-down \
	/home/davep/bin/waitforppp \
	/usr/yokel/bin/killppp \
	/usr/yokel/bin/killprog \
	/usr/yokel/sbin/FreeBSD/disable-mgetty-aa \
	/usr/yokel/sbin/FreeBSD/enable-mgetty-aa \
	/home/davep/doc/ppp.doc \
	/etc/resolv.conf \
	/usr/yokel/etc/resolv.conf.locus \
	/usr/yokel/etc/resolv.conf.cia \
	/usr/yokel/sbin/named.stop

#	elmaliases 
#	rhosts 
dbstuff dbs db myinfo: mailiases \
	go.emacs \
	mutt-aliases \
	mh-aliases \
	xfbook

ppp.tar: $(ppp_files)
	tar cvf ppp.tar $(ppp_files)

mailiases:
	- rm $(HOME)/etc/mailiases.el
	gen-mailiases >| $(HOME)/etc/mailiases.el

mutt-aliases:
	- rm $(HOME)/.mutt-aliases
	gen-mutt-aliases >| $(HOME)/.mutt-aliases

mh-aliases:
	- rm $(HOME)/.mh_aliases
	gen-mh-aliases >| $(HOME)/.mh_aliases

elmaliases:
	- rm $(HOME)/.elm/aliases.text
	gen-elmaliases >| $(HOME)/.elm/aliases.text
	newalias

xfbook:
	- rm $(HOME)/.xfmail/.xfbook
	gen-xfmail-aliases >| $(HOME)/.xfmail/.xfbook

# go.emacs.deps=.go.home .go.$(HOST) .go.emacs
go.emacs: 
	- rm $(HOME)/.go.emacs
	go2env -e >| $(HOME)/.go.emacs
	go2env -a

emacs-aliases emacs-abbrevs: go.emacs # old/obsolete... I don't use an emacs mail client. # mailiases


rhosts:
	- rm $(HOME)/.rhosts
	gen-rhosts >| $(HOME)/.rhosts

LOGIN_FILES=\
	.profile \
	.rc/env \
	.rc/alias \
	.rc/func \
	.rc/env \
	.rc/bind \
	.rc/dirstack \
	.rc/rc 

login.tgz: $(LOGIN_FILES)
	(cd $(HOME);  tar cvf - $(LOGIN_FILES) | $(ZIPPER) $(ZIP_ARGS) >| login.tgz )

login.tar: $(LOGIN_FILES)
	(cd $(HOME);  tar cvf login.tar $(LOGIN_FILES))

#include Makefile.lisp.mk
