;;
;; Datestamp:
;; ========================
;; Saturday January 12 2002
;; --
;; 
;; Timestamp:
;; ========================
;; 2002-01-12T10:52:25
;; --
;;
;; Topicstamp:
;; rec-start:   ========================
;;              2002-01-12T10:52:25
;; topic-start: <topic-name>
;;              --
;;
;; ========================
;; 2002-01-12T10:52:25
;; todo: add todos
;; --
;; ========================
;; 2002-01-12T10:52:25
;; <<done:2002-06-02T14:08:35>>todo: add todos
;; --
;;
;; This is really extraordinarily badly written.

(make-variable-buffer-local 'auto-save-interval)
(make-variable-buffer-local 'auto-save-timeout)

(defvar dpj-abbrev-list-modified-p nil
  "Non-nil when the abbrev list has been modified.")
(defvar dpj-todo-str "todo: ")
(defvar dpj-done-str "<<done:")
(defvar dpj-cancelled-str "~~cancelled:")
(defvar dpj-todo-re (format "^%s.*" dpj-todo-str))
(defvar dpj-cancelled-re (format "^%s.*" dpj-cancelled-str))
(defvar dpj-done-re (format "^\\(%s\\|%s\\).*" dpj-done-str dpj-cancelled-str))
(defvar dpj-todo/done-re (format "\\(%s\\|%s\\)" dpj-todo-re dpj-done-re)
  "Regexp to recognize a todo, open, done or cancelled.")
(defvar dpj-private-topic-str "&")
(defvar dpj-private-topic-re0 (format "^%s.*" dpj-private-topic-str))

(defvar dpj-private-topic-re (format "\\(%s\\|%s\\|%s%s\\)" 
				     dpj-todo-re dpj-done-re 
				     dpj-private-topic-re0
                                     dpj-private-topic-re-extra))

;;;(defvar dpj-bullet-regexp (concat dp-ws-regexp* (regexp-quote "$.+!@)))

(define-abbrev-table 'dpj-topic-abbrev-table '())

(defvar dpj-any-AI-regexp "[ 	]*?[?!@$]+[ 	]+")
;;(defvar dpj-any-AI-todo-regexp "[ 	]*\\([!@]+\\|\\?\\?\\?\\?*\\)[ 	]+")
(defvar dpj-any-AI-todo-regexp 
  "\\(^\\?+\\|[ 	]*\\([!@]+\\|\\?\\?\\?\\?*\\)\\)[ 	]+")
(defvar dpj-any-AI-regexp@bol (concat "^" dpj-any-AI-regexp)
  "Regexp to find AI at beginning of line.")
(defvar dpj-any-AI-todo-regexp@bol (concat "^" dpj-any-AI-todo-regexp)
  "Regexp to find todo type AI at beginning of line.")

(defvar dpj-timestamp-re0
  (concat "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T"
	  "[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}")
  "Regexp to recognize a timestamp. Not 100% accurate, but close.")

(defvar dpj-timestamp-re (concat dpj-timestamp-re0 "\n")
  "Regexp to recognize a timestamp. Not 100% accurate, but close.")

(defvar dpj-topic-location-re-format
  (concat "^"
	  dp-stamp-leader-regexp
	  dpj-timestamp-re
	  "%s%s%s--\n"))

(defvar dpj-datestamp-re
  (concat "^"
	  dp-stamp-leader
	  "[SMTWF][a-z]+ [JFMASOND][a-z]+ [0-3][0-9] [0-9]\\{4\\}\n"
	  "--\n")
  "Regexp that matches a datestamp.  Not 100% immune to false
positives, but funky enough to minimize them.")

(defvar dpj-local-variables-hack-separator (make-string 77 ?\;)
  "Separator which comes before local variables hack section.")

(dp-set-mode-local-value 'dp-local-variables-hack-separator
                         dpj-local-variables-hack-separator
                         'dp-journal-mode)

(defun dp-journal-mode-indent-according-to-mode ()
  "Indent line so it ends up 1 dpj tab under past the previous line's."
  (save-excursion
    (back-to-indentation)
  (indent-relative)))

(defconst dpj-link-left-delim "<<"
  "Link left delimitter.")

(defconst dpj-link-right-delim ">>"
  "Link right delimitter.")

(defvar dpj-last-process-topics-args '()
  "Last set of args to dpj-process-topics.")

(defvar dpj-embedded-lisp-regexp ":\\((.*)\\):"
  "Regexp to recognize an embedded lisp expression.")

(defun dpj-mk-topic-re (&optional topic-re)
  "Add the topic's RE into the overall topic header format."
  (let ((lparen "\\(")
	(rparen "\\)\n"))
    (cond
     ((eq topic-re nil) (setq topic-re ".+?"))
     ((equal topic-re "") (setq lparen "" rparen "")))
    (format dpj-topic-location-re-format lparen topic-re rparen)))


(defcustom dp-journal-invisible-text-glyph-string nil
  "*String from which to make dp-journal mode's  `invisible-text-glyph'."
  :type 'string
  :group 'dp-vars)

(defcustom dp-journal-invisible-text-glyph-file (and (featurep 'xpm) 
                                                     nil)
  "*File from which to make the `invisible-text-glyph'.  
nil says to use the default builtin image."
  :type '(file :must-match t)
  :group 'dp-vars)

(defcustom dp-journal-invisible-text-glyph-color "gray30"
  "*Color to make the `invisible-text-glyph' when using the builtin default."
  :type 'string
  :group 'dp-vars)

(defcustom dp-journal-use-invisible-text-glyph-p (and (featurep 'xpm)
                                                      t)
  "*Flag telling whether or not to use our own value for
`invisible-text-glyph'."
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-journal-sort-topics-p t
  "*Should we keep the topic list sorted?"
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-journal-sort-topic-func 'dpj-topic<
  "*How do we sort the topics?"
  :type 'custom
  :group 'dp-vars)

(defcustom dpj-file-wrap-limit 12
  "*Limit to number of months of files we will wrap thru to find a topic."
  :type 'integer
  :group 'dp-vars)

(defvar dpj-info-regexps0 (regexp-opt '("http://" "https://" "ftp://" 
				       "gopher://" "mailto:" "telnet://"
				       "www." "ftp.")
				     'wrap-in-parens)
  "Regexp to represent information-like patterns,
e.g. URLs.")

(defvar dpj-topic-to-file-map 
  '(("\\(\\.\\|^\\)politics\\(\\.\\|$\\)" "daily-private")
    ("\\.*" "daily"))
  "Map a topic name to a topic specific file name")

(defun dpj-topic-to-file (topic)
  "Create a topic specific note file name.
!<@todo XXX allow the name-base to include a dir."
  (let* ((name-base (cadr (dp-assoc-regexp topic dpj-topic-to-file-map))))
    (dp-make-dated-note-file-name name-base 
                                  :extension ".jxt"
                                  :note-base-dir (dpj-base-dir-name topic))))

(defvar dpj-info-regexps (concat dpj-info-regexps0 "[^ 	
]*"))

(defvar dpj-alt-regexp "^[ 	]*\\(!*[0-9]+[.a-zA-Z0-9]*\\)[].:|!)].*$")
;;;(defvar dpj-alt-regexp "^[ 	]*|.*$")
;;;(defvar dpj-alt-regexp "^\\([ 	]*| .*\\|[0-9][0-9]*) .*\\)$")

(defun dpj-alt (limit n max-colors)
  (catch 'done
    (let (n-th)
      (while (dp-re-search-forward dpj-alt-regexp limit t)
        (setq n-th (mod (truncate (string-to-int (match-string 1)))
                        max-colors))
;         (dmessage "ms1>%s<, s2i: %s, n: %s, n-th: %s" 
;                   (match-string 1) 
;                   (string-to-int (match-string 1))
;                   n n-th)
        (if (= n-th n)
            (throw 'done t))))
    nil))

; (defun dpj-alt (limit n)
;   (catch 'done
;     (save-excursion
;       (while (dp-re-search-forward dpj-alt-regexp limit t)
; 	(setq l-and-1 (logand (line-number) 1))
; 	(if (= n (logand (line-number) 1))
; 	    (throw 'done t)))
;       (set-match-data nil))))

(when (featurep 'filladapt)
  ;; This was in dpmacs.el, but it doesn't really belong there unless there
  ;; was some dependency or some such issues.
  (defvar dpj-filladapt-token-table-additions 
    '(("[!?@$]+[ 	]" dpj-action-item)
      ("\\(~~\\|==\\)>[ 	]" dpj-action-item-resolution))
    "Things I'd like filladapt to know about.
This associates a regexp with a symbol name. The symbol names are used by
`fill-adapt-token-match-table'.")
  (dp-add-list-to-list 'filladapt-token-table 
                       dpj-filladapt-token-table-additions)

  (defvar dpj-filladapt-token-match-table-additions
    '((dpj-action-item dpj-action-item)
      (dpj-action-item-resolution dpj-action-item-resolution))
    "Inform filladapt about my journal mode tokens.")
  (dp-add-list-to-list 'filladapt-token-match-table 
                       dpj-filladapt-token-match-table-additions))

(defun dpj-alt-0 (limit)
  "Helps to determine if chars in a sequence can be considered even.
Things like (sub-)?topics in an outline:
{1 2 3 4 5...} {a b c d...} {i ii...}(I don't think I did this one.)
In these sequences, {1 a i...} are considered odd.
This way we can get alternating colors on journal mode structure in the text:
+  Blah
   1) .... ; color one, dpj-alt-1 is t
   2) .... ; color two, dpj-alt-0 is t
   3) .... ; color one, dpj-alt-1 is t
--actually, or vice versa--
..."
  (dpj-alt limit 0 2))

(defun dpj-alt-1 (limit)
  "Same for odd."
  (dpj-alt limit 1 2))

;; see `font-lock-keywords' for format of this variable
(defvar dp-journal-mode-font-lock-keywords  ;<:font lock keywords:>
  (list
   ;; ?? Add whitespace after prefix?
   ;; yes, since the searches use ws and this way the line
   ;; won't highlight if a search won't find it.
   ;; we can add spaces here or remove them from the search regexp.
   ;; For these basic line type faces, only apply them to the unfontified
   ;; parts of the line. They are essentially background. This allows any
   ;; specific things (like the function face) to work w/o specifically
   ;; prepending it. Even though it is done that way below at this time.
   (cons "^[ 	]*!!!+ .*$" 'dp-journal-high-problem-face)
   (cons "^[ 	]*!! .*$" 'dp-journal-medium-problem-face)
   (cons "^[ 	]*! .*$" 'dp-journal-low-problem-face)

   (cons "^[ 	]*@@@+ .*$" 'dp-journal-high-todo-face)
   (cons "^[ 	]*@@ .*$" 'dp-journal-medium-todo-face)
   (cons "^[ 	]*@ .*$" 'dp-journal-low-todo-face)

   (cons "^[ 	]*\\?\\?\\?+ .*$" 'dp-journal-high-question-face)
   (cons "^[ 	]*\\?\\? .*$" 'dp-journal-medium-question-face)
   (cons "^[ 	]*\\? .*$" 'dp-journal-low-question-face)
   ;; what was I doing here???   
   ;; (cons "\\?+[^?].*\\?\\?*" (list 0 'dp-journal-low-question-face 'keep))

   (cons "^[ 	]*\\$\\$\\$+ .*$" 'dp-journal-high-info-face)
   (cons "^[ 	]*\\$\\$ .*$" 'dp-journal-medium-info-face)
   (cons "^[ 	]*\\$ .*$" 'dp-journal-low-info-face)
   (cons "^[ 	]*[Ff][Yy][Ii]:? .*$" 'dp-journal-medium-info-face)
   (cons "^[ 	]*>>>>+ .*$" 'dp-journal-extra-emphasis-face)
   (cons "^[ 	]*>>> .*$" 'dp-journal-high-info-face)
   (cons "^[ 	]*>> .*$" 'dp-journal-medium-info-face)
   (cons "^[ 	]*> .*$" 'dp-journal-low-info-face)
   (cons "^[ 	]*\\+\\+\\++ .*$" 'dp-journal-high-attention-face)
   (cons "^[ 	]*\\+\\+ .*$" 'dp-journal-medium-attention-face)
   (cons "^[ 	]*\\+ .*$" 'dp-journal-low-attention-face)
   (cons "^[ 	]*\\*\\*\\*+ .*$" 'dp-journal-high-attention-face)
   (cons "^[ 	]*\\*\\* .*$" 'dp-journal-medium-attention-face)
   (cons "^[ 	]*\\* .*$" 'dp-journal-low-attention-face)
   ;; e.g. (fyi: I have a eg --> e.g. abbrev)
   (cons "^[ 	]*[Ee]\\.?[Gg][.:]?\\(\\s-+\\|:\\).*$" 
         'dp-journal-high-example-face)
   ;; n.b. (fyi: I have an abbrev for nb --> N.B.)
   (cons "^[ 	]*[nN]\\.?[Bb]\\.? .*$" 'dp-journal-extra-emphasis-face)

   ;; plain timestamps
   (cons (dpj-mk-topic-re "") 'dp-journal-timestamp-face)
   ;; datestamps
   (cons dpj-datestamp-re 'dp-journal-datestamp-face)
   ;; topics
   (list (dpj-mk-topic-re) 
	 (list 0 'dp-journal-topic-stamp-face)
	 (list 1 'dp-journal-topic-face t))
   ;; todos
   (list (dpj-mk-topic-re dpj-todo-re)
	 (list 1 'dp-journal-todo-face t))
   ;; done todos
   (list (dpj-mk-topic-re dpj-done-re)
	 (list 0 'dp-journal-done-face t))


   ;; Why did I do two? 1) Topic type. 2) embedded.
   ;; example, e.g.
   (cons "\\((e.g[^)]*)\\)" (list 1 'dp-journal-high-example-face t))

   (cons dpj-info-regexps 'dp-journal-medium-info-face)

   (cons "\\([ 	]\\|^\\)\\(\\*\\*.+?\\*\\*\\)" ; extra **emphasis**
	 (list 2 'dp-journal-extra-emphasis-face 'prepend))
   (cons "\\([ 	]\\|^\\)\\(\\*.+?\\*\\)" 
	 (list 2 'dp-journal-emphasis-face 'prepend)) ; *emphasis*

   (cons "\\([ 	]\\|^\\)\\(\\?[^?].*?\\?\\)" 
	 (list 2 'dp-journal-low-question-face 'prepend)) ; ?huh?
   
   ;; [?.....?] unsure editorial change
   (cons "\\([ 	]\\|^\\)\\(\\[\\?.+?\\?\\]\\)"
         (list 2 'dp-journal-emphasis-face 'prepend)) 

   ;; add extra emphasis to a line.
   ;; this allows us, e.g., to emphasize a particular item in a list.
   ;; it is set up so that the <<<... overrides any existing face
   ;; whereas the preceding text face is not overridden.
   (cons "\\(^[^=~].*?\\)\\(<<<<<*\\|\\?\\?\\?\\?\\?*\\|!!!!!*\\|WTF\\|\\^\\^\\^\\^\\^*\\)\\(.*\\)$"
	 (list
	  (list 1 'dp-journal-extra-emphasis-face nil)
	  (list 2 'dp-journal-extra-emphasis-face t)
	  (list 3 'dp-journal-extra-emphasis-face nil)))

   (cons "`\\([^'`
]+\\)'" (list 1 'dp-journal-quote-face t)) ; `quote'
   (list "\\([a-zA-Z_]\\([0-9a-zA-Z_.-]\\|-\>\\|::\\)*\\)(\\(.*?\\))" 
	 (list 1 'dp-journal-function-face t)
	 (list 3 'dp-journal-function-args-face t)) ; functions

   (cons (concat "=======" dpj-timestamp-re0 "=======")
	 'dp-journal-topic-stamp-face)
   ;; no need to dim these out, just remove highlight
   (cons "^[ 	]*~[?!@].*$" 'dp-journal-cancelled-action-item-face)
   (cons "^[ 	]*=[?!@].*$" 'dp-journal-completed-action-item-face)
   
   (cons dpj-embedded-lisp-regexp 
         (list 0 'dp-journal-embedded-lisp-face t))

   ;; deemphasize a line
   ;; text after /s will not be dimmed
   ;; C++ type comment * 2 (////...) but affects the preceding text.
   (cons "\\(^.*?\\)\\(/////*\\)\\(.*\\)$"
	 (list
	  (list 1 'dp-journal-deemphasized-face t)
	  (list 2 'dp-journal-deemphasized-face t)
	  (list 3 'dp-journal-deemphasized-face nil)))
   (cons "^[ 	]*--+ .*$" 'dp-journal-deemphasized-face)

   ;; Alternating colors based on a numeric prefix.
   ;; E.g. 
   ;; 1) sjdhjsdh     <<<< color 1
   ;; 2) not sjdhjsdh <<<< color 2
   ;; 3) yadda        <<<< color 1
   (cons 'dpj-alt-0 (list 0 'dp-journal-alt-0-face 'prepend))
   (cons 'dpj-alt-1 (list 0 'dp-journal-alt-1-face 'prepend))

   ;; Shell type comment face
;    (cons "\\(^[^=~].*?\\)\\(.*?\\) \\(# .*\\)$"
;          (list 3 'dp-journal-low-question-face t))
   (cons "\\(^.*?\\) \\(# .*\\)$"
         (list 2 'dp-journal-low-question-face t))
        
   (cons "^[ 	]*[0-9][0-9]*)" 
         (list 0 'dp-journal-medium-question-face t))

   ) 
  "Journal mode font lock keywords")

;;
;; this has a problem.  if we use a regexp that has no matches, then
;; C-n still uses that pattern and goes nowhere.
(defvar dpj-next-in-topic-topic nil
  "If not nil, `dpj-next-in-topic' finds this topic.
Otherwise, it uses the topic of the current item.")

(defvar dpj-show-topic-topic nil
  "The currently highlighted topic.")

(defvar dpj-topic-re (dpj-mk-topic-re)
  "Regular expression to find a topic.")

(setq dpj-topic-re (dpj-mk-topic-re))

(defvar dpj-regexp-quote-topic t
  "Controls whether or not we quote the current-topic when we extract
  it from the journal file.")

;;
;; encapsulate our access to the match data
;; this is also a workaround for xemacs
;; re-search bugs
(defvar dpj-saved-match-data nil
  "Results of last search.")

(defvar dpj-topic-subexp 1
  "re-match-{forward|backeard} subexpression which holds the topic string.")

(defvar dpj-current-journal-file nil
  "*Current journal file. This can be global or buffer-local.  
A particular journal can be made sticky. This means that the sticky file will
be used instead of the computed newest journal file. Making a journal sticky
makes this variable become buffer local.  If it is made default, then the
buffer-local default is set. The variable remains bufer-local and so can be
used to override the global/default value.
A particular notes file can be made sticky so that notes added while in that
buffer will go into that notes file.
A non-standard (latest date-wise) file can be made the default as well, so,
for example, a project notes file can be used.")

(defun dpj-current-journal-file ()
  ;; !<@todo XXX FOR NOW!
  dpj-current-journal-file)

(defun dpj-set-current-journal-file (file-name &optional sticky-p default-p)
  (interactive "fJournal file name? \nP")
  (when (or default-p sticky-p)
    ;; Clear existing and set new.
    (kill-local-variable 'dpj-current-journal-file)
    (when (eq sticky-p t)
      (make-variable-buffer-local 'dpj-current-journal-file))
    (when (and default-p (dp-local-variable-p 'dpj-current-journal-file nil t))
      (setq-default dpj-current-journal-file file-name)))
  (setq dpj-current-journal-file file-name)
  (message "New %s%scurrent journal file: %s"
           (if sticky-p
               "sticky "
             "")
           (if default-p
               "default "
             "")
           dpj-current-journal-file))

(defun dpj-unstick-current-journal-file ()
  (dpj-set-current-journal-file nil 'un t))

(defun* dpj-journal-file-sticky-p (&optional (buffer (current-buffer)))
  (dp-local-variable-p 'dpj-current-journal-file buffer))

;;;###autoload
(defun dpj-stick-journal-file (&optional file-name unstick-p default-p)
  "Ass/2 way to make non-standard journal files a little less unusable."
  (setq-ifnil file-name (buffer-file-name))
  (interactive "P")
  (if unstick-p
      (dpj-unstick-current-journal-file)
    (dpj-set-current-journal-file file-name t default-p)))

;;;###autoload
(defun dpj-stick-current-journal-file (&optional unstick-p default-p)
  "Ass/2 way to make non-standard journal files a little less unusable."
  (interactive "P")
  (dpj-stick-journal-file (buffer-file-name) unstick-p default-p))

(dp-defaliases 'dpj-stick 'dpj-scfj 'dpj-sjf 'sjf 'snf 'dpj-make-sticky
               'dpj-stick-current-journal-file)


(defsubst dpj-restore-match-data (&optional data)
  "Set DATA or our saved match data into the global match-data."
  (set-match-data (or data dpj-saved-match-data)))

(defsubst dpj-set-match-data (&optional data)
  "Set DATA or current global match data into our saved match data."
  (setq dpj-saved-match-data 
	(if (or (eq data nil)
		(listp data))
	    data
	  (match-data))))

(defsubst dpj-match-data ()
  "Make a copy of our saved match data."
  (copy-sequence dpj-saved-match-data))

(defsubst dpj-topic-match-string (&optional num)
  (dpj-restore-match-data)
  (match-string (or num dpj-topic-subexp)))

(defsubst* dpj-topic-match-beginning (&optional num (no-marker-p t))
  (dpj-restore-match-data)
  (dp-mk-buffer-position (match-beginning 
                          (or num dpj-topic-subexp))
                         (not no-marker-p)))

(defsubst* dpj-topic-match-end (&optional num (no-marker-p t))
  (dpj-restore-match-data)
  (dp-mk-buffer-position (match-end 
                          (or num dpj-topic-subexp))
                         (not no-marker-p)))

(defsubst dpj-topic-match-timestamp ()
  "Return point of the timstamp part of a topic after finding a topic"
  (+ (dpj-topic-match-beginning 0) dp-stamp-leader-len))

(defun dpj-is-a-journal-p (file-name)
  (string-match "\\(^\\|/\\)daily-.*.jxt$"  file-name))
  
(defun dpj-is-private-topic-p (topic)
  (and (> (length topic) 0)
       (string= dpj-private-topic-str
		(substring topic 0 1))))

(dp-deflocal dpj-non-standard-journal-p nil
  "This isn't a regular journal file.  Don't assume anything about its name.
This variable is used to identify things like view bufs.")

(defsubst dpj-non-standard-journal-p ()
  (interactive)
  dpj-non-standard-journal-p)

(defun dpj-make-private-topic (topic)
  (concat dpj-private-topic-str topic))

(defun dpj-match-message (m)
  (message "ms0>%s<, ms0>%s<" 
	   (dpj-topic-match-string) (dpj-topic-match-string))
  (message "ms0>%s<, ms0>%s<" 
	   (dpj-topic-match-string) (dpj-topic-match-string)))

(defun dpj-highlight-region (from to op)
  "Highlight a region according to OP."
  (dp-highlight-region from to op 'dp-journal
                       'dp-journal-selected-face 'dp-journal-unselected-face))

(defun dpj-show-buffer ()
  "Remove all highlighting extents from the buffer."
  (interactive)
  (dpj-highlight-region (point-min) (point-max) 'showall)
  (setq dpj-last-process-topics-args nil))

(defsubst dpj-topic-info-record-start (info)
  (nth 1 info))
(defsubst dpj-topic-info-topic-start (info)
  (nth 2 info))
(defsubst dpj-topic-info-end (info)
  (nth 3 info))
(defun dpj-topic-info-timestamp (info)
  (buffer-substring (+ (dpj-topic-info-record-start info)
		       dp-stamp-leader-len)
		    (dpj-topic-info-topic-start info)))

;; NB: must retain side effect of moving point to topic start!!!
(defsubst dpj-get-current-timestamp-pos ()
  (when (dpj-goto-current-topic-start)
    (- (point) dp-timestamp-len 1)))
  
(defun dpj-get-current-timestamp ()
  "Pluck the timestamp from the current topic.
Return CONS (ts-text . ts-position)."
  (save-excursion
    (let ((ts-start (dpj-get-current-timestamp-pos)))
      (when ts-start
        (cons (buffer-substring ts-start (1- (point))) ts-start)))))

(defun dpj-find-topic (searchf movef skip-current &optional topic-re count
			       skip-re)
  "Search for topic statements using function SEARCHF.
Also sets topic value into dpj-topic-match-beginning, etc.
Does not affect point.  Use `dpj-goto-topic' to move to a new topic."
  (or topic-re
      (setq topic-re ".*"))
  (save-excursion
    (catch 'done
      (let* ((re (dpj-mk-topic-re))
	     (opoint (point))
	     topic-matches
	     topic
	     (skip-func (if (functionp skip-re)
			    skip-re
			  'string-match)))
	(while (setq ret (funcall searchf re nil t))
	  (dpj-set-match-data 'use-match-data)
	  (setq topic (dpj-topic-match-string))
	  (setq topic-matches (string-match topic-re topic))
	  ;; did we find the target topic?
	  ;(dmessage "top>%s<, top-re>%s<, skip-re>%s<" topic topic-re skip-re)
	  (if (and topic-matches
		   (not (dp-mmm-in-any-subregion-p 
			 (dpj-topic-match-beginning 0)))
		   (or (not skip-re)
		       (not (funcall skip-func skip-re topic))))
	      ;; do we want to skip the current topic?
	      (if (and skip-current
		       (eq opoint (dpj-topic-match-beginning 0)))
		  (progn
		    ;;(dmessage "find-topic: skipping current")
		    (setq skip-current nil))
		;;(dmessage "find-topic: throwing 'done %s" ret)
		(throw 'done ret))
	    ;;(dmessage "skipping topic: matches: %s, skip-re: %s, sm: %s"
	    ;;    topic-matches skip-re (funcall skip-func skip-re topic))
	    )
	  )
	(throw 'done nil)))))

(defun dpj-goto-topic (searchf movef skip-current &optional topic-re count
			       skip-re)
  "Find a matching topic and go there."
  ;;(message "find topic: %s" topic-re)
  (let ((ret (dpj-find-topic searchf movef skip-current topic-re 
			     count skip-re)))
    (if ret 
	(goto-char (dpj-topic-match-beginning)))
    ret))

(defun dpj-read-topic+skip+count ()
  "Read some or all of TOPIC-RE SKIP-CURRENT COUNT, depending on prefix arg.
The number of \\[universal-argument]'s  tells which to prompt for:
1 --> topic-re
2 --> 1 + skip-current
3 --> 2 + count
4 --> 3 + skip-re
Vals besides topic-re are mainly for debugging."
  (let ((prefix-val (and current-prefix-arg 
			 (prefix-numeric-value current-prefix-arg)))
	topic-re skip-current count skip-re)
    (when prefix-val
      (when (>= prefix-val 4)
	(setq topic-re (dpj-read-topic (car (dpj-find-topics topic-re))
					topic-re))
	(when (>= prefix-val 16)
	  (setq skip-current (y-or-n-p "skip current "))
	  (when (>= prefix-val 64)
	    (setq count (dp-read-number "num: " t 1))
	    (when (>= prefix-val 256)
	      (setq skip-re (read-from-minibuffer "skip-re: ")))))))
    (list topic-re skip-current count skip-re)))
  
(defun dpj-goto-topic-forward (&optional topic-re skip-current count skip-re)
  "Move forward to the next topic.
RETURNS:
 nil on failure (e.g: no more {files|topics}
 non-nil on success."
  (interactive (dpj-read-topic+skip+count))
  (if (dpj-goto-topic 'dp-re-search-forward 'forward-char 
		      skip-current topic-re count skip-re)
      (progn
	;;(dmessage "topic, f>%s<" (dpj-topic-match-string))
	;;(dpj-match-message "topic, f")
	;;(dpj-match-message "topic, f2")
	t)
    nil))

(defun dpj-goto-topic-backward (&optional topic-re skip-current count skip-re)
  "Move backwards to the previous topic."
  (interactive (dpj-read-topic+skip+count))
  (if (dpj-goto-topic 're-search-backward 'backward-char 
		      skip-current topic-re count skip-re)
      (progn
	;;(dmessage "topic, b>%s<" (dpj-topic-match-string))
	t)
    nil))

(defun dpj-position-point-in-new-file (file-delta)
  (if (<= file-delta 0)
      (goto-char (point-max)) ; start at end of prev file
    (goto-char (point-min)) ; or start of next
    ))

(defun dpj-move-with-file-wrap (move-func file-delta &optional topic-re 
					  skip-current count skip-re)
  "Move to the next/prev topic, moving into the next/prev file as needed."
  (interactive)
  (let* ((buf (current-buffer)) 
	 (obuf buf)
	 (pos (point)) 
	 (opos pos)
	 (start-month-num (dp-date-to-month-num))
	 (do-range-checking t)
	 cur-month-num
	 month-diff
	 found-one
	 had-to-visit
	 old-file-name
	 new-file-name)
    ;; @todo ? rework file traversal with xx-noselect versions that only
    ;; set buffer vs move to it.
    (save-excursion
      (setq found-one
	    (catch 'done
	      (while (not (funcall move-func topic-re skip-current count 
				   skip-re))
		;;(dmessage "trying %s buf" file-delta)

		(when (or (eq 0 file-delta)
			  (dpj-non-standard-journal-p))
		  (message "No more notes in non-standard file.")
		  ;;(ding)
		  (throw 'done nil))

		(setq cur-month-num (+ (dpj-journal-name-to-month-num)
				       file-delta))

		(message "start-mon: %s, cur-mon-num: %s, journal-mon: %s"
			 start-month-num
			 cur-month-num (dpj-journal-name-to-month-num))

		(setq old-file-name (buffer-file-name))
		(when had-to-visit
		  (kill-this-buffer))

		(setq month-diff (abs (- start-month-num cur-month-num)))
		(when (and do-range-checking
			   (> month-diff dpj-file-wrap-limit))
		  (message 
		   "No more notes: file history limit exceeded(files scanned: %s, max: %s)."
		   month-diff dpj-file-wrap-limit)
		  (ding)
		  (throw 'done nil))

		(unless (setq new-file-name 
			      (dpj-next-journal-file file-delta 'must-exist
						     old-file-name))
		  (message "No more notes: no more note files for topic `%s'."
			   topic-re)
		  (ding)
		  (throw 'done nil))
		(setq had-to-visit (cdr new-file-name))
		(dpj-position-point-in-new-file file-delta)
		)
	      ;; we found a match, save position info
	      (setq dpj-found-a-match t)
	      (setq buf (current-buffer) pos (point))
	      ;;(dmessage "mwfw: t")
	      (throw 'done t))))
    ;;(dmessage "found-one>%s<" found-one)
    (when found-one
;      (let ((marker (make-marker)))
;	(set-marker marker opos obuf)
;	(dp-push-go-back marker))
      (unless (eq buf obuf)
	(ding)
	(message "wrapped to new file: %s (topic: %s)" 
		 (car new-file-name) topic-re)))
    (switch-to-buffer buf)
    (goto-char pos)))

(defun dpj-goto-topic-backward-with-file-wrap (&optional topic-re 
							 skip-current count
							 skip-re)
  "Move backward to the previous topic, moving into the previous file when appropriate."
  (interactive (dpj-read-topic+skip+count))
  (let ((topic (or topic-re dpj-show-topic-topic)))
    (when dpj-show-topic-topic
      (message "using show topic `%s'" dpj-show-topic-topic))
    (dpj-move-with-file-wrap 'dpj-goto-topic-backward -1 
			     topic
			     skip-current count skip-re))
  (dp-set-zmacs-region-stays t))

(defun dpj-goto-topic-forward-with-file-wrap (&optional topic-re 
							skip-current count
							skip-re)
  "Move forward to the next topic, moving into the next file when appropriate."
  (interactive (dpj-read-topic+skip+count))
  (let ((topic (or topic-re dpj-show-topic-topic)))
    (when dpj-show-topic-topic
      (message "using show topic `%s'" dpj-show-topic-topic))
    (dpj-move-with-file-wrap 'dpj-goto-topic-forward 1
			     topic
			     skip-current count skip-re))
  (dp-set-zmacs-region-stays t))

(defun dpj-xxx-in-topic (move-func file-delta &optional topic-re)
  "Move using MOVE-FUNC within topic."
  (interactive)
  (if topic-re
      (setq dpj-next-in-topic-topic topic-re))
  (let ((topic (or dpj-next-in-topic-topic 
		   (concat "^" (car (dpj-current-topic-or-todo)) "$"))))
    (message "move in %s topic `%s'" 
	     (if dpj-next-in-topic-topic "persistent" "")
	     topic)
    (dpj-move-with-file-wrap move-func file-delta topic))
  (dp-set-zmacs-region-stays t))


(defun dpj-get-topic-or-clear-def-topic (&optional faux-prefix-arg)
  (list
   (let ((prefix-arg (or current-prefix-arg faux-prefix-arg)))
     (if (not prefix-arg)
	 nil
       (let ((pval (prefix-numeric-value prefix-arg)))
	 (if (= pval 4)
	     (car (dpj-get-topic-interactive))
	   (setq dpj-next-in-topic-topic nil)
	   nil))))))

(defun dpj-next-in-topic (&optional topic-re)
  "Goto next matching topic.  If we have highlighted some topics, then
we move to the next matching in that set.  Otherwise, we go to the
next topic that matches the current topic."
  (interactive (dpj-get-topic-or-clear-def-topic))
  (dpj-xxx-in-topic 'dpj-goto-topic-forward 1 topic-re))

(defun dpj-prev-in-topic (&optional topic-re)
  "Like `dpj-next-in-topic' only previous."
  (interactive (dpj-get-topic-or-clear-def-topic))
  (dpj-xxx-in-topic 'dpj-goto-topic-backward -1 topic-re))

(defun dpj-prev-in-topic-menu-command ()
  "Service menu command."
  (interactive)
  (apply 'dpj-prev-in-topic (dpj-get-topic-interactive)))

(defun dpj-next-in-topic-menu-command ()
  "Service menu command."
  (interactive)
  (apply 'dpj-next-in-topic (dpj-get-topic-interactive)))

(defun dpj-find-todo (direction set-topic)
  "Find the prev todo in the files."
  (cond 
   ((or (equal set-topic '(4))		; 1 C-u
	(eq set-topic 'set-topic))
    (setq dpj-next-in-topic-topic (dpj-read-topic)))
   ((or (equal set-topic '(16))		; 2 C-u
	(eq set-topic 'clear-topic))
    (setq dpj-next-in-topic-topic nil)))
  (cond
   ((eq direction 'forward)
    (dpj-move-with-file-wrap 'dpj-goto-todo-or-ai-forward 1 dpj-todo-re))
   ((eq direction 'forward-no-wrap)
    (dpj-move-with-file-wrap 'dpj-goto-todo-or-ai-forward 0 dpj-todo-re))
   ((eq direction 'backward)
    (dpj-move-with-file-wrap 'dpj-goto-todo-or-ai-backward -1 dpj-todo-re))
   ((eq direction 'backward-no-wrap)
    (dpj-move-with-file-wrap 'dpj-goto-todo-or-ai-backward 0 dpj-todo-re))
   (t (message "Bad direction(%s) in dpj-find-dodo" direction))))

(defun dpj-prev-todo (topic-flag)
  "Move backwards to the previous todo item."
  (interactive "P")
  (dpj-find-todo 'backward topic-flag))

(defun dpj-next-todo (topic-flag)
  (interactive "p")
  (dpj-find-todo 'forward topic-flag))

(defun dpj-next-todo-this-file (topic-flag)
  (interactive "p")
  (dpj-find-todo 'forward-no-wrap topic-flag))

(defun dpj-find-topics (&optional topic-re pos skip-re no-markers-p)
  "Visit all topics.  Return two lists, matching and not-matching TOPIC-RE.
Each list element is a list:
\(topic-string record-start topic-start record-end\)
@todo may want to cache these based on args and file's last mod time."
  (interactive)				;@todo at least during testing
  (when (memq skip-re '(t skip-todos))
    ;;(dmessage "got skip-re t")
    (setq skip-re dpj-todo/done-re))
  (save-excursion
    (goto-char (or pos (point-min)))
    ;; return list (list-of-matching-topics list-of-unmatching-topics)
    (if (not topic-re)
	(setq topic-re ".*"))
    (let ((not-done t) 
	  matching-list unmatching-list match-or-not
	  last-entry topic-start rec-start topic skip) 
      ;;(dmessage "dpj-find-topics: topic-re>%s<" topic-re)
      (while not-done
	;;(dmessage "loop start")
	(setq not-done (dpj-goto-topic-forward))
	(setq topic (if not-done
			(dpj-topic-match-string)
		      nil))
	(setq skip (and skip-re
			(and topic
			     (string-match skip-re topic))))
	(if (and (not skip) 
		 not-done)
	    (setq rec-start (dpj-topic-match-beginning 0)
		  topic-start (dpj-topic-match-beginning))
	  (setq rec-start (dp-mk-marker (1+ (point-max)))
		topic-start nil))
	;;(dmessage "not-done>%s< skip>%s< rec-start>%s< mtop>%s<" 
	;;	  not-done skip rec-start topic)
	(when (and last-entry
		   (or (not skip)
		       (not not-done)))
	  ;; handle stuff from previous itertion
	  ;;(dmessage "finish last-entry>%s<" last-entry)
	  ;; end of previous rec is beginning of next-1
	  (setq last-entry 
		(append last-entry (list (1- rec-start))))
          (unless no-markers-p
            (setq last-entry (list (nth 0 last-entry)
                                   (dp-mk-marker (nth 1 last-entry))
                                   (dp-mk-marker (nth 2 last-entry))
                                   (dp-mk-marker (nth 3 last-entry)))))
	  (if match-or-not
	      (setq matching-list (append matching-list 
					  (list last-entry)))
	    (setq unmatching-list (append unmatching-list 
					  (list last-entry))))
	  ;;(dmessage "ml>%s<, uml>%s<" matching-list unmatching-list)
	  )
	(when (and (not skip)
		   not-done)
	  ;;(dmessage "set up next")
	  ;; set up stuff for next iteration
	  (setq match-or-not (string-match topic-re topic))
	  ;;(dmessage "m-or-n>%s<" match-or-not)
	  (setq last-entry (list topic 
				 rec-start 
				 topic-start)))
	)
      ;;(dmessage "F:ml>%s<, uml>%s<" matching-list unmatching-list)
      (cons matching-list unmatching-list))))

;; Need this shim to match the signature of `dpj-highlight-region'
(defun dpj-kill-topic-record (start end op)
  (funcall op start end))

(defun dpj-process-topics (topic-re match-op others-op keep-others 
				    &optional skip-re no-contig)
  "Process items matching TOPIC-RE.  Process matching entries with
MATCH-OP, non-matching entries with OTHERS-OP.  KEEP-OTHERS if
non-nil says to not reset all highlighting before proceeding."
  (setq dpj-last-process-topics-args 
	(list topic-re match-op others-op keep-others skip-re no-contig))
  (if keep-others
      ;; merge the new regexp with the existing one.
      (setq dpj-next-in-topic-topic 
	    (dp-re-concat dpj-next-in-topic-topic topic-re))
    (setq dpj-next-in-topic-topic topic-re))
  ;; partition topics into matching and unmatching lists
  (let* ((lists (dpj-find-topics dpj-next-in-topic-topic nil skip-re))
	 (match-list (car lists))
	 (other-list (cdr lists))
         ;; @todo XXX factor something like this out.
         (processor (if (memq match-op '(delete-region kill-region))
                        'dpj-kill-topic-record
                      'dpj-highlight-region)))

    ;; apply match op to matching list
    (dolist (topic-info match-list)
      ;;(dmessage "show, topic-info>%s<" topic-info)
      (funcall processor (dpj-topic-info-record-start topic-info)
               (dpj-topic-info-end topic-info)
               match-op))

    ;; process contiguous unmatching topics as a unit.
    ;; this makes the hidden stuff appear as a single instance of
    ;; the `invisible-text-glyph'
    (let ((start nil)
	  (end nil)
	  tstart tend)
      (dolist (topic-info other-list)
	(setq tstart (dpj-topic-info-record-start topic-info))
	(setq tend   (dpj-topic-info-end topic-info))
	(if (null start)
	    (progn
	      (setq start tstart
		    end tend))
	  ;; start is not nil, see if current is contig w/last
	  ;; if so, move end to end of current
	  (if (and (not no-contig)
		   (= (1+ end) tstart))
	      (setq end tend)
	    ;; otherwise, process previous contig block
	    ;;(dmessage "show, topic-info>%s<" topic-info)
	    (dpj-highlight-region start end others-op)
	    (setq start tstart
		  end tend))))

      ;; handle the last item
      (when start
	(dpj-highlight-region start end others-op)))))

(defun dpj-re-process-topics (args)
  (interactive)
  (if args
      (apply 'dpj-process-topics args)
    (unless dpj-next-in-topic-topic
      (dpj-show-all))))

(defun dpj-hook-set-buffer ()
  (defadvice set-window-buffer (after dp-maybe-re-process-topics activate)
    "Re-process topics when switching to a journal mode buffer."
    (dpj-handle-set-window-buffer dpj-last-process-topics-args)))

(defun dpj-unhook-set-buffer ()
  ;;(ad-unadvise 'set-window-buffer)
  (ad-remove-advice 'set-window-buffer 'after 'dp-maybe-re-process-topics))

(defsubst dpj-journal-mode-p ()
  (eq major-mode 'dp-journal-mode))

(defsubst dpj-handle-set-window-buffer (args)
  (interactive)
  ;;(dmessage "in dpj-maybe-re-process-topics, mm>%s<" major-mode)
  (when (eq major-mode 'dp-journal-mode)
    (dpj-set-current-journal-file (buffer-file-name))
    (dpj-re-process-topics args)))

(defun dpj-read-topic-n-flag (&optional topic-re)
  "Read a topic/re, using only this file's topics for completion.
Return a list of the chosen topic/re and the current-prefix-arg."
  (list (dpj-read-topic (car (dpj-find-topics topic-re))
			    topic-re)
	current-prefix-arg))

(defun dpj-highlight-topic (&optional topic-re keep-others skip-re)
  "Highlight the matching topics by giving them `dp-journal-selected-face'."
  (interactive (dpj-read-topic-n-flag))
  ;;(dmessage "topic-re>%s<" topic-re)
  (dpj-process-topics topic-re 'highlight 'lowlight keep-others skip-re))

(defun dpj-kill-topic-records (&optional topic-re keep-others skip-re)
  "Kill the matching topics."
  (interactive (dpj-read-topic-n-flag))
  ;;(dmessage "topic-re>%s<" topic-re)
  (dpj-process-topics topic-re 'kill-region 'nop keep-others skip-re)
  (setq dpj-last-process-topics-args nil))

(defun dpj-delete-topic-records (&optional topic-re keep-others skip-re)
  "Delete the matching topics."
  (interactive (dpj-read-topic-n-flag))
  ;;(dmessage "topic-re>%s<" topic-re)
  (dpj-process-topics topic-re 'delete-region 'nop keep-others skip-re)
  (setq dpj-last-process-topics-args nil))

(defun dpj-show-topic (&optional topic-re keep-others skip-re)
  "Show matching topics, hiding all others."
  (setq dpj-show-topic-topic topic-re)
  (dpj-process-topics topic-re 'show 'hide keep-others skip-re)
  (message "Now showing: %s" topic-re))

(defun dpj-show-topic-command (&optional topic-re keep-others)
  (interactive (dpj-read-topic-n-flag))
  (dpj-show-topic topic-re keep-others 'skip-todos))

;;;; topic list stuff

(defvar dpj-topic-list nil
  "Global topic list.")

(defvar dpj-topic-list-read-time nil
  "Time we last read the global topic list.")

(defvar dpj-topic-file-name "journal-topics")
(defvar dpj-topic-buffer-name (concat "*" dpj-topic-file-name "*"))
(defvar dpj-topic-file (format "%s/%s" dp-note-base-dir dpj-topic-file-name)
  "Global topic file")
(defvar dpj-local-pdict (format "%s/%s" dp-note-base-dir "j-dict")
  "Global topic file")
(defvar dpj-topic-file-id-magic ";; dp-journal topics file")
(defvar dpj-topic-file-id-magic-OLDE ";; topics")

(defun dpj-topic-file-mod-time ()
  "Return the topic file's modification time.
Also, will create the topic file if it does not exist."
  (let ((fmod (file-attributes dpj-topic-file)))
    (unless fmod
      ;; no file... create it
      ;; 
      (dpj-write-topic-file)
      (setq fmod (file-attributes dpj-topic-file)))
    (nth 5 fmod)))

(defun dpj-topic-file-newer (&optional than-time)
  "Determine if the topic file has changed since we last read it."
  (not (equal (dpj-topic-file-mod-time) 
	      (or than-time 
		  dpj-topic-list-read-time))))

;; grabbed from etags.el
(defun dpj-visit-topic-file ()
  "Visit the buffer containing the global topics.  Reread it if it changed
on disk."
  (set-buffer (or (get-file-buffer dpj-topic-file)
		  (find-file-noselect dpj-topic-file)))
  (rename-buffer dpj-topic-buffer-name)
  (unless (verify-visited-file-modtime (get-file-buffer dpj-topic-file))
    (revert-buffer t t)))

(defun dpj-read-topic-list ()
  "Read the global topic list into a lisp variable."
  (save-excursion
    (dpj-visit-topic-file)
    ;; Here, the specificity is good since we're ID'in the file.
    (goto-line 2)
    (if (or (search-forward dpj-topic-file-id-magic (line-end-position) t)
            (and (search-forward dpj-topic-file-id-magic-OLDE 
                                 (line-end-position) t)
                 (dp-ding-and-message "Found old topic file ID line.")))
        (eval-region (point-min) (point-max))
      (dp-ding-and-message "Not eval'ing topic file."))))

(defun dpj-get-topic-file-list ()
  "Get the global topic list, re-reading the topic file if needed."
  (if (or (not dpj-topic-list-read-time)
	  (dpj-topic-file-newer))
      (progn
	(dpj-read-topic-list)
	(setq dpj-topic-list-read-time (dpj-topic-file-mod-time))))
  dpj-topic-list)

(defvar dpj-last-written-topic-list nil
  "A copy of the last written list so we can avoid writing.")

(defun dpj-topic< (s1 s2)
  (string< (car s1) (car s2)))

(defun dpj-topic-date< (s1 s2)
  (string< (plist-get (cdr s1) 'last-update:)
           (plist-get (cdr s2) 'last-update:)))

(defun dpj-write-topic-file ()
  "Save the topic-list into the topic file."
  (save-excursion
    ;;(dmessage "lwl>%s<" dpj-last-written-topic-list)
    ;;(dmessage " tl>%s<" dpj-topic-list)
    (dpj-visit-topic-file)
    (setq dpj-topic-list (delq nil 
                               (mapcar 
                                (function
                                 (lambda (el)
                                   ;;(dmessage "el>%s<" el)
                                   (if (string-match dpj-private-topic-re 
                                                     (car el))
                                       nil
                                     el)))
                                dpj-topic-list)))
;;    (setq dpj-topic-list (delq nil dpj-topic-list))
    (if dp-journal-sort-topics-p
	(setq dpj-topic-list (sort dpj-topic-list 'dpj-topic<)))

    (when (or (not (equal dpj-last-written-topic-list dpj-topic-list))
	      dpj-abbrev-list-modified-p)
      (dp-erase-buffer)
      (insert ";; -*-emacs-lisp-*-\n")
      (insert dpj-topic-file-id-magic "\n")
      (let ((standard-output (current-buffer)))
	(pp `(setq dpj-topic-list (quote ,dpj-topic-list))))
      (insert "\n; topic abbrevs\n")
      (insert-abbrev-table-description 'dpj-topic-abbrev-table)
      (set-buffer-modified-p t)
      (write-region (point-min) (point) dpj-topic-file nil 1)
      (set-buffer-auto-saved)
      (set-buffer-modified-p nil)
      (if (buffer-file-name) 
	  (set-visited-file-modtime))
      
      ;; this should be OK due to the way we add elements to the topic list.
      (setq dpj-last-written-topic-list dpj-topic-list)
      (setq dpj-abbrev-list-modified-p nil)
      (setq dpj-topic-list-read-time (dpj-topic-file-mod-time)))))

(defun dpj-merge-all-topics (&optional list write-em)
  "Merge all of the topics into a single list.
Merges topics from the global topic-file as well as any found in the
current file.  If WRITE-EM is non-nil, write the list to the topic-file."
  (interactive)
  (let ((local-list (or list 
			(car (dpj-find-topics)))))
    (dpj-get-topic-file-list)
    ;; grab just the topics from the find-topics list.
    ;; save the topics as a list of lists '(("topic1") ("topic2")...))
    ;; since completing read wants to use the car of each list
    ;; element.
    ;; add *all* topics to the topic-list, including todos and 
    ;; local topics.  Filter the latter two from the write list
    (mapcar (function 
	     (lambda (el)
	       ;;(dmessage "el>%s<" el)
	       (let* ((key (car el))
		      (topic (list key)))
		 ;; this needs to compare only CARs < not true anymore.
		 (dp-add-item-or-update-alist 'dpj-topic-list topic 
                                              :update-p 'rem-add 
                                              :keep-old-if-nil-p t)
		 (if (string-match dpj-private-topic-re key)
		     nil
		   topic))))
	    local-list)
    (when write-em
      (dpj-write-topic-file))))

(defun dpj-mk-topic-completion-list (&optional pos)
  "Make a topic completion list."
  (interactive)
  ;; just the list of matching topics, since completing-read
  ;; uses the car of each element
  (dpj-merge-all-topics)
  dpj-topic-list)

(defvar dpj-topic-history '()
  "History of entered topics.")

(defvar dpj-view-topic-buffer-name "*dpj-view-topic*"
  "Name of topic viewing buffer.")

(defun* dpj-read-topic (&optional topics-in topic-re req-match no-def-topic
                        (prompt-format-string "topic%s: "))
  "Read topic[/re] from minibuffer.
REQ-MATCH means user must select from the available choices."
  ;; must call `dpj-mk-topic-completion-list' first since it
  ;; ensures that the topic list and abbrev table are up to date.
  (let* ((topics (or topics-in (dpj-mk-topic-completion-list)))
	 (dp-minibuffer-abbrev-table dpj-topic-abbrev-table)
	 (dp-minibuffer-mark-line-p t))
    (completing-read (format prompt-format-string (if req-match "" "/re"))
		     topics
		     nil req-match 
		     (if no-def-topic () 
		       (or topic-re
			   (dpj-current-topic nil 'no-quote)))
		     'dpj-topic-history)))

(defsubst dpj-get-topic-interactive (&optional topics topic-re req-match 
					       no-def-topic)
  "Get a topic name, interactively with completion.  Use TOPICS if
non-nil otherwise get the current list topics."
  (list
   (dpj-read-topic topics topic-re req-match no-def-topic)))

(defun dpj-update-topic-list (topic)
;;  (interactive "stopic: ")
  (interactive (dpj-get-topic-interactive))
  (let ((topic-l (list topic 'last-update: (dp-timestamp-string))))
    ;; topic list looks: '(("topic" "extra-info, like date") ("top2" "xxx"))
    (dp-add-item-or-update-alist 'dpj-topic-list topic-l :update-p 'rem-add)))
;;    (dp-add-to-alist-if-new-key 'dpj-topic-list topic-l)))

(defun dpj-short-timestamp ()
  (interactive)
  (beginning-of-line)
  (unless (looking-at "^$")
    (end-of-line)
    (insert "\n"))
  (insert "=======" (dp-timestamp-string) "=======\n"))

(defun dpj-no-spaced-append-p (&optional force-p)
  "Determine if we want to add new topics at eof after a blank line."
  (or force-p
      current-prefix-arg))

(defun* dpj-new-topic0 (&key topic no-spaced-append-p private-p)
  (if (and private-p
	   (not (dpj-is-private-topic-p topic)))
      (setq topic (dpj-make-private-topic topic)))
  (unless topic
    (setq topic (car (dpj-get-topic-interactive))))
  (unless (or 
	   no-spaced-append-p
	   (dpj-no-spaced-append-p))
    (dp-set-eof-spacing 2 (dpj-new-topic-insertion-point)))
  (when (not (string= topic ""))
    ;; @todo make new, full ts if date is different.
    (if nil ;; (equal topic (dpj-current-topic nil 'no-re-quote))
        ;; short timestamps don't work well when there are many within a single
        ;; record.  This makes it hard to jump back to a particular point that
        ;; was significant enough to be marked with a cxc.  Another ?better? 
        ;; solution is to include short topics in the topic scans.
        (dpj-short-timestamp)
      (dp-timestamp nil nil topic 'v2))
    (dpj-update-topic-list topic)
    (insert "\n")
    (backward-char)))


(defun dpj-remove-topic (topic)
  "Remove the given topic from the topic list."
  (interactive (list (dpj-read-topic)))
  (remove-alist 'dpj-topic-list
                (or (and (eq topic 'current-topic-p)
                         (current-topic))
                    topic)))
(dp-defaliases 'dpj-kill-topic 'dpj-nuke-topic 'dpj-delete-topic
               'dpj-rm-topic 
               'kill-topic 'nuke-topic 'delete-topic
               'rm-topic
               'dpj-remove-topic)
   
(defun dpj-get-and-insert-topic ()
  (interactive)
  (insert (dpj-read-topic)))

(defun dpj-get-and-replace-current-topic (&optional remove-from-topic-list-p)
  (interactive)
  (let* ((new-topic (dpj-read-topic))
	 (cur-topic-bounds (dpj-current-topic-boundaries))
	 (start (car cur-topic-bounds))
	 (end (cdr cur-topic-bounds)))
    (when remove-from-topic-list-p
      (dpj-remove-topic (dpj-current-topic)))
    (save-excursion
      (kill-region start end)
      (goto-char start)
      (insert new-topic))
    (dpj-update-topic-list new-topic)))
(defalias 'dpj-ren-topic 'dpj-get-and-replace-current-topic)
(defalias 'dpj-mv-topic 'dpj-get-and-replace-current-topic)
(defalias 'dpj-repl-topic 'dpj-get-and-replace-current-topic)

(defun dpj-extract-a-record (record-info buffer)
  (buffer-substring 
   (dpj-topic-info-record-start record-info)
   (dpj-topic-info-end record-info)
   buffer))

(defun dpj-view-topic-visit-real-topic ()
  (interactive)
  (let* ((extent (car (extents-at (point) nil 'dpj-view-topic)))
	 ;;(boo (dmessage "props>%s<" (extent-properties extent)))
	 (file (get extent 'dpj-source-file))
	 (pos (get extent 'dpj-source-start)))
    (dpj-edit-journal-file file 'must-exist)
    (goto-char pos)))

(defvar dpj-view-topic-keymap nil)
(setq dpj-view-topic-keymap (make-keymap))
(define-key dpj-view-topic-keymap [(ctrl) ?m] 'dpj-view-topic-visit-real-topic)
(define-key dpj-view-topic-keymap [?v] 'dpj-view-topic-visit-real-topic)
(define-key dpj-view-topic-keymap [(meta ?.)] 'dpj-view-topic-visit-real-topic)
(define-key dpj-view-topic-keymap [?q] 'kill-this-buffer)
(define-key dpj-view-topic-keymap [?Q] 'kill-this-buffer)
(define-key dpj-view-topic-keymap [?x] 'kill-this-buffer)
(define-key dpj-view-topic-keymap [?X] 'kill-this-buffer)

(defun dpj-switch-to-view-buf (&optional view-buffer)
    (switch-to-buffer (or view-buffer dpj-view-topic-buffer-name))
    (set-buffer-modified-p nil)
    (toggle-read-only 1)
    (dp-journal-mode)
    (setq dpj-non-standard-journal-p t)
    (dp-define-buffer-local-keys '([(meta ?-)] dp-maybe-kill-this-buffer)
                                 nil nil nil "dstvb")
    (message "Visit real topic w/C-m, v or M-.; Type q to quit."))

(defun dpj-view-topic-list (topics &optional buf-name-in visit-p 
				   init-buffer-p src-buffer)
  "View a list of topics in a view-buf.
The buf is read-only.  It uses the following keymap:
\\{dpj-view-topic-keymap}"
  (let* ((buf-name (or buf-name-in dpj-view-topic-buffer-name))
	 (buffer (get-buffer-create buf-name))
	 (jfile-name (buffer-file-name))
	 new-start
	 new-end
	 new-extent
	 (source-file (buffer-file-name))
	 (source-buffer (or src-buffer (current-buffer))))

    (with-current-buffer buffer
      (when init-buffer-p
	(toggle-read-only 0)
	(dp-erase-buffer))

      ;; do we want to do this for buffers w/no matches?
      (dpj-new-topic0 :topic (format "*** Journal File: %s" jfile-name) 
		      :no-spaced-append-p nil 
		      :private-p 'dpj-private-topic-re)
      (insert "\n")
      (dolist (topic-info topics)
	(setq new-start (point))
	(insert (dpj-extract-a-record topic-info source-buffer))
	(setq new-end (point))
	(dp-make-extent new-start new-end
			'dpj-view-topic
			'dpj-source-file source-file
			'dpj-source-start (dpj-topic-info-topic-start 
					   topic-info)
			'keymap dpj-view-topic-keymap)
	(insert "\n")
	))
    (if visit-p
	(dpj-switch-to-view-buf buffer))))

(defun dpj-find-for-view-topic (topic-re &optional src-buffer)
  "Extract topics from current-buffer and insert into view-buffer."
  (interactive (dpj-get-topic-interactive))
  (car (dpj-find-topics topic-re)))

(defun dpj-read-num-and-topic (&optional num-prompt get-re2 num-default no-re1)
  (interactive)
  (setq-ifnil num-prompt "Number")
  (let ((n-prompt (concat num-prompt
			  (if num-default 
			      (format "(%d)" num-default)
			    "")
			  ": ")))
    (delq nil (list
	       (dp-read-number n-prompt 'integers-only 
			       (or num-default 1))
               (unless no-re1
                 (dpj-read-topic))
               (if get-re2
                   (read-string get-re2)
                 nil)
               ))))

(defun dpj-create-view-buf (buf-name)
  (let ((buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (setq dpj-non-standard-journal-p t))
    buf))

(defun dpj-view-topics (number-of-months topic-extractor extractor-args
					 &optional dont-visit)
"View topics matching specified criteria in a dedicated view buffer.
NUMBER-OF-MONTHS tells how many months back from the current journal to search.
TOPIC-EXTRACTOR is a function called with EXTRACTOR-ARGS as each journal
file is visited.  It is expected to return a list of topic-info records.
Each list is inserted into the view buffer.
DONT-VISIT says not to make the view-buffer the current buffer before
returning."
  (unless (numberp number-of-months)
    (setq number-of-months 'all))
  (if (= number-of-months 0)
      (setq number-of-months 1))
  ;; use a copy of dpj-current-journal-file so we don't change it.
  (let* ((dpj-current-journal-file (dpj-current-journal-file))
	 (latest-file (or dpj-current-journal-file
			  (dpj-latest-note-file-name)))
	 (latest-month-num (dpj-journal-name-to-month-num latest-file))
	 (oldest-month-name (- latest-month-num (1- number-of-months)))
	 (jmon oldest-month-name)
	 (view-buf-name dpj-view-topic-buffer-name)
	 (view-buffer (dpj-create-view-buf dpj-view-topic-buffer-name))
	 (num_matches 0)
	 tlist
	 already-loaded
	 jfile)
    
    (with-current-buffer view-buffer
      (toggle-read-only 0)
      (dp-erase-buffer)
      (dpj-new-topic0 :topic 
                      (format "*** Visiting topic %s, from the last %d months" 
			      topic-re number-of-months)
		      :no-spaced-append-p nil
		      :private-p 'dpj-make-topic-private))
    
    (dotimes (n number-of-months)
      (setq jfile (dpj-month-num-to-journal-name jmon))
      (setq jmon (1+ jmon))
      (setq already-loaded (get-file-buffer jfile))

      (when (dpj-edit-journal-file jfile 'must-exist)
	(setq tlist (apply topic-extractor extractor-args))
	(dpj-view-topic-list tlist)
	(setq num_matches (+ num_matches (length tlist)))
	(unless already-loaded
	  (kill-this-buffer)))
      )

    (with-current-buffer view-buffer
      (dpj-new-topic0 :topic 
       (format "*** End of topics matching %s, from the last %d months" 
	       topic-re number-of-months)
       :no-spaced-append-p nil
       :private-p 'dpj-make-topic-private))
    (unless dont-visit
      (dpj-switch-to-view-buf view-buffer))
    (if (> num_matches 0)
	(message "Found %d matches" num_matches)
      (message "*** No matches ***"))
    ))

(defun dpj-view-topic-history (number-of-months topic-re)
  "View all topics in preceding NUMBER-OF-MONTHS files matching TOPIC-RE in a view-buf."
  (interactive (dpj-read-num-and-topic "Number of months" nil 1))
  (dpj-view-topics number-of-months 
		   'dpj-find-for-view-topic
		   (list topic-re)))

(defun dpj-insert-sticky-variables-hack ()
  "Create a local variables hack block that make a journal sticky when it loads."
  (interactive)
  (dp-insert-local-variables-hack 
   '("eval: (dpj-stick-current-journal-file)")))

;;;###autoload
(defun* dpj-grep-and-view-hits (number-of-months topic-re grep-re 
                                &optional 
                                (continue-from-last-p nil cflp-set-p))
  "Grep topics for regexp and view in view buf.
Search NUMBER-OF-MONTHS files back in time.
Search topics matching TOPIC-RE for GREP-RE.
View all records with matches in a view buf.
START-WITH-CURRENT-JOURNAL-P \(interactively the prefix-arg) says to start
the search with the current journal file."
  (interactive (dpj-read-num-and-topic "Number of months" "grep expr: "))
  (let ((x-args (list grep-re topic-re nil 'just-remember-records))
        (rewind-p (if cflp-set-p 
                        continue-from-last-p 
                      (not current-prefix-arg))))
    (when rewind-p
      (dpj-tidy-journals-keep))
    (dpj-view-topics number-of-months 
		     'dpj-grep-bodies
		     x-args
		     'dont-visit)
    (set-buffer dpj-view-topic-buffer-name)
    ;; switch to view buffer and highlight all the matches.
    (if (not (or (string= grep-re "")
                 (string= grep-re ".")
		 (string= grep-re ".*")))
	(save-excursion
	  (dp-beginning-of-buffer)
	  (while (dp-re-search-forward grep-re nil t)
	    (dp-make-extent (match-beginning 0) (match-end 0) 
			    'dpj-view-topic
			    'face 'dpj-view-grep-hit-face))))
    (dpj-switch-to-view-buf)))

;;;###autoload
(defalias 'gv 'dpj-grep-and-view-hits)
;;;###autoload
(defalias 'dg 'dpj-grep-and-view-hits)
;;;###autoload
(defalias 'jg 'dpj-grep-and-view-hits)
;;;###autoload
(defalias 'dpj-grep 'dpj-grep-and-view-hits)

(defun dpj-list-topic (num-months topic-re)
  "List all records matching TOPIC-RE for NUM-MONTHS.
Simple front end w/1 less parameter.
Also will use prefix-arg as default NUM-MONTHS."
  (interactive (dpj-read-num-and-topic 
		"Num-months" 
		nil
		(setq x890 (prefix-numeric-value current-prefix-arg))
		))
  ;;(dmessage "pnv>%d<, x>%d<" (prefix-numeric-value prefix-arg) x890)
  (let ((current-prefix-arg nil))
    (dpj-grep-and-view-hits num-months topic-re ".")))

(defalias 'lt 'dpj-list-topic)


(defun dpj-find-todos-for-view-topic ()
  "Find todos in the current file and return a list of topic-info records."
  (let (rec-list
	opos
	rec-bounds)
    (goto-char (point-min))
    (catch 'done
      (while t
	(setq opos (point))
	(dpj-next-todo-this-file nil)
	(if (= opos (point))
	    (throw 'done nil))
	(setq rec-bounds (dpj-current-record-boundaries))
	(message "rec-bounds>%s<" rec-bounds)
	;;topic-info:: (topic-string record-start topic-start record-end)
	(setq rec-list (cons 
			(cons "topic-not-used" rec-bounds) 
			rec-list))
	(goto-char (nth 2 rec-bounds))))
    (nreverse rec-list)))

(defun dpj-view-todos (number-of-months)
  "View all todos in preceding NUMBER-OF-MONTHS files in a view-buf."
  (interactive (list (dp-read-number
		      "Number of months(1): " 'integers-only "1")))
  (let ((topic-re "n/a"))		;remove use of topic-re in view code
    (dpj-view-topics number-of-months 
		     'dpj-find-todos-for-view-topic
		     nil)))

(defun dpj-insert-matching-topics (topic-re)
  (dolist (topic (dpj-get-topic-file-list))
    (if (string-match topic-re (car topic))
	(insert (car topic) "\n"))))

(defun dpj-grep-topic-list (topic-re)
  "Search topics in topic list for regexp.  Present results in a buffer."
  (interactive "sTopic re: ")
  (let* ((key-map (make-keymap)))
    (define-key key-map [return] (kb-lambda 
                                   (let ((topic (dp-copy-to-end-of-line
                                                 'from-beginning)))
                                     (kill-this-buffer)
                                     topic)))
    (dp-simple-viewer "*grep topics*"
                      (function 
                       (lambda () ;fill func
                         (dpj-insert-matching-topics topic-re)))
                      nil               ;QUIT-KEYS 
                      nil               ;Q-KEY-COMMAND 
                      key-map)          ;KEY-MAP
    ))
(defalias 'dpj-grep-topics 'dpj-grep-topic-list)
		    
;;;###autoload
(defun dpj-tidy-journals (&optional dont-delete-p)
  "Kill all but the most recent journal buffers."
  (interactive "P")
  (let (latest-journal-buffer
        (latest-journal (dpj-latest-note-file-name)))
    (if (not dont-delete-p)
	(dolist (buf (buffer-list))
	  (set-buffer buf)
	  (when (and (eq major-mode 'dp-journal-mode)
		     (not (string= (buffer-file-name) latest-journal)))
	    (if (buffer-modified-p)
		(if (y-or-n-p (format "Save %s? " (buffer-file-name)))
		    (save-buffer)))
	    (when buf
	      (message "killing %s" (buffer-file-name buf))
	      (kill-buffer buf)))))
    (if (setq latest-journal-buffer (find-buffer-visiting latest-journal))
        (switch-to-buffer latest-journal-buffer)
      (dp-journal nil nil 'visit-latest)
      (dpj-set-current-journal-file latest-journal))
    (dp-push-go-back "dpj-tidy-journals")
    (goto-char (point-max))))

(defalias 'djx 'dpj-tidy-journals)

;;;###autoload
(defun dpj-tidy-journals-keep ()
  (interactive)
  (dpj-tidy-journals 'dont-delete-p))

(defalias 'djn 'dpj-tidy-journals-keep)
(defalias 'dj> 'dpj-tidy-journals-keep)
(defalias 'djc 'dpj-tidy-journals-keep)
(defalias 'djl 'dpj-tidy-journals-keep)

 ;;;###autoload
(defun dpj-chase-link (file-name offset date-string)
  "Follow a link to another note.
 !<@todo XXX Make this put the BM in the most recent journal."
  ;;@todo add notes dir to file-name
  (if (not (string= "/" (substring file-name 0 1)))
      (setq file-name
	    ;; can this be done by the note-file routines in dpmisc?
	    (append-expand-filename (concat dp-note-base-dir "/") file-name)))
  (dp-push-go-back "dpj-chase-link")
  (if (dpj-is-a-journal-p file-name)
      (dpj-edit-journal-file file-name 
			     'must-exist 
			     dp-embedded-lisp-eval@point-prefix-arg)
    (apply (if current-prefix-arg
               'find-file
             'find-file-other-window)
           (list file-name)))
  (dp-sticky-goto-char offset)
  (when (and date-string (not (string= date-string ""))
	     (dpj-is-a-journal-p file-name))
    (goto-char (dpj-get-current-timestamp-pos))
    (unless (search-forward date-string nil t)
      (goto-char (point-min))
      (unless (search-forward date-string nil t)
	(error "Cannot find ds>%s<" date-string)))
    (beginning-of-line)
    (dpj-move-with-file-wrap 'dpj-goto-topic-forward 0)
    ;; if offset is within the current note, go there.
    (if (dpj-pos-in-current-record-p offset)
	(goto-char offset))))

;;; @todo make view-topic-file-list.  

;;; @todo make functions to build topic lists: date ranges, n back from
;;; current.

(defvar dpj-auto-link-distance-frac '(3 . 4))
(defvar dpj-auto-link-distance-lines nil)

(defun dpj-auto-link-by-distance-p (from to &optional frac)
"Determine if we want to auto-link based on distance link would span."
  (unless frac
    (setq frac dpj-auto-link-distance-frac))
  (if (and to from)
      (>= (count-lines to from)
	  (or dpj-auto-link-distance-lines
	      (/ (* (or dp-initial-frame-height (frame-height))
		    (car frac))
		 (cdr frac))))))
		
(defun dpj-age-string (&optional length)
  (interactive)
  (let ((timestamp (dpj-get-current-timestamp)))
    (cond
     ((eq length 'long)
      (format "%s" (dp-delta-t (car timestamp))))
     ((eq length 'short)
      (format "%s" (dp-delta-t (car timestamp) nil 'short))))))

(defun dpj-age ()
  (interactive)
  (message "age: %s" (dpj-age-string 'long)))

(defun dpj-topic-info ()
  (interactive)
  (message "%s, age: %s"
	   (dpj-current-topic dpj-todo/done-re 'no-quote)
	   (dpj-age-string 'short)))

(defun dpj-rec-knote ()
  (interactive)
  )

(defun dpj-raw ()
  "Add `mmm-mode' codes to get raw text (NOT `text' mode!)"
  (interactive)
  ;; @todo parse new region with: mmm-parse-block
  (let (p)
    (insert "{%fundamental%}\n")
    (setq p (point))
    (insert "\n{%/fundamental%}\n")
    (goto-char p)))

;; Make this stop before a possible local variables hack section.
;; My style is:
;; 3x comment start chars, ^L
;; 3x comment start chars, Local Variables:<space>***
;; ...
;; ;; 3x comment start chars, End:<space>***
;; I use ; for comment start
;; ??? goto eof, look back <n-lines> for ^;;; End: ***
;; If found, look back for ;;;^L
;; If found (beginning-of-line) (insert "\n") (previous-line) (beginning-of-line
(defun dpj-new-topic-insertion-point ()
  (save-excursion
    (goto-char (point-max))
    (if (re-search-backward (regexp-quote (dp-mk-local-variables-hack-header))
                            nil t)
        (progn
          (while (re-search-backward "^;" nil t)
            )
          (point))
      (point-max))))

(defun dpj-visit-appropriate-journal-file (topic dir-name)
  "Visit the journal file based on various criteria."
  ;; 1) Map topic to specific file
  ;; 2) Look for cwd/local-notes.jxt (buffer & possibly file in cwd)
  ;; 3) as before.
  ;; Let's see if the topic should live in another file.
  (unless (string= (dpj-current-journal-file)
                   (dpj-latest-note-file-name topic dir-name))
    ;; !<@todo XXX Make a `dp-journal-noselect'.
    (dp-journal other-win-p nil 'visit-latest topic)))

;;;###autoload
(defun dp-add-elisp-journal-entry ()
  (interactive)
  (dpj-new-topic :topic "emacs.elisp")
  (insert "@@ \n")
  (backward-char))

;;;###autoload
(dp-safe-alias 'ee 'dp-add-elisp-journal-entry)

;;;###autoload
(defun* dpj-new-topic (&key topic no-spaced-append-p
                      link-too-p is-a-clone-p
                      other-win-p dir-name)
  "Insert a new topic item.  Completion is allowed from the list of known topics."
  (interactive)
  (dp-push-go-back "dpj-new-topic")
  (let (vbuf 
	cur-topic
	(file-name (buffer-file-name))
	offset
	context-info
	new-record-pos
	timestamp-info)

    (if (and (dpj-journal-mode-p)
	     (> (point-max) 1))
	(progn
	  ;; save position info in case we are making a link.
	  (setq timestamp-info (dpj-get-current-timestamp)
		cur-topic (dpj-current-topic nil 'no-quote)
		context-info (car timestamp-info)))
      (setq context-info ""))
    
    ;; links to journals and non-journals need an offset.
    (setq offset (point))

    ;; Get the "current" topic, `point'-wise from the current journal file.
    (dp-journal other-win-p nil 'visit-latest topic)
    (unless topic
      (setq topic (car (dpj-get-topic-interactive nil cur-topic))))
    (dpj-visit-appropriate-journal-file topic dir-name)
    ;;(goto-char (setq new-record-pos (dpj-new-topic-insertion-point)))
    ;; `dpj-new-topic0' does the moving.
    (dpj-new-topic0 :topic topic :no-spaced-append-p no-spaced-append-p)
    (if (or link-too-p
	    (and is-a-clone-p
		 (or
		  (not (string= file-name (buffer-file-name)))
		  (dpj-auto-link-by-distance-p offset new-record-pos))))
        (prog1
            ;; This link is ???
            (dpj-insert-link file-name offset context-info)
          ;;(dp-add-bookmark-extent file-name offset context-info)
          )
      )))

;;;###autoload
(defun* dpj-new-topic-other-window (&key topic no-spaced-append-p 
                                    link-too-p is-a-clone-p)
  (interactive)
  (dpj-new-topic :topic topic 
                 :no-spaced-append-p no-spaced-append-p 
                 :link-too-p link-too-p 
                 :is-a-clone-p is-a-clone-p
                 :other-win-p 'other-win))


;;;###autoload
(defalias 'cx 'dpj-new-topic-other-window) ;cx -- context switch
;;;###autoload
(defalias 'cx2 'dpj-new-topic-other-window) ;cx -- context switch
;;;###autoload
(defalias 'cx1 'dpj-new-topic)          ;cx -- Context switch, same window.
;;;###autoload
(defalias 'cx0 'dpj-new-topic)          ;cx -- Context switch, same window.
;;;###autoload
(defalias 'cx. 'dpj-new-topic)          ;cx -- Context switch, same window.

;;;###autoload
(defalias 'nt 'dpj-new-topic-other-window) ;nt -- new topic
;;;###autoload
(defalias 'ntc 'dpj-clone-topic) ; cx-clone, cx-continue 
;;;###autoload
(defalias 'nt2 'dpj-new-topic-other-window) ;nt -- new topic
;;;###autoload
(defalias 'nt1 'dpj-new-topic)          ;nt -- new topic
;;;###autoload
(defalias 'nt0 'dpj-new-topic)          ;nt -- new topic

;;;###autoload
(defun dpj-goto-end-of-journal ()
  (interactive)
  (let ((vbuf (dp-journal nil 'goto-eof 'visit-latest)))
    (dp-journal nil 'goto-eof 'visit-latest)
    (unless vbuf
      (dp-set-auto-mode))))

;;;###autoload
(defalias 'eoj 'dpj-goto-end-of-journal)

(defun dpj-todo (todo)
  "Insert a new todo."
  (interactive "stodo: ")
  (let ((topic (format "%s%s" dpj-todo-str todo)))
    (dp-timestamp nil nil topic)))

(defun dpj-get-topic-and-ai-start (&optional skip-re skip-current)
  "Return a cons of the preceding todo and action-item."
  (cons (or (dpj-get-current-topic-start skip-re)
	    (point-min))
	(or (dpj-find-action-item-backwards t skip-current)
	    (point-min))))

(defsubst dpj-not-a-todo (unused-arg topic-str)
  (interactive)
  (not (string-match dpj-todo-re topic-str)))

(defun dpj-todo-complete (done-str done-delim ai-res &optional timestamp-ai-p)
  (let* ((td.ai (dpj-get-topic-and-ai-start 'dpj-not-a-todo))
	 (topic-start (car td.ai))
	 (ai-start (cdr td.ai)))
    ;;(dmessage "ts>%s<, as>%s<" topic-start ai-start)
    (if (>= ai-start topic-start)
	(dpj-resolve-action-item ai-res timestamp-ai-p)
      ;;(dpj-goto-current-topic-start)
      (goto-char (car td.ai))
      (beginning-of-line)
      (insert done-str (substring (dp-mk-timestamp "" "") 0 -1) done-delim))))

;(defun dpj-goto-todo-or-ai (&optional topic-re skip-current count skip-re)
;  (let* ((td.ai (dpj-get-topic-and-ai-start 'dpj-not-a-todo 'skip-current))
;	 (td (car td.ai))
;	 (ai (cdr td.ai)))
;    (message "td:%s, ai: %s" (car td.ai) (cdr td.ai))
;    ;; td and ai can only be eq if there are no more of either item
;    (if (eq td ai)
;	nil
;      (goto-char (max (car td.ai) (cdr td.ai))))))

(defvar dpj-todo-or-ai-regexp (format "\\(%s\\|%s\\)"
				      dpj-any-AI-todo-regexp@bol
				      (dpj-mk-topic-re dpj-todo-re)))

(defun dpj-goto-todo-or-ai (search-func &optional topic-re 
					skip-current count skip-re)
  (catch 'done
    (let ((opoint (point)))
      (while (funcall search-func dpj-todo-or-ai-regexp nil t)
	(unless (dp-mmm-in-any-subregion-p (match-beginning 0))
	  (if (or (not skip-re)
		  (not (string-match skip-re (match-string 0))))
	      (if (and skip-current
		       (eq opoint (match-beginning 0)))
		  (setq skip-current nil)
		(when (or (not dpj-next-in-topic-topic)
			  (and (message 
				"Only looking in topics matching: %s"
				dpj-next-in-topic-topic)
			       nil)
			  (string-match dpj-next-in-topic-topic
					(dpj-current-topic 
					 nil 'dont-quote-regexp)))
		(throw 'done (match-beginning 0))))))
	))))

(defun dpj-goto-todo-or-ai-forward (&optional topic-re 
					      skip-current count skip-re)
  (dpj-goto-todo-or-ai 'dp-re-search-forward topic-re
		       skip-current count skip-re))

(defun dpj-goto-todo-or-ai-backward (&optional topic-re 
					       skip-current count skip-re)
  (dpj-goto-todo-or-ai 're-search-backward topic-re
		       skip-current count skip-re))

(defun dpj-goto-todo-or-ai-command ()
  (interactive)
  (dp-push-go-back "dpj-goto-todo-or-ai-command")
  (dpj-goto-todo-or-ai))

(defun dpj-todo-done (&optional timestamp-p)
  "Insert a todo completion timestamp."
  (interactive "*P")
  (dpj-todo-complete dpj-done-str ">>" "=" timestamp-p))

(defun dpj-todo-cancelled (&optional timestamp-p)
  "Insert a todo cancelled timestamp."
  (interactive "*P")
  (dpj-todo-complete dpj-cancelled-str "~~" "~" timestamp-p))

(defun dpj-highlight-todos (&optional keep-others)
  "Highlight the todos in the current buffer."
  (interactive "P")
  (dpj-highlight-topic dpj-todo-re keep-others))

(defun dpj-show-todos (&optional keep-others)
  "Show the todos in the current buffer."
  (interactive "P")
  (dpj-show-topic dpj-todo-re keep-others))

(defun dpj-goto-current-topic-start (&optional skip-re)
  "Go to start of current topic."
  (interactive)
  (unless (dpj-goto-topic-forward nil 'skip-current nil)
    ;; no next topic
    (dpj-set-match-data nil)
    (goto-char (point-max)))
  (let ((mdata (dpj-match-data)))
    (if (dpj-goto-topic-backward nil nil nil skip-re)
	t
      ;; no prev topic
      ;;(dmessage "%s" mdata)
      (dpj-set-match-data mdata)
      nil)))

(defun dpj-current-topic (&optional skip-re no-quote)
  "Get the current topic.
SKIP-RE - skip if re matches topic.
NO-QUOTE - do not perform a `regexp-quote' on the topic before returning it.
Side effect is that dpj-match-data is set."
  (interactive)
  (save-excursion
    (dpj-goto-current-topic-start skip-re)
    ;;(dmessage "curtopic>%s<" (dpj-topic-match-string))
    (if (and (not no-quote) dpj-regexp-quote-topic)
	(regexp-quote (dpj-topic-match-string))
      (dpj-topic-match-string))))

(defun dpj-current-topic-boundaries (&optional skip-re no-quote 
					       entire-record-p)
  "Return the current topic's boundaries: (START . END).
Same params as `dpj-current-topic' +
ENTIRE-RECORD-P which says to return END st the entire record is
spanned."
  (interactive)
  (dpj-current-topic)
  (cons (dpj-topic-match-beginning)
	(dpj-topic-match-end)))

(defun dpj-current-boundaries (start)
  (interactive)
  (let (topic-start)
    (dpj-current-topic)
    (setq topic-start (dpj-topic-match-beginning))
    (save-excursion
      (list (dpj-topic-match-beginning start)
	    topic-start
	    (let (p)
	      (if (dpj-goto-topic-forward)
		  (1- (dpj-topic-match-beginning 0))
		(point-max)))))))

(defun dpj-current-record-boundaries ()
  (dpj-current-boundaries dpj-topic-subexp))


(defun dpj-pos-in-current-record-p (pos)
  (interactive)
  (let* ((bounds (dpj-current-record-boundaries))
	 (lo (nth 0 bounds))
	 (hi (nth 2 bounds)))
    (and (>= pos lo)
	 (<= pos hi))))

(defun dpj-get-current-topic-start (&optional skip-re no-quote)
  "Get the current topic."
  (interactive)
  (save-excursion
    (if (dpj-goto-current-topic-start skip-re)
	(point)
      nil)))				;;; ????????

;;;###autoload
(defun dpj-clone-topic (&optional link-too-p insert-this-text 
                        link-forward-also-p)
  "Clone the current topic with a new timestamp.
NB: previous topic means the previous SAME topic.
LINK-TOO-P, if non-nil says to link to the previous topic.
LINK-TOO-P, if nil will make a link to the previous topic if it is 
\"far enough away.\"
INSERT-THIS-TEXT is text to insert after the topic is inserted.
Allows for an indication of time flow within a continuing topic or 
continuation of a topic at a later time."
  (interactive "P")
  (let ((topic (dpj-current-topic dpj-todo/done-re 'no-quote))
	(current-prefix-arg nil)) ;bleaghhhh dpj-no-spaced-append-p uses this
    (if (not (string= topic ""))
        (dpj-new-topic :topic topic 
                       :no-spaced-append-p nil 
                       :link-too-p link-too-p 
                       :is-a-clone-p 'is-a-clone-p)
      (dp-set-eof-spacing 2 (dpj-new-topic-insertion-point)))
    (when insert-this-text
      (insert insert-this-text "\n"))))

;;;###autoload
(defalias 'cxc 'dpj-clone-topic)	; cx-clone, cx-continue

;;;###autoload
(defun dpj-clone-topic-and-link ()
  "Clone topic and force link to previous topic regardless of distance."
  (interactive)
  (dpj-clone-topic 'link-too-p))
(defalias 'cxcl 'dpj-clone-topic-and-link)

;;;###autoload
(defun cxl ()
  (interactive)
  (let (current-prefix-arg)		;bleaggh!!
    (dpj-new-topic :topic nil 
                   :no-spaced-append-p nil 
                   :link-too-p 'link-too-p)))
    
;;;###autoload
(defun* dpj-mk-external-bookmark (&optional (pos (point))
                                  (file-or-buf (current-buffer)))
  "Make link a topic @ (or POS (point)) in (or FILE-OR-BUF (current bufer))."

  ;; 
  (interactive)
  (let ((boundaries (dp-region-or-line-boundaries)))
    (dpj-clone-topic 'link-too-p (buffer-substring (car boundaries) 
                                                 (cdr boundaries)))))

(defun dpj-current-topic-or-todo ()
  "Get the topic currently under point.  
If the topic looks like a todo \(matches `dpj-todo-re'\) then return a
wildcard todo string. This allows us to sit on a todo and find all of
the others easily.  See also `dpj-next-todo'.  
Returns a cons: (topic . is-a-todo-p)"
  (let ((topic (dpj-current-topic dpj-done-re)))
    ;;(dmessage "tot-topic>%s<" topic)
    (if (string-match dpj-todo-re topic)
	(cons (concat dpj-todo-str ".*") t)
      (cons topic nil))))

(defun dpj-xxx-current (func keep-others)
  "FUNC the topic at the current position.
See `dpj-process-topics' for meaning of KEEP-OTHERS."
  (let* ((l (dpj-current-topic-or-todo))
	 (skip-todos (not (cdr l))))
    (funcall func (concat "^" (car l) "$") 
	     keep-others skip-todos)))

(defun dpj-highlight-current (&optional keep-others)
  "Highlight the topic at the current position."
  (interactive "P")
  (dpj-xxx-current 'dpj-highlight-topic keep-others))

(defun dpj-show-current (&optional keep-others)
  "Show the topic at the current position."
  (interactive "P")
  (dpj-xxx-current 'dpj-show-topic keep-others))

(defun dpj-show-all ()
  "Unhide, unhighlight everything."
  (interactive)
  (setq dpj-next-in-topic-topic nil)
  (setq dpj-show-topic-topic nil)
  (dpj-show-buffer))

;(defun dpj-insert-link (&optional topic)
;  "Add an easily recognized link to an *existing* topic."
;  (interactive (dpj-get-topic-interactive nil nil t))
;  (insert dpj-link-left-delim topic dpj-link-right-delim))

(defun* dpj-make-link-string0 (file-name offset timestamp 
                              &optional (delimitter ":"))
  "Create a dp-journal link to FILE-NAME @ OFFSET including TIMESTAMP.
The string is in my embedded lisp format."
  (if (dpj-is-a-journal-p file-name)
      (setq file-name (file-name-nondirectory file-name)))
  ;; Make string I can extract and `eval'.
  (format "%s(dpj-chase-link \"%s\" %s \"%s\")%s\n"
          delimitter
	  file-name offset timestamp
          delimitter))

(defun dpj-make-link-string ()
  (let ((file-name (buffer-file-name))
	(offset (point))
	(timestamp-info (dpj-get-current-timestamp)))
    (dpj-make-link-string0 file-name offset (car timestamp-info))))

(defun dpj-insert-link (file-name offset timestamp)
  (interactive)
  (insert (dpj-make-link-string0 file-name offset timestamp)))

(defun dpj-link-to-point ()
  (interactive)
  (let ((link-string (dpj-make-link-string)))
    (dp-journal)
    (insert link-string)))

(defun dpj-kill-link ()
  "Make a link and add it to the kill-ring for easy insertion elsewhere."
  (interactive)
  (kill-new (dpj-make-link-string)))

;; this will be replaced by dpj-chase-link
; (defun dpj-goto-link (&optional link)
;   (interactive)
;   (unless link
;     (save-excursion
;       (setq link (dp-bracketed-buffer-substring 
; 		  dpj-link-left-delim dpj-link-right-delim))))
;   (dp-push-go-back "dpj-goto-link")
;   (dpj-goto-topic-backward link))

(defvar dpj-grep-addrs nil
  "List of points from the last grep operation.")

(defvar dpj-grep-cursor nil
  "Cursor into list of points from the last grep operation.")

(defun dpj-grep-bodies (grep-re &optional topic-re skip-re 
			       just-remember-records)
  "Grep the bodies of the selected topic records."
  (interactive "sgrep-re: ")
  (when current-prefix-arg
    (setq topic-re (dpj-read-topic))
    (if (> (prefix-numeric-value current-prefix-arg) 4)
	(setq just-remember-records t)))
  (setq topic-re (or topic-re
		     (or dpj-next-in-topic-topic 
			 (concat "^" (car (dpj-current-topic-or-todo)) "$"))))
  (save-excursion
    (let ((matching-topics (car (dpj-find-topics topic-re nil skip-re)))
	  matching-records
	  done)
      (unless just-remember-records
	(setq dpj-grep-addrs nil))
      (dolist (topic-info matching-topics)
	(setq done nil)
	(goto-char (dpj-topic-info-record-start topic-info))
	(while (and (not done)
		    (dp-re-search-forward grep-re 
				       (dpj-topic-info-end topic-info) t))
	  (if just-remember-records 
	      (setq matching-records (cons topic-info matching-records)
		    done t)
	    (setq dpj-grep-addrs 
		  (cons (match-beginning 0) dpj-grep-addrs)))))
      
      (if just-remember-records
	  (nreverse matching-records)	; return val fur this case
	(setq dpj-grep-addrs (nreverse dpj-grep-addrs)
	      dpj-grep-cursor dpj-grep-addrs)
	(message "grep topic: %s for %s" topic-re grep-re))
      )))

(defun dpj-grep-next ()
  "Goto next grep hit."
  (interactive)
  (if dpj-grep-cursor
      (let ((pt (car dpj-grep-cursor)))
	(setq dpj-grep-cursor (cdr dpj-grep-cursor))
	(goto-char pt))
    (ding)
    (message "No more grep hits.")
    (setq dpj-grep-cursor dpj-grep-addrs)))

;; sort predicates
(defun dpj-topic-date-less-p (d1 d2)
  (string< d1 d2))

(defun dpj-topic-record-less-p (r1 r2)
  (string< r1 r2))

(defun dpj-insert-topic-sorted (new)
  "Insert NEW into the current buffer in the properly sorted location."
  (interactive)
  ;; get all of the topic
  (let ((topics (car (dpj-find-topics)))
	(insert-point (point-min))
	insert-end
	new-timestamp)
    ;;(dmessage "new>%s<" new)
    (string-match dpj-timestamp-re new)
    (setq new-timestamp (match-string 0 new))
    (catch 'done
      (while topics
	;;(dmessage ">%s< >%s<" new-timestamp 
	;;    (dpj-topic-info-timestamp (car topics)))
	(when (dpj-topic-date-less-p new-timestamp
				   (dpj-topic-info-timestamp (car topics)))
	  (goto-char insert-point)
	  (insert new "\n")
	  (throw 'done nil))
	(setq insert-point (1+ (dpj-topic-info-end (car topics))))
	(setq topics (cdr topics)))
      (goto-char (point-max))
      (insert "\n" new "\n"))
    (setq insert-end (point))
    (if (and (re-search-backward "[^ 	\n]" nil t)
	     (dp-re-search-forward "[ 	\n]+" nil t))
	(replace-match "\n\n"))
    ))

(defun dpj-extract-records (topic-list)
  "Return list of records extracted from the file using the list of topic-info items."
  (mapcar 
   (function 
    (lambda (info)
      (buffer-substring (dpj-topic-info-record-start info)
                        (dpj-topic-info-end info))))
   topic-list))				; ??? @todo was topics?

(defun dpj-insert-topics-sorted (topics-str)
  "Insert a bunch of topics, putting each in its properly sorted place."
  (interactive)
  (let (new-topics old-topics topics)
    ;; insert string into a temp buffer and
    ;; get all of the topics into a list of strings
    (with-temp-buffer
      (insert topics-str)
      (setq topics (car (dpj-find-topics)))
      ;;(dmessage "topics>%s<" topics)
      (setq new-topics (dpj-extract-records topics)))
    
    (if (< (length new-topics) 5)
	(progn
	  ;; this can work better for a merging in a few records
	  ;; insert each topic to its sorted place.
	  ;; this is an easy but *incredibly* slow way to do this.
	  (mapcar (function 
                   (lambda (rec)
                     (dpj-insert-topic-sorted rec)))
		  new-topics))
      ;; get current file's topics into a list of strings 
      (setq topics (car (dpj-find-topics)))
      (setq old-topics (dpj-extract-records topics))
      ;; combine lists of topic strings
      (setq topics (append old-topics new-topics))
      ;; sort them
      (sort topics 'dpj-topic-record-less-p)
      ;; remove current file contents.
      (dp-erase-buffer)
      ;; insert all records.  This results in a reformatting of
      ;; any old records by resulting a a single newline bewteen
      ;; records.  ?? Or are trailing newlines retained in each record?
      (mapcar (function 
               (lambda (rec)
                 (insert rec "\n")))
	      topics))))

(defun dpj-insert (&optional dont-insert-sorted)
  "Insert into a journal.  
If `current-kill' is a topicstamp, insert into sorted place in file.
In this case, `current-kill' must be a single topic item."
  (interactive)
  (let ((insert-str (current-kill 0 nil)))
    (push-mark (point))
    (if (and (not dont-insert-sorted)
	     (string-match dpj-topic-re insert-str))
	(dpj-insert-topics-sorted insert-str)
      (insert insert-str))
    (setq this-command 'yank)		;? so meta-y works
;;    (kill-new insert-str) ;; ??? WFT did I do this?
      ))

(defun dpj-pretty-timestamp ()
  "Show a timestamp in a more readable fashion."
  (interactive)
  (let ((ts (car dpj-get-current-timestamp)))
    (message "%s" (dp-timestamp-to-datestr ts))))

(defun dpj-get-journal-file-interactive ()
  "Prompt for the file's month any year."
  (let* ((dlist (decode-time (current-time)))
	 (month (nth 4 dlist))
	 (year  (nth 5 dlist)))
    (setq month (read-from-minibuffer "month: " (format "%s" month)))
    (setq year  (read-from-minibuffer "year: " (format "%s" year)))
    (list month year)))

(defun dpj-make-journal-name (month year &optional topic dir-name)
  "Construct a journal file's name."
  (expand-file-name
   (dp-make-dated-note-file-name "daily" :extension ".jxt" :year-first-p t
                                 :amon month :ayear year
                                 :note-base-dir 
                                 (or dir-name
                                     (dpj-base-dir-name topic)))))

(defun dpj-latest-note-file-name (&optional topic dir-name)
   (dpj-make-journal-name nil nil topic dir-name))

;;;###autoload
(defun dpj-edit-journal-file (fname &optional missing-file-action other-win-p)
  "Edit the journal file."
  (interactive "FJournal file name? ")
  (if (not (file-exists-p fname))
      (cond
       ((eq missing-file-action 'keep-looking)
        'keep-looking)        
       ((or t (eq missing-file-action 'must-exist))
        (message "%s doesn't exist." fname)
        (ding)
        nil))
    ;; File exists!
    (if other-win-p
        (find-file-other-window fname)
      (find-file fname))
    (dpj-set-current-journal-file (expand-file-name fname))
    ;; do this here or hook set-buffer.
    ;; hooking set-buffer is experimental.
    ;;(dpj-re-process-topics dpj-last-process-topics-args)
    fname))
;; (defalias 'dpj-edit-journal-file 'dpj-new-journal-file)
;; (defalias 'dpj-visit-journal-file 'dpj-new-journal-file)
;; (defalias 'dpj-edit-journal-file 'dpj-new-journal-file)
;; (defalias 'dpj-find-journal-file 'dpj-new-journal-file)

; (defun dpj-edit-journal-file-for-month&year (month year &optional must-exist)
;   "Edit the journal file indicated by month and year."
;   (this needs to handle topic specific journal names!)
;   (interactive (dpj-get-journal-file-interactive))
;   (dpj-edit-journal-file (dpj-make-journal-name month year) must-exist))

(defun dpj-journal-name-to-month-num (&optional fname)
  "Convert a journal file's name to a month number."
  (let* ((jfile (file-name-sans-extension 
		 (file-name-nondirectory (or fname buffer-file-name))))
	 (parts (split-string jfile "-"))
	 (year  (string-to-int (nth 1 parts)))
	 (month (string-to-int (nth 2 parts))))
  (+ month -1 (* year 12))))

(defun dpj-month-num-to-journal-name (month-num &optional jname-in)
  "Convert a month-num to a journal file's name."
  (let ((month (1+ (mod month-num 12)))
	(year (/ month-num 12)))
    (dpj-make-journal-name month year nil 
                           (or jname-in
                               (file-name-directory (or jname-in
                                                        buffer-file-name))))))

(defun dpj-next-journal-file (&optional incr missing-file-action jname-in)
  "Move to the next/prev journal file, timewise.
INCR should be 1 or -1.
Returns nil on failure, else
CONS of file-name and flag indicating whether we had to load the file."
  (interactive (list (string-to-int 
		      (completing-read "incr: " '(("1") ("-1")) nil t "-1"))))
  (if (not (buffer-file-name))
      (progn
	(message "No %s file for this buffer." (if (< 0 incr)
						   "prev"
						 "next"))
						   
	nil)
    (let* ((jmon (+ (dpj-journal-name-to-month-num jname-in) (or incr -1)))
	   (new-name (dpj-month-num-to-journal-name jmon))
	   (already-loaded (get-file-buffer (expand-file-name new-name)))
	   (got-file (dpj-edit-journal-file new-name missing-file-action)))
      (cond 
       ((eq got-file 'keep-looking)
        (dpj-next-journal-file incr missing-file-action buffer-file-name))
       (got-file
        (when (not already-loaded)
          (dpj-position-point-in-new-file incr))
        (cons got-file (not already-loaded)))
       (t nil)))))

(defalias 'dpjn 'dpj-next-journal-file)
(defalias 'dpjnf 'dpj-next-journal-file)

;(defvar dpj-menu       
;  '("Journal")
;  "*Menu for Journal mode.")

(defsubst dpj-define-key (keys def &optional keymap)
  "Define a key in the journal keymap."
  (define-key (or keymap dp-journal-mode-map) keys def))

;(defun dpj-add-menu-item (menu-text menu-def)
;  "Add or replace an item to the menu."
;  (let* ((menu-item (vector menu-text (or menu-def def))))
;    (dmessage "m>%s<" dpj-menu)
;    (easy-menu-add-item dpj-menu '("Journal") menu-item)))

(defun dpj-add-menu-item (menu-text menu-def)
  "Add or replace an item to the menu."
  (let* ((menu-item (vector menu-text (or menu-def def)))
	 (prev-item (member menu-item dpj-menu)))
    (unless prev-item
      (setq dpj-menu (nconc dpj-menu (list menu-item))))))

(defun dpj-define-key-and-add-to-menu (keys def menu-text 
					    &optional keymap menu-def)
  "Bind command to key and add to menu."
  (dpj-define-key keys def keymap)
  (when menu-text
    (dpj-add-menu-item menu-text (or def menu-def))))

(defun dpj-add-menubar-menu ()
  "Add the journal mode menu to the menubar."
  (interactive)
  (easy-menu-add dpj-menu))

;; 
;;(defun dpj-find-bullet-backwards)
;; No hardcoded regexp.
;;

;;!<@todo Make defun* and change no-error-p to default to t 
(defun dpj-find-action-item-backwards (&optional no-error-p skip-current-p)
  "Find the previous action item, returning its position or nil if not found.
NO-ERROR-P says no previous item is OK.
SKIP-CURRENT-P says to not count the current AI when looking backwards."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (and skip-current-p (looking-at dpj-any-AI-regexp@bol)
             (not (bobp)))
        (progn
          (forward-char -1)
          (beginning-of-line))
      (end-of-line))
    ;; Force no-error-p to be t or nil, since any other value changes the
    ;; semantics of the search.
    (re-search-backward dpj-any-AI-regexp@bol nil (to-bool no-error-p))))
  
(defun* dpj-operate-on-AI-backwards (&key (no-error-p t) skip-current-p 
                                     push-go-back-p operator)
  (interactive)
  (let ((p (dpj-find-action-item-backwards no-error-p skip-current-p)))
    (when p
      (funcall operator p))))

(defun* dpj-goto-action-item-backwards (&optional (no-error-p t) 
                                        (skip-current-p t)
                                        push-go-back-p)
  (interactive)
  (let ((p (point)))
    (when (and (dpj-operate-on-AI-backwards :no-error-p no-error-p 
                                            :skip-current-p skip-current-p
                                            :operator 'goto-char)
               push-go-back-p)
      (dp-push-go-back "dpj-goto-action-item-backwards" p))))

(defun dpj-get-prev-AI-indentation ()
  (interactive)
  (dpj-operate-on-AI-backwards :no-error-p t
                               :skip-current-p nil
                               :operator (function
                                          (lambda (point)
                                            (save-excursion
                                              (goto-char point)
                                              (current-indentation))))))

(defun dpj-outdent-section ()
  "Outdent current line to the level of the previous section."
  (interactive)
  (let ((c (dpj-get-prev-AI-indentation))
        (pmark (dp-mk-marker)))
    (when c
      (save-excursion
        (beginning-of-line)
        (indent-to c)
        (save-match-data
          (when (looking-at dp-ws-regexp+)
            (replace-match "")))))))
(defalias 'dpj-dedent-section 'dpj-outdent-section)
(defalias 'dpj-back-dent-section 'dpj-outdent-section)

;;!<@todo merge this code and span action item? 
(defun dpj-outdent (&optional num-levels)
  (interactive "p")
  (when (> (current-indentation 0))
    (let* ((initial-pos (point))
           (limit (save-excursion
                    (goto-char (car (dpj-current-topic-boundaries)))
                    (forward-line 2)
                    (point)))
           current-indent-column
           (our-indent-column (current-indentation))
           (parent-indentation
            (catch 'up
              (while t
                (forward-line -1)
                (beginning-of-line)
                (when (not (looking-at "^\\s-*$"))
                  (when (< (point) limit)
                    (throw 'up nil))
                  (when (< (current-indentation) our-indent-column)
                    (throw 'up (current-indentation))))))))
      (goto-char initial-pos)           ; Starting line
      (if parent-indentation
          ;; Leaves us @ end of indentation.
          (indent-line-to parent-indentation)))))
(defalias 'dpj-dedent 'dpj-outdent)
(defalias 'dpj-back-dent 'dpj-outdent)

(defun dpj-outdent-or-backward-delete-word ()
  "Delete the previous word or level of indentation depending on context.
We outdent if we're looking back at white space."
  (interactive)
  (call-interactively 
   (if (dp-looking-back-at dp-ws-regexp+)
       'dpj-outdent
     'dp-backward-delete-word)))

(defun dpj-outdent-section-or-backward-delete-word ()
  "Delete the previous word or level of indentation depending on context.
We outdent if we're looking back at white space."
  (interactive)
  (call-interactively 
   (if (dp-looking-back-at (concat "^" dp-ws-regexp+))
       'dpj-outdent-section
     'dp-backward-delete-word)))

;; @todo convert to span-filladapted-region
(defun dpj-span-action-item (&optional span-forward-p)
  "Return boundaries of current or immediately preceding action item.
End is following line with less (or no) indentation."
  (save-excursion
    (let (begin prefix
		(end (save-excursion
		       (beginning-of-line)
		       (if (looking-at "^[ 	]*$")
			   (point)
			 nil))))
      (when (or (not span-forward-p) end)
        (dpj-goto-action-item-backwards))
      (setq begin (point))
      (if end
	  ;; end is already set
	  (goto-char end)		
	;; find first lesser-indented or empty line
	(setq prefix 
	      (concat "^" (filladapt-convert-to-spaces (match-string 0))))
	(forward-line 1)
	(beginning-of-line)
	(setq end (point))
	(catch 'done
	  (while t
	    (unless (dp-re-search-forward prefix (line-end-position) t)
	      (throw 'done nil))
	    ;; space only/empty line???
	    (if (looking-at "^[ 	]*$")
		(throw 'done nil))
	    ;; try to move down a line
	    (if (= (forward-line 1) 1)
		(throw 'done nil))
	    (if (eobp)
		(throw 'done nil))
	    (beginning-of-line))))
      (beginning-of-line)
      (backward-char 1)
      (cons begin (point)))))

(defun dpj-mark-action-item ()
  (interactive)
  (let* ((reg (dpj-span-action-item))
	 (begin (car reg))
	 (end (cdr reg)))
    (dp-set-mark begin)
    (goto-char end)
    (dp-activate-mark)))

(defun dpj-resolve-action-item (&optional resolution-char timestamp-p
					  no-summary-p
                                          resolve-forward-p)
  "Resolve an action item by marking it completed or cancelled.
RESOLUTION-CHAR is ?= or ?~ indicating completed or cancelled.  If nil,
then determine RC based upon current-prefix arg \(interactively\).
TIMESTAMP-P determines whether or not a timestamp is inserted into the
resolution summary.
NO-SUMMARY-P controls whether we insert a summary indicator
\(==> or ~~>\)."
  (interactive)
  (unless resolution-char
    (setq resolution-char (if (and (interactive-p) current-prefix-arg) "~" "="
			      "=")))
  (let ((region (or (dp-mark-active-p) 
                    (dpj-span-action-item resolve-forward-p))))
    ;; the entire AI is marked.
    (goto-char (car region))
    (let ((prefix (make-string (skip-chars-forward "[ 	]") ? )))
      (insert resolution-char)
      (unless no-summary-p
	(goto-char (cdr region))
	(end-of-line)
	(insert "\n" prefix resolution-char (if timestamp-p
						(dp-timestamp-string)
					      "")
		resolution-char "> ")))))

(defalias 'ri 'dpj-resolve-action-item)

(defun dpj-electric-resolve-action-item (resolution-char &optional timestamp-p)
  (interactive)
  (if (and (dp-looking-back-at "^[ 	]*" t) 
	   (looking-at dpj-any-AI-regexp))
      (dpj-resolve-action-item resolution-char 
                               (or timestamp-p current-prefix-arg)
                               nil t)
    (call-interactively 'self-insert-command)))

(defun dpj-electric- ()
  (interactive)
  (dpj-electric-resolve-action-item "~" current-prefix-arg))

(defun dpj-electric= ()
  (interactive)
  (dpj-electric-resolve-action-item "=" current-prefix-arg))

(defun dpj-add-topic-abbrev (name topic)
  "Add abbrev to dpj-topic-abbrev-table."
  (interactive (list (read-from-minibuffer "abbrev: ")
		     (dpj-read-topic nil nil nil nil "expands to topic%s: ")))
  (define-abbrev dpj-topic-abbrev-table name topic)
  (setq dpj-abbrev-list-modified-p t)
  (dpj-write-topic-file))

(defun dpj-set-next-in-topic-topic (clear)
  (interactive "P")
  (setq dpj-next-in-topic-topic (if clear
				    nil
				  (dpj-read-topic))))

;;!<@todo We really only need one of these.
(defvar dp-journal-home-command-list 
  `(beginning-of-line
    dpj-goto-topic-backward-with-file-wrap
    ,(lambda () (move-to-window-line 0))
    ,(lambda () 
       (dp-push-go-back "dpj-home" dp-consecutive-key-command-initial-point)
       (dp-beginning-of-buffer 'no-save-pos)))
  "Commands to run based on number of consecutive keys pressed.")

(defvar dp-journal-home-command-ptr dp-brief-home-command-list
  "Command to run.")

(defvar dpj-def-note-base-dir-key "///"
  "The key used to match the default note-base-dir in the topic->dir map.")

(defvar dpj-topic-to-dir-map-default-entry    
  (list dpj-def-note-base-dir-key dp-note-base-dir)
  "Default topic --> directory mapping entry.")

(defvar dpj-topic-to-dir-map '()
  "Map to find a note directory given a topic regexp.")
(add-to-list 'dpj-topic-to-dir-map dpj-topic-to-dir-map-default-entry)

(defun dpj-base-dir-name (&optional topic)
  (cadr (dp-assoc-regexp (or topic dpj-def-note-base-dir-key) 
                         dpj-topic-to-dir-map)))

(defun dp-journal-home ()
  "Go bol, botopic, bow, bof."
  (interactive)
  (dp-consecutive-key-command 'dp-journal-home-command-ptr
			      dp-journal-home-command-list
			      'dp-journal-home))

(defun dpj-tidy-topic-ends (&optional query)
  (interactive "P")
  (let ((topic-re (concat "\\(\n\n*?\\)"
			  "\\("
			  "\n\n" 
			  (substring (dpj-mk-topic-re) 1)
			  "\\)"
			  ))
	m-end)
    (if query
	;; use query replace so we get to use all of its features
	(query-replace-regexp topic-re "\\2")
      (while (dp-re-search-forward topic-re nil t)
	;; use marker so we go to the right place after deletions
	;; change char positions.
	(setq m-end (point-marker))
	(delete-region (match-beginning 1) (match-end 1))
	(goto-char m-end)))
    (setq m-end nil)))

(defun dpj-fill-paragraph-or-region ()
  "Fill region else fill without including topic header."
  (interactive)
  (if (dp-mark-active-p)
      (call-interactively 'fill-paragraph-or-region)
    (let ((paragraph-start (dp-re-concat paragraph-start "^--$"))
	  (paragraph-separate (dp-re-concat paragraph-separate "^--$")))
      (call-interactively 'fill-paragraph-or-region))))

(defun dpj-buffer-killed-hook ()
  "See if this buffer is the current-buffer and reset current-buffer if so."
  (if (and (dpj-current-journal-file)
	   (string= (dpj-current-journal-file) (buffer-file-name)))
      (dpj-set-current-journal-file nil)))

;(defun dp-journal (&optional other-win-p goto-eof visit-latest)
;  (interactive)
;  (if (and dpj-current-journal-file
;	   (not visit-latest))
;      (if other-win-p
;	  (find-file-other-window dpj-current-journal-file)
;	(find-file dpj-current-journal-file))
;    (dnf "daily" ".jxt" 'skip-tf 'year-first other-win-p)
;    (setq dpj-current-journal-file (buffer-file-name)))
;  (if goto-eof
;      (dp-end-of-buffer)))

(defun* dpj-next-journal-command (&optional latest-journal-p
                                  (keep-looking-p 'keep-looking))
  (interactive "P")
  (if latest-journal-p
      (dp-journal nil nil 'visit-latest)
    (dpj-next-journal-file 1 keep-looking-p)))

;;;###autoload
(defun dp-journal (&optional other-win-p goto-eof visit-latest topic)
  "Visit a journal file.
If `dpj-current-journal-file' is non-nil, visit that file, otherwise
visit the journal for the current date and set `dpj-current-journal-file'.
OTHER-WIN-P says visit in other window.
GOTO-EOF says go to end of file.
VISIT-LATEST says visit the current journal even if
`dpj-current-journal-file' is non-nil.
RETURN buffer that was visiting the journal, or nil."
  (interactive)
  (when (interactive-p)
    (setq-ifnil visit-latest current-prefix-arg))
;  (unless goto-eof
;    (setq goto-eof current-prefix-arg))

  (when (or (not (dpj-current-journal-file))
            (and (not (dpj-journal-file-sticky-p))
                 visit-latest))
    (dpj-set-current-journal-file (dpj-latest-note-file-name topic)))
  
  (let ((visiting-buffer (find-buffer-visiting (dpj-current-journal-file))))
    (if other-win-p
	(dp-find-file-other-window (dpj-current-journal-file))
      (dp-find-file (dpj-current-journal-file)))
    (when (or goto-eof
	      (not visiting-buffer))
      (dp-end-of-buffer)
      (recenter -4))
    visiting-buffer))

;;;###autoload
(defun dp-journal2 ()
  (interactive)
  (dp-journal 'other-win-p))

;;;###autoload
(defalias 'dj 'dp-journal2)

;;;###autoload
(defalias 'dj2 'dp-journal2)

;;;###autoload
(defalias 'dj1 'dp-journal)
;;;###autoload
(defalias 'dj0 'dp-journal)
;;;###autoload
(defalias 'dj. 'dp-journal)
;;;###autoload
(defalias 'djd 'dp-journal)

;;;###autoload
(defun dpj-visit-other-journal-file (file-name &optional other-window-p)
  "Visit FILE-NAME as journal and make it sticky to the current buffer.
This kind of allows us to use a journal file with a non-standard name."
  (interactive "fJournal file name: ")
  (dpj-set-current-journal-file file-name 'sticky)
  (dp-journal other-window-p))
(dp-defaliases 'dpjvo 'dpj-visit-other-journal-file)

;;;###autoload
(when (dp-xemacs-p)
  ;; add us to the default menubar
  (defvar dpj-menubutton-guts
    [ dp-journal :active (fboundp 'dp-journal)]
    "Menu button to activate journal.")
  (defvar dpj-menubar-button (vconcat ["Dj"] dpj-menubutton-guts)
    "Journal menubar button.")
  (defvar dpj-menu-button-added nil
    "Non nil if we've already added the menu-button.")
  
  ;; @todo Add to tools menu?
  ;;  (defvar dp-mew-menu-button 
  ;;    (vconcat ["%_Read Mail (Mew)"] dp-mew-menubutton-guts)
  ;;    "Mew internet menu button.")
  
  ;; add to Tools->Internet menu
  ;;  (add-menu-button '("Tools" "Internet") dp-mew-menu-button
  ;;		   "Read Mail 1 (VM)...")
  
  ;; add to menu-bar
  (unless dpj-menu-button-added
    (add-menu-button nil dpj-menubar-button nil default-menubar)
    (setq dpj-menu-button-added t)))

;;; dummy def for autoloading
;;;###autoload
(defun dp-journal-mode ()
  "Major mode for editing journals."
  (interactive))

;;;###autoload
(defun dpj-setup-invisibility ()
  "Make a nice glyph for invisible text regions."
  (interactive)
  ;; show the dots... or whatever
  ;; as of: 2010-06-24T12:22:06, I'm wondering why I made this different here
  ;; than in dp-setup-invisibility
  ;; And why I changed it from t in the first place.
  ;; I think I changed it to use my other region highlighting functions.
  ;; ?to standardize?
  ;; !<@todo XXX I need to merge functionality of `dp-highlight-region' and
  ;; dp-colorize-region'
  ;; (setq buffer-invisibility-spec (list (cons t t)))
  ;; ??? This could be nice... why did I stop doing it?
  ;;(make-variable-buffer-local 'invisible-text-glyph)
  (cond
   (dp-journal-invisible-text-glyph-string 
    (dp-set-buffer-invisible-text-glyph 
     `[string :data ,dp-journal-invisible-text-glyph-string]))
   (dp-journal-use-invisible-text-glyph-p
    (dp-set-buffer-invisible-text-glyph 
     (dp-setup-invisible-glyph dp-journal-invisible-text-glyph-file 
                               dp-journal-invisible-text-glyph-color)))))

(defvar dp-journal-mode-pre-hook nil
  "Call these hook functions before all other journal mode code.")

(defvar dp-journal-mode-post-hook nil
  "Call these hook functions after all other journal mode code.")

;;; real dp-journal-mode function defined here:
(define-derived-mode dp-journal-mode text-mode "Jrn" ;; "Journal"
  "Major mode for editing journals.
A journal is a text file divided into topics.  A topic is indicated by
a timestamp (see `dp-timestamp') with extra text before the suffix
which names the topic.  Topic records can be interleaved within a
file.  In general, a journal should be linear in time with context
switches noted by topic headers.  Commands exist to highlight a topic
and to show a topic while hiding all others (invisible text is alluded
to by `invisible-text-glyph' (usually an ellipsis...)).  Commands also
exist to move from one topic record to the next or previous.

\\{dp-journal-mode-map}"

  (run-hooks 'dp-journal-mode-pre-hook)
  
  ;;(dmessage "ENTER: dp-journal-mode")

  ;; We make these variables buffer local and lower 'em into the paranoid zone.
  (setq auto-save-interval 200
        auto-save-timeout 30)
  
  ;; Text mode turns this on, and it does many things I don't like. Perhaps I
  ;; am not using it correctly, esp in relation to filladapt.
  (auto-fill-mode -1)

  ;;
  ;; this make line up/down movement commands skip over invisible
  ;; text.  It is said to slow things down.  if it is too slow, we can
  ;; only set this when a non-empty set of records is invisible
  (make-local-variable 'line-move-ignore-invisible)
  (setq line-move-ignore-invisible t)

  (dp-set-indent/tab-style0)
  (dpj-setup-invisibility)

  (dpj-merge-all-topics nil 'write-merged-list)

  (unless (boundp 'dpj-menu)
    (easy-menu-define dpj-menu
		      dp-journal-mode-map
		      "Journal mode map"
		      '("Journal")))
  ;;(dmessage "m>%s<" dpj-menu)

  (dpj-define-key-and-add-to-menu "\C-p" 'dpj-prev-in-topic "Prev in topic")
  (dpj-add-menu-item "Prev in topic..." 'dpj-prev-in-topic-menu-command)
  (dpj-define-key-and-add-to-menu "\C-n" 'dpj-next-in-topic "Next in topic")
  (dpj-add-menu-item "Next in topic..." 'dpj-next-in-topic-menu-command)
  (dpj-define-key-and-add-to-menu [(meta left)] 
				  'dpj-goto-topic-backward-with-file-wrap
				  "Prev topic")
  (dpj-define-key-and-add-to-menu [(meta right)] 
				  'dpj-goto-topic-forward-with-file-wrap 
				  "Next topic")
  (dpj-define-key-and-add-to-menu "\C-cn" 'dpj-new-topic "Insert new topic")
  (dpj-define-key-and-add-to-menu [(control meta ?')] 'dpj-clone-topic 
				  "Clone current topic")
  (dpj-define-key-and-add-to-menu "\C-ch" 'dpj-highlight-topic
				  "Highlight topic")
  (dpj-define-key-and-add-to-menu "\C-c\C-s" 
                                  'dpj-show-topic-command "Show topic")
  (dpj-add-menu-item "Show current topic" 'dpj-show-current)

  ;; use outline mode's show-all binding.
  (dpj-define-key-and-add-to-menu "\C-c\C-a" 'dpj-show-all "Show all")

  (dpj-define-key-and-add-to-menu "\C-ct" 'dpj-todo "Insert todo")
  (dpj-define-key-and-add-to-menu "\C-cdd" 'dpj-todo-done "Complete todo")
  (dpj-define-key-and-add-to-menu "\C-c\C-t" 'dpj-prev-todo "Goto prev todo")
  (dpj-define-key-and-add-to-menu "\C-c\C-v" 'dpj-next-todo "Goto next todo")
  (dpj-define-key-and-add-to-menu "\C-c\C-d" 'dpj-todo-cancelled 
				  "Cancel todo")
  (dpj-define-key-and-add-to-menu "\C-cp" 'dpj-pretty-timestamp 
				  "Show topic time")
  (dpj-define-key-and-add-to-menu "\C-c\C-p" 'dpj-set-next-in-topic-topic 
				 "Set persistent topic")
  (dpj-define-key-and-add-to-menu [(meta ?,)] 'dp-pop-go-back "Go back")
  (dpj-define-key-and-add-to-menu "\C-cl" 'dpj-insert-link "Insert link")
  (dpj-define-key-and-add-to-menu [insert] 'dpj-insert "Yank [records]")
  (dpj-define-key-and-add-to-menu "\et" 'dpj-short-timestamp "Short timestamp")
  (dpj-define-key-and-add-to-menu "\C-ci" 'dpj-topic-info "Topic info")
  (dpj-define-key-and-add-to-menu [(meta tab)] 'dpj-outdent "Outdent")
  (dpj-define-key-and-add-to-menu "\M-." 'dp-embedded-lisp-eval@point "Goto link")
  (dpj-define-key-and-add-to-menu "\M-," 'dp-pop-go-back "Go back")

  ;;
  ;; keys only
  ;;
  ;; Since I write add so many lisp ideas/tasks/questions/...
  (dpj-define-key [(control tab)] 'lisp-complete-symbol)
  (dpj-define-key [(control meta ?n)] (kb-lambda
                                          (dpj-next-journal-command nil nil)))
  (dpj-define-key [(control meta ?p)] (kb-lambda
			     (dpj-next-journal-file -1 nil)))

  (dpj-define-key "\C-c\C-n" 'dpj-new-topic)
  (dpj-define-key "\C-c\C-r" (kb-lambda 
			      (dpj-re-process-topics 
			       dpj-last-process-topics-args)))
  (dpj-define-key "-" 'dpj-electric-)	;keep this since it is unshifted
  (dpj-define-key "~" 'dpj-electric-)
  (dpj-define-key "`" 'dpj-electric-)
  (dpj-define-key "=" 'dpj-electric=)
  (dpj-define-key [(meta ?-)] 'dp-bury-or-kill-buffer)
  (dpj-define-key "\eq" 'dpj-fill-paragraph-or-region)
  (dpj-define-key [(control space)] 'dp-expand-abbrev)
  (dpj-define-key [(control a)] 'dp-journal-home)
  (dpj-define-key [(meta tab)] 'dpj-outdent-section)
  (dpj-define-key [(control backspace)] 
                  'dpj-outdent-section-or-backward-delete-word)

  ;; menu only
  (dpj-add-menu-item "Replace current topic..." 
		     'dpj-get-and-replace-current-topic)
  (dpj-add-menu-item "View topic history..." 
		     'dpj-view-topic-history)
  (dpj-add-menu-item "Grep bodies..." 'dpj-grep-bodies)
  (dpj-add-menu-item "Next grep hit" 'dpj-grep-next)
  (dpj-add-menu-item "Grep and view hits..." 'dpj-grep-and-view-hits)
  (dpj-add-menu-item "View open todos..." 'dpj-view-todos)
  (dpj-add-menu-item "Kill old journal buffers " 'dpj-tidy-journals)
  
  ;; oh, wow, the COLORS.
  (dp-set-font-lock-defaults 'dp-journal-mode 
			     '(dp-journal-mode-font-lock-keywords t))
  (font-lock-set-defaults)
  
  (dp-make-local-hook 'after-save-hook)
  (add-hook 'after-save-hook (function 
			      (lambda ()
				(dpj-merge-all-topics nil 'write-em)))
	    nil 'local)

  (add-local-hook 'kill-buffer-hook 'dpj-buffer-killed-hook)
  
  (dpj-hook-set-buffer)
  (dpj-add-menubar-menu)
  (setq mode-popup-menu dpj-menu)

  ;;;;;;;;;;;;;;;;;(setq ispell-local-pdict dpj-local-pdict)
  (flyspell-mode 1)
  (dp-flyspell-local-persistent-highlight nil)
  ;; abbrevs in ~/.abbrev_defs --> ~/lisp/dp-abbrev-defs.el
  ;; @todo... try it on since the global abbrev table only has typos
  ;; corrections in it.
  (abbrev-mode 1)

  (setq auto-save-interval 42
        auto-save-timeout 30
        comment-start "; ")


  ;; now that we have auto-save-timeout, let's crank this up


  ;;(dmessage "EXIT: dj-journal-mode")

  (run-hooks 'dp-journal-mode-pre-hook))
