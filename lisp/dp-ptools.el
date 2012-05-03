;;;
;;; Programming tools
;;;

(dmessage "loading dp-ptools.el...")

(define-error 'dp-*TAGS-aborted
  "Badness in the guts of the (too) deeply nested *TAGS stiff." 
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
  (other-window-finder))

(defvar dp-*TAGS-handlers
  (list
;;CO;    (list "GTAGS" (make-dp-*TAGS-handler 
;;CO;                   :finder 'gtags-find-tag
;;CO;                   :returner 'gtags-pop-stack 
;;CO;                   :other-window-finder 'gtags-find-tag-other-window)
;;CO;          )
   (list "TAGS" (make-dp-*TAGS-handler 
                 :finder 'find-tag 
                 :returner 'pop-tag-mark 
                 :other-window-finder 'find-tag-other-window)))
  "Tags commands for given tag systems.")

(defvar dp-default-*TAGS-file-names '("TAGS") ; "GTAGS") Mostly sucks.
  "In order of preference.
Either GTAGS/Global sucks big-time or I'm too stupid to use it rightly.  It
never seems to find what I need and (minor point) doesn't clean up after
itself when it can't find what is needed.
E.g. Exuberant ctags + `find-tag' given Vector::Iterate finds:
class VectorSink : public Sprockit::Sink1<Frame<int> >
...
  void Iterate()

Whereas Global can't even find Vector.
It can't be this bad, I must be missing something.")

(defun dp-find-nearest-*TAGS-file-path (&optional tag-file-names start-dir)
  (dp-find-nearest-*-file (or tag-file-names dp-default-*TAGS-file-names)
                          start-dir))

(defun dp-find-nearest-*TAGS-file (&optional tag-file-names start-dir)
  (file-name-nondirectory (or (dp-find-nearest-*TAGS-file-path tag-file-names 
                                                               start-dir)
                              (error 'dp-*TAGS-aborted 
                                     (format "Can't find any tags file (%s, %s)" 
                                             tag-file-names start-dir)))))

(defun dp-get-*TAGS-handler (&optional tag-file-names start-dir)
  (cadr (assoc (dp-find-nearest-*TAGS-file tag-file-names start-dir)
               dp-*TAGS-handlers)))

(defun* dp-get-*TAGS-handler-list (&optional 
                                   (tag-file-names dp-default-*TAGS-file-names) 
                                   start-dir)
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
               (call-interactively (funcall gettor handler))
               ;; gtags is a pain in the ass.  It moves point to the
               ;; beginning of the current symbol and leaves it there. This
               ;; makes it look like a tag was found.  A partial workaround
               ;; is to see if we've moved off the current line.  This will
               ;; break when we try to find a symbol that is defined on the
               ;; current line, which is basically a braino.
               ;; FUCK gtags for now.
               (dp-*TAGS-push-handler handler)
               (return))
;;                (setq new-pos (point-marker))
;;                (when (or (not (equal start-buffer (current-buffer)))
;;                          (< new-pos bol)
;;                          (> new-pos eol))
;;                  (dp-*TAGS-push-handler handler)
;;                  (return))
;;                (dp-ding-and-message "Tag didn't take us anywhere."))
           (t (dmessage "Caught condition: %s in dp-*TAGS-try-handler-funcs"
                        err))))))

(defun dp-tag-find-old (&rest r)
  (interactive)
  (call-interactively (dp-*TAGS-handler-finder (dp-get-*TAGS-handler))))

(defun dp-tag-find (&rest r)
  (interactive)
  (condition-case err
      (dp-*TAGS-try-handler-funcs (dp-get-*TAGS-handler-list)
                                  'dp-*TAGS-handler-finder)
    ('dp-*TAGS-aborted (ding)(message "Tag op aborted: %s" err))))

(defun dp-tag-pop-old (&rest r)
  (interactive)
  (call-interactively (dp-*TAGS-handler-returner (dp-get-*TAGS-handler))))

(defun dp-tag-pop (&rest r)
  (interactive)
  (let ((handler (dp-*TAGS-pop-handler)))
    (if handler
        (call-interactively (dp-*TAGS-handler-returner handler))
      (dp-ding-and-message "No tags on stack."))))

(defun dp-tag-find-other-window (&rest r)
  (interactive)
  (call-interactively (dp-*TAGS-handler-other-window-finder 
                       (dp-get-*TAGS-handler))))
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
(global-set-key [(control ?.)] (kb-lambda (find-tag nil (not (dp-xemacs-p)))))

(defun dp-gtags-select-mode-hook ()
  (dp-define-buffer-local-keys 
   `([return] ,(kb-lambda
                  (dp-push-go-back&call-interactively
                   'gtags-select-tag
                   nil nil "dp-gtags-select-mode-hook")))))
(add-hook 'gtags-select-mode-hook 'dp-gtags-select-mode-hook)

(provide 'dp-ptools)
(dmessage "done loading dp-ptools.el...")
