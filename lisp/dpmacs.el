;;;
;;; $Id: dpmacs.el,v 1.149 2005/07/03 08:20:10 davep Exp $
;;;
;;; Bulk of .emacs so we can byte compile it.
;;;

;; load fsf/x emacs compat functions

;; load this first so that all defined history lists will be added to
;; savehist-history-variables.
;;

(require 'advice)
(defun dp-xemacs-p ()
  "A cheap way of detecting xemacs."
  ;; We'll treat these the same until we need to treat 'em differently.
  (or (featurep 'xemacs)
      (featurep 'sxemacs)))

(if (dp-xemacs-p)
    (require 'dp-xemacs)
  (require 'dp-fsf))

(eval-when-compile
  (require 'cl)
  (unless (dp-xemacs-p)
    (require 'cl-lib))
  (load "cl-macs")
  (require 'dp-macros))

;; @todo XXX A default.  Make it a more common one, like a lucida or
;; some such.
;;(message "Setting frame font...")
;; A simple function meant to be easily used when Emacs is started.
;; Currently doesn't help.  The way xem evolved, it has severe quoting
;; issues.  It cannot quote host_info options with spaces.  Should rewrite it
;; all in Python.
(defvar dp-set-frame-font-size-default 13)
(defvar dp-set-frame-font-size-current dp-set-frame-font-size-default)
(defun dp-set-frame-font-size (&optional font-size font-name)
  (interactive "P")
  (setq-ifnil font-name "RictyDiminishedDiscord"
	      font-size (if current-prefix-arg
			    current-prefix-arg
			  (read-number
			   (format "Enter font %s's size (current: %s): "
				   font-name dp-set-frame-font-size-current)
			   dp-set-frame-font-size-default)))
  (let ((frame-font (format "%s-%s" font-name (prefix-numeric-value
					       font-size))))
    (message "Setting frame font to: %s" frame-font)
    (setq dp-set-frame-font-size-current font-size)
    (set-frame-font frame-font)))
(dp-defaliases 'sfs 'sffs 'dp-set-frame-font-size)

;; Not sure why this isn't buffer local by default.
;; quote:
;; This variable is intended for use by making it local to a buffer.
;; But it is local only if you make it local.
(make-variable-buffer-local 'backup-inhibited)

(unless (getenv "EMACS")
  (setenv "EMACS" "t"))

(set-frame-font "RictyDiminishedDiscord-13")

;; Make file that holds every keybinding that points to real xemacs
;; functions.
;; grep -v "-dp" 
;; will get lots
(global-set-key [(meta ?u)] 'undo)

(defvar dp-$HOME (getenv "HOME")
  "Convenience for future reference.")
(defvar dp-$HOME-truename (substring (shell-command-to-string 
                                           (concat "realpath " dp-$HOME)) 0 -1)
  "The `realpath(1)' of the aforementioned $HOME variable.")

(defvar dp-ipython-temp-file-re "ipython_edit_.*\\.py$"
  "Name ipython uses when %edit'ing something.")

(defvar dp-known-temp-file-re-list 
  (list 
   dp-ipython-temp-file-re)
  "List of known temp file regexps, so `dp-server-visit-hook' doesn't muse about 
its temp-ness.")

;;; Dummy hooks: Define these here so that when I make changes that
;;; break everything, I can exit w/o having these defuns be unbound
;;; and causing errors.  I guess I should really look at doing some
;;; reording and clean up in general.
(message "dpmacs.el...")

(define-error 'dp-signal-message
  "Signal an error just for the message.  This is in `debug-ignored-errors'."
  'user-error)

(define-error 'dp-disabled-function 
  "This function has been disabled for safety reasons." 'invalid-function)

(if (boundp 'ascii-symbols)
    ;; Use mule's in case they improve something or...
    (progn 
      (defvar dp-ascii-char ascii-char)
      (defvar dp-ascii-space ascii-space)
      (defvar dp-ascii-symbols ascii-symbols)
      (defvar dp-ascii-numeric ascii-numeric)
      (defvar dp-ascii-English-Upper ascii-English-Upper)
      (defvar dp-ascii-English-Lower ascii-English-Lower)
      (defvar dp-ascii-alphanumeric ascii-alphanumeric))
  ;; Stolen from mule.
  (defvar dp-ascii-char "[\40-\176]")
  (defvar dp-ascii-space "[ \t]")
  (defvar dp-ascii-symbols "[\40-\57\72-\100\133-\140\173-\176]")
  (defvar dp-ascii-numeric "[\60-\71]")
  (defvar dp-ascii-English-Upper "[\101-\132]")
  (defvar dp-ascii-English-Lower "[\141-\172]")
  (defvar dp-ascii-alphanumeric "[\60-\71\101-\132\141-\172]"))
;; Brittle much?
;; And confuzing? Can't remember what it's for. OR why.
(loop for vname in '("dp-ascii-char" "dp-ascii-space" "dp-ascii-symbols" 
                     "dp-ascii-numeric" "dp-ascii-English-Upper" 
                     "dp-ascii-English-Lower" "dp-ascii-alphanumeric")
  do
  (let* ((new-name (concat "dp-not-" (substring vname 3)))
         (new-sym (intern new-name))
         (new-val (concat "[^" 
                          (substring (symbol-value (intern-soft vname)) 1))))
    (set new-sym new-val)))

;; Don't let edebug reset the window configuration whenever it steps or goes
;; or runs, etc.  Sometimes it's nice, but it's usually a PITA.
(set-variable 'edebug-save-windows nil)

(defvar dp-message-buffer-name (setq dp-message-buffer-name
                                     (if (dp-xemacs-p)
                                         " *Message-Log*" ;XEmacs
                                       "*Messages*")) ;FSF
  "*The name of the message buffer.
Man, can't these guys agree on *ANYTHING*?
This should be set by the emacs specific code.")

(defvar dp-warning-buffer-name "*Warnings*"
  "*The name of the buffer warning messages (duh).
It's the same (!!) on both macsen! And by the same, I mean not different.")

(defvar dp-ding-backtrace-p t
  "Show a traceback when `ding' is called.  Useful for debugging init stuff.")

(defvar dp-ding-backtrace-args (list nil (get-buffer dp-message-buffer-name))
  "Show a traceback when `ding' is called.  Useful for debugging init stuff.")

(defadvice ding (before dp-advised-ding activate)
  (when dp-ding-backtrace-p
    (unwind-protect
        (condition-case appease-byte-compiler
            (progn
              (message (make-string 77 ?!))
              (message "!*!*! THIS IS AN INIT-TIME BACKTRACE GENERATED BY AN ADVISED `ding'")
              (apply 'backtrace dp-ding-backtrace-args))
          (error nil))
      ))
  (message "!!!!!!!!!!!!!!!!!advised ding!!!!!!!!!!!!!!!!!"))

(defun to-bool (expr)
  "Convert expr to boolean, ie t or nil."
  (not (not expr)))

(defvar dp-primary-frame (selected-frame))

(defun dp-primary-frame()
  "Return the primary frame, the startup frame by default."
  dp-primary-frame)

(defun dp-primary-frame-p (&optional frame)
  "Return non-nil if frame \(or \(selected-frame)) is the primary frame."
  (equal (dp-primary-frame) (or frame (selected-frame))))

;;is this used/needed? (defvar dp-kill-emacs-hook '()
;;is this used/needed?   "List of things to do during exit.")

(require 'dp-compat)
(require 'dp-errors)

(defvar dp-cscope-perverted-index-option nil
  "This is a localized value for cscope-perverted-index-option (q.v.).")

;; load fsf/x emacs specific stuff
(require 'dp-init-early)
(if (dp-xemacs-p)
    (require 'dp-xemacs-early)
  (require 'dp-fsf-early))
;;
;; load now so we can override/append/modify vars in spec-macsen
(require 'dp-vars)
(defvar dp-post-dpmacs-hook '()
  "List of things to do after init.")
(defvar dpj-private-topic-re-extra ""
  "No extra patterens to ignore")
(defvar dp-after-kill-this-buffer-hook '()
  "Runs after my kill buffer function.")

(setq list-command-history-max nil)     ; Unlimited limit.

;; I need to require this because it inits its name ring to a funky value.
(require 'wconfig)
;; I've stolen the code from XEmacs.  There may be another non-specific version
;; "out there."
;; Also, annoyingly, its public and apparently meant to be used by clients is
;; a defconst, not defvar. Admittedly, those are two fucked up names.
;; ok with default?; (setq wconfig-ring-max 16) ; def 10... is it enough?
;; This function is b0rked in the source here @ intel on chele
;; so we fix it:
(defun wconfig-delete-pop ()
  "Replaces current window config with most recently saved config in ring.
Then deletes this new configuration from the ring."
  (interactive)
  (let ((ring (wconfig-get-ring)))
    (if (ring-empty-p ring)
	(dmessage 
         "(wconfig-delete-pop): Window configuration save ring is empty")
      (set-window-configuration (ring-ref ring 0))
      (ring-remove ring 0))))

(defvar comint-input-ring-size 5120
  "*Size of input history ring.")

(defvar dp-time-val-0 '(0 0 0)
  "Time val = to 0.")

(defvar ediff-auto-refine-limit 5120
  "*Size of region up to which we will automagically refine differences.")

;; Since I can now cancel an alarm, more warnings can be less annoying.
(defvar appt-msg-countdown-list '(15 7 3 1)
  "*List of impending appointment warning times.
Times are minutes before appointment.")

(defvar dp-c*-additional-type-list nil
  "More types beyond the standard ones and not suffixed in a recognizable
way.")

(setq appt-display-duration 30)

(setq ediff-temp-file-prefix (concat (getenv "HOME") "/tmp/")
      grep-command "egrep -n -e "
      grep-find-command "find . -type f -print0 | xargs -0  egrep -n -e ")

(setq igrep-program "egrep")            ; igrep adds -n -e before regexp.

;;   "List of arguments (switches) to pass to `diff' by `recover-file'.")
(setq recover-file-diff-arguments '("-u"))

(autoload 'c++-mode "cc-mode" "C++ Editing Mode" t)
(autoload 'c-mode   "cc-mode" "C Editing Mode" t)

(defconst dp-default-sig-source 
  (cons 'expr '(insert (dp-mk-baroque-fortune-sig)))
  "See `dp-insert-sig'.")
;;

(defconst dp-edting-server-valid-host-regexp ".*"
  "Only hosts which match this regexp will be allowed to be advertised as
editing servers via `dp-editing-server-ipc-file'.")

;; Load these first so I can navigate somewhat better when I hose another rc
;; file.
(require 'dp-keys) ;; my highly unstandard keybindings.
(require 'dpmisc)
(require 'dp-lang)
(require 'dp-lang-c-like)
(require 'dp-cf)
(require 'dp-cal)
(require 'dp-appt)
(require 'dp-c-like-styles)

;;
;; Now we can do my kinds of things...
;;

(unless (dp-xemacs-p)
  (dp-optionally-require 'edebug-x)
  (require 'dp-magit))

;; in XEmacs (only?)
(when dp-use-xgtags-p
  (dp-optionally-require 'xgtags))

(defun dp-xgtags-p ()
  (and dp-use-xgtags-p
       (or (featurep 'xgtags )
           (and (fboundp 'xgtags-mode)
                (dmessage "not featurep 'xgtags, but xgtags-mode defined.")))))

;; In Emacs (only?)
(when dp-use-ggtags-p 
  (dp-optionally-require 'ggtags))
(defun dp-ggtags-p ()
  (and dp-use-ggtags-p
       (or (featurep 'ggtags )
           (and (fboundp 'ggtags-mode)
                (dmessage "not featurep 'ggtags, but ggtags-mode defined.")))))
(when dp-use-gtags-p
  (dp-optionally-require 'gtags))
(defun dp-gtags-p ()
  (and dp-use-gtags-p
       (or (featurep 'gtags )
           (and (fboundp 'gtags-mode)
                (dmessage "not featurep 'gtags, but gtags-mode defined.")))))

;; Load these first so I can navigate somewhat better when I hose another rc

;; I like it on by default, but it is painfully slow over low bandwidth
;; links, so I set it up here and let it be overridden in a spec-macs.
(setq visible-bell t)

(defvar dp-p4-global-disable-detection-p nil
  "*Turn off ALL perforce detection in find file hooks.")

(defun dp-p4-active-here-p (&optional file-name)
  "*Determine if this file needs to be worried about perforce. (Abstract to any SCM).
Override in spec-macs.
Allow us to limit perforce checks to certain dirs. At nVIDIA, a simple 
`p4 opened' can take 10+ minutes. Checking all files for p4-ed-ness adds
intolerable delays to files not in perforce."
  ;; let it be off unless forced on.
  (setq-ifnil file-name (buffer-file-name))
  (and (not dp-p4-global-disable-detection-p)
       (dp-sandbox-file-p file-name)
       (not (string-match dp-p4-ignore-regexp file-name))))

(defvar dp-most-specific-spec-macs nil
  "The most specific dp-dot-emacs*.el file we `load'ed.")

(defun dp-edit-most-specific-spec-macs ()
  (interactive)
  (find-file dp-most-specific-spec-macs))

(defvar dp-loaded-spec-macsen '()
  "A list of all of the spec-macs files we loaded. Most specific to least.")

;;
;; We put this here because (at least) the amd c-mode-hook needs to run
;; before the "meister" c-mode-common-hook
;;
(add-hook 'c-mode-common-hook 'dp-c-like-mode-common-hook)

(defun dp-load-spec-macs (spec-macs)
  "Possibly load a more specific .emacs type startup file."
  ;;(message "spec-macs>%s<" spec-macs)
  (setq spec-macs (dp-lisp-subdir "dp-dot-emacs%s.el" spec-macs))
  ;;(message "spec-macs>%s<" spec-macs)
  (when (file-readable-p spec-macs)
	;;(message "loading>%s<" spec-macs)
	(load spec-macs)
        spec-macs))

;; load any host specific thingies...
;; process all of the possible specific init files
(setq dp-loaded-spec-macsen (nreverse (delq nil (mapcar
                                                 'dp-load-spec-macs 
                                                 (dp-specific-extensions))))
      dp-most-specific-spec-macs (car-safe dp-loaded-spec-macsen))


;;
;; derived vars from spec-macs specific stuff
;;(setq mail-host-address (format "%s.%s" dp-mail-outgoing-host dp-mail-domain))
;; Changes for vm.el
(setq mail-host-address dp-mail-domain) 
(setq dp-mail-addr (format "%s@%s" dp-mail-user dp-mail-domain))

(eval-and-compile
      (require 'font-lock))

;;;
;;; normal requires...
;;(require 'sendmail)
(require 'compile)

;; This allows me to tack something onto the end of my user name in order to
;; uniquely identify the mail's recipient,
;; e.g. davep.possible-seller-of-email-addrs-to-spammers.  Also useful to see
;; who may have been hacked to obtain addresses if company really hasn't sold
;; addresses.
(if (or (not (boundp 'dp-my-mail-address-format))
	(not dp-my-mail-address-format))
    (setq dp-my-mail-address-format (format "\"%s\" <%s%%s@%s>" 
					dp-mail-fullname 
					dp-mail-user dp-mail-domain)))
;(format dp-my-mail-address-format ""))

(defvar dp-initial-frame-height nil
  "Height of the default frame right after 'macs finishes running
the init files.")

(add-hook 'after-init-hook (function
                            (lambda ()
                              (setq dp-initial-frame-height (frame-height)))))
(autoload 'w3m "w3m" "Interface for w3m on Emacs." t)
(setq w3m-quick-start nil)		; tell w3m to prompt for an url
(add-hook 'w3m-mode-hook 'dp-w3m-mode-hook)
(autoload 'namazu "namazu" nil t)
(when (dp-xemacs-p)
  (toggle-auto-compression 1))

(cond 
 ((and dp-use-gtags-p 
       (dp-optionally-require 'gtags))
  (dmessage "gtags'ing, move all init to dp-ptools.el")
  (define-key gtags-select-mode-map [?o] 'gtags-select-tag-other-window)
  (define-key gtags-select-mode-map [??] 'describe-mode)
  (define-key gtags-select-mode-map [(control ?o)] 'dp-one-window++)
  (define-key gtags-select-mode-map [?q] 'bury-buffer)
;;fsf;;;   (define-key gtags-mode-map 'button2 'gtags-pop-stack)
;;fsf;;;   (define-key gtags-mode-map 'button3 'gtags-find-tag-by-event)
  (define-key gtags-mode-map [(meta ?.)] 'dp-tag-find)
  (define-key gtags-mode-map [(meta ?>)] 'gtags-find-rtag)
  (define-key gtags-mode-map [(control meta ?.)] 'dp-tag-find-other-window)
  (define-key gtags-mode-map [(meta ?,)] 'dp-tag-pop)
  (define-key gtags-mode-map [(control meta ?,)] 'dp-tag-pop-other-win)
  (defconst gtags-global-command "ranking-global-gtags.py")
)
 ;; @todo put defaults here:
 (t nil))				; Make it easy to add others.

;; <:savehist stuff | save history | save variables:>

;; Save it on a per-node basis.
(setq savehist-file (dp-nuke-newline (shell-command-to-string 
                                    "mk-persistent-dropping-name.sh emacs-history")))
;;(dp-mk-pathname (list (dp-lisp-dir) 
;;                                          (concat "history." 
;;
;;                                                 (dp-short-hostname)))))
;; How often we dump out the history.
(setq savehist-autosave-interval (* 1 60))

(when (dp-optionally-require 'savehist nil)
  ;; This isn't in all versions of savehist.
  (condition-case badness
      (dp-funcall-if 'savehist-mode (1))
    (t (warn "`savehist-mode' failed." )
       (message "badness: %s" badness)))
  
  ;; The kill-ring needs to have the kill-ring-yank-pointer set.
  (setq-ifnil kill-ring-yank-pointer kill-ring)
  
  ;; Different versions use different variables to hold additional user
  ;; requested variables to save.  Find one.  In the latest version I use,
  ;; `savehist-additional-variables' is the variable to use.
  (let ((hist-var-sym (loop for v in '(savehist-history-variables 
                                       savehist-additional-variables)
                        when (boundp v) return v)))
    (when hist-var-sym
      (dp-add-list-to-list hist-var-sym 
                           '(Manual-page-minibuffer-history
                             dired-history
                             dired-regexp-history
                             dp-colorize-bracketing-regexps-history 
                             dp-gdb-cf-history
                             dp-gdb-sudo-history
                             dp-grep-history
                             dpj-topic-history
                             dpy-read-history
                             file-name-history
                             grep-all-files-history
                             grep-find-history
                             hyper-apropos-face-history
                             hyper-apropos-help-history
                             hyper-apropos-regexp-history
                             igrep-files-history 
                             igrep-regex-history
                             mmm-interactive-history
                             read-envvar-name-history
                             set-variable-value-history
                             setenv-history
                             svn-status-directory-history
                             command-history
                             ssh-history
			     ;; I can't believe I left this out.  I
			     ;; don't think I did.  I think Emacs
			     ;; works differently.
                             kill-ring
                             dp-go-back-ring ; or this
                             search-ring  ; Or these...
                             regexp-search-ring
                             wconfig-names
                             dp-killed-file-states
                             dp-recently-killed-files
                             gtags-buffer-stack
                             killed-rectangle
                             ;; <:add new vars variables to save here:>
                             ))
      (message "added `savehist' vars."))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; auto-mode-alist machinations
;;;

;; For debugging and undoing things.
(defvar dp-orig-auto-mode-alist auto-mode-alist)

(defvar dp-auto-mode-alist-additions
  '()
  "All of my additions in one place. This allows me to restore the original
  mode is I want to and then re-apply my changes.")

(defun dp-add-auto-mode-alist-additions ()
  (dp-add-list-to-list 'auto-mode-alist dp-auto-mode-alist-additions))
(add-hook 'dp-post-dpmacs-hook 'dp-add-auto-mode-alist-additions)

;;@todo XXX Use this more often?
(defun dp-add-to-dp-auto-mode-alist-additions (extension mode 
                                               &optional add-transparent-p)
  (add-to-list 'dp-auto-mode-alist-additions
               (cons (if add-transparent-p
                         (dp-mk-mode-transparent-regexp extension)
                       extension)
                     mode)))

;; Prevents these from being indexed, etc. along with other "real" source
;; files.
(defvar dp-default-mode-transparent-r/w-suffix-regexp
  (regexp-opt '(
   "wip" "exp" "dev" "WIP" "EXP" "DEV" "hack" "HACK" "play" "PLAY"
   "emerged" "merged" "emerge" "merge"))
"In development, works in progress, being developed.")

;; !<@todo XXX things like save-2 don't work, but save2 do. The [] expr is
;; suspect.
(defvar dp-default-mode-transparent-r/o-suffix-regexp
  (concat "historical\\|save\\|hide\\|no-index\\|pristine"
          "\\|HISTORICAL\\|SAVE\\|HIDE\\|NO-INDEX\\|PRISTINE"
          "\\|\\TMP[.-]HIDE"
          "\\|\\HIDE[.-]TMP"
          "\\|KEEP\\|keep"
          "\\|REFERENCE\\|reference"
          ;; Stuff being hidden from version control
          "\\(\\|,novc\\|,junk\\|,nogit\\|.,,\\|,.*,\\)$"
          "\\|,NOVC\\|,JUNK\\|,NOGIT"
          ;; Old but broken or out-of-date.
          "\\|stale\\|bad\\|b0rked\\|broken?\\|hosed\\|fubar"
          "\\|STALE\\|BAD\\|B[O0]RKED\\|BROKEN?\\|HOSED\\|FUBAR"
          "\\|davep\\|" (user-login-name)
          "\\|gitrev-[0-9a-fA-F]+"
          "\\|noindex\\|NOINDEX\\|noidx\\|NOIDX"
          ;; Perforce uses .original.[0-9]+ to save modified files.  I, too,
          ;; like to copy a file to a .orig before hacking it up, although
          ;; I've come to use RCS instead.
          "\\|merged?\\|obs\\|olde?\\|orig\\(inal\\)?"
          "\\|MERGED?\\|OBS\\|OLDE?\\|ORIG\\(INAL\\)?"
	  "\\|OEM\\|oem")
          
  "Read only part of dp-default-mode-transparent-suffix-regexp (q.v.)")

(defvar dp-default-mode-transparent-suffix-regexp
  (concat "\\([.,-]"
          "\\("
          dp-default-mode-transparent-r/o-suffix-regexp
          "\\|"
          dp-default-mode-transparent-r/w-suffix-regexp
          "\\)"
          "\\([.,-]?\\([0-9]*\\)\\)?\\)?$")
"Suffixes which can be added after a regular extension and are ignored
for the purpose of mode setting.  At this time, these are also visited read
only.
So, for example, if I don't want `make check' to look at a work in progress,
I can name a file why-must-I-be-tortured-by-Perl.pm.wip. *.pm won't match
this but when I edit it, I get it in (shudder) Perl mode.")

(defun* dp-mk-mode-transparent-regexp (extension &optional 
        (suffix-regexp dp-default-mode-transparent-suffix-regexp)
        (extra-suffix-regexp nil)
        (dot "."))
  (concat (if extension
              (concat 
               "\\(" (regexp-quote (concat dot extension)) "\\)")
            "")
          (dp-regexp-concat 
           (append (list suffix-regexp) extra-suffix-regexp))))

(defun* dp-mk-mode-transparent-r/o-regexp (extension &optional
                                          extra-suffix-regexp
                                          (dot "."))
  (dp-mk-mode-transparent-regexp extension
                                 dp-default-mode-transparent-r/o-suffix-regexp
                                 extra-suffix-regexp
                                 dot))

(defun* dp-mk-mode-transparent-r/w-regexp (extension &optional
                                          extra-suffix-regexp
                                          (dot "."))
  (dp-mk-mode-transparent-regexp extension
                                 dp-default-mode-transparent-r/w-suffix-regexp
                                 extra-suffix-regexp
                                 dot))
  
(defun dp-mk-mode-transparent-auto-mode-alist (mode extensions)
  (mapcar (lambda (ext)
            (cons (dp-mk-mode-transparent-regexp ext) mode))
          extensions))

(defun dp-mk-mode-transparent-alist-from-mode-ext-lists (mode-ext-lists)
  "Pass in `auto-mode-alist' type conses (ext . mode) except that the ext is a string not a regexp."
  (mapcan (lambda (mode-ext-list)
            (dp-mk-mode-transparent-auto-mode-alist 
             (car mode-ext-list)        ; mode
             (cdr mode-ext-list)))      ; extension list
          mode-ext-lists))

(defvar dp-mode-transparent-regexps
  (dp-mk-mode-transparent-alist-from-mode-ext-lists
   (list (cons 'c-mode
               (append dp-c-just-c-source-file-extensions
                       dp-c-just-c-include-file-extensions
                       '("y" "x")))
         (cons 'c++-mode
               (append dp-cxx-source-file-extensions
                       dp-cxx-include-file-extensions))
         '(emacs-lisp-mode "emacs" "abbrev_defs")
         '(python-mode "py" "pydb")
         '(perl-mode "pm" "pl" "pdbx")
         '(ruby-mode "rb")
         '(pike-mode "pike")
         '(dylan-mode "dylan")))
  "Build regexps that allow me to add things to a file's extension that
don't interfere with mode setting.  I want to have them be like
x.cxx-merged instead of x.merged.cxx, so I need to adjust the regexp to
allow some useful additions (e.g. merged, old, orig).  I can also use
things like c.cxx-no-index to prevent those files from being indexed
w/tags, cscope, etc.")

(dp-add-list-to-list
 'dp-auto-mode-alist-additions
 dp-mode-transparent-regexps)

(dp-add-list-to-list
 'dp-auto-mode-alist-additions
 '(
   ("\\.txt$" . text-mode)
   ("snd.[0-9]*" . text-mode)           ; elm mail files
   ("\\.ol$" . outline-mode)            ; outlines
   ("\\.outline$". outline-mode)        ; ibid
   ("\\.pdb$" . pdb-mode)               ; perl database mode.
   ("\\.sawfishrc$" . sawfish-mode)     ; sawfish lisp files (librep)
   ;; sawfish lisp files (librep)
   ("\\.sawfish/custom$" . sawfish-mode)
   ("\\.jl$" . sawfish-mode)            ; sawfish lisp files (librep)
   ;; my .rc dir files (mostly bash login stuff)
   ;; @todo XXX revist blanket application of sh mode.
   ("/\\.rc/[^/]+$" . shell-script-mode)
   ("\\.jxt$" . dp-journal-mode)        ; dp Journal files.
   ("Makefile\\(\\.in\\)?\\.?[0-9]*" . makefile-mode)
   ))

;; Try alternative to suck-ass `sh-mode' "Shell-script" ksh-mode sucks,
;; too. It get errors whereas sh-mode simply fucks up indentation.
;;(setq interpreter-mode-alist
;;      (subst 'ksh-mode 'sh-mode interpreter-mode-alist))


(dp-add-to-list 'folding-mode-marks-alist '(dp-journal-mode "{{{" "}}}"))

;; pull in multiple major mode stuff if available.
(when (and (dp-xemacs-p)
           (dp-optionally-require 'dp-mmm))
  ;; add our class to journal buffers
  ;;(dmessage "adding mmm...")
  (setq mmm-global-mode 'maybe)
  (make-variable-buffer-local 'mmm-global-mode)
  (setq mmm-mode-string " m3")
  (mmm-add-mode-ext-class 'dp-journal-mode "\\.jxt$" 'dp-universal))

(add-to-list 'jka-compr-compression-info-list
             ["\\.bz2\\(~\\|\\.~[0-9]+~\\)?\\'" 
              "bzipping" "bzip2" ("-c" "-q") 
              "unbzipping" "bzip2" ("-c" "-q" "-d") t t])

;; remove particularly offensive modes.
;; this takes too much time, I never use it, and the extension
;; collides with grub's menu.lst file.
(dolist (el '(("\\.LST\\'" . sas-listing-mode)
	      ("\\.lst\\'" . sas-listing-mode)))
  (setq auto-mode-alist (delete el auto-mode-alist)))


;; case makes C files look like C++
(if (not (in-windwoes))
    (add-to-list 'dp-auto-mode-alist-additions
		 '("\\.C$"  . c++-mode)))

(dp-add-list-to-list 'interpreter-mode-alist
                     '(("python" . python-mode)
                       ("ruby" . ruby-mode)
                       ;;gentoo init.d sctiping interpreter
                       ("runscript" . shell-script-mode)))

(autoload 'compilation-minor-mode "compile")
(autoload 'compilation-buffer-p "compile")
(require 'etags)
(defun file-of-tag ()
  "Replace etags' version. Theirs barfs on large tag files.
This will not handle the 'include feature... but I don't use it.
And their failure occurs way too often."
  (save-excursion
    (end-of-line)
    (re-search-backward "^$")
    (forward-line)
    (beginning-of-line)
    (let ((b (point))
          e)
        (dp-re-search-forward ",")
        (setq e (1- (point)))
        (buffer-substring b e))))

(autoload 'pdb-mode "pdb-mode" "Perl data base mode." t)
;;;;;;;(autoload 'python-mode "python-mode" "Python editing mode." t)
;;;;;;;(autoload 'py-shell "python-mode" "" t)
(autoload 'ruby-mode "ruby-mode" "" t)
(autoload 'sawfish-mode "sawfish" "sawfish lisp editing mode." t)
(setq mc-default-scheme 'mc-scheme-gpg)
(autoload 'mc-decrypt "mc-toplev" "Decrypt a message in the current buffer."
  t)
(autoload 'mc-encrypt "mc-toplev" "Encrypt the current buffer."
  t)
(autoload 'mc-verify "mc-toplev" "Verify the signature of the current buffer."
  t)
(autoload 'dylan-mode "dylan-mode" "Dylan language editing mode.")
(dp-optionally-require 'auto-dp-autoloads)
(dp-optionally-require 'rust-mode)

;; add our python mode hook here, so we can interoperate with ipython.el
;; If there's no ipython.el then we're still ok.
;; fsf needs a python mode (require 'python-mode)
;; fsf (add-hook 'py-shell-hook 'dp-py-shell-hook)

(defun dp-setup-ipython-shell()
  "Setup my ipython shell."
  (let ((an-ipython-command (executable-find "ipython")))
    (when an-ipython-command
      (setq ipython-command an-ipython-command)
      (setq py-python-command-args '("--no-autoindent" 
                                     "--colors=NoColor"))
      (dp-optionally-require 'ipython)

      ;; The string sent to ipython to query for all possible completions. I
      ;; (dp) had to remove the comment (#PYTHON-MODE SILENT) from the end of
      ;; the command string."
      ;; for older IPythons
      ;;    (setq ipython-completion-command-string
      ;;"print ';'.join(__IP.Completer.all_completions('%s'))\n")
      (setq ipython-completion-command-string
            "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

      (setq py-python-command-args '("--no-autoindent" "--colors" "NoColor"))
      (when (featurep 'ipython)
        (defun dp-ipython-complete-collector (string)
          "This was a lambda in `ipython-complete', but I've broken it out to
look for a bug which causes, sometimes, the list of completions to be
printed in the *Python* buffer rather than in a completion
buffer. It's intermittent and repeating the command will eventually
get it to work."
          ;;(message (format "DEBUG filtering: %s" string))
          (setq ugly-return (concat ugly-return string))
          (delete-region comint-last-output-start
                         (process-mark (get-buffer-process (current-buffer)))))

        (defun ipython-complete ()
          "Try to complete the python symbol before point. Only knows about the
stuff in the current *Python* session."
          (interactive)
          (let* ((ugly-return nil)
                 (sep ";")
                 (python-process (dp-python-get-process))
                 ;; XXX currently we go backwards to find the beginning of an
                 ;; expression part; a more powerful approach in the future
                 ;; might be to let ipython have the complete line, so that
                 ;; context can be used to do things like filename completion
                 ;; etc.
                 (beg (save-excursion (skip-chars-backward "a-z0-9A-Z_."
                                                           (point-at-bol))
                                      (point)))
                 (end (point))
                 (pattern (buffer-substring-no-properties beg end))
                 (completions nil)
                 (completion-table nil)
                 completion

                 ;; WAG: just use this set of functions.
         ;;;;;(comint-output-filter-functions nil)

                 ;; @todo XXX Why is this in in a let?  It seems like I'd want
                 ;; the world to know the new value.
                 (comint-output-filter-functions
                  (append comint-output-filter-functions
                          '(ansi-color-filter-apply
                            dp-ipython-complete-collector))))
            ;;(message (format "#DEBUG pattern: '%s'" pattern))
            (process-send-string python-process
                                 (format ipython-completion-command-string
                                         pattern))
            (accept-process-output python-process)
            ;;(message (format "DEBUG return: %s" ugly-return))
            (setq completions
                  (let* ((start (1+ (string-match "'" ugly-return)))
                         (ss (substring ugly-return start))
                         (end (string-match "'" ss))
                         (ss2 (substring ss 0 end)))
                    (split-string ss2 ";")))
            (setq completion-table (loop for str in completions
                                     collect (list str nil)))
            (setq completion (try-completion pattern completion-table))
            (cond ((eq completion t))
                  ((null completion)
                   (message "Can't find completion for \"%s\"" pattern)
                   (ding))
                  ((not (string= pattern completion))
                   (delete-region beg end)
                   (insert completion))
                  (t
                   (message "Making completion list...")
                   (with-output-to-temp-buffer "*Python Completions*"
                     (display-completion-list
                      (all-completions pattern completion-table)))
                   (message "Making completion list...%s" "done")))))))))

(defun dp-setup-python-shell ()
  "Setup python shell.  Choose ipython if preferred."
  (interactive)
  (when dp-prefer-ipython-shell-p
    (dp-setup-ipython-shell)))

(dp-setup-ipython-shell)

;;;;###autoload
;(let ((hm-el '("\\.hs$" . hugs-mode)))
;  (unless (member hm-el auto-mode-alist)
;    (setq auto-mode-alist (cons hm-el auto-mode-alist))))

(if (and (dp-xemacs-p) (file-readable-p "custom-load.el"))
    (load "custom-load"))

(defalias 'with-saved-match-data 'save-match-data)

(dp-defaliases 'cvar 'customize-variable)

;;
;; autoload some template functions
(autoload 'tempo-template-dppydb-fam "dp-templates" 
  "Insert a dppydb family entry with a tempo template." t)
(defalias 'famtemp 'tempo-template-dppydb-fam)
(autoload 'tempo-template-dppydb-host "dp-templates" 
  "Insert a dppydb host entry with a tempo template." t)
(defalias 'hosttemp 'tempo-template-dppydb-host)
(autoload 'tempo-template-pb-entry "dp-templates" 
  "Insert a phonebook entry with a tempo template." t)
(defalias 'pbtemp 'tempo-template-pb-entry)

;;
;; Aliases for stuff whose frequency of use doesn't warrant a binding, but is
;; not too uncommon. And whose name is too long.  And with annoying
;; completion.  Yes, I'm looking at you cl-prettyprint and cl-prettyexpand.
(defalias 'cl-pp 'cl-prettyprint)
(defalias 'cl-pe 'cl-prettyexpand)
(defalias 'cl-px 'cl-prettyexpand)
(dp-defaliases 'cust 'cst 'cmz 'customize)
(dp-defaliases 'custv 'cusv 'cstv 'csv 'cmv 'cmzv 'customize-variable)
(dp-defaliases 'custa 'cusa 'csta 'csa 'cma 'cmza 'customize-apropos)

(when (and dp-use-ffap-p
           (dp-optionally-require 'ffap))
  (message "ffaping...")
  (ffap-bindings)			; do default key bindings
  (dp-add-list-to-list 'ffap-compression-suffixes '(".bz2"))

  ;; the builtin ds.internic.net seems to be history
  ;; alternates:
  ;; NIS.NSF.NET:/internet/documents/rfc/rfc%s.txt
  ;; FTP.RFC-EDITOR.ORG:/in-notes/rfc%s.txt
  ;; SUNSITE.ORG.UK:rfc/rfc%s.txt
  ;; ftp.isi.edu:/in-notes/rfc%s.txt
  ;; send mail to: RFC-SERVER@ISI.EDU w/body: help: ways_to_get_rfcs
  ;;  to get info about obtaining rfcs.
  (setq ffap-rfc-path
        (concat (ffap-host-to-path "ftp.rfc-editor.org")
                "/in-notes/rfc%s.txt"))

  (defvar dp-ffap-ffap-file-finder ffap-file-finder
    "Copy of `ffap-file-finder', since we point it our function.")

  (setq ffap-file-finder 'dp-ffap-file-finder2)

  ;; Add some of my favorite places to find included files, or, more
  ;; precisely, any file names in a c/c++ file.
  ;; Called by by using `ffap-alist' (q.v.). 
  ;;
  (dp-add-list-to-list 'ffap-c-path 
                       '("../include" 
                         "../inc"
                         "../h"
                         "../src"))

  (add-to-list 'ffap-alist (cons dp-p4-location-regexp 
                                 'dp-maybe-expand-p4-location+))

  (message "ffapped.")
)

(defvar dp-file-finder (if (and dp-use-ffap-p
				(featurep 'ffap))
			   'find-file-at-point
			 'find-file)
  "Function used to open files.")

(defvar dp-file-finder-other-window 
  (if (and dp-use-ffap-p
           (featurep 'ffap))
      'ffap-other-window
    'find-file-other-window)
  "Function used to open files in another window.")

(dp-deflocal dp-file-group nil
  "Associate files in some way.
See `dp-set-file-group'.
This can be callable.")

;;
;; my highly unstandard keybindings.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(load "dp-keys")

(transient-mark-mode 1)
(line-number-mode 1)
(column-number-mode 0)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'eval-expression 'disabled nil)
(setq-default scroll-step 1)

;;

;; Set lots of variables more to my liking.
(setq next-line-add-newlines nil
      search-highlight t
      find-file-use-truenames nil	; I set up the symlinks For A REASON.
      find-file-existing-other-name t
      tag-mark-stack-max 128
      compilation-window-height 10
      default-major-mode 'text-mode
      save-buffer-context t
      
      calendar-latitude 42.3
      calendar-longitude -71.1
      calendar-location-name "Reading, MA"
      parens-require-spaces nil
      truncate-partial-width-windows nil
      focus-follows-mouse t
      )

;; Put some things in their own frames...
(add-to-list 'special-display-regexps "^\\*P4.*\\*$")

;; configure an Emacs mail subsystem...
(when (and nil (bound-and-true-p dp-use-dp-mail-p))
  (require 'dp-mail))

(require 'dp-makefile-mode)


;;; ********************
;;; "Filladapt is a paragraph filling package.  When it is enabled it
;;; makes filling (e.g. using M-q) much much smarter about paragraphs
;;; that are indented and/or are set off with semicolons, dashes, etc."
;;; (copped from sample.init.el)
(when (dp-optionally-require 'filladapt)
  (setq-default filladapt-mode t)
  (add-hook 'outline-mode-hook 'turn-off-filladapt-mode)
  (setq filladapt-mode-line-string " Fa"))

;;;;;(require 'dp-shells)

(defun dp-mk-remote-files-precious (&optional buffer pred)
  (setq-ifnil buffer (current-buffer)
              pred 'dp-remote-file-p)
  (when (funcall pred buffer-file-name)
    (setq file-precious-flag t)))

(when (dp-xemacs-p)
  ;; FSF has other option[s].
  (icomplete-mode))

;;;
;;; Best remote file access protocol I've seen so far.
;;;
(defun dp-setup-tramp ()
  (interactive)
  (setq tramp-persistency-file-name (concat 
                                     (dp-mk-dropping-dir "/tramp.d" 
                                                         'no-change) 
                                     "/cache")
        tramp-auto-save-directory (dp-mk-dropping-dir 
                                   "/tramp.d/auto-saves.d" 
                                   'no-change))
  (dmessage "0:tramp-auto-save-directory>%s<" tramp-auto-save-directory)
  
  (when (dp-optionally-require 'tramp)
    (make-local-variable 'file-precious-flag)  
    (add-hook 'find-file-hooks 'dp-mk-remote-files-precious))
  (dmessage "1:tramp-auto-save-directory>%s<" tramp-auto-save-directory)

)
(add-hook 'dp-post-dpmacs-hook 'dp-setup-tramp)

;; let's see if this works well.
(when dp-fontify-p
  ;; dunno which is best... the menus use -shot.
  ;; with this one, I do see regular text, then the colors popup
  ;;(add-hook 'font-lock-mode-hook 'turn-on-lazy-shot)
  (if (dp-xemacs-p)
      (progn
        (require 'lazy-lock)
        (add-hook 'font-lock-mode-hook 'turn-on-lazy-lock)
        (dp-set-minor-mode-modeline-id 'lazy-lock-mode)
        (dp-set-minor-mode-modeline-id 'font-lock-mode))
    ;; We may be able to use font-lock-mode for both.
    ;; It exists in xemacs.
    (global-font-lock-mode t )))

(dp-set-minor-mode-modeline-id 'abbrev-mode " Abv")
(dp-set-minor-mode-modeline-id 'auto-fill-function " Fl")

;(when (dp-optionally-require 'highline)
;      (highline-mode-on))
(autoload 'highline-mode "highline" "Turn on current line highlighting." t)
(autoload 'dp-diary-entries-to-pcal "dp-cal" 
  "Convert diary entries to pcal entries." t)

;;; load late 'macs specific stuff. 
(if (dp-xemacs-p)
    (progn
      (require 'dp-xemacs-late)
      (dp-setup-invisibility))
  ;; dp-fsf-late
  (dp-bump-key-binding (kbd "C-x SPC") 'rectangle-mark-mode (kbd "C-x M-SPC")
		       global-map))

(defun dp-using-flyspell-p ()
  "Are we using flyspell? We need a spell program and the flyspell feature."
  (and dp-use-flyspell-p
       (executable-find ispell-program-name)
       (fboundp 'flyspell-mode)))

(if-and-boundp 'dp-ispell-program-name
    ;; Use a spec-macs defined variable if there is one and it is non-nil
    (progn 
      (setq ispell-program-name dp-ispell-program-name)
      (dmessage "Using spec macs spell program: %s" dp-ispell-program-name))
  ;; Else try to find one
  ;; Why did I comment this out?
  (dp-init-spellin))

;;
;; when this abbrev is expanded, it gets the cwd from the
;;  rsh buffer and inserts it into the minibuffer.
(when dp-minibuffer-abbrev-table
  (define-abbrev dp-minibuffer-abbrev-table "wd" "wd"
    'dp-rsh-expand-replace-cwd))

(require 'dp-ilisp)

(defun dp-org-mode-hook ()
  ;; Restore these in this buffer
  (message "WH00T!")
  (local-set-key [(meta up)] 'dp-other-window-up)
  (local-set-key [(meta kp-up)] 'dp-other-window-up)
  (local-set-key [(meta down)] 'other-window)
  (local-set-key [(meta kp-down)] 'other-window)
  (local-set-key [(control ?<)] 'org-metaup)
  (local-set-key [(control ?>)] 'org-metadown)
  (local-set-key [(meta ?-)] 'dp-bury-or-kill-buffer))

(defun dp-setup-org-mode()
  "Set up org mode my, overly complicated, way."
  (interactive)
  (if (dp-optionally-require 'org)
      (progn
	(global-set-key [(control ?c) ?l] 'org-store-link)
	(global-set-key [(control ?c) ?a] 'org-agenda)
	
	(setq org-log-done 'time)
	(add-hook 'org-mode-hook 'dp-org-mode-hook)
	)
    (message "org-mode is not available.")))

;; This needs to be done before we're required because the hook is called
;; just before the file exits.
(defun dp-setup-bookmarks ()
  (interactive)
  (add-hook 'bookmark-load-hook 'dp-bookmark-load-hook)

  ;; `defvar' so we can set it elsewhere like a spec-macs.
  (defvar bookmark-default-file
        (dp-nuke-newline (shell-command-to-string
                          "mk-persistent-dropping-name.sh --use-project-as-a-suffix emacs.bmk")))
 
  (require 'bookmark)
  (setq bookmark-save-flag 1)
  (defun dp-bookmark-mk-location-str (bookmark &optional no-history)
    "Insert the name of the file associated with BOOKMARK.
Optional second arg NO-HISTORY means don't record this in the
minibuffer history list `bookmark-history'."
    (interactive (bookmark-completing-read "Insert bookmark location"))
    (or no-history (bookmark-maybe-historicize-string bookmark))
    (let ((start (point)))
      (prog1
          ;; *Return this line*
          (format "%s:%sc"
                          (bookmark-location bookmark)
                          (bookmark-get-position bookmark))
        (if window-system
            (put-text-property start
                               (save-excursion (re-search-backward
                                                "[^ \t]")
                                               (1+ (point)))
                               'mouse-face 'highlight)))))
  (defun dp-bookmark-insert-location (&rest r)
    (interactive)
    (insert (call-interactively 'dp-bookmark-mk-location-str)))

  (defun dp-bookmark-bmenu-locate ()
    "Display location of this bookmark.  Displays in the minibuffer."
    (interactive)
    (if (bookmark-bmenu-check-position)
	(let ((bmrk (bookmark-bmenu-bookmark)))
	  (message (dp-bookmark-mk-location-str bmrk)))))

  ;; Make sure a bookmark file exists and has the correct format.  This must
  ;; be in the bookmark code, but Ah canna find it.
  (bookmark-write-file bookmark-default-file)
)

(add-hook 'dp-post-dpmacs-hook 'dp-setup-bookmarks)

;; turn flyspell on everywhere for certain major modes
;; (see dp-flyspell.el :: dp-flyspell-hooks)
(dp-flyspell-setup)

;; turn flyspell on in prog mode for certain major modes.
;; flyspell's prog mode only checks for spelling errors
;; in program comments, strings, etc.
;; (see dp-flyspell.el :: dp-flyspell-prog-hooks)
(dp-flyspell-prog-setup)

(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
          (function
           (lambda ()
             (inf-ruby-keys))))

(setq search-ring-max 128
      regexp-search-ring-max 128)

(dp-set-frame-title-format)

;; Do these more like at run-time vs load-time.
;; This hook is run at the end of dpmacs.el
(add-hook 'dp-post-dpmacs-hook
          (function
           (lambda ()
;;;(require 'psvn) ; Just let vc take care of everything?
             (require 'dp-faces)
	     (require 'dp-ptools)
             (add-hook 'isearch-mode-hook 'dp-isearch-mode-hook)
             (add-hook 'isearch-mode-end-hook 'dp-isearch-mode-end-hook)
             ;; @todo autoload-ify the main entry points.
             (require 'dp-hooks)
	     (require 'dp-vc)
             (dp-setup-cscope)
             (if (dp-xemacs-p)
                 (paren-activate))
             )))

(when (paths-file-readable-directory-p dp-site-package-info)
  (add-to-list dp-info-path-var dp-site-package-info))

(when (paths-file-readable-directory-p dp-local-package-info)
  (add-to-list dp-info-path-var dp-local-package-info))

(autoload 'follow-mode "follow"
  "Synchronize windows showing the same buffer, minor mode." t)

(autoload 'follow-delete-other-windows-and-split "follow"
  "Delete other windows, split the frame in two, and enter Follow Mode." t)

(when (dp-optionally-require 'folding nil)
  (setq-default folding-internal-margins nil))

(defvar dp-orig-comint-password-prompt-regexp comint-password-prompt-regexp
  "`defvar' allows us to save the original version once, unless eval'd interactively.")

;; Make the password hider work with some other programs.
;;till-fixed (loop for prompt in '("Enter passphrase for" 
;;till-fixed                       "Enter password"
;;till-fixed                       "[sudo] password for dapanarx")
;;till-fixed   do (unless (posix-string-match (concat "^" prompt "$")
;;till-fixed               comint-password-prompt-regexp)
;;till-fixed        (setq comint-password-prompt-regexp 
;;till-fixed              (concat comint-password-prompt-regexp
;;till-fixed                      (concat "\\|\\("
;;till-fixed                              (regexp-quote prompt)
;;till-fixed                              ".*: \\)")))))

(setq comint-password-prompt-regexp
      (concat
       "\\(\\([Oo]ld \\|[Bb]ad \\|[Nn]ew \\|^\\)?[Pp]assword\\|pass[ _-]?phrase\\):?\\s-*\\'"
       "\\|"
       "\\(Enter passphrase for.*: \\)"
       "\\|"
       "\\(Password for .*\\)"
       "\\|"
       "\\(Bad passphrase, try again for.*:\\)"
       "\\|"
       "\\(Enter password.*:\\s-+\\)"
       "\\|"
       "\\(\\(\\[sudo\\] \\)?[Pp]assword for .*"
       "\\(davep\\||dpanariti\\|dapanarx.*\\).*:? \\)")
      )

;;matches everything (setq comint-password-prompt-regexp
;;matches everything       (concat
;;matches everything        "\\(\\([Oo]ld \\|[Bb]ad \\|[Nn]ew \\|^\\)?[Pp]ass\\(word\\|-?phrase\\)\\):?"
;;matches everything        "\\s-*\\'"
;;matches everything        "\\|"
;;matches everything        "\\(Enter passphrase for.*: \\)"
;;matches everything        "\\|"
;;matches everything        "\\(Enter password.*:\\s-+\\)"
;;matches everything        "\\|"
;;matches everything        "\\(\\(\\[sudo\\] \\)?[Pp]assword for .*"
;;matches everything        "\\(davep\\||dpanariti\\|dapanarx.*\\).*:? \\)?"))

(cond
 ((bound-and-true-p dp-wants-emms-p) (dp-optionally-require 'dp-emms))
 ((bound-and-true-p dp-wants-mingus-p) (dp-optionally-require 'dp-mingus))
 (t (message "No music player requested.")))

(dp-set-frame-title-format)

;;;;;;;

(dp-init-abbrevs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Run dp-post-dpmacs-hook.  Very, very little (should be made
;;; nothing) should be done after this.  We do this last because the
;;; hooks use other internal routines and I don't want any
;;; undefined/void errors.
(message "dpmacs.el: dp-post-dpmacs-hook, running: %s..." dp-post-dpmacs-hook)

(message "point: %s, point-max: %s" (point) (point-max))
(let ((l dp-post-dpmacs-hook)
      hook)
  (while l
    (setq hook (car l)
          l (cdr l))
    ;;(message "running hook: %s" hook)
    (run-hook-with-args (quote hook))
    ;;(message "finished hook: %s" hook)
    (goto-char (point-max))
    ))

(message "dpmacs.el: dp-post-dpmacs-hook, FINISHED.")

(add-hook 'kill-emacs-hook 'dp-kill-emacs-hook)

(setq dp-ding-backtrace-p nil)
(ad-unadvise 'ding)

;; Some of the methods of binding are very fucked up.
;; E.g. these fail
;; (global-set-key [(meta space)] 'dp-id-select-thing)
;; (global-set-key [(control space)] 'dp-expand-abbrev)
;; But these work.  Seems limited. E.g. I've seen it with
;; {control,meta} X {space,tab}
(define-key esc-map " " 'dp-id-select-thing)
(define-key global-map [?\C- ] 'dp-expand-abbrev)

(dp-set-to-max-vert-frame-height)
(message "dpmacs.el... finished.")
