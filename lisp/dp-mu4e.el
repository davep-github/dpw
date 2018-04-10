;;
;; Support for mu4e, mu for Emacs.
;; Mu is a mail indexer.
;; mu4e is a mailer that uses mu.
;;

(defvar dp-mu4e-initial-bookarks mu4e-bookmarks
  "Keep the original value so I can reinit when playing with new bookmarks.")

(defun dp-mu4e-add-bookmarks (&optional resetp)
  "Add my queries (bookmarks) to the list used by mu4e.
These will show up in the main mu4e screen."
  (when resetp
    (setq mu4e-bookmarks dp-mu4e-initial-bookarks))
  (dp-add-list-to-list 'mu4e-bookmarks
		       ;; each bookmark looks like:
		       ;; (QUERY DESCRIPTION KEY)
		       ;; see `mu4e-bookmarks'
		       '(("to:panariti" "To me @ work" ?d)
			 ("from:panariti" "From my work addr" ?f)
			 ("from:gillono OR from:jfg" "John" ?j)
			 ("from:writer" "From Tim" ?T)
			 )))

(defun dp-setup-mu4e0 ()
  (mu4e-update-mail-and-index 'run-in-background)
  (global-set-key [(control ?c) ?r] 'mu4e)
  (global-set-key [(control ?x) ?m] 'mu4e-compose-new)
  ;; No fucking shift keys.
  (define-key mu4e-main-mode-map [?u] 'mu4e-update-mail-and-index)
  (dp-mu4e-add-bookmarks)
  )

(defun dp-setup-mu4e (&optional quiet)
  (if (dp-optionally-require 'mu4e)
      (dp-setup-mu4e0)
    (unless quiet
      (warn "mu4e not available. Now go away before I warn you a second time."))))
    
(defun dp-mu4e-view-mode-hook ()
  (dp-define-local-keys
   '(
     ;; Swap current keys: r (mark for refile) and R (reply)
     ;; They must be real refileophiles.
     [?r] mu4e-compose-reply
     [?R] mu4e-headers-mark-for-refile
     [(meta up)] dp-other-window-up
     [(meta down)] other-window)))

(defun dp-mu4e-headers-mode-hook ()
  (dp-define-local-keys
   '(
     ;; Swap current keys: r (mark for refile) and R (reply)
     ;; They must be real refileophiles.
     [?r] mu4e-compose-reply
     [?R] mu4e-headers-mark-for-refile
     [(meta up)] dp-other-window-up
     [(meta down)] other-window)))

(provide 'dp-mu4e)
