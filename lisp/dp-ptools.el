;;;
;;; Programming tools
;;;

(dmessage "loading dp-ptools.el...")

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
in, say, \"~/work/some/important/stuff\", so by default I make sure that
we're under a directory named work."
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
                                          "Doesn't look workish: %s; accept? "
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
   (t
    (call-interactively 'gtags-find-tag))))

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
  (call-interactively 'gtags-pop-stack))
;;   (let ((handler (dp-*TAGS-pop-handler)))
;;     (if handler
;;         (call-interactively (dp-*TAGS-handler-returner handler))
;;       (dp-ding-and-message "No tags on dp tag stack."))))

(defun dp-tag-find-other-window (&rest r)
  (interactive)
  (call-interactively 'gtags-find-tag-other-window))
;;   (call-interactively (dp-*TAGS-handler-other-window-finder 
;;                        (dp-get-*TAGS-handler))))
(global-set-key [(meta ?.)] 'dp-tag-find)
(global-set-key [(control ?x) (control ?.)]
  (kb-lambda 
      (let ((current-prefix-arg '(4)))
        (call-interactively 'dp-tag-find))))
(global-set-key [(control meta ?.)] 'dp-tag-find-other-window)
(global-set-key [(meta ?,)] 'dp-tag-pop)  ; "\e,"
;;
;; fsf wants nil t to go to the next tag,
;; xemacs wants nil nil ""
;;(global-set-key [(control ?.)] (kb-lambda (find-tag nil (not (dp-xemacs-p)))))
;; When gtagsing, this will be it's prefix.

(dp-deflocal dp-gtags-suggested-key-mapping t
  "Does this buffer want gtags key mappings?")

;; XXX @todo Fix this to use a real predicate.
(when t ;;(dp-gtags-p)
  (make-variable-buffer-local 'gtags-auto-update)
  (setq-default gtags-auto-update nil)
  (defun dp-gtags-update-file ()
    (interactive)
    (let ((gtags-mode t)
          (gtags-auto-update t))
      (message "gtags updating...")
      (gtags-auto-update)
      (message "done.")))
  (defalias 'guf 'dp-gtags-update-file)

  (defun dp-gtags-select-tag-other-window ()
    (interactive)
    (dp-push-go-back&call-interactively
     'gtags-select-tag-other-window
     nil nil "dp-gtags-select-mode-hook"))
  
  (defun dp-gtags-select-mode-hook ()
    (dp-define-buffer-local-keys
     `([return] dp-gtags-select-tag-other-window
       [(meta ?-)] dp-bury-or-kill-buffer
       [?h] gtags-display-browser
       [?P] gtags-find-file
       [?f] gtags-parse-file
       [?g] gtags-find-with-grep
       [?I] gtags-find-with-idutils
       [?s] gtags-find-symbol
       [?r] gtags-find-rtag
       [?t] gtags-find-tag
       [?d] gtags-find-tag
       [?v] gtags-visit-rootdir
       [?.] gtags-select-tag
       [?=] gtags-select-tag
       [space] dp-gtags-select-tag-one-window
       [?1] dp-gtags-select-tag-one-window
       [(meta return)] gtags-select-tag
       [?u] dp-gtags-update-file
       [?o] gtags-select-tag-other-window)))

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
  (add-hook 'gtags-select-mode-hook 'dp-gtags-select-mode-hook))

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
(dmessage "done loading dp-ptools.el...")
