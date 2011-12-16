	  dp-From:-suffix-alist
	  `(("To:\\|Cc:" ("xemacs" . ".xemacs"))
	    ("To:\\|Cc:" ("freebsd" . ".freebsd"))
	    ("To:\\|Cc:" ("mew" . ".mew"))
	    ("To:\\|Cc:" ("sawfish" . ".sawfish"))
	    ("To:\\|Cc:" ("amazon.com" . ".amazon"))
	    ("To:\\|Cc:" ("buy.com" . ".buy.com"))
	    ("To:\\|Cc:" ("chelmervalve" . ".cvc"))
	    ("To:\\|Cc:" ("uce@ftc.gov" . ".uce"))
	    ("To:\\|Cc:" ("2k3\\|2003" . "chicxulub"))
	    ("To:\\|Cc:" ("jobs" . ".jobs@crickhollow.org"))
	    ("To:\\|Cc:" ("katz" . ".jobs@crickhollow.org"))
	    ("To:\\|Cc:" ("bob@rail.com" . ".jobs@crickhollow.org"))
	    ("To:\\|Cc:" (,dp-homeys . "%fdavep@crickhollow.org"))
	    ("To:\\|Cc:" ("classmates.com" . ".classmates"))
	    ("To:\\|Cc:" ("sonicfoundry.com" .
			  "annoying.and.intrusive.registrations"))
	    ("To:" ("@crickhollow.org" . "%fdavep@crickhollow.org"))
	    ))


(defun dp-mail-generate-from (from-suffix)
  "Create a From: value given FROM-SUFFIX.
If FROM-SUFFIX contains an `@', then the substring after the `@' is used
 instead of `dp-mail-domain' below.
If FROM-SUFFIX begins w/., then it is a user-name suffix and is composited 
with `dp-mail-fullname', `dp-mail-user' and `dp-mail-domain'.
Otherwise begins w/`dp-mail-user', then we format as with `.', except 
we assume that the FROM-SUFFIX contains the user name, too.
Otherwise the FROM-SUFFIX and the domain are used to form the return value."
  (let ((domain dp-mail-domain)
	(user dp-mail-user))
    ;; if our ``suffix'' contains an @, then we'll assume that
    ;;  the mail domain is being explicitly specified
    (save-match-data
      (when (string-match "\\([^@]*\\)@\\(.*\\)$" from-suffix)
	(setq domain (match-string 2 from-suffix)
	      from-suffix (match-string 1 from-suffix))))

;;    (((((((((((((((HE!RE)))))))))))))))

    ;; if from-suffix starts with %f, then set user to "", since 
    ;; the user name is included in the from-suffix.
    ;;
    ;; %f allows `dp-mail-fullname' to be used in the final value.
    ;; suffixes starting without a "." will result in a final value identical
    ;; to the value of the from suffix.
    ;;
    ;; @todo formalize %, etc, escapes for various elements, e.g.:
    ;; %f <-- ""
    ;; %ububba%u <-- sets user to bubba
    ;; %Ublah%U <-- sets full-name to blah
    ;; -OR- expand cons to be all of the possible elements and use defaults
    ;; only in the case of nil or ""
    (if (or (string= (substring from-suffix 0 1) ".")
	    (and (string= (substring from-suffix 0 2) "%f")
		 (setq from-suffix (substring from-suffix 2)
		       user "")))
	(format "\"%s\" <%s%s@%s>" 
		dp-mail-fullname user 
		from-suffix domain)
      (format "<%s@%s>" from-suffix domain))))
