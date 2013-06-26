(message "dp-abbrev eval-ing...")

(setq dp-preserve-above-monition
      ;; These first two cannot have trailing newlines embedded because then
      ;; the search for them ends up on a line not including the text and so
      ;; a `beginning-of-line' doesn't go to the beginning of the correct
      ;; line.
      ";;; --------------- Preserve everything above this line ----------------"
      dp-preserve-above-monition-comment
      ";;; Anything in this file *before* the above line is preserved."
      dp-begin-generated-section-declaration
      ";;; --------------------- Begin generated section ----------------------"
      dp-begin-generated-section-declaration-comment
      ";;; Everything in this file from the beginning of the previous line to the
;;; end of file will be deleted.
;;;"
      dp-abbrev-shared-comment-block
      ";;;
;;; `manual' abbrevs are more common than global since they are only expanded
;;; upon request.  Automatic expansion in the wrong place is *veru* amnoying!
;;; These used to be called `common.' Manual abbrevs can be more ambiguous
;;; and `error prone' because they are only expanded where the human has
;;; deemed correct. So something like `a' is acceptable as manual but insane
;;; as automatic.
;;;
;;; `auto' abbrevs are put into the *macs standard `global-abbrev-table' and
;;; so are expanded automatically.  These are called `global.' Global derives
;;; from `global-abbrev-table' but auto is more descriptive.
;;;
;;; 'global abbrevs are for automatic expansion, e.g. speling erors.
;;; 'global becomes global-abbrev-table and abbrevs in that table are
;;; auto expanded.  I currently have too many things in there that are
;;; expanded annoyingly often, so I need to revisit the table
;;; ASSIGNMENTS.
;;; 'manual abbrevs are expected to be expanded by hand.
;;; @ todo... add mode to `properties' and then add to table for that mode.
;;; Stems of abbrev tables.  If just a symbol then construct a table name of
;;; @ todo... add 'tmp property to indicate table is not to be saved.
;;;  <sym>-abbrev-table
;;; Abbrev entry format:
;;; ABBREV-ENTRY ::= (ABBREVS/EXPANSIONS TABLE-INFO)
;;; ABBREVS/EXPANSIONS ::= (ABBREV-NAMES EXPANSIONS)
;;; ABBREV-NAMES ::= \"abbrev-name\" | (\"abbrev-name0\"...)
;;; EXPANSIONS ::= \"expansion0\"... | '= | 'circular
;;; TABLE-INFO ::= TABLE-NAME | TABLE-INFO-PLIST
;;; TABLE-NAME ::= 'table-name-sym | \"table-name\"  ; it's `format'd w/%s
;;; TABLE-INFO-PLIST ::= (PROP/VAL PROP/VAL ...)
;;; PROP/VAL ::= 'table-name TABLE-NAME
;;;
;;; If EXPANSIONS memq '(circular =) then EXPANSIONS is set to ABBREV-NAMES.
;;; This is a hack to allow a ring of abbrevs to be defined with little effort.
;;; This means that '(("a" "b" "c") '=) becomes:
;;; (("a" "b" "c") "a" "b" "c") which defines:
;;; This results in multiple entries: 
;;; "a" -> '("a" "b" "c")
;;; "b" -> '("a" "b" "c")
;;; "c" -> '("a" "b" "c")
;;; This means that "a" "b" or "c" can begin a cycle around those expansions.
;;; In addition, the ring begins just after the initial abbrev.
;;; Doing just '("a" "b" "c") allows:
;;; "a" -> '("b" "c" "a"...) But "b" doesn't go to "c", "a", ...
;;;
;;; We define abbrevs: {ABBREV-NAMES} X {EXPANSIONS} X {TABLES}
;;; for each name
;;;     for each table
;;;         define abbrev name expansion[-list]
;;;         ;; expansion[-list] is saved as a string `format'd with %S the
;;;         ;; list can be `read' to recreate the list.  The expansion list
;;;         ;; can be iterated over by successive invocations of
;;;         ;; `dp-expand-abbrev'
;;;         [put props on table variable]
;;;
;;; Come on!  There needs to be the need/ability to use eval'able forms
;;; somewhere!
;;; 
;;; !<@todo ??? Modify data structures to allow a way to add suffixes
;;; programmatically. Eg t for a space? 's for pluralization?
;;; !<@todo Automatically generate \"logical\" case mixtures.
;;; Convenience binding:
;;; C-c C-c (dp-save-and-redefine-abbrevs)
;;;
;;; This information is common between this abbrev file and dp-abbrev.el
;;; This is copied to each abbrev file when it is saved, so it can be 
;;; out of date. I don't know why I don't just put a see dp-abbrev.el comment
;;; in these files.

")
(defvar dp-dp-style-abbrev-tables '()
  "All of my `special' tables.")

(defvar dp-minibuffer-abbrev-table nil
  "Abbrev table used in minibuffer.")

