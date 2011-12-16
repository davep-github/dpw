;;;
;;; $Id: dp-dot-emacs.HOME_BOX_0.el,v 1.15 2004/02/07 09:20:18 davep Exp $
;;;
;;; local settings that vary from host to host
;;;

(setq dp-mail-fullname "David A. Panariti")
(setq dp-mail-domain "ll.mit.edu")
(setq dp-mail-user "davep")
(setq dp-mail-host "davep")

;; Load path
;;(dp-add-list-to-list 'load-path 
;;                     (paths-find-recursive-load-path '("~/lisp/contrib/cedet")))

;; @info info path definitions
(let* ((prefix "/home/davep/yokel")
       (emacs-ver-dir (concat prefix "/lib/xemacs-" emacs-program-version))
       (emacs-dir (concat prefix "/lib/xemacs")))
  (dp-add-list-to-list dp-info-path-var
                       `(,(concat prefix "/info")
                         ,(concat emacs-ver-dir "/info")
                         ,(concat emacs-dir "/info")
                         ,(concat emacs-dir "/xemacs-packages/info")
                         ;;,(concat emacs-dir "/site-lisp/info")
                         ;;,(concat emacs-dir "/site-modules/info")
                         "/usr/info"
                         "/usr/share/info")))

;;
;; mew's variables. see mew Info.
(setq dp-mew-case "ll")
;; see dp-mail.el
(setq dp-sig-source '(dp-insert-file-sig "~/.signature"))
;;(setq dp-sig-source '(dp-insert-shell-cmd-sig "fortune" "-s"))
;;(setq dp-sig-source '(insert (dp-mk-baroque-fortune-sig)))

;; set appt countdown times
(setq appt-msg-countdown-list '(15 1))
(message "spec-macs (%s) done." spec-macs)

;; A completion list for common host names as used with dp-ssh.
;; The elements must needs be conses; the . t is unused (at least for now.)
(dp-add-list-to-list 
 'dp-ssh-host-name-completion-list
 `(("tc-le3" . t) ("tc-le4" . t) ("tc-le5" . t) ("tc-le6" . t)
   ("dnstve0-ws1" . t) ("dnstve0-ws2" . t) ("dnstve1-man" . t)
   ("dnstve2-man" . t) ("dnstve0-mon" . t)
   ("z10" . t) ("z11" . t) ("z12" . t) ("z13" . t) ("z14" . t) ("z15" . t)
   ("z16" . t) ("z17" . t) ("z18" . t) ("z19" . t)
   ("mon0" . ,(dp-plist-put nil 'ip-addr "172.18.6.4"))
   ("g65svn" . t)
   ))

(defvar dp-max-frame-width 232
  "Absolute max width we can handle.")

;;(defvar dp-ifdef-debug-const "DEBUG"
;;  "Current debug manifest constant to use in debug ifdefs.")
(setq dp-ifdef-debug-const "LL_DEBUG")

;; Good value for my office's LCD panel.
;;(defvar dp-sfh-height 71)             ;old Dell
(setq dp-sfh-height 84)                 ;new Dell (?? temp ??)

(defvar dp-ll-emacs-start-time (current-time)
  "When this xemacs session started.  Usually arrival time @ work.
Exit time is usually when leaving for the night.
This is only set on the first invocation.")

(defvar dp-ll-first-emacs-start-time nil
  "Start time of first session of the day.")

(defvar dp-ll-emacs-session-thresholds '(8.0 9.0 12.0)
  "Create appointment reminders for each of these elapsed times in this session.
Each list element can be:
+ A number, in which case the current elapsed time is displayed using a default
format.
+ A cons, where the car is the elapsed time and the cdr is the format string.")

(require 'time-date)

(defun dp-ll-kill-emacs-hook ()
  "As a contractor at LL, I must needs keep a time log."
  (interactive)
  (let ((debug-on-error nil))
    (dp-log-end-of-session (or dp-ll-first-emacs-start-time
                               (dp-get-first-emacs-start-time))
                           nil (current-time)
                           "First login today")))

;; (defun dp-ll-add-appts ()
;;   (loop for thresh in dp-ll-emacs-session-thresholds do
;;     (appt-add (dp-appt-time-hours-from thresh dp-ll-first-emacs-start-time) 
;;               (format "You've now been here for %s hours" thresh))))

(defun* dp-ll-mk-threshold-appt-list (&key num 2 offset period
                                      thresh-list
                                      (from dp-ll-first-emacs-start-time))
  (let ((thresh-list (nconc thresh-list
                            (or num
                                (dp-mk-periodic-list num offset period)))))
    (dp-mk-appt-list (dp-hour-list-to-time-val-list thresh-list from)
                     (mapcar (function 
                              (lambda (hrs)
                                (format "You've been here %s hours." hrs)))
                             thresh-list))))

(defun dp-ll-add-appts (&optional thresh-list)
  (dp-add-list-of-appts 
   (setq dp-debug-ll-appts (dp-ll-mk-threshold-appt-list
                            :thresh-list (or thresh-list
                                             dp-ll-emacs-session-thresholds)))))

(defun dp-ll-post-dpmacs-hook ()
  "As a contractor at LL, I must needs keep a time log."
  (interactive)
  (dp-log-time-to-file dp-std-start-stamp dp-ll-emacs-start-time)
  (setq dp-ll-first-emacs-start-time (dp-get-first-emacs-start-time))
  ;; We need to hook this after that stuff is done.
  (add-hook 'dp-appt-creation-hooks 'dp-ll-add-appts)
  (add-hook 'kill-emacs-hook 'dp-ll-kill-emacs-hook))
  

(add-hook 'dp-post-dpmacs-hook 'dp-ll-post-dpmacs-hook)
(add-hook 'dp-post-dpmacs-hook 'dp-appt-new-setup)

(defconst dp-frame-title-format (list ""
                                      (format "%s:" (dp-short-hostname))
                                      'buffer-file-truename)
  "*Base frame title format.")

(add-hook 'kill-emacs-query-functions 
	      (function
               (lambda ()
                 (y-or-n-p "Really exit(windows [key] sucks)?"))))

(defvar dpj-topic-to-dir-map 
  (list 
   (list (concat "^dp\\.\\|^private\\|emacs\\|elisp\\|vilya\\|home\\|meduseld"
                 "\\|"
                 (regexp-opt '("politics" "huffpo" "religion")))
         (paths-construct-path (list dp-note-base-dir ".private"))))
  "Map to find a note directory given a topic regexp.")


(defun dp-initial-window-config ()
  "Set up windows, sizes, etc.  This is the default; it lives in dp-dot-emacs.ll.el
This can be set per spec-macs. and the last to override it wins."
  (interactive)
  ;; I like a little bit of a margin.
  (sfw (setq dp-2w-frame-width 174))
  (dp-2-vertical-windows))
