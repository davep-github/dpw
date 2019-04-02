;;
;; set up the appointment stuff.
;;
(if (dp-xemacs-p)
    (require 'dp-appt-xemacs)
  (require 'dp-appt-fsf))

(defun dp-activate-appts ()
  "Initiate appointment processing."
  (interactive)
  (dp-find-diary-file)
  (if (not diary-file)
      (message "No diary file found.")
    (message "Using `%s' as diary file." diary-file)
    (condition-case dummy
	(progn
	  (if (dp-xemacs-p)
	      (progn
		(appt-initialize)
		(setq appt-announce-method 'dp-appt-frame-announce)
		;;(setq appt-announce-method 'appt-frame-announce)
		)
	    ;; FSF
	    (dmessage "Add insinuation, etc, code here.")
	    (dp-appt-initialize-on)
	    (message "Alarms for appointments enabled.")))
	(message "Appt module not available."))
      ;; switch to the following if the patch is accepted
    ;;
    ))

(dp-appt-setup)

(provide 'dp-appt)