(defvar dp-common-abbrev-file-name 
  (expand-file-name "~/lisp/dp-common-abbrevs.el")
  "File name in which common abbrevs reside.")

(defvar dp-common-abbrev-file-names (list dp-common-abbrev-file-name)
  "A list of files full of abbrevs in my style (see the file proper.)")

(defvar dp-default-abbrev-table 'dp-manual
  "*Use this table if TABLE-INFO is nil.")

(dp-deflocal dp-refresh-my-abbrevs-p nil
  "When this is set in a buffer, it means to set that buffer's local alias
  list to the newly loaded list.")

(defun* dp-abbrev-refresh-buffers (&optional (abbrevs 'dp-go-abbrev-table))
  (mapc (function
         (lambda (buffer)
           (with-current-buffer buffer
             (when dp-refresh-my-abbrevs-p
               (dp-funcall-if dp-refresh-my-abbrevs-p (abbrevs)
                 (setq local-abbrev-table abbrevs))))))
        (buffer-list)))

;; dp-reinitialized-abbrev-table-alist)

;;;
;;; 'global abbrevs are for automatic expansion, e.g. speling erors.
;;; 'global becomes global-abbrev-table and abbrevs in that table are
;;; auto expanded.  I currently have too many things in there that are
;;; expanded annoyingly often, so I need to revisit the table
;;; assignments.

;;; 'manual abbrevs are expected to be expanded by hand.
;;; @ todo... add mode to "properties" and then add to table for that mode.
;;; Stems of abbrev tables.  If just a symbol then construct a table name of
;;;  <sym>-abbrev-table
;;;

(defvar dp-style-abbrevs t 
  "This is a list format that I use to allow the same abbrev to be
added to more than one table.  There are two formats. The first is a
list of items:
\( \(abbrev-name expansion) table-stem0 table-stem1... )
The first sublist is a list with 2 strings: the abbrev-name and its
expansion value.
Following is a series of table-stems.  A table-stem is, at this time, a
prefix added to \"-abbrev-table\".
So: \(let* \(\(abbrev-sublist \(car this-list-item))
           \(abbrev-name \(car abbrev-sublist))
           \(abbrev-exp  \(cadr abbrev-sublist))
           \(table-stems \(cdr this-list-item)))
      ;; Go to town...
)
")

(defun dp-is-a-dp-common-abbrev-sym-p (var-sym)
  "Determine if the VAR-SYM references a dp style abbrev thing.
If so, the `symbol-value' of VAR-SYM is returned."
  (and (boundp var-sym)
       (get var-sym 'dp-I-am-a-dp-style-abbrev-file)
       (let ((val (symbol-value var-sym)))
	 (and val
              (listp val)
	      (> (length val) 0)
              val))))

;; Why did I do this? It's not used.
(defvar dp-abbrev-sym-table-name-map '() 
  "Alist for mapping a symbol (as from a dp-style-abbrev) identifying an 
abbrev-table to an abbrev-table name.")

(defun* dp-abbrev-mk-abbrev-table-name (name-or-sym &optional 
                                        (name-formatter "%s-abbrev-table"))
  (or (assoc name-or-sym dp-abbrev-sym-table-name-map)
      (format name-formatter name-or-sym)))
  
(defun dp-abbrev-mk-mode-abbrev-table-name ()
  (dp-abbrev-mk-abbrev-table-name "dp"
                                  (format "%%s-%s-abbrev-table" major-mode)))
;;
;; @todo
;; property: 'upcase. If non-nil --> add all uppercase version as expansion.
;; e.g. (("eof" "end of file") '(table-name dp-manual upcase t)) results in
;; an expansion list: ("end of-file" "EOF")
;; And so for downcase
;; And, as usual, allow an expansion val to be a function returning an abbrev
;; or nil.
(defun dp-redefine-abbrev (dp-style-abbrev &optional force-clear-p)
  "Define abbrevs into list\(s) given in DP-STYLE-ABBREV."
  (let* ((abbrev+expansions (car dp-style-abbrev))
         (abbrev-names (car abbrev+expansions))
         (expansions (cdr abbrev+expansions))
         (table-info (cdr dp-style-abbrev))
         filtered-expansions
         full-table-name-str
         full-table-name
         table)
    (setq-ifnil table-info (list dp-default-abbrev-table))
    (unless (listp abbrev-names)
      (setq abbrev-names (list abbrev-names)))
    (when (member (car expansions) '('circular '=))
      (setq expansions abbrev-names))
    (loop for abbrev-name in abbrev-names do
      (loop for table-name in table-info do
        (let* ((props (and (listp table-name)
                           (valid-plist-p table-name)
                           table-name))
               (full-type1-name-str
                (if (and props  ; type 2
                         ;; Error if no table name.  I
                         ;; mean, come on, throw me a bone.
                         (not (assert (plist-get table-name 
                                                 'table-name)
                                      'SHOW-ARGS)))
                    (dp-abbrev-mk-abbrev-table-name 
                     (plist-get props 'table-name))
                  (and table-name
                       (symbolp table-name)  ; --> type 1
                       (dp-abbrev-mk-abbrev-table-name table-name))))
               doc-string)
          (when (and full-type1-name-str
                     ;; Catch void and interned & unbound.
                     (not (boundp (intern full-type1-name-str))))
            ;; Create a type 1 dp-style-abbrev list.
            (setq full-table-name (intern full-type1-name-str)
                  full-table-name-str (format "%s" full-table-name)
                  doc-string
                  (format "%s: %s" full-table-name-str
                          "Abbrev table.  Created automagically whilst executing `dp-redefine-abbrev'.
Should it be formally defined elsewhere?"))
            (eval `(defconst ,full-table-name ,(make-abbrev-table) ,doc-string))
            (when props
              (put full-table-name 'dp-abbrev-table-plist props)))
          (setq-ifnil full-table-name-str 
                      (if (and (listp table-name)
                               (not (assert 
                                     (valid-plist-p table-name))))
                          (dp-abbrev-mk-abbrev-table-name 
                           (plist-get table-name 'table-name))
                        full-type1-name-str)
                      full-table-name (intern-soft full-table-name-str))
          (unless full-table-name
            ;; New table... create an empty one.
            (setq full-table-name (intern full-table-name-str))
            (define-abbrev-table full-table-name '())
            (setq dp-dp-style-abbrev-tables
                  (cons (symbol-value full-table-name)
                        dp-dp-style-abbrev-tables)))
          (setq table (symbol-value full-table-name))
          ;; Have we cleared it this time around?
          ;; This alist must be empty before this whole process begins.
          (unless (assoc full-table-name dp-reinitialized-abbrev-table-alist)
            (clear-abbrev-table table)
            (dp-add-to-alist-if-new-key 'dp-reinitialized-abbrev-table-alist 
                                        (cons full-table-name t)))
          ;;
          ;; There's no sense in having x expand to x. In fact it's confusing
          ;; because it can make it look like there are no expansions when
          ;; x's doppelganger is the first expansion value. In addition it's
          ;; redundant because we circle around to the initial value anyway.
	  (unless expansions
	    (dmessage "Expansions is nil"))
          ;; Can't rotate an empty list. But `define-abbrev' uses nil
          ;; EXPANSION to undefine an abbrev, so we handle the case and let
          ;; the nil go through.
          (setq filtered-expansions 
                (and expansions
                     (dp-rotate-and-func expansions abbrev-name 
                                         'remove 'missing-ok)))
          ;; Don't define empty expansions.
          (when filtered-expansions
            (define-abbrev table abbrev-name
              (format "%S" filtered-expansions))))))))

