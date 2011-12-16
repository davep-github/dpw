;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq fcc-alist '(("talisman" "talisman"
			      "@isi.com"
			      "@atinucleus.com")
		  ("old-gang" "filko"
			       "gouge")
		  ("sent_mail" ".*")))
(defun find-fcc (to)
  (interactive "sto: ")
  (message "1")
  (let*
      (
       (lst fcc-alist)
       (lst2 nil)
       (re-lst nil)
       (re-el nil)
       (ret nil)
       )
    (message "2")
    (while lst
      (setq lst2 (car lst))
      (message (format "%s" lst2))
      (setq re-lst (cdr lst2))
      (while re-lst
	(message (format "%s" re-lst))
	(setq re-el (car re-lst))
	(setq re-lst (cdr re-lst))
	(message (format "%s" re-el))
	(message (format "%s" re-lst))
	(message (format "psm: re>%s<, s>%s<" re-el to))
	(if (posix-string-match re-el to)
	    (progn
	      (message "MATCH")
	      (setq ret (car lst2))
	      (setq lst2 nil)
	      (setq lst nil)))
	(message "iter re-lst"))
      (setq lst (cdr lst))
      (message "iter lst2"))
    ret))

(defun scan-re-list (target match-list)
  (let* ((lst match-list)
	 sub-list re-lst re-el)
    (catch 'found
      (while lst
	(setq sub-list (car lst))
	(setq re-lst (cdr sub-list))
	(while re-lst
	  (setq re-el (car re-lst))
	  (setq re-lst (cdr re-lst))
	  (if (posix-string-match re-el target)
	      (progn
		(throw 'found (car sub-list))))
	(setq lst (cdr lst))
      nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
