;;;
;;; Programming tools
;;;

(dmessage "Loading dp-ptools...")

(define-error 'dp-*TAGS-aborted
  "Badness in the guts of the (too) deeply nested *TAGS stuff." 
  'error)

;;(dp-setup-hyperbole)
;;(autoload 'smart-ancestor-tag-files "hmouse-tag")

;;
;; Copped from an olde version of hyperbole.  The new stuff is quite
;; different and I can't find this anywhere so I've ganked it out of the
;; version I originally used.
(defun smart-ancestor-tag-files (&optional path name-of-tags-file)
  ;; Walk up path tree looking for tags files and return list from furthest
  ;; to deepest (nearest).
  (or path (setq path default-directory))
  (let ((tags-file-list)
	tags-file)
    (while (and
	    (stringp path)
	    (setq path (file-name-directory path))
	    (setq path (directory-file-name path))
	    ;; Not at root directory
	    (not (string-match
		  (concat (file-name-as-directory ":?") "\\'")
		  path)))
      (setq tags-file (expand-file-name (or name-of-tags-file "TAGS") path))
      (if (file-readable-p tags-file)
	  (setq tags-file-list (cons tags-file tags-file-list))))
    tags-file-list))


(defconst dp-default-work-root-pattern (dp-concat-regexps-grouped
                                        '("/work/"
                                          "/scratch.dpanariti"
                                          "work-is-play"
                                          "/include/"
                                          "/inc/"
                                          "/h/"
                                          "/source/"
                                          "/src/"))
  "This must be in a path name for the path name to be considered a work path
  name.")

(defun* dp-in-a-work-dir-p (path-name &optional 
                           (work-root-dir dp-default-work-root-pattern))
  (string-match work-root-dir path-name))

(defvar dp-ok-tags-files '())

(defun* dp-find-nearest-*-file (file-names &optional start-dir
                                (final-pred 'dp-in-a-work-dir-p)
                                (final-pred-args '())
                                (ask-if-pred-fails-p t))
  "Find closest file in FILE-NAMES up in the dir tree.
The name appearing first in FILE-NAMES will win in the case of a tie.  We'll
\(apply FINAL-PRED MAX-STRING FINAL-PRED-ARGS\) to the final candidate.  We
want to prevent things like running into \"~/TAGS\" when looking for files
in, say, \"~/work/some/important/stuff\", so by default FINAL_PRED makes sure
that we're under a directory named work."
  (setq-ifnil start-dir default-directory)
  (let* ((path-lists (mapcar 
                      (function 
                       (lambda (tf-name)
                         ;; Using this has no TAG file requirements, so it
                         ;; can look up the tree for any file.
                         (smart-ancestor-tag-files start-dir tf-name)))
                      file-names))
         (max-lens (mapcar
                    (function
                     (lambda (path-list)
                       (dp-longest-delimited-string-len path-list)))
                    path-lists))
         (i-of-max (dp-index-of-max max-lens))
         (max-len (nth i-of-max max-lens))
         (max (if (and i-of-max
                       (>= i-of-max 0))
                  (car (last (nth i-of-max path-lists)))
                nil)))
    (if (and max
             (or (not final-pred)
                 (or (apply final-pred max final-pred-args)
                     (and ask-if-pred-fails-p
                          (or (member max dp-ok-tags-files)
                              (and 
                               (y-or-n-p (format 
                                          "That doesn't sound workish to me: %s; accept? "
                                          max))
                               (add-to-list 'dp-ok-tags-files max)))))))
        max
      nil)))

(defun* dp-find-nearest-*-files (file-names &optional start-dir
                                 (final-pred 'dp-in-a-work-dir-p)
                                 (final-pred-args '()))
  (delq nil (mapcar (function
                     (lambda (file-name)
                       (apply 'dp-find-nearest-*-file (list file-name)
                              start-dir
                              final-pred
                              final-pred-args)))
                    file-names)))

(defstruct dp-*TAGS-handler
  (finder)
  (returner)
  (other-window-finder)
  (name))

;; 
;; -C ignore case.
;; ????? (setq cscope-command-args '("-C"))
(defun dp-setup-cscope ()
  (interactive)
  (defadvice cscope-extract-symbol-at-cursor 
    (around dp-cscope-extract-symbol-at-cursor activate)
    (if (dp-mark-active-p)
        (setq ad-return-value (buffer-substring (mark) (point)))
      ad-do-it))

  (defun dp-cscope-list-entry-hook ()
    (define-key cscope-list-entry-keymap "i" 'dp-tag-find-with-idutils-bury-first))
  (add-hook 'cscope-list-entry-hook 'dp-cscope-list-entry-hook)

  (defun dp-cscope-select-entry-this-window ()
    "Visit the current entry in the cscope buffer window."
    (interactive)
    (cscope-select-entry-specified-window (selected-window)))

  (defun dp-bind-xcscope-keys (&optional map)
    (interactive "Smap? ")
    (setq-ifnil map global-map)
    ;;
    (define-key map [f5]  'cscope-find-this-symbol)
    (define-key map [f6]  'cscope-find-global-definition)
    (define-key map [(control ?c) ?s ?A] 'cscope-unset-initial-directory)
    (define-key map [(control ?c) ?s ?B] 'cscope-display-buffer-toggle)
    (define-key map [(control ?c) ?s ?C] 'cscope-find-called-functions)
    (define-key map [(control ?c) ?s ?D] 'cscope-dired-directory)
    (define-key map [(control ?c) ?s ?E] 'cscope-edit-list-of-files-to-index)
    (define-key map [(control ?c) ?s ?G] 'cscope-find-global-definition-no-prompting)
    (define-key map [(control ?c) ?s ?L] 'cscope-create-list-of-files-to-index)
    (define-key map [(control ?c) ?s ?N] 'cscope-next-file)
    (define-key map [(control ?c) ?s ?P] 'cscope-prev-file)
    ;; Annoyingly, this could change whenever I change gtags tagging backend.
    ;; With `native', cscope can do references.
    ;; ex-ctags and uctags can't, but can do other things better.
    (define-key map [(control ?c) ?s ?S] 'cscope-find-this-symbol)
    (define-key map [(control ?c) ?s ?s] 'dp-tag-find-with-idutils)

    (define-key map [(control ?c) ?s ?T] 'cscope-tell-user-about-directory)
    (define-key map [(control ?c) ?s ?W] 'cscope-tell-user-about-directory)
    (define-key map [(control ?c) ?s ?a] 'cscope-set-initial-directory)
    (define-key map [(control ?c) ?s ?b] 'cscope-display-buffer)
    (define-key map [(control ?c) ?s ?c] 'cscope-find-functions-calling-this-function)
    (define-key map [(control ?c) ?s ?d] 'cscope-find-global-definition)
    (define-key map [(control ?c) ?s ?e] 'cscope-find-egrep-pattern)
    (define-key map [(control ?c) ?s ?f] 'cscope-find-this-file)
    (define-key map [(control ?c) ?s ?g] 'cscope-find-global-definition)
    (define-key map [(control ?c) ?s ?i] 'dp-tag-find-with-idutils)
    (define-key map [(control ?c) ?s ?n] 'cscope-next-symbol)
    (define-key map [(control ?c) ?s ?p] 'cscope-prev-symbol)
    (define-key map [(control ?c) ?s ?t] 'cscope-find-this-text-string)
    (define-key map [(control ?c) ?s ?u] 'cscope-pop-mark)
    (global-set-key [(control ?c) ?s ?I] 'cscope-find-files-including-file)
    ;; The previous line corresponds to be end of the "Cscope" menu.
    ;; ---
    ;; 'o' is Buffer-menu-other-window, 'o' is dired-find-file-other-window
    ;; etc. So I'm moving some keys:
    )
  ;;
  ;; Make xcscope bindings global
  ;; ??? Do this only in c-mode-common-hook?
  ;;
  (defun dp-bind-xcscope-fkeys (&optional map)
    (interactive "Smap? ")
    (setq-ifnil map global-map)
    (define-key map [(control f3)] 'cscope-set-initial-directory)
    (define-key map [(control f4)] 'cscope-unset-initial-directory)
    (define-key map [(control f5)] 'cscope-find-this-symbol)
    (define-key map [(control f6)] 'cscope-find-global-definition)
    (define-key map [(control f7)] 'cscope-find-global-definition-no-prompting)
    (define-key map [(control f8)] 'cscope-pop-mark)
    (define-key map [(control f9)] 'cscope-next-symbol)
    (define-key map [(control f10)] 'cscope-next-file)
    (define-key map [(control f11)] 'cscope-prev-symbol)
    (define-key map [(control f12)] 'cscope-prev-file)
    (define-key map [(meta f9)] 'cscope-display-buffer)
    (define-key map [(meta f10)] 'cscope-display-buffer-toggle))
  
  (defvar dp-cscope-current-dir-only-regexps nil
    "The value for `cscope-database-regexps' that will cause us to search the
    current directory only.
??? Maybe should be '(t) ??? As per `cscope-database-regexps' doc?")
  (defvar dp-cscope-db-update-required-p nil)

  (defun dp-cscope-minor-mode-p ()
    "Return non-nil if `cscope-minor-mode' is in effect."
    (assq 'cscope-minor-mode minor-mode-map-alist))

  (defun dp-cscope-set-db-update-required ()
    (setq dp-cscope-db-update-required-p
          (and (dp-in-c)
               (dp-cscope-minor-mode-p))))

  (defun dp-cscope-force-current-dir-only (&optional restore-p)
    (interactive "P")
    (if restore-p
        (dp-cscope-set-cscope-database-regexps 'reset)
      (setq cscope-database-regexps dp-cscope-current-dir-only-regexps)))
  (dp-defaliases 'dp-cscope-. 'dp-cscope. 'dp-cscope-force-current-dir-only)

  (when (dp-optionally-require 'xcscope)
    ;; defun dp-cscope-minor-mode-hook Something in some files can cause the
    ;; permuted style index (-q) to fail to find things. Currently, there is
    ;; something in the src tree @ nv that causes this.
    (setq cscope-perverted-index-option dp-cscope-perverted-index-option
          cscope-edit-single-match nil)
    (defun dp-cscope-minor-mode-hook ()
      (interactive)
      (define-key cscope-list-entry-keymap [(meta ?-)] 
        (kb-lambda (dp-func-or-kill-buffer 
                    'cscope-bury-buffer)))
      (dp-define-keys cscope-list-entry-keymap 
                      '([?.] dp-cscope-select-entry-this-window
                        [?v] cscope-show-entry-other-window
                        [?o] cscope-select-entry-other-window
                        [return] cscope-select-entry-other-window
                        [? ] cscope-select-entry-one-window
                        [?1] cscope-select-entry-one-window
                        [(tab)] cscope-next-symbol
                        [(control ?i)] cscope-next-symbol
                        [?d] cscope-find-global-definition)))
    
    (add-hook 'cscope-minor-mode-hooks 'dp-cscope-minor-mode-hook)
    ;; @todo XXX This should actually DO SOMETHING... it's only acting as a
    ;; predicate.
    (add-hook 'after-save-hook 'dp-cscope-set-db-update-required)

    ;; defun cs
    (defun dp-cscope-buffer (&optional no-select)
      "Switch to cscope results buffer, if it exists."
      (interactive)
      (if (setq b (get-buffer cscope-output-buffer-name))
          (if no-select
              (set-buffer b)
            (dp-display-buffer-select b))
        (message "No cscope results buffer yet.")))
    (defalias 'cs 'dp-cscope-buffer)

    (when-and-boundp dp-bind-xcscope-keys-p
      (dp-bind-xcscope-keys))
    (when-and-boundp dp-bind-xcscope-fkeys-p
      (dp-bind-xcscope-fkeys))
    
    (defadvice cscope-prompt-for-symbol (before dp-cscope-push-gb activate)
      "Push go back before doing a cscope operation.
This seems to be a fairly common routine that is run before most commands.
It gives us a common point to save our position before going off after a
cscope discovery.
*** Look at new xcscope.el. It has some mark stack capability now."
      (dp-push-go-back "go-back advised cscope-prompt-for-symbol"))
    
    (defadvice  cscope-next-symbol 
      (before dp-advised-cscope-next-symbol activate)
      (dp-set-current-error-function 'dp-cscope-next-thing
                                     nil
                                     'cscope-next-symbol))
    
    (defadvice  cscope-next-file (before dp-advised-cscope-next-file activate)
      (dp-set-current-error-function 'dp-cscope-next-thing 
                                     nil 
                                     'cscope-next-file))
    
    (defadvice  cscope-prev-symbol 
      (before dp-advised-cscope-prev-symbol activate)
      (dp-set-current-error-function 'dp-cscope-next-thing
                                     nil
                                     'cscope-prev-symbol))
    
    (defadvice  cscope-prev-file (before dp-advised-cscope-prev-file activate)
      (dp-set-current-error-function 'dp-cscope-next-thing
                                     nil
                                     'cscope-prev-file))
    
    ;;!<@todo Do I want to do this? It doesn't cause a current window change,
    ;;but it is a common action and ?is? logically similar to the others.
    ;; Right now, it has a problem in that it unconditionally sets the error
    ;; function to cscope-next-symbol rather than what it was that preceded
    ;; it.
    ;; There is a problem when this is used directly from the cscope buffer.
    ;; The value is not set there and so will retain the previous value which
    ;; may be nil or unset.
    (defadvice  cscope-show-entry-other-window 
      (before dp-advised-cscope-prev-file activate)
      (dp-set-current-error-function 'dp-cscope-next-thing
                                     nil
                                     'cscope-next-symbol))
    
    (defadvice  cscope-select-entry-other-window 
      (before dp-advised-cscope-prev-file activate)
      (dp-set-current-error-function 'dp-cscope-next-thing
                                    nil
                                    'cscope-next-symbol)))
  (defvar dp-def-work-dir (dp-mk-pathname (getenv "HOME") "work"))
  (defvar dp-def-cscope-db-dir-name "def-cscope.d")
  (defvar dp-def-work-cscope-db-dir-name
    (dp-mk-pathname dp-def-work-dir dp-def-cscope-db-dir-name))
  (defvar dp-def-home-cscope-db-dir-name 
    (dp-mk-pathname (getenv "HOME") dp-def-cscope-db-dir-name))
;; This is a poorly documented, convolutedly implemented bizarre variable and
;; in general boggles my mind and confuzes the hell out of me... and yet
;; seems so simple.  All I want to do is to search upward from the current
;; dir for the database. If nothing is found, then I'd like to access a
;; default db.  So, if I'm in a work dir, I'll get the most specific
;; db. Otherwise (say in ~), I'll get some default db (say my current
;; project's current sandbox's db.)
;;   (setq cscope-database-regexps
;;         `(
;;           ( ,(concat "^" dp-def-work-dir)
;;             ( t )
;;             t
;;             ( ,dp-def-work-cscope-db-dir-name ("-d"))
;;             t)
;;           ( ".*"
;;             t
;;             ( ,dp-def-home-cscope-db-dir-name ("-d"))
;;             t)
;;           ))
  )

;; XXX @todo remove regular tags if
;; 1) gtags proves better
;; 2) gtags is installed
;; In general, verify existence of tag chaser.
(defvar dp-*TAGS-handlers
  (list
   (list "GTAGS" (make-dp-*TAGS-handler
                  :finder 'gtags-find-tag
                  :returner 'gtags-pop-stack
                  :other-window-finder 'gtags-find-tag-other-window
                  :name "gtags")
         )
   (list "TAGS" (make-dp-*TAGS-handler 
                 :finder 'find-tag 
                 :returner 'pop-tag-mark 
                 :other-window-finder 'find-tag-other-window
                 :name "tags")))
  "Tags commands for given tag systems.")

;; Let the handlers register themselves and their tag file names.
;; This lets us enable/disable in one place.
(defvar dp-default-*TAGS-file-names '("GTAGS" "TAGS")
  "In order of preference.
Either GTAGS/Global sucks big-time or I'm too stupid to use it rightly.  It
never seems to find what I need and (minor point) doesn't clean up after
itself when it can't find what is needed.
E.g. Exuberant ctags + `find-tag' given Vector::Iterate finds:
class VectorSink : public Sprockit::Sink1<Frame<int> >
...
  void Iterate()

Whereas Global can't even find Vector.
It can't be this bad, I must be missing something.
By default, gtags doesn't look in .h files C++ features.
Oddly, it doesn't handle structs.")

(defun dp-find-nearest-*TAGS-file-path (&optional tag-file-names start-dir)
  (dp-find-nearest-*-file (or tag-file-names dp-default-*TAGS-file-names)
                          start-dir))

(defun dp-find-nearest-*TAGS-file (&optional tag-file-names start-dir)
  (let ((tag-file (dp-find-nearest-*TAGS-file-path tag-file-names 
                                                   start-dir)))
    (when tag-file
      (file-name-nondirectory tag-file))))

(defun dp-get-*TAGS-handler (&optional tag-file-names start-dir)
  (let ((tag-file (dp-find-nearest-*TAGS-file tag-file-names start-dir)))
    (when tag-file
      (cadr (assoc (dp-find-nearest-*TAGS-file tag-file-names start-dir)
                   dp-*TAGS-handlers)))))

(defun* dp-get-*TAGS-handler-list (&optional 
                                   (tag-file-names dp-default-*TAGS-file-names)
                                   start-dir)
  "Create a list of tag handlers based on current dir and existing tag files."
  (delq nil (mapcar (function
                     (lambda (tag-file-name)
                       (funcall 'dp-get-*TAGS-handler (list tag-file-name)
                                start-dir)))
                    tag-file-names)))

(defvar dp-*TAGS-stack '()
  "I need to remember how a tag was found so I can pop it off the right stack.")

(defun dp-*TAGS-push-handler (handler)
  (push handler dp-*TAGS-stack))

(defun dp-*TAGS-pop-handler ()
  (pop dp-*TAGS-stack))

(defun dp-*TAGS-try-handler-funcs (handlers gettor)
  (interactive)
  (loop for handler in handlers
    do (let ((start-pos (point-marker))
             (start-buffer (current-buffer))
             (bol (dp-mk-marker (line-beginning-position)))
             (eol (dp-mk-marker (line-end-position)))
             new-pos)
         (condition-case err
             (progn
               ;; Try the handler. If it succeeds, then we'll push a
               ;; corresponding handler entry onto our old stack. This is
               ;; used to return from a tag in a handler specific fashion.
               ;; We need to know if the gettor succeeded in order for this
               ;; to work. GLOBAL/GTAGS makes this hard.
               (message "Trying: %s" (dp-*TAGS-handler-name handler))
               (call-interactively (funcall gettor handler))
               ;; gtags is a pain in the ass.  It moves point to the
               ;; beginning of the current symbol and leaves it there. This
               ;; makes it look like a tag was found.  A partial workaround
               ;; is to see if we've moved off the current line.  This will
               ;; break when we try to find a symbol that is defined on the
               ;; current line, which is basically a braino.
               ;; FUCK gtags for now.
               ;; gtags seems to be fixed. By default, .h files are treated
               ;; as C only and are not examined for C++ constructs. Oddly,
               ;; structs don't work wither
;;               (dp-*TAGS-push-handler handler)
;;               (return))
               (setq new-pos (point-marker))
               ;; Compensate for gtags.el's bogus moving of point even if it
               ;; cannot find the tag, and only push the (return)handler if
               ;; we've moved to a different line.
               (when (or (not (equal start-buffer (current-buffer)))
                         ;; Inconvenient, but failure leaves us at point if
                         ;; we enter an unfindable tag name on a blank line.
                         (= (point) (start-pos))
                         (< new-pos bol)
                         (> new-pos eol))
                 ;; When gtags goes to the gtags buffer, we lose the ability
                 ;; to return to original spot, so hack till time:
                 (dp-push-go-back "Hack in dp-tags stuff.")
                 (dp-*TAGS-push-handler handler)
                 (return))
               (dp-ding-and-message "%s didn't take us anywhere with the tag."
                                    (dp-*TAGS-handler-name handler)))
           (t (dmessage "Caught condition: %s in dp-*TAGS-try-handler-funcs"
                        err))))))

;;
;; fsf wants nil t to go to the next tag,
;; xemacs wants nil nil ""
;;(global-set-key [(control ?.)] (kb-lambda (find-tag nil (not (dp-xemacs-p)))))
;; When gtagsing, this will be it's prefix.

(dp-deflocal dp-gtags-suggested-key-mapping t
  "Does this buffer want gtags key mappings?")

;;
;; We make xgtags use this.
(when (or (dp-gtags-p) (dp-xgtags-p))
  (make-variable-buffer-local 'gtags-auto-update)
  (setq-default gtags-auto-update nil)
  (make-variable-buffer-local 'dp-gtags-auto-update-flags)
  (setq-default dp-gtags-auto-update-flags "--rgg-first-db")
  (defun dp-gtags-update-file ()
    (interactive)
    (let ((gtags-mode t)
          (gtags-auto-update t))
      (message "gtags updating...")
      (gtags-auto-update)
      (message "done.")))
  (defalias 'guf 'dp-gtags-update-file))

(when (dp-gtags-p)

  (defun dp-gtags-current-token ()
    (if (dp-mark-active-p)
        (buffer-substring (mark) (point))
      (gtags-current-token)))

  (defun dp-gtags-select-tag-other-window ()
    (interactive)
    (dp-push-go-back&call-interactively
     'gtags-select-tag-other-window
     nil nil "gtags-select-tag-other-window"))
  
  (defun dp-gtags-select-mode-hook ()
    (dp-define-buffer-local-keys
     `([return] dp-gtags-select-tag-other-window
       [(meta ?-)] dp-bury-or-kill-buffer
       [(meta return)] gtags-select-tag
       [?.] gtags-select-tag
       [?1] dp-gtags-select-tag-one-window
       [?=] gtags-select-tag
       [?i] gtags-find-with-idutils
       [?P] gtags-find-file
       [?d] gtags-find-tag
       [?f] gtags-parse-file
       [?g] gtags-find-with-grep
       [?h] gtags-display-browser
       [?o] gtags-select-tag-other-window
       [?r] gtags-find-rtag
       [?s] gtags-find-symbol
       [?t] gtags-find-tag
       [?u] dp-gtags-update-file
       [?v] gtags-visit-rootdir
       [space] dp-gtags-select-tag-one-window
       [up] ,(kb-lambda
                (call-interactively 'dp-up-with-wrap-non-empty))
       [down] ,(kb-lambda 
                  (call-interactively 'dp-down-with-wrap-non-empty)))))

  (defun dp-gtags-select-tag-one-window ()
    (interactive)
    (gtags-select-tag)
    (dp-one-window++))

  (defun dp-visit-gtags-select-buffer (&optional other-window-p)
    (interactive "P")
    (let ((buf (dp-get-buffer (car-safe (dp-choose-buffers-by-major-mode
                                         'gtags-select-mode))
                              'nil-if-nil)))
      (if buf
          (if other-window-p
              (switch-to-buffer-other-window buf)
            (switch-to-buffer buf))
        (dp-ding-and-message "No gtags select buffers."))))

  (defun dp-gtags-setup-next-error ()
    (interactive)
    (defadvice gtags-goto-tag (before auto-go-back-stuff activate)
      "Push go back before doing a gtags operation.
This seems to be a fairly common routine that is run before most commands.
It gives us a common point to save our position before going off after a
gtags discovery."
      (dp-push-go-back "go-back advised gtags-goto-tag"))

    (dp-current-error-function-advisor 
     'dp-gtags-select-tag-one-window
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'dp-gtags-select-tag-other-window
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-find-with-idutils
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-find-with-grep
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-find-with-file
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-find-tag
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-find-symbol
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-find-rtag
     'dp-gtags-next-thing)

    (dp-current-error-function-advisor 
     'gtags-select-tag
     'dp-gtags-next-thing)

    (defun dp-gtags-next-thing (&optional func)
      (interactive "P")
      ;; Don't set the next error function here.
      ;; Only let it be set when the functions are called directly.
      (let ((dp-dont-set-latest-function t))
        (dp-visit-gtags-select-buffer 'other-window)
        (dp-down-with-wrap-non-empty 1)
        (gtags-select-tag-other-window)
        ;; (call-interactively func)
        ))
    )

  (dp-gtags-setup-next-error)

  (add-hook 'gtags-select-mode-hook 'dp-gtags-select-mode-hook))

(when (dp-xgtags-p)
  (make-variable-buffer-local 'xgtags-update-db)
  ;; Need this (or something like it) to 1) handle C++ scopy things (::) and
  ;; 2) make sure that the entire word is grabbed.  For completion purposes.
  ;;(setq xgtags--symbol-regexp "^[~A-Za-z_]\\([A-Za-z_0-9.]\\(::\\)?\\)*")

  (setq-default xgtags-update-db nil)
  (setq xgtags-goto-tag 'unique)
  (defun dp-xgtags-update-file ()
    (interactive)
    (let ((xgtags-mode t)
          (xgtags-update-db t))
      (message "xgtags updating...")
      (xgtags--update-db xgtags-rootdir)
      (message "done.")))
  (defalias 'guf 'dp-xgtags-update-file)

  ;;
  ;; Ganked from gtags.el to make xgtags less sucky.  xgtags has a better
  ;; display of hits.  May be better to move display code to gtags.

  (defcustom gtags-auto-update nil
    "*If non-nil, tag files are updated whenever a file is saved."
    :type 'boolean
    :group 'gtags)

  ;;
  ;; Invoked on saving a file.
  ;;
  (defun gtags-buffer-file-name ()
    ;; real gtags-buffer-file-name has tramp awareness.
    buffer-file-truename)

  (defun gtags-auto-update ()
    (if (and xgtags-mode gtags-auto-update buffer-file-name)
        (progn
          (call-process xgtags-global-program
                        nil nil nil
                        dp-gtags-auto-update-flags
                        "-u" (concat "--single-update=" (gtags-buffer-file-name))))))

  (defun* dp-xgtags-get-token (&optional
                               (dflt-prompt "xgtags token: ")
                               (get-token 'xgtags--token-at-point)
                               (history xgtags--history-list))
    (interactive)
    (let* ((tagname (funcall get-token))
           (prompt (if tagname
                       (concat dflt-prompt " (default " tagname ") ")
                     (concat dflt-prompt " "))))
      (completing-read prompt xgtags--completition-table
                       nil nil nil history tagname)))

  (defun dp-xgtags-find-tag-other-window ()
    (interactive)
    (let ((tagname (dp-xgtags-get-token "other window token: "))
          (xgtags-goto-tag 'always))
      ;;(other-window 1)
      (xgtags--goto-tag tagname)))

  (defun dp-xgtags-select-selected-tag-other-window (&optional tag)
    (interactive)
    (xgtags--select-and-follow-tag tag))

  (defun dp-xgtags-select-selected-tag-other-window-cmd ()
    "Works only in select buffer."
    (interactive)
    (let ((tag (xgtags--find-tag-near-point)))
      (other-window 1)
      (dp-push-go-back&apply-rest
       "dp-xgtags-select-selected-tag-other-window-cmd-v2"
       'dp-xgtags-select-selected-tag-other-window
       tag)))

  (defun dp-xgtags-select-mode-hook ()
    (dp-define-buffer-local-keys
     `([return] dp-xgtags-select-selected-tag-other-window-cmd
       [(meta ?-)] dp-bury-or-kill-buffer
       [(meta return)] gtags-select-tag
       [?.] xgtags-select-tag-near-point
       [?1] dp-xgtags-select-tag-one-window
       [?=] xgtags-select-tag-near-point
       [?i] xgtags-find-with-idutils
       [?P] xgtags-find-file
       [?d] xgtags-find-tag
       [?f] xgtags-parse-file
       [?g] xgtags-find-with-grep
       [?h] xgtags-display-browser
       [?o] dp-xgtags-select-selected-tag-other-window-cmd
       [?q] bury-buffer
       [?r] xgtags-find-rtag
       [?s] xgtags-find-symbol
       [?t] xgtags-find-tag
       [?u] dp-xgtags-update-file
       [?v] xgtags-visit-rootdir
       [space] dp-xgtags-select-tag-one-window
       [up] ,(kb-lambda
                 (call-interactively 'dp-up-with-wrap-non-empty))
       [down] ,(kb-lambda
                   (call-interactively 'dp-down-with-wrap-non-empty)))))

  (defun dp-xgtags-mode-hook ()
    (if xgtags-mode
        (add-hook 'after-save-hook 'gtags-auto-update)
      (remove-hook 'after-save-hook 'gtags-auto-update)))
  (add-hook 'xgtags-mode-hook 'dp-xgtags-mode-hook)

  (defun dp-xgtags-select-tag-one-window ()
    (interactive)
    (xgtags-select-tag-near-point)
    (dp-one-window++))

  (defun dp-xgtags-next-thing (func)
    (interactive)
    ;; Don't set the next error function here.
    ;; Only let it be set when the functions are called directly.
    (let ((dp-dont-set-latest-function t))
      (if (bobp (xgtags--get-buffer))
          (progn 
            (setq xgtags--selected-tag (xgtags--find-tag-near-point))
            (call-interactively 'dp-xgtags-select-selected-tag-other-window-cmd))
        (call-interactively func)
        (display-buffer (xgtags--get-buffer) t))))

  (defun dp-visit-xgtags-select-buffer (&optional other-window-p)
    (interactive "P")
    (let ((buf (dp-get-buffer (car-safe (dp-choose-buffers-by-major-mode
                                         'xgtags-select-mode))
                              'nil-if-nil)))
      (if buf
          (if other-window-p
              (switch-to-buffer-other-window buf)
            (switch-to-buffer buf))
        (dp-ding-and-message "No xgtags select buffers."))))

;;needs work   (defun dp-xgtags--find-with (&rest r)
;;needs work     (interactive)
;;needs work     (call-interactively 'xgtags--find-with)
;;needs work     (dp-beginning-of-buffer)
;;needs work     (xgtags--find-tag-near-point))

  (defun dp-xgtags-setup-next-error ()
    (defadvice xgtags--find-with (before dp-xgtags-go-back-stuff activate)
      "Push go back before doing an xgtags operation.
This seems to be a fairly common routine that is run before most commands.
It gives us a common point to save our position before going off after a
xgtags discovery.
*** Look at new xcscope.el. It has some mark stack capability now."
      (setq icky-directory-from-which-we-are-tag-searching
            (dp-get-buffer-dir-name))
      (dp-push-go-back "go-back advised xgtags--find-with"))

    ;; Start with next error function setup so we can M-n immediately after a
    ;; search operation.
;;needs work     (dp-current-error-function-advisor-after
;;needs work      'xgtags--find-with
;;needs work      'dp-xgtags--find-with)

    (dp-current-error-function-advisor 
     'xgtags-find-with-idutils
     'dp-xgtags-next-thing
     'xgtags-select-next-tag)

    (dp-current-error-function-advisor 
     'xgtags-find-with-grep
     'dp-xgtags-next-thing
     'xgtags-select-next-tag)
    
    (dp-current-error-function-advisor 
     'xgtags-select-next-tag
     'dp-xgtags-next-thing)

    (dp-current-error-function-advisor 
     'xgtags-select-prev-tag
     'dp-xgtags-next-thing)
    
    (dp-current-error-function-advisor 
     'xgtags-switch-to-buffer-other-window
     'dp-xgtags-next-thing
     'xgtags-select-next-tag)

    (dp-current-error-function-advisor 
     'xgtags-select-tag-near-point
     'dp-xgtags-next-thing
     'xgtags-select-next-tag)

    (dp-current-error-function-advisor 
     'xgtags-select-tag-by-event
     'dp-xgtags-next-thing
     'xgtags-select-next-tag)
    )

  (dp-xgtags-setup-next-error)

  (add-hook 'xgtags-select-mode-hook 'dp-xgtags-select-mode-hook))

(defun dp-gtags-ripped-of-completor (patteren &optional predicate code)
  "Needs to rip off more!"
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "Symbol to complete")))
  ;;(gtags-completing 'bubba patteren nil t))

  (let ((complete-list (make-vector 511 0))
        options)
    (if patteren
        (setq options (cons "-c" (list patteren)))
      (setq options (list "-c")))
    (with-temp-buffer
      (apply 'call-process "global" nil t nil "-c" options)
      (goto-char (point-min))
      (while (re-search-forward xgtags--symbol-regexp nil t)
        (intern (match-string-no-properties 0) complete-list)))
    (cond ((eq code nil)
           (try-completion string complete-list predicate))
          ((eq code t)
           (all-completions string complete-list predicate))
          ((eq code 'lambda)
           (if (intern-soft string complete-list) t nil)))))

(defun dp-gtags-completing-read-completor (string predicate meh)
  ;;(dmessage "string>%s<, predicate>%s<, meh>%s<" string predicate meh)
  (dp-gtags-ripped-of-completor string predicate meh))

(defun dp-tag-find-old (&rest r)
  (interactive)
  (call-interactively (dp-*TAGS-handler-finder (dp-get-*TAGS-handler))))

(defun dp-tag-find (&rest r)
  (interactive)
  (cond
   ((looking-at "(")
    (dp-eval-naked-embedded-lisp))
   ((looking-at ":(")
    (dp-eval-embedded-lisp-region))
   ((dp-xgtags-p)
    (call-interactively 'xgtags-find-tag))
   ((dp-gtags-p)
    (call-interactively 'gtags-find-tag))
   (t
    (error "No tag finder."))))

(defun dp-tag-find-rtag (&rest r)
  (interactive)
  (cond
   ((dp-xgtags-p)
    (call-interactively 'xgtags-find-rtag))
   ((dp-gtags-p)
    (call-interactively 'gtags-find-rtag))
   (t
    (error "No tag finder."))))

(defun dp-tag-find-with-grep (&rest r)
  (interactive)
  (cond
   ((dp-xgtags-p)
    (call-interactively 'xgtags-find-with-grep))
   ((dp-gtags-p)
    (call-interactively 'gtags-find-with-grep))
   (t
    (error "No tag grep finder."))))

(defun dp-tag-find-with-idutils (&rest r)
  (interactive)
  (cond
   ((dp-xgtags-p)
    (call-interactively 'xgtags-find-with-idutils))
   ((dp-gtags-p)
    (call-interactively 'gtags-find-with-idutils))
   (t
    (error "No tag idutils finder."))))

(defun dp-tag-find-with-idutils-bury-first ()
  (interactive)
  (let ((window (dp-get-buffer-window)))
    (dp-tag-find-with-idutils)
    (delete-window window))
)

;;   (condition-case err
;;       (let ((handler-list (dp-get-*TAGS-handler-list)))
;;         (if handler-list
;;             (dp-*TAGS-try-handler-funcs handler-list
;;                                         'dp-*TAGS-handler-finder)
;;           (dp-ding-and-message "No handlers/tag files found.")))
;;     ('dp-*TAGS-aborted 
;;      (ding)
;;      (message "Tag op aborted: %s" err))))

(defun dp-tag-pop-old (&rest r)
  (interactive)
  (call-interactively (dp-*TAGS-handler-returner (dp-get-*TAGS-handler))))

(defun dp-tag-pop (&rest r)
  (interactive)
  (cond
   ((dp-xgtags-p)
    (call-interactively 'xgtags-pop-stack))
   ((dp-gtags-p)
    (call-interactively 'gtags-pop-stack))
   (t
    (error "No tag popper."))))

(defun dp-tag-pop-other-win ()
  (interactive)
  (gtags-pop-stack t))

(defun dp-tag-find-other-window (&rest r)
  (interactive)
  (cond
   ((dp-xgtags-p)
    (call-interactively 'dp-xgtags-find-tag-other-window))
   ((dp-gtags-p)
    (call-interactively 'gtags-find-tag-other-window))
   (t
    (error "No find tag other windower."))))

(defun dp-global-set-tags-keys ()
  (global-set-key [(meta ?.)] 'dp-tag-find)
  (global-set-key [(control ?x) (control ?.)]
    (kb-lambda
        (let ((current-prefix-arg '(4)))
          (call-interactively 'dp-tag-find))))
  (global-set-key [(control meta ?.)] 'dp-tag-find-other-window)
  (global-set-key [(meta ?,)] 'dp-tag-pop) ; "\e,"
  (global-set-key [(control meta ?,)] 'dp-tag-pop-other-win))

;;;
;;; end *tags support
;;; begin hide ifdef support
;;;
(defvar dp-wants-hide-ifdef-p nil
  "Do I want the hide ifdef package activated?")

(defvar dp-hide-ifdef-configure-function nil
  "What to call to set up the initial hide ifdef configuration.")

(when (and (bound-and-true-p dp-wants-hide-ifdef-p)
           (dp-optionally-require 'hideif))

  (defun dp-hideif-assign-defs (def-list name)
    "Define/undef a list of #define names.
DEFLIST is a list of pairs (defname operation).
DEFNAME is the constant name, e.g. DEBUG is in #ifdef DEBUG
OPERATION is called with the defname as a parameter. Some useful values are 
`hide-ifdef-define' and `hide-ifdef-undef' to define or undefine defname
respectively.
NAME is a short name associated by hideif with the list of defs."
    (loop for (def op) in def-list do
      (funcall op def))
    (hide-ifdef-set-define-alist name))

  (defun dp-hide-ifdefs (name)
    (interactive)
    (hide-ifdef-mode 1)
    (hide-ifdef-use-define-alist "name")
    (hide-ifdefs))

;;needs finished Make hide-ifdef-define use the symbol @ point as a default.
;;needs finished hide-ifdef-define reads the name as a symbol.
;;needs finished Need to make the string a symbol (intern?)
;;needs finished   (defun dp-hide-ifdef-mode-hook ()
;;needs finished     (local-set-key [?d] 'dp-hide-ifdef-define))
;;needs finished   (add-hook 'hide-ifdef-mode-hook 'dp-hide-ifdef-mode-hook)
  
  (message "Configuring hide-ifdef...")
  (if dp-hide-ifdef-configure-function
      (funcall dp-hide-ifdef-configure-function)
    (message "No hide-ifdef configure function configured.")))

(defun dp-show-if1 ()
  "Set up hide-ifdef to show all #if 1 code. Activates the mode.
Mostly used for the side effect of hiding #if 0.
It does hide everything else, but that can be controlled by, duh, 
defining other constants.
@todo XXX Make a function to [un]define symbol @ point."
  (interactive)
  (hide-ifdef-mode 1)
  (hide-ifdef-define '\1)
  (hide-ifdefs))

;; Not really hide if0, but kind of.
(dp-defaliases 'dp-hide-if0 'hif0 'dp-show-if1)

;;
;; Give the ability to prevent writing to certain directory trees.
;;
;; (defvar dp-singlular-write-restricted-regexp nil
;;   "This is a special case. It can only have a single value, so it's useful
;;   for things like a current sandbox.")

;; (defun dp-set-singlular-write-restricted-regexp (regexp)
;;   (interactive "sRegexp: ")
;;   (setq dp-implied-read-only-filename-regexp-list
;;         (delete dp-singlular-write-restricted-regexp 
;;                 dp-implied-read-only-filename-regexp-list)
;;         dp-implied-read-only-filename-regexp-list
;;         (cons regexp dp-implied-read-only-filename-regexp-list)
;;         dp-singlular-write-restricted-regexp regexp))

(defvar dp-me-expand-dest-pne-opt "--pne")

(defun dp-me-expand-dest0 (abbrev &optional sb)
  (let ((ret (dp-nuke-newline
              (shell-command-to-string 
               (format "me-expand-dest %s %s %s" ;;;;;; 2>/dev/null"
                       (or dp-me-expand-dest-pne-opt
                           "")
                       abbrev (or sb 
                                  ;;(dp-current-sandbox-name)
                                  ""))))))
    (if (string= ret "")
        nil
      ret)))

(defun dp-me-expand-dest (abbrev &optional sb)
  (or (dp-me-expand-dest0 abbrev sb)
      (and (not sb)
           (dp-me-expand-dest0 abbrev (dp-current-sandbox-name)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Sandbox support.
;;; Gives us the ability to make sure we don't edit files in the wrong SB and
;;; then wonder why things aren't changing, etc.
;;; Wouldn't be needed if only one SB needed to be used at one time. Ahhh for
;;; the old days.
;;;

(defvar dp-sandbox-regexp-private nil
  "Regexp to detect a sandbox.")

;; Use in a spec-macs.
(defsubst dp-set-sandbox-regexp (regexp)
  (setq dp-sandbox-regexp-private regexp))

(defsubst dp-sandbox-regexp ()
  dp-sandbox-regexp-private)

;; Set in a spec-macs.
(defvar dp-sandbox-make-command nil
  "A special makefile for using in sandbox. E.g. mmake @ nvidia.")

(defsubst dp-sandbox-file-p (filename)
  (and filename
       (dp-sandbox-regexp)
       (string-match (dp-sandbox-regexp) filename)))

(defvar dp-current-sandbox-regexp-private nil
  "Regexp to detect the current sandbox.")

(defsubst dp-current-sandbox-regexp ()
  dp-current-sandbox-regexp-private)

;; XXX @todo I want to allow an abbrev for the name.
;; It will be expanded and regexp quoted into `dp-current-sandbox-regexp'.
(defvar dp-current-sandbox-name-private nil
  "Name of the current sandbox.")

(defsubst dp-current-sandbox-name ()
  dp-current-sandbox-name-private)

(defvar dp-current-sandbox-path-private nil
  "Root of the current sandbox.")

(defsubst dp-current-sandbox-path ()
  dp-current-sandbox-path-private)

(defvar dp-current-sandbox-read-only-private-p nil
  "See `dp-set-sandbox' for the meaning of this variable.")

(defsubst dp-current-sandbox-read-only-p ()
  (or dp-current-sandbox-read-only-private-p
      (dp-read-only-sandbox-p (dp-current-sandbox-path))))

(defvar dp-all-sandboxes-read-only-private-p nil
  "See `dp-set-sandbox' for the meaning of this variable.")

(defsubst dp-all-sandboxes-read-only-p ()
  dp-all-sandboxes-read-only-private-p)

(defvar dp-read-only-sandbox-regexp-private nil
  "*Anything (e.g. a sandbox name) matching this regexp will be read-only")

(defsubst dp-read-only-sandbox-p (filename)
  (or (dp-all-sandboxes-read-only-p)
      (and filename
           dp-read-only-sandbox-regexp-private
           (string-match dp-read-only-sandbox-regexp-private filename))))

(defsubst dp-current-sandbox-file-p (filename)
  "Return non-nil if we are in the current sandbox dir.
Returns nil if there is no current sandbox."
  (and (dp-sandbox-file-p filename)
       (dp-current-sandbox-regexp)
       (string-match (dp-current-sandbox-regexp) filename)))

(defsubst dp-current-sandbox-dir-p (dirname)
  (dp-current-sandbox-file-p (concat dirname "/")))

;; Begin moving to a sandbox per frame.
(defsubst dp-set-current-sandbox-read-only-p (read-only-p)
  (setq dp-current-sandbox-read-only-private-p read-only-p))

(defun dp-mk-sb-read-only (&optional rw-p)
  (interactive "P")
  (dp-set-current-sandbox-read-only-p (not rw-p)))

(defun dp-set-sandbox-name-and-regexp (name regexp &optional default-p)
  (let ((path (dp-me-expand-dest "/" name)))
    (if default-p
        (setq-default
         dp-current-sandbox-name-private name
         dp-current-sandbox-path-private path
         dp-current-sandbox-regexp-private regexp)
      (setq-default
       dp-current-sandbox-name-private name
       dp-current-sandbox-path-private path
       dp-current-sandbox-regexp-private regexp)))
  (dp-update-editor-identification-data 
   :sandbox-name (dp-current-sandbox-name)
   :update-our-data-p t))

(defun* dp-set-sandbox (sandbox &optional read-only-p)
  "Setup things for a singular, unique SANDBOX.
Files from other sandboxes are read only to prevent editing in the wrong
place. It is preferable to have one editor per sandbox. In addition, the
current sandbox is used for some defaults.

READ-ONLY-P says to keep the sandbox read only. This is good for editors on
non-o-xterm machines. They will often be working in the same sandbox as the
primary editor, and it is better to allow only one instance to modify the
files. Setting the sandbox on these machines is useful for the places where
the current sandbox is used for defaults, etc."
  (interactive (list (read-from-minibuffer
                      (format "Sandbox name/path%s: "
                              (if (dp-current-sandbox-regexp)
                                  (format "[current: %s (%s)]"
                                          (dp-current-sandbox-regexp)
                                          (dp-current-sandbox-name))
                                "")))
                     current-prefix-arg))
  (dp-set-current-sandbox-read-only-p read-only-p)
  (let ((sandbox (if (member sandbox '("/" "-" "'" "!"))
                     nil
                   (if (member sandbox '("" "." "=" "=="))
                       (dp-current-sandbox-name)
                     sandbox)))
        expanded-dest)
    (if (not sandbox)
        ;; @todo XXX Why isn't this a `setq-default' like the others?
        ;; ? Don't want to clear it everywhere?
        (dp-set-sandbox-name-and-regexp nil nil)
      ;; If name, determine path/sandbox
      ;; If path/sandbox, determine name
      (if (string-match "/" sandbox)
          ;; We're a path. find sb name
          ;; NB: Just "/" implies clear sandbox and is caught earlier.
          (dp-set-sandbox-name-and-regexp
           (file-name-nondirectory (directory-file-name
                                    (file-name-directory
                                     (directory-file-name 
                                      sandbox))))
           sandbox
           'set-default)
        ;; We're a name, find path
        (dp-set-sandbox-name-and-regexp
         sandbox
         (if (string= "*" sandbox)
             ".*"                      ; We're always in the "right" sandbox.
           (if (setq expanded-dest (dp-me-expand-dest "/" sandbox))
               (concat expanded-dest "/")
             (dp-ding-and-message "Sandbox `%s' not found." sandbox)
             ;; Leave unchanged?
             (dp-set-sandbox-name-and-regexp nil nil)
             (dp-set-frame-title-format)
             (return-from dp-set-sandbox)))
         'set-default)))
    (dp-set-frame-title-format)
    (if (dp-current-sandbox-regexp)
        (progn
          (dp-cscope-set-cscope-database-regexps)
          (define-abbrev dp-manual-abbrev-table
            "sb" (dp-current-sandbox-regexp))
          (message "sb dir: %s" (dp-current-sandbox-regexp)))
      (setq cscope-database-regexps nil)
      (message "Current sandbox cleared."))))

(dp-safe-aliases 'dp-ssb 'dpsb 'dpssb 'dp-set-sandbox)
  

(defun dp-sandbox-read-only-p (filename)
  "Determine if a file is in a readonly sandbox.
An RO sandbox is one that is not the current one or has
`dp-current-sandbox-read-only-p' non-nil. This is done to prevent a
modification to the wrong file when several sandboxes \(NOT good but
necessary) are in play.  For additional safety, all sandboxes are read only
if there is no current one set."
  (setq filename (expand-file-name filename))
  (dmessage "dp-sandbox-read-only-p, filename>%s<" filename)
  (dmessage "dp-sandbox-read-only-p, regexp>%s<" (dp-current-sandbox-regexp))
  ;; If in another sb (in sb and not in current sb)
  ;; If in current sb and current sb RO
  ;; no sb --> not-RO
  (when
      (and 
       (dp-current-sandbox-regexp)
       (dp-sandbox-file-p filename)
       (or
        (dp-read-only-sandbox-p filename)
        (not (dp-current-sandbox-file-p filename))
        (dp-current-sandbox-read-only-p)))
    (message "!!! File not in current sandbox: %s" filename)
    t))

(add-hook 'dp-detect-read-only-file-hook 'dp-sandbox-read-only-p)

;;;
;;; Sandbox support.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Tempo comment support.
;;;

;;finish-me (defvar dp-c-doxy-comment-introduction 
;;finish-me   (format "/*%s*/" (make-string (- fill-column 4) ?*))
;;finish-me   "First line of a doxy commment.
;;finish-me XXX @todo This should be dynamically computed based on the current indent.")


(defvar doxy-c-class-member-comment-elements '(
" /***************************************************************************/" > "
 /*!" > "
  * @brief " (P "brief desc: " desc nil) > "
  */" > % >)
  "Elements of a class function comment template")

(defvar doxy-c-function-comment-elements '("
 /***************************************************************************/" > "
 /*!" > "
  * @brief " (P "brief desc: " desc nil) > "
  */" > % >)
  "Elements of a C/C++ function comment template")

(defvar doxy-c-class-comment-elements '("
 /***************************************************************************/" > "
 /*!" > "
 * @class " p > "
 * @brief " (P "brief desc: " desc nil) > "
 */" > % >)
  "Elements of a C/C++ class comment template")

(defvar doxy-c-file-comment-elements '("
 /***************************************************************************/" > "
 /*!" > "
 * @file " p > "
 * @brief " (P "brief desc: " desc nil) > "
 */" > % >)
  "Elements of a C/C++ file comment template")
          
(tempo-define-template "doxy-c-class-member-comment"
		        doxy-c-class-member-comment-elements)
(tempo-define-template "doxy-c-function-comment"
		        doxy-c-function-comment-elements)
(tempo-define-template "doxy-c-class-comment"
		        doxy-c-class-comment-elements)
(tempo-define-template "doxy-c-file-comment"
		        doxy-c-file-comment-elements)

(defun dp-insert-tempo-template-comment (template-func &optional 
                                         no-indent no-bol indent-to
                                         beginning-of-statement)
  "Use TEMPLATE-FUNC to add a comment. Typically a tempo template.
Often context sensitive.
Please enter a brief description of the function at the prompt.
If NO-INDENT is non-nil (interactively with prefix arg) then
do not indent the newly inserted comment block."
  (or no-bol
      (and beginning-of-statement
           (goto-char beginning-of-statement))
      (end-of-line)
      (if (dp-in-c)
          (dp-c-beginning-of-statement)))
  
  ;; '% in tempo handles adding a newline
  ;;   (if (not (looking-at "^\\s-*$"))
  ;;      (save-excursion (insert "\n")))
  (let ((beg (dp-mk-marker))
        (end (dp-mk-marker (1+ (point)))))
    (funcall template-func)
    (when (and (not no-indent)
	       (fboundp 'c-indent-region))
      (indent-region beg (1- end) indent-to)))
  (setq beg nil end nil))

(defun dp-c-tempo-insert-member-comment (&optional no-indent)
  "Add a tempo class function comment."
  (interactive "*")
  (dp-insert-tempo-template-comment 
   'tempo-template-doxy-c-class-member-comment no-indent))
(dp-defaliases 'tcfc 'tcmc 'dp-c-tempo-insert-member-comment)

(defun dp-c-tempo-insert-function-comment (&optional no-indent)
  "Add a tempo function comment."
  (interactive "*")
  (dp-insert-tempo-template-comment 
   'tempo-template-doxy-c-function-comment no-indent))
(defalias 'tfc0 'dp-c-tempo-insert-function-comment)

(defun* dp-c-insert-class-comment (&optional beginning-of-statement 
                                   template-p)
  "Insert a tempo class comment, using the class name from the current line."
  (save-match-data
    (save-excursion
      (beginning-of-line)
      ;; find the class name
      ;; @todo templates *WILL* break this.
      ;; Apparently not.
      (re-search-forward 
       "^\\s-*\\(enum\\|class\\|struct\\)\\s-+\\(\\S-+?\\)\\s-*\\(:\\|{\\|$\\)"))
    (let ((class-name (match-string 2)))
      (when template-p
        (setq class-name (format "%s <template>" class-name)))
      ;;(tempo-template-doxy-c-class-comment)
      (dp-insert-tempo-template-comment 
       'tempo-template-doxy-c-class-comment nil
       nil nil (or beginning-of-statement
                   (match-beginning 0)))
      (insert class-name)
      (tempo-forward-mark))))

(defun dp-c-tempo-insert-file-comment (&optional no-indent)
  "Add a tempo file comment."
  (interactive "*")
  (dp-insert-tempo-template-comment 
   'tempo-template-doxy-c-file-comment no-indent))
(dp-defaliases 'cifc 'ifc 'tifc 'dp-c-tempo-insert-file-comment)

(defun dp-c-insert-tempo-comment (&optional no-indent-p)
  "Insert a C/C++ mode tempo comment in a syntax sensitive manner."
  (interactive "*P")
  (if (dp-in-c++-class-p)
      (dp-c-tempo-insert-member-comment)
    (if (save-excursion
          (beginning-of-line)
          (looking-at "\\s-*\\(enum\\|class\\|struct\\|template\\)"))
        (dp-c-insert-class-comment (line-beginning-position)
                                   (string= "template" (match-string 1)))
      ;; not in C++, just insert a function comment
      (dp-c-tempo-insert-function-comment))))

(dp-deflocal dp-insert-tempo-comment-func nil
  "Function to call when adding a tempo template based comment.")

(defun dp-insert-tempo-comment (&optional no-indent-p)
  "Add a tempo comment.
Insert a context sensitive comment using a tempo template.
This is vectored via the buffer local variable `dp-insert-tempo-comment-func'
so each mode can have its own logic."
  (interactive "*P")
  (when dp-insert-tempo-comment-func
    (funcall dp-insert-tempo-comment-func no-indent-p)))
(defalias 'tc 'dp-insert-tempo-comment)

;;;
;;; Tempo comment support.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Crappy perforce crap.
;;;

(defun dp-p4-delimit-p4-loc (&optional dont-stop-at-bol-p)
  (interactive "P")
  (when (or (looking-at dp-p4-location-regexp)
            (re-search-backward dp-p4-location-regexp-ext
                                (if dont-stop-at-bol-p
                                    nil
                                  (line-beginning-position)) t))
    (re-search-forward dp-p4-location-regexp-ext (line-end-position) t)
;;     (message "p4 loc: %s, ms0: %s ms1: %s ms2: %s"
;;              (match-string 1)
;;              (match-string 0)
;;              (match-string 1)
;;              (match-string 2))
    ;; `re-search-forward' should return non-nil, but this ensures the proper
    ;; return value in case there is ever any code added before the end of
    ;; the `when'
    t))

(defun dp-p4-copy-p4-loc (&optional dont-stop-at-bol-p)
  (interactive "P")
  (let ((starting-point (point)))
    (if (dp-p4-delimit-p4-loc dont-stop-at-bol-p)
        (progn
          (if (not (= (line-number starting-point)
                      (line-number (match-end 1))))
              (dp-push-go-back "back to perforce location" starting-point))
          (goto-char (match-end 1))
          (kill-new (match-string 1)))
    (message "Cannot find p4 location%s." (if dont-stop-at-bol-p
                                              ""
                                            " on this line")))))

;;;
;;; Crappy perforce crap.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'dp-ptools)
(dmessage "Loading dp-ptools...done")
