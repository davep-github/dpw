; -*-Emacs-Lisp-*-
;;;
;;;
;;;

;; !<@todo Fix this, somehow.  Don't force horizontal split when requested by
;; gnus, it makes it most ugly.
(ad-unadvise 'split-window)
(ad-unadvise 'split-window-vertically)

;; Wisdom from the gahdz...
;; Threads!  I hate reading un-threaded email -- especially mailing
;; lists.  This helps a ton!

;; Will this work ok with my thread stuff below?
(setq gnus-summary-thread-gathering-function 
      'gnus-gather-threads-by-subject)

(setq gnus-thread-sort-functions 
      '(gnus-thread-sort-by-most-recent-date)
      gnus-article-sort-functions
      '(gnus-article-sort-by-date))

;; "regexp" on group.
;; || ('header MATCH REGEXP) <--> (header "from" "bubba|bob")
;; || (A-FUNCTIONP)
;; [and a few more]
;; If a match, set some variables...
;; 
(defvar dp-use-gnus-posting-styles-p t
  "Simple switch for using the following styles.")

(setq gnus-posting-styles
      (and dp-use-gnus-posting-styles-p
           ;; Safest/tamest values.
           `((".*"
              (signature dp-insert-tame-sig))
;;dp-tame-sig-source))
             
             ((header 
               "from"
               ,(dp-regexp-concat 
                 '("gouge" "jfg" "gillono" "@meduseld.net" "@crickhollow.org" 
                   "@withywindle.org" "thayer" "mattisjo")))
              (signature dp-maybe-insert-sig)
              ))))

;;
;; Stuff from customize.
;;
(setq gnus-use-trees nil                ; Maps thread w/ASCII tree when read.
      ;;gnus-logo-color-style 'no
      gnus-use-toolbar 'top
      gnus-window-min-height 1
      gnus-window-min-width 2
      gnus-select-method '(nnimap "vanu.com"
                           (nnimap-address "imap.vanu.com")
                           (nnimap-stream ssl))
      gnus-show-threads t
      gnus-thread-indent-level 2
      gnus-treat-display-smileys nil
      gnus-use-dribble-file nil         ; No news for us.
      gnus-confirm-treat-mail-like-news nil  ; We're mail, dammit!
      gnus-confirm-mail-reply-to-news t
      news-reply-header-hook nil
      mail-self-blind t                 ; gnus doesn't seem to honor this.
      message-interactive t             ; Be paranoid.
      gnus-save-newsrc-file nil
      gnus-read-newsrc-file nil
      ;;;;
      ; You are prompted to read groups/folders bigger than this.
      ;;gnus-large-newsgroup 200
      ;; The following variable does end with a newline.
      ;; older one: "%d: %U%R%z%B%(%[%-23,23f%]%) %s + newline"
      ;; %U -> status: U --> unread, O --> olde, (plus see Info)
      ;; %R -> secondary mark (see Info); 
      ;; %B -> fancy thread tree (trn style)
      ;; %(.*%) -> .* an extent highlighted with `gnus-mouse-face'
      gnus-summary-line-format "%d: %U%R%B%(%[%-23,23f%]%) %s
")                                      ; Yes, a newline precedes.

(defvar dp-gnus-dont-ask-to-send-p nil
  "Don't don't ask?")

;;!<@todo Add a To: sensitive check for sig type here. 
(defvar dp-gnus-message-send-query-method
  '(mail
    message-mail-p
    (lambda (arg-unused)
      (or (bound-and-true-p dp-gnus-dont-ask-to-send-p)
          (y-or-n-p "Really send the message? "))))
  "Query to actually send mail.")
  
(defun dp-gnus-add-message-send-query-method ()
  (dp-save-orig-n-set-new 'message-send-method-alist '(unused . self))
  ;; As you were, maggot!
  (dp-restore-orig-value 'message-send-method-alist)
  ;; It would be nice to put this last, but currently the actual send is last
  ;; and if we go after that then gnus thinks we're doing a resend.
  ;; This is *very* dependent on the current value of message-send-method-alist.
  (unless (member dp-gnus-message-send-query-method message-send-method-alist)
    (setq message-send-method-alist 
          (list (car (butlast message-send-method-alist))
                dp-gnus-message-send-query-method
                (car (last message-send-method-alist))))))

;; e.g. (mail message-mail-p message-send-via-mail)
;; We want the predefined value, too.
;;CO; (eval-after-load "gnus" 
;;CO;   (dp-add-query-to-send))

(dp-gnus-add-message-send-query-method)

;; Try this out...
;; Fetch only part of the article if we can.  I saw this in someone
;; else's .gnus
(setq gnus-read-active-file 'some)

;; and this...
;; Tree view for groups.  I like the organisational feel this has.
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)


;; Also, I prefer to see only the top level message.  If a message has
;; several replies or is part of a thread, only show the first
;; message.  'gnus-thread-ignore-subject' will ignore the subject and
;; look at 'In-Reply-To:' and 'References:' headers.

;; Maybe... NO!
(setq gnus-thread-hide-subtree t)
;; Doubtful...
(setq gnus-thread-ignore-subject t)


;; Change email address for work folder.  This is one of the most
;; interesting features of Gnus.  I plan on adding custom .sigs soon
;; for different mailing lists.
;;@todo work on asap; (setq gnus-posting-styles
;;@todo work on asap;       '((".*"
;;@todo work on asap;          (name "Mark A. Hershberger")
;;@todo work on asap;          ("X-URL" "http://mah.everybody.org/"))
;;@todo work on asap;         ("work" 
;;@todo work on asap;          (address "mhershb@mcdermott.com"))
;;@todo work on asap;         ("everybody.org"
;;@todo work on asap;          (address "mah@everybody.org"))))

(add-hook 'message-mode-hook 'dp-gnus-message-mode-hook)

(defun dp-gnus-summary-toggle-current-thread-expansion ()
  "What more can I say about what it does?
How it does it is another matter:  Poorly."
  (interactive)
  (let ((lep-before (progn 
                      (gnus-summary-top-thread)
                      (line-end-position)))
        (lep-after (progn 
                     (gnus-summary-show-thread)
                     (gnus-summary-top-thread)
                     (line-end-position))))
    ;; If the top of thread line didn't change size, we're either already
    ;; expanded or not expandable.  In either case a
    ;; `gnus-summary-hide-thread' is called for or harmless.
    (when (equal lep-before lep-after)
      (gnus-summary-hide-thread))))

;; I can get a buffer in gnus-group-mode w/o having my keys bound
;; to my blm extent.
;; Does this mean my hook isn't being run?  
;; IIR, sometimes the buffer is erased, so the extent goes away.
;; ??? Erase buffer hook?  Super sticky extents?
;;!<@todo REMOVE ME 
(dp-deflocal dp-gnus-debug-info0 nil
  "Hold debug info until all bugs, everywhere, are fixed.")
(defvar dp-gnus-debug-info1 nil
  "Hold debug info until all bugs, everywhere, are fixed.")

(defun dp-bind-group-mode-keys ()
  (dp-define-buffer-local-keys 
   `([q] dp-bury-or-kill-gnus-group-buffer
     [(meta ?-)] gnus-group-exit
     [(meta e)] find-file-at-point
     [return] dp-gnus-topic-select-group
     [(meta return)] ,(kb-lambda 
                          (dp-gnus-topic-select-group t))
     [(control return)] gnus-group-quick-select-group
     [(control m)] dp-gnus-topic-select-group))
  ;; Bug quest
  (setq dp-gnus-debug-info0 (cons (list 'blm-ext (dp-blm-get-extent)
                                        'major-mode major-mode
                                        'buffer (current-buffer))
                                  dp-gnus-debug-info0)
        dp-gnus-debug-info1 (cons (current-buffer) dp-gnus-debug-info1)))


(defun dp-gnus-message-mode-hook ()
  (dp-define-buffer-local-keys '([(meta return)] dp-open-newline
                                 [(meta q)] 
                                 dp-fill-paragraph-or-region-with-no-prefix
                                 [(control a)] dp-brief-home)))

(defun dp-gnus-summary-mode-hook ()
  "MY bindings dammit!"
  (dp-define-buffer-local-keys 
   '([(meta down)] other-window
     [(meta up)] dp-other-window-up
     [g] gnus-summary-insert-new-articles
     [a] gnus-summary-reply-with-original
     [tab] dp-gnus-summary-toggle-current-thread-expansion
     [(iso-left-tab)] gnus-summary-hide-thread
     [(control o)] dp-one-window++
     [(meta ?-)] dp-bury-or-kill-buffer))
  (gnus-summary-sort-by-date t)
;;  (gnus-summary-insert-old-articles 50)
)

(add-hook 'gnus-summary-mode-hook 'dp-gnus-summary-mode-hook)

(defun dp-gnus-summary-prepared-hook ()
  (gnus-summary-insert-new-articles)
;;CO;   (gnus-summary-insert-old-articles t)
  )

(add-hook 'gnus-summary-prepared-hook 'dp-gnus-summary-prepared-hook)

(defun dp-bury-or-kill-gnus-group-buffer (&optional kill-pred-func)
  "Call `dp-func-or-kill-buffer' with `bury-buffer' and  `gnus-group-exit'."
  (interactive)
  (dp-func-or-kill-buffer 'bury-buffer 
                          'gnus-group-exit
                          nil nil kill-pred-func))

(defun dp-gnus-default-num-messages-when-selected ()
  42)

(defun dp-gnus-topic-select-group (&optional arg)
  (interactive "P")
  ;; Let C-- mean all.
  (gnus-topic-select-group (cond
                            ((eq arg '-) t)
                            ((not arg) 
                             (dp-gnus-default-num-messages-when-selected))
                            (t arg))))

(add-hook 'gnus-group-mode-hook 'dp-bind-group-mode-keys)
(add-hook 'gnus-group-prepare-hook 'dp-bind-group-mode-keys)

;;;
;;; Some of my mailer specific support functions
;;; Fill in other ones as problems arise.
;;;
;; must be implemented for each mailer.
(defun dp-mail-end-of-body ()
  "Return position of end of body.
For gnus, gnow, it is the end of buffer since I haven't played with
attachments (or much else) yet."
  (point-max))

(defun dp-gnus-message-setup-hook ()
;;CO;     (dp-maybe-insert-sig)
  )

(add-hook 'gnus-message-setup-hook 'dp-gnus-message-setup-hook)

(bbdb-insinuate-gnus)

;;;
;;; Ta-ta...
;;;
(provide 'dp-dot-gnus)
