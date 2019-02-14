;;;
;;; $Id: dp-mew-config.el,v 1.6 2005/05/31 08:20:08 davep Exp $
;;;
;;; Holds most of the configuration data for Mew.
;;; loaded by ~/.mew.el --> ~/lisp/dp-dot-mew.el
;;; when Mew starts up.
;;;

(defcustom dp-mew-config-From:-rewrite-alist
  nil
  "Alist of suffixes to add to the From: address based on other mail headers.
Format is a list of these:
   '(header-selection-regexp (header-value-regexp . suffix-string)"
  :group 'dp-vars
  :type mew-custom-type-of-guess-alist)

(defcustom dp-mew-config-clear-p
  t
  "Should we clear the existing Mew config data before setting the new config data"
  :group 'dp-vars
  :type 'boolean)

;(defalias 'fwd-spam
;  (read-kbd-macro "fuce@ftc.gov C-c C-c yd"))

(defvar dp-mew-config-From:-suffix-obarray (make-vector 32 0)
  "Obarray for holding generated symbols used by my mail From: rewriting rules.")
(defun dp-mew-config-clear-obarray ()
  (setq dp-mew-config-From:-suffix-obarray (make-vector 32 0)))

(defun dp-mew-config-deref-name (name)
  "Return value of the variable named NAME from `dp-mew-config-From:-suffix-obarray'."
  (dp-deref-symbol-name name dp-mew-config-From:-suffix-obarray))

(defalias 'dp-mew-config-get-From:-rewrite-info 'dp-mew-config-deref-name)

(defun dpmc-setq-tmp-name (val)
  "Create a unique, tmp name for From: rewriting support."
  (dp-setq-tmp-name val "dp-mew-tmp-" dp-mew-config-From:-suffix-obarray))

;;
;; some things are the same in multiple environments.
;; we can define 'em once and reference them
;; (homeys needs to be completed)

(defun dp-mew-config-internal-set-config ()
  (interactive)

  ;; @todo XXX Get name from $HOST or host-info or ...
  (unless (boundp 'dp-mew-case)
    (message "dp-mew-case is void, using default.  Set it somewhere like: %s"
	     dp-most-specific-spec-macs)
    ;; Make non-void.
    (setq dp-mew-case nil))

  (defvar dp-homeys (dp-string-join
		     '(;;;;;;;;;;"panariti" "davep"
		       "filko" "mel@digital\\.net" "thayer"
		       "be_unique@" "gouge" "buchner" "woodruff"
		       "dake" "page_lee" "leep@" "grotefend"
		       "borzner" "mattison" "gillono" "jfg"
		       "kuris" "shep"
		       "lepper" "ghofrani" "auld" "mattisjo@") "\\|"))
  
  (let ((etailers (dp-string-join '("amazon.com" "buy.com" "mwave.com"
				    "enpc.com" "directron.com" "tccomputers"
				    "googlegear.com") "\\|"))
	(ipaq-rule '("To:\\|Cc:\\|From:" 
		     ("lwesson@pce2000.com" . "+ipaq")))
	(mew-rule '("To:\\|Cc:\\|From:"
		    ("@mew.org" . "+mew")))
	(work-rule '("To:" 
		     ("@ll.mit.edu"
		      . "+work")))
	(spam-rule `("To:\\|Cc:"
		     ("uce@ftc\\.gov\\|419\\.fcd@usss\\.treas\\.gov" . 
		      ,dp-mew-no-fcc))))
    
    ;;
    ;; not everything I want to customize on a per-host basis is
    ;; available as a mew-config-alist key, so instead of configuring
    ;; with two different methods, I just configure on my own.
    (cond
     ;;
     ;; home computer's configuration...
     ((equal dp-mew-case "home")
      (setq mew-fcc "+sent_mail"
	    mew-user dp-mail-user
	    mew-mail-domain dp-mail-domain
	    mew-mailbox-type 'mbox
;	  mew-mbox-command "getpop+inc.sh"
	    mew-mbox-command "mew-inc.sh"
	    mew-mbox-command-arg nil
;	  mew-mail-domain-list '("attbi.com") ; not a mew-config-alist key
	    mew-mail-domain-list '("meduseld.net") ; not a mew-config-alist key
	    mew-header-alist '(("X-Attribution:" . "davep"))
					; not a mew-config-alist key
	    mew-prog-grep (or (executable-find "agrep") "grep")
	    dp-mew-prog-agrep-opts '("-l" "-e") ; not a mew-config-alist key
	    ;; not a mew-config-alist key
	    mew-refile-guess-alist 
	    `(("To:\\|Cc:\\|From:" (,dp-homeys . "+oldgang"))
	      ,ipaq-rule
	      ,mew-rule
	      ,work-rule
	      ,spam-rule
	      ("To:\\|From:\\|Cc:" (,etailers . "+etail"))
	      ("To:\\|From:\\|Cc:" ("xemacs" . "+xemacs"))
	      ("Subject:" ("tcpd:\\|FreeBSD.*Security Advisory" . "+security"))
	      ("Sender:" ("freebsd" . "+freebsd"))
	      ("From:" ("sesamefamily" . "+robbie"))
	      ("From:" ("vanguardmail@" . "+invest"))
	      ("Subject:" ("test" . "+tests")))
	    dp-mew-config-From:-rewrite-alist
	    `(("To:\\|Cc:" ("xemacs" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".xemacs"))))
	      ("To:\\|Cc:" ("freebsd" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".freebsd"))))
	      ("To:\\|Cc:" ("mew" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".mew"))))
	      ("To:\\|Cc:" ("sawfish" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".sawfish"))))
	      ("To:\\|Cc:" ("amazon.com" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".amazon"))))
	      ("To:\\|Cc:" ("buy.com" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".buy.com"))))
	      ("To:\\|Cc:" ("chelmervalve" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".cvc"))))
	      ("To:\\|Cc:" ("uce@ftc.gov" . 
			    ,(dpmc-setq-tmp-name '(:suffix ".uce"))))
	      ("To:\\|Cc:" ("2k3\\|2003" . 
			    ,(dpmc-setq-tmp-name '(:user 
						   "chicxulub"
						   :fullname ""))))
	      ("To:\\|Cc:" ("jobs\\|katz\\|bob@rail.com\\|@tadresources.com" . 
			    ,(dpmc-setq-tmp-name '(:user 
						   "panariti"
						   :domain 
						   "verizon.net"))))
	      ("Subject:" ("job" . 
                           ,(dpmc-setq-tmp-name '(:user 
                                                  "panariti"
                                                  :domain 
                                                  "verizon.net"))))
	      ("To:\\|Cc:" (,dp-homeys . 
			    ,(dpmc-setq-tmp-name '(:user 
						   "davep"
						   :domain 
						   "crickhollow.org"))))
              ("To:\\|Cc:" ("@mikemorton" . 
			    ,(dpmc-setq-tmp-name '(:user 
						   "davep"
						   :domain 
						   "withywindle.org"))))
	      ("To:\\|Cc:" ("classmates.com" . 
			    ,(dpmc-setq-tmp-name '(:suffix 
						   ".classmates"))))
	      ("To:\\|Cc:" ("sonicfoundry.com" .
			    ,(dpmc-setq-tmp-name '(:user 
				"annoying.and.intrusive.registrations"))))
	      ("To:" ("@crickhollow.org" . 
		      ,(dpmc-setq-tmp-name '(:user 
					     "davep"
					     :domain 
					     "crickhollow.org"))))
	))
;    (if (not (boundp 'mew-mail-address-list))
;	(message "YOP!"))
      ;;(add-to-list 'mew-mail-address-list "^panariti@attbi.com$")
      ;;(add-to-list 'mew-mail-address-list "^panariti@ne.mediaone.net$")
      ;;(add-to-list 'mew-mail-address-list "^panariti@mediaone.net$")
      (add-to-list 'mew-mail-address-list "^panariti@verizon.net")
      (add-to-list 'mew-mail-address-list "^davep.*@withywindle.org")
      (add-to-list 'mew-mail-address-list "^davep.*@crickhollow.org")
      (add-to-list 'mew-mail-address-list "^davep.*@meduseld.net"))
     ;;
     ;; work computers' configuration...
     ;; Make sure host machine has lines like this in
     ;; /etc/mail/relay-domains
     ;; to allow relaying.
     ;; crl.dec.com
     ;; compaq.com
     
     ((equal dp-mew-case "work-crl")
      (setq mew-fcc "+sent_mail"
            mew-mailbox-type 'mbox
            mew-mbox-command "rinc"
            mew-mbox-command-arg nil
            mew-user "David.Panariti"
            mew-mail-domain "HP.Com"
            mew-mail-domain-list '("HP.Com")
            mew-mail-address-list '("^davep@crl.dec.com$"
                                    "^david.panariti@compaq.com$"
                                    "^david.panariti@hp.com$"
                                    "^CRLFullTimeStaff@Compaq.Com$")
            
            mew-refile-guess-alist 
            `(("To:\\|Cc:\\|From:" (,dp-homeys . "+personal"))
              ("From:" ("kishore\\|ramachandran" . "+stampede"))
              ,ipaq-rule
              ,work-rule)))
     
     ((equal dp-mew-case "ll")
      (setq mew-fcc "+sent_mail"
            mew-mailbox-type 'imap
            mew-smtp-server "llpost"
            mew-imap-server "llpop"
            mew-user "davep"
            mew-mail-domain "ll.mit.edu"
            mew-mail-domain-list '("ll.mit.edu")
            mew-mail-address-list '("^davep@ll.mit.edu$")
            
            mew-refile-guess-alist 
            `(("To:\\|Cc:\\|From:" (,dp-homeys . "+personal"))
              ,work-rule)))

     ((equal dp-mew-case "amd")
      (setq mew-fcc "+sent_mail"
            mew-mailbox-type 'imap
            mew-smtp-server "llpost"
            mew-imap-server "llpop"
            mew-user "davep"
            mew-mail-domain "ll.mit.edu"
            mew-mail-domain-list '("amd.com")
            mew-mail-address-list '("^david.panariti@amd.com$")
            
            mew-refile-guess-alist 
            ))
     ;;
     ;; hopefully useful defaults
     (t
      (message "*** Using default mew configuration!!!!!!!!!!!!")
      (ding)
      (setq mew-fcc "+sent_mail"
            mew-mailbox-type 'mbox
            mew-mbox-command "inc"
            mew-mbox-command-arg nil
            mew-mail-domain-list '("meduseld.net"))))))


(defun dp-mew-config-set-config (&optional force-retain-p)
  "Set the config, possibly clearing it first.
FORCE-RETAIN-P tells us to keep the existing data.
@todo does retaining old config data make any sense?
@todo resolve issue of dp-mew-config-From:-rewrite-alist being a defcustom
      and the way I set it in dp-mew-config-internal-set-config.
@todo Ditto-ish for dp-homeys.  Seems like it could be a local var."
  (interactive "P")
  (when (and (not force-retain-p)
	     dp-mew-config-clear-p)
    (dp-mew-config-clear-obarray)
    (makunbound 'dp-homeys))
  (dp-mew-config-internal-set-config))
