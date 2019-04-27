;;;
;;; $Id: dp-supercite.el,v 1.11 2003/12/01 08:30:05 davep Exp $
;;;
;;; set up supercite
;;;

(setq mail-yank-prefix "> ")
(setq mail-yank-ignored-headers ":")
(add-hook 'mail-citation-hook 'sc-cite-original)
;; do this thru customize now
;;(setq sc-citation-leader "")
(setq sc-preferred-attribution-list
      (list "sc-lastchoice" "x-attribution" "sc-consult"
	    "firstname" "initials" "lastname"))

(setq sc-attrib-selection-list
      '(
	("from" (("C.*Gouge" . "Chris")
		 ("gouge_chris" . "Chris")
		 ("gouge@iname.com" . "Chris")
		 ("Dav.*Panariti" . "davep")
		 ("Mel.*Filko" . "Mel")
		 ("75562.3052" . "Pages")
		 ("bg@" . "Ben")
		 ("grot" . "Dan")
		 ("page_lee@" . "Lee")
		 ("bbaker@zk3.dec.com" . "Brian")
		 ("ghofrani" . "Ben")
		 ("bentley@hcgl1.eng.ohio-state.edu" . "Eric")
		 ("os2@4u" . "Eric")
		 ("kthanasi" . "Leonidas")
		 ("halstead" . "Bert")
		 ("nikhil" . "Nikhil")
		 ("James Hicks" . "Jamey")
		 ("Hicks, J" . "Jamey")
		 ("cfj" . "Chris")
		 ("tuttle" . "Mark")
		 ("gillono\\|jfg". "John")
		 ("b.*buchner" . "bb")
		 ("rsmith\\|smithrz" . "robair")
		 ("low_stick_side" . "Jimmy")
		 ("mattison@cpeedy\\|mattisjo" . "Joanne")))))

;;
;; add a hook that will make sc prompt us if the attribution has any
;; funky characters in it.
;;
(add-hook 'sc-attribs-postselect-hook
	  (function
           (lambda ()
	     (setq query-p (or
			    sc-confirm-always-p
			    (posix-string-match "[^a-zA-Z]" attribution)))
             ;;	     (message (format "query-p: %s, sc-: %s"
             ;;			      query-p sc-confirm-always-p))
	     )))

(setq sc-confirm-always-p nil)
(setq sc-cite-region-limit 500)
(setq sc-auto-fill-region-p nil)	;@todo do I like this?
(setq sc-blank-lines-after-headers nil)

;;;
;;;
;;;
(provide 'dp-supercite)