(defun* dp-eval-abbrev-file (abbrev-file &optional 
                             (abbrev-sym 'dp-common-abbrevs))
  "ABBREV-FILE can be a simple file of `define-abbrev' statements or a
list in my DP-STYLE-ABBREV format (q.v.)"
  (if (get-file-buffer f)
      (eval-buffer (get-file-buffer f))
    (when (file-readable-p f)
      (load f)))
  ;; We've eval'd the file.  It could have been a regular file, in
  ;; which case we're done.  Or it could've been one of my files.  If
  ;; so, then a few things should've been done to identify it as funky
  ;; file.  Each file will set the dp-common-abbrevs variable and
  ;; `put' a property on it.
  (if (dp-is-a-dp-common-abbrev-sym-p abbrev-sym)
      (dp-redefine-abbrev-table (symbol-value abbrev-sym))
    (makunbound abbrev-sym)))

(defvar dp-emacs-style-abbrev-files 
  '("~/.abbrev_defs" "~/.abbrev-defs")
  "Boring old emacs style abbrev files. Emacs can just load them")

(defun* dp-abbrevs (&optional show-make-output-p (make-p t) 
                    (save-some-buffers-p t)
                    &key (emacs-style-abbrev-files dp-emacs-style-abbrev-files))
  "Load aliases and abbreviation files listed in `dp-abbrev-files'."
  (interactive "P")
  (dmessage "dp-abbrevs")
  (when make-p
    (when save-some-buffers-p
      ;; regexp: |\\.go.*\\|
      (dmessage (concat "@todo: Use a predicate with `save-some-buffers-p'"
                        " so we don't get swamped with save requests."))
      (save-some-buffers))
    (message "make(1L)'ing...")
    (let* ((make-command0 "make -C $HOME emacs-abbrevs")
           (make-command (format "echo %s; %s" make-command0 make-command0))
           (obuf (get-buffer-create (format "*dp-abbrevs make buf: %s*"
                                            make-command0)))
           (status
            (progn
              (erase-buffer obuf)
              ;; 99% from shell-command just so I can get the effin' status.
              ;; What did I miss?
              (call-process shell-file-name 
                            nil 
                            obuf
                            nil
                            shell-command-switch make-command)))
            (ok (= status 0)))
      (if (or show-make-output-p
              (not ok))
          (dp-switch-to-buffer-other-window obuf)
        (kill-buffer obuf))
      
      ;; Does this nuke any useful info in the echo area?
      ;; If so, just try a `ding'.
      ;;(ding)
      (message "make(1L)'ing... %s.  Status: %s"
               (if ok "done" "FAILED")
               status)
      (unless ok
        (return-from dp-abbrevs))))

  ;;! @todo XXX eval'ing my abbrev tables must come before reading the normal
  ;;  ones because my table code clears any tables that have abbrevs defined
  ;;  in them.
  ;; FIX THIS. add prop to my defs? Add prop to normal table names?
  ;;! @todo XXX eval'ing in this order nukes defs in my files.

  ;; Clear the list of my style abbrev tables.
  
  (setq dp-dp-style-abbrev-tables '())
  (loop for f in dp-common-abbrev-file-names do
    (dp-eval-abbrev-file f))

  ;; Normal tables.
  (mapcar (function
	   (lambda (file)
	     (if (file-readable-p file)
		 (load file))))
	  dp-abbrev-files)

  ;;
  ;; Pull in any hard-coded, standard emacs type abbrev tables.
  (mapcar (function
           (lambda (file)
             (when (file-readable-p file)
               (read-abbrev-file file)
               (setq save-abbrevs nil))))
          dp-emacs-style-abbrev-files)
  (dp-abbrev-refresh-buffers dp-go-abbrev-table))

(defvar dp-num-dp-aliases-tried 0)

;; Operant conditioning.
(defun dp-aliases (&rest rest)
  (interactive)
  (message (format "Use dp-abbrevs%s"
                   (cond
                    ((> dp-num-dp-aliases-tried 30)
                     (format "! OMFG!  I've told you %d times!" 
                             dp-num-dp-aliases-tried))
                    ((> dp-num-dp-aliases-tried 20)
                     " FOOL!")
                    ((> dp-num-dp-aliases-tried 10)
                     " you IDIOT!")
                    ((> dp-num-dp-aliases-tried 5)
                     " you twit!  I'll do it this time...")
                    (t "!"))))
  (incf dp-num-dp-aliases-tried)
  (ding)
  (ding)
  (ding)
  (ding)
  (ding)
  (when (<= dp-num-dp-aliases-tried 5)
    (apply 'dp-abbrevs rest)))

(defun dp-save-and-redefine-abbrevs (&optional arg1)
  (interactive "P")
  (save-buffer)
  (dp-init-abbrevs)
  (when arg1
    (kill-this-buffer)))

(defun dp-edit-abbrev-associated-file (file-name &optional other-window-p
                                       &rest dp-abbrevs-args)
  (interactive "fGo file: ")
  ;; we're probably interested in the current dir, so put it on the kill ring.
  (kill-new default-directory)        ; ???
  (funcall (if other-window-p
               'find-file-other-window
             'find-file)
           file-name)
  (dp-define-buffer-local-keys '("\C-X\#" dp-save-and-redefine-abbrevs
                                 [(meta control x)] dp-save-and-redefine-abbrevs
                                 "\C-c\C-c" dp-save-and-redefine-abbrevs))
  (message "Use %s or %s to save and redefine abbrevs."
           (key-description [(control x) ?#]) 
           (key-description "\C-c\C-c")))

(defun* dp-edit-common-abbrevs-file (&optional 
                                     (abbrev-file dp-common-abbrev-file-name)
                                     (other-window-p t))
  ;;!<@todo prompt for file name, with ABBREV-FILE as default.
  (interactive)
  (dp-edit-abbrev-associated-file abbrev-file other-window-p))
(dp-defaliases 'eca 'dca 'dpeca 'dpea 'edpa 'edpca 'ecaf 'decaf 'deca
               'dp-edit-common-abbrevs-file)

(defsubst* dp-edit-common-abbrevs-file-other-window (&optional 
                                                     (abbrev-file 
                                                      dp-common-abbrev-file-name)
                                                     (other-window-p nil))
  (interactive)
  (funcall 'dp-edit-common-abbrevs-file abbrev-file other-window-p))

(dp-defaliases 'eca0 'dca0 'edpa0 'edpca0 'ecaf0 'aca 'nca
               'dp-edit-common-abbrevs-file-other-window)

(defun dp-edit-go-file (&optional go-file other-window-p)
  "Edit GO-FILE, the most specific .go file or prompt for one, in this order."
  (interactive)
  (let* ((wtf (kb-lambda
                  (save-buffer)
                  (dp-abbrevs)))
         ;; Ask the go manager for the most specific go file.
         (go-name (shell-command-to-string "go-mgr -G"))
         (def-file (expand-file-name 
                    (substring (or (and go-name 
                                        (not (string= "" go-name)) 
                                        go-name)
                                   "~/.go.home\n") 
                               0 -1)))
         (go-path (getenv "GOPATH"))
         (go-file (cond
                   ((and current-prefix-arg (interactive-p))
                    (read-file-name (format "GO file (default %s): " def-file)
                                    "~/"
                                    def-file
                                    nil))
                   ((and (stringp go-file)) go-file)
                   (t def-file))))
    (dp-edit-abbrev-associated-file go-file other-window-p)))

(defalias 'ego 'dp-edit-go-file)
(defsubst ego2 (&optional go-file)
  (interactive)
  (dp-edit-go-file go-file 'other-window))

(defun* dp-read-abbrev-name-and-expansion (&key 
                                           (a-prompt "abbrev-name:")
                                           (a-prompt-prefix "")
                                           (e-prompt "expansion: ") 
                                           (e-prompt-prefix ""))
  (list (dp-prompt-with-symbol-near-point-as-default 
         (format "%s%s" a-prompt-prefix a-prompt))
        (read-string (format "%s%s" e-prompt e-prompt-prefix))))


(defun dp-add-manual-abbrev (abbrev expansion)
    ;;(interactive "sabbrev: \nsexpansion: ")
    (interactive (dp-read-abbrev-name-and-expansion 
                  :a-prompt-prefix "manual "))
    (dp-add-abbrev abbrev expansion nil :table-names '(dp-manual)))
;;;;???? 0?    (dp-add-abbrev0 abbrev expansion '(dp-manual)))

(defun dp-add-global-abbrev (abbrev expansion)
    (interactive (dp-read-abbrev-name-and-expansion 
                  :a-prompt-prefix "auto "))
    (dp-add-abbrev abbrev expansion nil :table-names '(global)))
;;;;???? 0?    (dp-add-abbrev0 abbrev expansion '(global)))

(defstruct dp-expand-abbrev-state
  (expansions nil)                      ; All of the available expansions.
  (current nil)                         ; The, ah, well, current expansion.
  (success nil)                         ; Last iteration found an expansion.
  (expansion-len nil))

(defvar dp-expand-abbrev-state nil
  "Holds state information if we are scrolling thru multiple expansions.")

(dp-deflocal dp-abbrev-suffix nil
  "`insert' this immediately after the expansion.
Setting to nil or \"\" can be used to disable suffix addition.
Disabled by default.")

(defvar dp-modes-wanting-post-alias-spaces '(text-mode)
  "Sometimes it's easiest to have spaces automagically inserted after an
abbrev is expanded.")

(dp-set-mode-local-value 'dp-abbrev-suffix " "
                         dp-modes-wanting-post-alias-spaces)

(defun* dp-get-special-abbrev (key-string regexp-for-abbrev-text
                               &optional component-split-string
                               key-string-optional-p)
  (interactive)
  ;; optional doesn't work when searching backwards (which we must do)
  ;; because the optional part, if present, will match the required part and
  ;; the match will stop there. ??? Skip back all non-abbrev chars and search
  ;; fwd?
  (let* ((opt-string (if key-string-optional-p
                         "?"
                       ""))
         (key-regexp (concat "\\(" key-string opt-string "\\)"))
         (regexp (concat regexp-for-abbrev-text key-regexp)))
    (when (dp-looking-back-at regexp)
      (list (match-beginning 2)
            ;; Include terminating key string.
            (+ (length (match-string 3)) (match-end 2))
            (if component-split-string
                (split-string (match-string 2) component-split-string)
              (match-string 2))))))

(defvar dp-work-rel-abbrev-key-string ";")

(defvar dp-work-rel-abbrev-regexp 
  ;;"\\(^\\|[^a-zA-Z0-9]\\)\\([^a-zA-Z0-9]*\\)"
  "\\(^\\|[ /]\\)\\([^ /]*\\)"
  "The abbrev must be in match string 2.")

(defun dp-get-work-rel-abbrev ()
  (interactive)
  (or (dp-get-special-abbrev dp-work-rel-abbrev-key-string 
                             "\\(/work/\\)\\([^/]+?/[^/]+?\\)"
                             "/")
      (dp-get-special-abbrev dp-work-rel-abbrev-key-string 
                             dp-work-rel-abbrev-regexp
                             ",")))

(defun dp-expand-work-rel-abbrev ()
  (interactive)
  (let* ((abbrev-data (dp-get-work-rel-abbrev))
         beg end abbrev-strings expansion)
    (when abbrev-data
      (setq beg (nth 0 abbrev-data)
            end (nth 1 abbrev-data)
            abbrev-strings (nth 2 abbrev-data)
            expansion (dp-nuke-newline 
                       (shell-command-to-string 
                        (format "dogo_work_rel %s" 
                                (dp-string-join abbrev-strings " ")))))
      (delete-region beg end)
      (insert expansion)
      t)))

;; Just get the whole string and let me-expand-dest sort it out.
(defun dp-get-sandbox-rel-abbrev ()
  (when (dp-looking-back-at "\\(?:/\\| \\|^\\)\\(\\(//\\|[ ,]\\)\\([^, 
	]+\\)\\([, ][^, 
	]*\\)?[ ,]?\\)")
    (list (match-beginning 1)
          (match-end 1)
          (match-string 1))))
  
;; Expand:
;; ,<abbrev>,?                    -- Expand abbrev relative to current sb.
;; ,,<abbrev>,<sb>,?              -- Expand abbrev relative to given sb.
;; //p4/location/of/file          -- Expand // relative current sb.
;; //p4/location/of/file,<sb>,?   -- Expand // relative given sb.
(defun dp-expand-sandbox-rel-abbrev ()
  (interactive)
  (let* ((abbrev-data (dp-get-sandbox-rel-abbrev))
         beg end abbrev-strings expansion)
    (when abbrev-data
      (setq beg (nth 0 abbrev-data)
            end (nth 1 abbrev-data)
            abbrev-strings (nth 2 abbrev-data)
            expansion (dp-me-expand-dest
                       (if (listp abbrev-strings)
                           (dp-string-join abbrev-strings " ")
                         abbrev-strings)))
      (when expansion
        (delete-region beg end)
        (insert expansion "/")          ; Could add the "/" only if is-dir
        t))))

(defun dp-get-p4-location ()
  (interactive)
  (dp-get-special-abbrev "'" "\\(\\(^//.*\\)\\)"))

(defun dp-expand-p4-abbrev ()
  (interactive)
  (let* ((abbrev-data (dp-get-p4-location))
         beg end abbrev-strings expansion)
    (when abbrev-data
      (setq beg (nth 0 abbrev-data)
            end (nth 1 abbrev-data)
            abbrev-strings (nth 2 abbrev-data)
            expansion (dp-expand-p4-location
                       (if (listp abbrev-strings)
                           (dp-string-join abbrev-strings " ")
                         abbrev-strings)
                       "."))
      (delete-region beg end)
      ;; Are we interested more in dirs or files?
      ;; Time will tell.
      (insert expansion) ;; "/")
      t
      )))

(defun dp-abbrev-insert-suffix-p ()
  "Determine if we should add a suffix."
  ;; The minibuffer is in text-mode, which is one of the only fucking modes
  ;; which wants a suffix added. And we *really* don't want one in the
  ;; minibuffer.
  (and (not (dp-minibuffer-p))
       (or dp-abbrev-suffix
           ;; Different name spaces.
           (dp-mode-local-value 'dp-abbrev-suffix))))

(defun dp-abbrev-suffix ()
  "What is the abbrev suffix?"
  (if (dp-abbrev-insert-suffix-p)
      (or dp-abbrev-suffix
          ;; Different name spaces.
          (dp-mode-local-value 'dp-abbrev-suffix))
    ""))

(defun dp-abbrev-len (len-or-string)
  (+ (if (dp-abbrev-insert-suffix-p)
         (length dp-abbrev-suffix)
       0)
     (if (stringp len-or-string)
         (length len-or-string)
       len-or-string)))

(defun dp-expand-abbrev-from-tables (&rest tables)
  "Try to expand an abbrev using TABLES or `dp-expand-abbrev-default-tables'.
Tried in order given and first match wins."
  (interactive)
  ;; !<@todo XXX hacky way to have some semblance of functional expansion.
  ;; We can look for particular patterns to give us direction in expanding an
  ;; abbrev.
  ;; Is this a consecutive invocation?
  (if (and (eq last-command this-command)
           dp-expand-abbrev-state)
      (let* ((next (or (cdr (dp-expand-abbrev-state-current
                             dp-expand-abbrev-state))
                       (dp-expand-abbrev-state-expansions
                        dp-expand-abbrev-state)))
             (exp (concat (car next) (dp-abbrev-suffix))))
        ;; Remove previous expansion
        (backward-delete-char (dp-expand-abbrev-state-expansion-len
                               dp-expand-abbrev-state))

        (insert exp)
        (setf (dp-expand-abbrev-state-current dp-expand-abbrev-state) next
              (dp-expand-abbrev-state-expansion-len dp-expand-abbrev-state)
              (length exp)))
    ;; First go; setup undo.
    ;;(undo-boundary)                     ; doesn't work.
    (let* ((tables (cond
                    ((null tables) dp-expand-abbrev-default-tables)
                    ;; Check `symbolp' after `null' above since nil is
                    ;; a symbol.
                    ;; "Real" nil vs nil --> emacs' defaults
                    ((symbolp tables) nil)
                    (t tables)))
           ;; Terrible function name...  it grabs the "word" near point,
           ;; hopefully exactly like `expand-abbrev' (a subr) does.
           (abbrev-name (abbrev-string-to-be-defined nil))
           ;; Check for a mode specific abbrev table.
           (mode-table (intern-soft (dp-abbrev-mk-mode-abbrev-table-name))))
      ;; Set `global-abbrev-table' in the let?
      ;; expand-abbrev uses some hard coded junk.
      ;; It may even reference the global table in such a way as to bypass a
      ;; shadowing definition in a let.
      (when mode-table
        ;; Put the mode specific table at the front of the list.
        (setq tables (cons (symbol-value mode-table) tables)))
      (dolist (table tables)
        (let* ((expansion0 (abbrev-expansion abbrev-name table))
               ;; This read turns a "normal" abbrev into a symbol.  The
               ;; `format' below can fix this, but if the expansion is not
               ;; a valid symbol, then we'll die here.
               (expansion (if table
                              (and expansion0 (read expansion0))
                            expansion0))
               (is-list-p (and expansion (listp expansion)))
               (exp (if is-list-p (car expansion) expansion)))
          (if (not expansion)
              (setq dp-expand-abbrev-state nil)
            (backward-delete-char (length abbrev-name))
            ;;(insert (format "from table>%s<\n" table)) format %s will
            ;; stringify anything. exp can be a symbol.  BUG. expansions
            ;; with spaces need to be quoted because the read only returns
            ;; the first word.  However, if they come from the default
            ;; table (table is nil) then the (read expansion0) isn't done
            ;; and the encompassing escaped quotes remain. I can't remember
            ;; why I only do the read if the expansion comes from a
            ;; non-default (nil) table.  I say symbol in the comment and
            ;; there is a abbrev-symbol function which I may have used at
            ;; one time.  The bottom line is that the way it works now, if
            ;; the expansion comes from the default map then the outer
            ;; quotes remain, otherwise things are copacetic.
            (setq exp (format "%s%s" exp (dp-abbrev-suffix)))
            (insert exp)
            (setq dp-expand-abbrev-state
                  (and is-list-p
                       (setq expansion (cons abbrev-name expansion))
                       (make-dp-expand-abbrev-state
                        :expansions expansion
                        :current (cdr expansion)
                        :expansion-len (length exp))))
            (return (list abbrev-name expansion table))))))))


(defvar dp-fallback-expand-abbrev-fun nil
  "Call this if expanding an abbrev the standard way fails.")

(defun dp-expand-abbrev (&rest tables)
  (interactive)
  (unless
      (cond
       ((dp-expand-sandbox-rel-abbrev))
       ((dp-expand-p4-abbrev))
       ((dp-expand-work-rel-abbrev))
       ((dp-expand-abbrev-from-tables tables))
       (t
        ;; Fall back to an unadorned sb relative name.
        (dp-funcall-if dp-fallback-expand-abbrev-fun tables)))
    (ding)))

   
(defun dp-expand-apprev (abbrev-symbol)
  (if (and (boundp abbrev-symbol)
           (symbol-value abbrev-symbol))
      (let ((local-abbrev-table (symbol-value abbrev-symbol)))
        (expand-abbrev))
    (expand-abbrev)))

(defun dp-expand-dir-abbrev (arg &optional abbrev-table)
  "Expand a dir from: abbrev-table or external `dogo' command."
  (interactive)
  (let ((abbrev-table 
         (dp-find-abbrev-table '(abbrev-table dp-shell-command-to-list))))
    (or
     (and abbrev-table
          (abbrev-expansion arg abbrev-table))
     (substring (shell-command-to-string (format "dogo %s" arg)) 0 -1)
     arg)))                             ;should never return this

(defun* dp-find-abbrev-table (&optional first-choice-sym 
                              (default 'dp-go-abbrev-table))
  "Find the best symbol table, checking symbol(s) in FIRST-CHOICE-SYM first.
return DEFAULT or `dp-go-abbrev-table' as a default.
@todo: would an alist of mode->abbrev-table-symbol be useful?"
  (let* ((first-choice-syms (if (listp first-choice-sym)
                                first-choice-sym
                              (list first-choice-sym)))
         (val (loop for sym in first-choice-syms
                do (if (or (and (boundp sym)
                                (symbol-value sym)))
                       (return (symbol-value sym))))))
    (or val
        (and
         (boundp default)
         (symbol-value default)))))

(defun* dp-save-abbrevs (&key (write-p 'ask)
                         (abbrev-list 'dp-common-abbrevs) 
                         (abbrev-file (car dp-common-abbrev-file-names)))
  "Create an expression that will regenerate ABBREV-LIST when `eval'd.
Optionally write it to ABBREV-FILE based on the value of WRITE-P.
If (eq t), write it.
If (eq 'ask), prompt w/`y-or-n-p'.
Otherwise don't write it."
  (save-excursion
    (set-buffer (find-file-noselect abbrev-file))
    (backup-buffer)
    (goto-char (point-min))
    (if (re-search-forward 
         (dp-regexp-concat (list dp-preserve-above-monition
                                 dp-begin-generated-section-declaration)
                           nil
                           'quote-elements)
         nil t)
        (beginning-of-line)
      (goto-char (point-min)))
    (delete-region (point) (point-max))
    (insert dp-preserve-above-monition "\n"
            dp-preserve-above-monition-comment "\n"
            dp-begin-generated-section-declaration "\n"
            dp-begin-generated-section-declaration-comment "\n"
            (format ";;; File: %s\n" abbrev-file)
            (dp-mk-timestamp ";;; Last saved: " "")
            dp-abbrev-shared-comment-block)
    (pprint `(defconst ,abbrev-list (quote ,(symbol-value abbrev-list)))
	    (current-buffer))
    (insert ";; We could just use the non-void-ness of dp-common-abbrevs, but I
;; like suspenders with my belt.
\(put 'dp-common-abbrevs 'dp-I-am-a-dp-style-abbrev-file t)
")
    (if (or (eq write-p t)
	    (and (eq write-p 'ask)
		 (y-or-n-p "Save abbrev file? ")))
	(save-buffer)
      (message "Abbrevs will be temporary unless the abbrev file is saved."))
    ;; `dp-abbrevs' will use the abbrev file's buffer if there is one.
    ;; if we haven't saved, then the abbrev is only temporary
    (dp-abbrevs)))

(defvar dp-abbrev-table-types-regexp
  "^\\(common\\|manual\\|dp-manual\\|man\\)$"
  "")

(defun* dp-add-abbrev (abbrev expansion 
                       &optional query-type-p
                       &key (abbrev-list 'dp-common-abbrevs)
                       (table-names '(dp-manual global))
                       (abbrev-file (car dp-common-abbrev-file-names)))
  (interactive (dp-read-abbrev-name-and-expansion 
                :a-prompt "abbrev-name"))
  (set abbrev-list
       (nconc (and (boundp abbrev-list)
                   (symbol-value abbrev-list))
              (list (append 
                     (list (list abbrev expansion)) 
                     (or (when (and (interactive-p)
                                    (or table-names
                                        current-prefix-arg))
                           (let ((types (read-string ; !!!!!!!! completing read
                                         "abbrev types (manual global)): "))
                                 (targ '()))
                             (loop for table in (split-string types)
                               do (cond
                                   ((eq 0 (string-match (regexp-quote table) 
                                                        ""))
                                    (push targ 'global))
                                   ((eq 0 (string-match 
                                           (regexp-quote table) 
                                           dp-abbrev-table-types-regexp))
                                    (push targ 'dp-manual))))
                             (message "targ>%s<" targ)))
                         table-names)))))
  (dp-save-abbrevs :write-p 'ask :abbrev-list abbrev-list
                   :abbrev-file abbrev-file))

(defun dp-redefine-abbrev-table (a-dp-style-abbrev-list)
  ;; "Parameter"... It needs to exist across all calls made by the `mapc'.
  (let ((dp-reinitialized-abbrev-table-alist '()))
    (mapc 'dp-redefine-abbrev a-dp-style-abbrev-list)))

(dp-deflocal dp-tmp-manual-abbrev-table (make-abbrev-table)
  "These don't ever get saved to a file and are buffer local.")

(defun dp-add-tmp-manual-abbrev (abbrev expansion)
  (interactive "sabbrev: \nsexpansion: ")
  (define-abbrev dp-tmp-manual-abbrev-table abbrev expansion))
(defalias 'deftma 'dp-add-tmp-manual-abbrev)

(dp-deflocal dp-expand-abbrev-default-tables '(nil)
  "All abbrev tables to check by default.  Use nil for the current default 
table.")

(defun dp-init-abbrevs ()
  (dp-abbrevs)				;load my mailiases and abbrevs
  ;; We need this here after this table has been read.
  (setq-default dp-expand-abbrev-default-tables 
                (list nil ; Default table.
                      dp-tmp-manual-abbrev-table
                      dp-go-abbrev-table 
                      dp-manual-abbrev-table))
  ;; Add some special abbrevs.
  ;; This needs to be done after the tables have been created
  (define-abbrev dp-manual-abbrev-table "xdrop" 
    (concat dp-xemacs-droppings "/"))
  (define-abbrev dp-manual-abbrev-table "edrop" 
    (concat dp-editor-droppings "/"))
  (define-abbrev dp-manual-abbrev-table "xebac" 
    (concat dp-backup-droppings "/"))
  (define-abbrev dp-manual-abbrev-table "asave" 
    (concat dp-auto-save-droppings "/"))
  )

;;;
;;;
;;;
(provide 'dp-abbrev)
(message "dp-abbrev eval-ed. Finished")

