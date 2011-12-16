; -*-Emacs-Lisp-*-

;;;
;;; Returned by vm-read-imap-folder-name, e.g.
;;; ("imap-ssl:imap.vanu.com:993:INBOX:login:davep:*" nil)
;;;
;;; "imap-ssl:HOST:PORT:MAILBOX:AUTH:USER:PASSWORD"
(defvar dp-vm-default-imap-folder
;;  "imap-ssl:imap.vanu.com:993:INBOX:login:davep:pwds-suck"
  ;; <sniff> exchange migrated we did, precious.
  "imap-ssl:mail.vanu.com:993:INBOX:login:davep:pwds-suck"
)

;; Set up my preferences.
;; `vm-frame-per-folder:' Nil mucks things up.  I get no frame for first
;; invocation, but visiting an IMAP buffer makes a new frame.
(defconst dp-vm-other-spool-files '()
  "Additional places to look for mail.  E.g. at work.")
(setq vm-frame-per-folder t
      vm-primary-inbox dp-vm-default-imap-folder
      vm-spool-files (append (list dp-vm-default-imap-folder)
                             dp-vm-other-spool-files)
      vm-frame-per-edit nil
      vm-frame-per-composition nil
      vm-frame-per-completion nil
      vm-warp-mouse-to-new-frame t)

(defconst dp-vm-preferred-sort-name "date"
  "How I like to sort.")

(defun dp-vm-preferred-sort (&optional name)
  (vm-sort-messages (or name dp-vm-preferred-sort-name)))

(unless (bound-and-true-p vm-imap-server-list)
  (defvar vm-imap-server-list
    (list dp-vm-default-imap-folder)))

(defun dp-vm-visit-default-imap-folder ()
  "Blah."
   (interactive)
   (vm-visit-imap-folder dp-vm-default-imap-folder))

(defun dp-vm-summary-mode-hook ()
  (dp-local-set-keys (list
                      [(return)] 'vm-scroll-forward
                      [?i] 'dp-vm-visit-default-imap-folder
                      [?I] 'vm-visit-imap-folder
                      [?Q] 'vm-quit
                      [?q] 'vm-quit-just-bury))
  (dmessage "YOPP! About to sort by date."))

(add-hook 'vm-summary-mode-hook 'dp-vm-summary-mode-hook)

(defun dp-vm-folders-summary-mode-hook ()
  (dmessage "Am I ever called?")
  )
(add-hook 'vm-folders-summary-mode-hook 'dp-vm-folders-summary-mode-hook)

(defun dp-vm-visit-folder-hook ()
  (dp-vm-preferred-sort)
  (goto-char (point-min))
  (when (vm-next-unread-message)
    ;; Non-nil if we fail.
       (goto-char (point-max))
       (beginning-of-line)))

(add-hook 'vm-visit-folder-hook 'dp-vm-visit-folder-hook)

(defun dp-vm-presentation-mode-hook ()
  ;; This mode shares the summary mode map.
  (dp-buffer-local-set-keys (list
                             ;; Equivalent to quit viewing and return to summary.
                                [?q] 'vm-summarize)))

(add-hook 'vm-presentation-mode-hook 'dp-vm-presentation-mode-hook)

(defun dp-vm-kill-buffer (&optional buffer)
  "Since the mail buffer isn't backed by a file, it is tossed w/o fuss."
   (interactive)
   (setq-ifnil buffer (current-buffer))
   (if (not (buffer-modified-p buffer))
       (kill-buffer buffer)
     (when (yes-or-no-p (format "Buffer %s is modified; kill anyway? "
                                 (buffer-name buffer)))
       (kill-buffer buffer))))
   

(mail-aliases-setup)

(defun dp-vm-common-edit-message-hook ()
  (dp-local-set-keys (list [(meta ?-)] 'dp-vm-kill-buffer
                           [(control space)] 
                           (kb-lambda
                               (dp-expand-apprev 'mail-aliases))))
  (dp-maybe-insert-tame-sig)
  (set-buffer-modified-p nil))

(add-hook 'vm-edit-message-hook 'dp-vm-edit-message-hook)

(defun dp-vm-edit-message-hook ()
  (dp-vm-common-edit-message-hook))

;;;
;;; Some of my mailer specific support functions
;;; Fill in other ones as problems arise.
;;;
;; must be implemented for each mailer.
(defun dp-mail-end-of-body ()
  "Return position of end of body.
For vm, it is the end of buffer since I haven't played with
attachments (or much else) yet."
  (point-max))

(defun dp-vm-mail-mode-hook ()
  (dp-vm-common-edit-message-hook))

(add-hook 'vm-mail-mode-hook 'dp-vm-mail-mode-hook)

(define-error 'dp-vm-IMAP-data-modification-disabled
  "This function wants to modify IMAP server data.  That's baaaaad."
   'dp-disabled-function)

(defun* dp-vm-IMAP-data-modification-disabled (&optional datum 
                                               (args nil args-set-p))
  (if args-set-p
      (error (or datum 'dp-vm-IMAP-data-modification-disabled) args)
    (error (or datum 'dp-vm-IMAP-data-modification-disabled))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; from a trace of mousing: Virtual --> Create Virtual Folder --> <click on new>
;; Creates a temp vm-virtual-folder-alist:
;; (
;;  ("INBOX new" 
;;   (((get-buffer "INBOX")) 
;;    (new)))
;; )

;; !<@todo Function/macro that takes name and makes entry.
;; vf name --> <user-name>-mail
;;  user-name &optional regexp: (or regexp re-quoted-name-for-regexp)
(setq vm-virtual-folder-alist
      '(
        ("new-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (new)))
        ("unread-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (unread)))
        ("steve-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (author "steve\\|muir")))
        ("manu-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (author "manu")))
        ("raghu-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (author "raghu")))
        ("jfg-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (author "gillono\\|jfg")))
        ("chris-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (author "gouge")))
        ("from-home"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (author "@\\(meduseld.net\\|withywindle.org\\|crickhollow.org\\|mvsik.org\\)")))
        ("unseen-mail"
         (((get-buffer "INBOX"))        ; This is eval'd at some point.
          (or (new) (unread)))))
)

(defun dp-vm-visit-virtual-folder (folder-name &optional read-only bookmark)
  (interactive)
  ;; The following appear unnecessary at this time, but more testing is needed.
;;CO;   (vm)
;;CO;   (vm-get-new-mail)
  (vm-visit-virtual-folder folder-name read-only bookmark))

;; Make a macro to make visitation functions.
(defun dp-vm-vvf-new-mail (&optional read-only bookmark)
  (interactive)
  (dp-vm-visit-virtual-folder "new-mail" read-only bookmark))

(defun dp-vm-vvf-unread-mail (&optional read-only bookmark)
  (interactive)
  (dp-vm-visit-virtual-folder "unread-mail" read-only bookmark))

(defun dp-vm-vvf-steve-mail (&optional read-only bookmark)
  (interactive)
  (dp-vm-visit-virtual-folder "steve-mail" read-only bookmark))

(defun dp-vm-vvf-chris-mail (&optional read-only bookmark)
  (interactive)
  (dp-vm-visit-virtual-folder "chris-mail" read-only bookmark))

(defun dp-vm-vvf-jfg-mail (&optional read-only bookmark)
  (interactive)
  (dp-vm-visit-virtual-folder "jfg-mail" read-only bookmark))

(defun dp-vm-vvf-family-mail (&optional read-only bookmark)
  (interactive)
  (dp-vm-visit-virtual-folder "family-mail" read-only bookmark))


;; Disable anything that will modify the data on the server.
(defmacro dp-vm-disable-IMAP-data-modification-command (fun-sym)
  (let ((fsym (eval fun-sym)))
    `(defadvice ,fsym
      (around ,(intern (format "dp-%s" fsym)) activate)
      (dp-vm-IMAP-data-modification-disabled))))
  
(defconst dp-vm-functions-to-disable 
  '(vm-save-message-to-imap-folder)
  "Functions I don't want to let vm execute.  In general, I want NO
  modifications done to the server data.")

(defun dp-vm-disable-commands (&optional function-list)
  (loop for f in (or function-list dp-vm-functions-to-disable)
    do (dp-vm-disable-IMAP-data-modification-command f)))

(dp-vm-disable-commands)
