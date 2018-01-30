;;;
;;; $Id: dp-dot-emacs.HOME_BOX_0.el,v 1.15 2004/02/07 09:20:18 davep Exp $
;;;
;;; local settings that vary from host to host
;;;

(setq dp-mail-fullname "David A. Panariti")
(setq dp-mail-domain "vanu.com")
(setq dp-mail-user "davep")
(setq dp-mail-outgoing-host "smtp.vanu.com")

;; @info info path definitions
(dp-add-list-to-list dp-info-path-var
		     '("/usr/yokel/info"
		       "/usr/yokel/sawmill-cvs/info"
		       "/usr/info"
		       "/usr/local/lib/xemacs-21.4.15/info"
		       "/usr/local/lib/xemacs-21.5-b16/info"
		       "/usr/local/lib/xemacs/xemacs-packages/info"
                       (dp-lisp-subdir "contrib/info")
		       "/usr/share/info"))

;; fits the hp5l
(setq lpr-page-header-switches '("-F" "-l" "61"))

;;
;; see dp-mail.el
;; obsolete
(setq dp-fcc-alist '(
	  (("filko" "mel@digital\\.net" "thayer" "be_unique@" 
	    "gouge" "buchner" "woodruff" "dake")
	   ("to" "cc") "oldgang")
	  (nil ("to") "sent_mail")))

;;
;; mew's variables. see mew Info.
(setq dp-mew-case "home")

;; see dp-mail.el
(setq dp-sig-source dp-default-sig-source)

;; set appt countdown times
(setq appt-msg-countdown-list '(15 1))
(message "spec-macs (%s) done." spec-macs)
