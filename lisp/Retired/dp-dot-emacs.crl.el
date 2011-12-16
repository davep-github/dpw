;;;
;;; $Id: dp-dot-emacs.crl.el,v 1.11 2003/07/30 07:30:10 davep Exp $
;;;
;;; local settings that vary from host to host
;;;

(defvar mail-default-reply-to 
  "\"David A. Panariti\" <David.Panariti@HP.Com>")
;;(setq mail-host-address "clove.crl.dec.com")
(dp-add-list-to-list dp-info-path-var
		      '("~/yokel/info" "/usr/yokel/info" "/usr/share/info"))

(dp-add-list-to-list 'load-path 
		     '("/usr/local/lib/xemacs/site-lisp/w3m"
		       "/usr/local/lib/xemacs/site-lisp/ecb"
		       ;; "~/yokel/share/emacs/site-lisp/hyperbole"
		       "~/yokel/share/emacs/site-lisp"))

;;
;; see dp-mail.el
;; obsolete when used with mew.  XXX move vals as appropriate to
;; dp-dot-mew.el crl case.
(setq dp-fcc-alist 
      '((("talisman" "@isi.com" "@atinucleus.com" "@wrs.com" "@episupport.com" 
	 "@cmx.com" "@jmi.com" "@mcci.com" "constable@jmisoftware.com" 
	 "capobianco@sharpsec.com" "@BEACONTOOLS.COM" "@delarue-exton.com" 
	 "@ssx5.com" "@arccores.com") ("to" "cc") "embedded")
	(("jmf@zk3" "johnf@zk3") ("to" "cc") "tru64source")
	(("@handhelds.org" "John\\.Pittman") ("to" "cc") "handhelds")

	(nil ("to") "sent_mail")))

;;
;; mew's variables. see mew Info.
(setq dp-mew-case "work-crl")

;; see dp-mail.el
(setq dp-sig-source '(dp-insert-file-sig "~/.signature"))
;;(setq dp-sig-source '(dp-insert-shell-cmd-sig "fortune" "-s"))

(setq browse-url-netscape-program "/usr/X11R6/bin/netscape")

(if (dp-xemacs-p)
    (display-time))
