<:step
1234567890

(defvar dpj-which-alt 0)

(defun dpj-alt-0 (limit)
  (when (= dpj-which-alt 0)
    (setq dpj-which-alt (logxor 1 dpj-which-alt))
    (re-search-forward dpj-alt-regexp limit t)))

(defun dpj-alt-1 (limit)
  (when (= dpj-which-alt 1)
    (setq dpj-which-alt (logxor 1 dpj-which-alt))
    (re-search-forward dpj-alt-regexp limit t)))



========================
2003-10-20T11:56:50
--
hack ws mode to hightlight only indentation.

(defvar ws-mode-indentation-highlights
  [ dp-journal-alt-0-face dp-journal-selected-face ]
  ;;;;;;;;;;;;;;;[ grey40 grey50 grey60 grey70 grey90 grey100]
  )
ws-mode-indentation-highlights

(defun whitespace-highlight-region (from to)
  "Highlights the whitespaces in the region from FROM to TO."
  (let ((start (min from to))
	(end (max from to)))
    (save-excursion
      ;;    (message "Highlighting tabs and blanks...")
      (goto-char start)
      (cond ((eq whitespace-chars 'tabs-and-blanks)
	     (while (search-forward-regexp 
		     "\\(^[ 	][ 	]*\\)" end t)
	       (let ((extent) (len) (index))
		 ;;(dmessage "mb1>%s<" (match-string 1))
		 (setq len (length (dp-untabify-string (match-string 1))))
		 (setq index (mod (/ len 4) 
				  (length ws-mode-indentation-highlights)))
		 ;;(dmessage "len: %d, index: %d" len index)
		 (setq extent (make-extent (match-beginning 1) 
					   (match-end 1)))
		 (set-extent-face extent (aref ws-mode-indentation-highlights
						index))


		 (set-extent-property extent 'start-open t)
		 (set-extent-property extent 'end-open t)
		 )))
	    ((eq whitespace-chars 'tabs)
	     (whitespace-highlight-chars-in-region whitespace-tab-search-string 
						   from 
						   to
						   'whitespace-tab-face))
	    ((eq whitespace-chars 'blanks)
	     (whitespace-highlight-chars-in-region 
	      whitespace-blank-search-string 
	      from 
	      to
	      'whitespace-blank-face))
	    (t (error "ERROR: Bad value of whitespace-highlight-char")))
      ;;    (message "")
      )))

(message FMT &rest ARGS)

========================
2003-12-11T00:32:32
--
(defun mc-decrypt-message ()
  "Decrypt whatever message is in the current buffer.
Returns a pair (SUCCEEDED . VERIFIED) where SUCCEEDED is t if the encryption
succeeded and VERIFIED is t if it had a valid signature."
  (save-excursion
    (let ((schemes mc-schemes)
	  limits 
	  (scheme mc-default-scheme))

      ; Attempt to find a message signed according to the default
      ; scheme.
      (if mc-default-scheme
	  (setq
	   limits
	   (mc-message-delimiter-positions
	    (cdr (assoc 'msg-begin-line (funcall mc-default-scheme)))
	    (cdr (assoc 'msg-end-line (funcall mc-default-scheme))))))

      ; We can't find a message signed in the default scheme.
      ; Step through all the schemes we know, trying to identify
      ; the applicable one by examining headers.
      (while (and (null limits)
		  schemes
		  (setq scheme (cdr (car schemes)))
		  (not (setq
			limits
			(mc-message-delimiter-positions
			 (cdr (assoc 'msg-begin-line (funcall scheme)))
			 (cdr (assoc 'msg-end-line (funcall scheme)))))))
	(setq schemes (cdr schemes)))
      
      (if (null limits)
	  (error "Found no encrypted message in this buffer.")
	(run-hooks 'mc-pre-decryption-hook)
	(let ((resultval (funcall (cdr (assoc 'decryption-func
					      (funcall scheme))) 
				  (car limits) (cdr limits))))
	  (goto-char (point-min))
	  (if (car resultval) ; decryption succeeded
	      (run-hooks 'mc-post-decryption-hook))
	  resultval)))))


(defun zz-text-mode-hook ()
  (let ((flist (get major-mode 'font-lock-defaults)))
    (setq flist (cons    
		 (cons "^\\*.*$" 'blue)
		 flist))
    (put major-mode 'font-lock-defaults flist))
  (font-lock-set-defaults))

(setq orig-text-mode-font-lock-defaults 
      (get 'text-mode 'font-lock-defaults))
nil


major-mode
lisp-interaction-mode

(put major-mode 'foo 'bar)
bar

(get 'lisp-interaction-mode 'font-lock-defaults)
lisp-mode
(symbol-plist 'lisp-interaction-mode)
(foo bar font-lock-defaults lisp-mode)
lisp-mode

(get 'lisp-mode 'font-lock-defaults)
((lisp-font-lock-keywords lisp-font-lock-keywords-1 lisp-font-lock-keywords-2) nil nil ((?: . "w") (?- . "w") (?* . "w") (?+ . "w") (?\. . "w") (?< . "w") (?> . "w") (?= . "w") (?! . "w") (?\? . "w") (?$ . "w") (?% . "w") (?_ . "w") (?& . "w") (?~ . "w") (?^ . "w") (?/ . "w")) beginning-of-defun)


(append nil '(abc))
(abc)

(append '(1 2) '(a b c))
(1 2 a b c)

(setq x '(1 2))
(1 2)

(1 2)

(1 2)

(nconc x '((a b)))
(1 2 a b (a b))

(list x '(a b))
((1 2) (a b))

(1 2 a b)


((a b) 1 2)

(cons '(1 2) '(a b))
((1 2) a b)

(cons '(a b) '((1 2) (3 4)))
((a b) (1 2) (3 4))

((1 2) (3 4))


bar

(dp-cut-to-

(defun cut-copy-clear-internal (mode)
  (or (memq mode '(cut copy clear)) (error "unkown mode %S" mode))
  (or (selection-owner-p)
      (error "XEmacs does not own the primary selection"))
  (setq last-command nil)
  (or primary-selection-extent
      (error "the primary selection is not an extent?"))
  (save-excursion
    (let (rect-p b s e)
      (cond
       ((consp primary-selection-extent)
	(message "consp")
	(setq rect-p t
	      b (extent-object (car primary-selection-extent))
	      s (extent-start-position (car primary-selection-extent))
	      e (extent-end-position (car (reverse primary-selection-extent)))))
       (t
	(message "t")
	(setq rect-p nil
	      b (extent-object primary-selection-extent)
	      s (extent-start-position primary-selection-extent)
	      e (extent-end-position primary-selection-extent))))
      (message "b: %s, s: %s, e: %s" b s e)
      (set-buffer b)
      (cond ((memq mode '(cut copy))
	     (if rect-p
		 (progn
		   ;; why is killed-rectangle free?  Is it used somewhere?
		   ;; should it be defvarred?
		   (setq killed-rectangle (extract-rectangle s e))
		   (kill-new (mapconcat #'identity killed-rectangle "\n")))
	       (copy-region-as-kill s e))
	     ;; Maybe killing doesn't own clipboard.  Make sure it happens.
	     ;; This memq is kind of grody, because they might have done it
	     ;; some other way, but owning the clipboard twice in that case
	     ;; wouldn't actually hurt anything.
	     (or (and (consp kill-hooks) (memq 'own-clipboard kill-hooks))
		 (own-clipboard (car kill-ring)))))
      (cond ((memq mode '(cut clear))
	     (if rect-p
		 (delete-rectangle s e)
	       (delete-region s e))))
      (disown-selection nil)
      )))




(defun isearch-yank-char ()
  "Pull next word from buffer into search string."
  (interactive)
  (isearch-yank 'forward-char))
isearch-yank-char

(define-key isearch-mode-map [(control \')] 'isearch-yank-char)
isearch-yank-char

isearch-yank-char


isearch-yank-char

isearch-yank-char

(define-key isearch-mode-map "\C-f" 'isearch-yank-char)
isearch-yank-char

(put 'isearch-yank-char 'isearch-command t)
t


========================
2004-03-03T22:51:39
--
(defun dp-copy-primary-selection (&optional arg)
  "Copy selection if it exists, else the current line."
  (interactive "p")
  (let ((opoint (point)))
    (message ">%s<" (mark))
    (dp-mark-line-if-no-mark)
    (message ">%s<" (mark))
    ;;(own-selection (buffer-substring (mark) (point)))
    (dmessage "r>%s<" (cons (point-marker t) (mark-marker t)))
    (activate-region-as-selection)
    (copy-primary-selection)
    (goto-char opoint)
    (dp-deactivate-mark)))



(defun mew-window-pop ()
  (let* ((frame (selected-frame))
	 (assoc (assoc frame mew-window-stack)))
    (if (and assoc (window-configuration-p (cdr assoc)))
	(progn
	  (dmessage "set-window-configuration %s" (cdr assoc))
	  (set-window-configuration (cdr assoc)))
      (dmessage "switch-to-buffer %s"
		(get-buffer-create mew-window-home-buffer))
      (switch-to-buffer (get-buffer-create mew-window-home-buffer)))
    (setq mew-window-stack (delq assoc mew-window-stack))))


========================
2004-04-02T12:08:47
--

(setq dped-list
      dp-From:-suffix-alist
      `(("To:\\|Cc:" ("xemacs" . ".xemacs"))
	("To:\\|Cc:" ("freebsd" . ".freebsd"))
	("To:\\|Cc:" ("mew" . ".mew"))
	("To:\\|Cc:" ("sawfish" . ".sawfish"))
	("To:\\|Cc:" ("amazon.com" . ".amazon"))
	("To:\\|Cc:" ("buy.com" . ".buy.com"))
	("To:\\|Cc:" ("chelmervalve" . ".cvc"))
	("To:\\|Cc:" ("uce@ftc.gov" . ".uce"))
	("To:\\|Cc:" ("2k3\\|2003" . "chicxulub"))
	("To:\\|Cc:" ("jobs" . ".jobs@crickhollow.org"))
	("To:\\|Cc:" ("katz" . ".jobs@crickhollow.org"))
	("To:\\|Cc:" ("bob@rail.com" . ".jobs@crickhollow.org"))
	("To:\\|Cc:" (,dp-homeys . "%fdavep@crickhollow.org"))
	("To:\\|Cc:" ("classmates.com" . ".classmates"))
	("To:\\|Cc:" ("sonicfoundry.com" .
		      "annoying.and.intrusive.registrations"))
	("To:" ("@crickhollow.org" . "%fdavep@crickhollow.org"))
	))

(let
(mew-refile-guess-alist dped-list)

========================
2004-04-03T01:42:03
--
;; (make-vector LENGTH 0)
;; dp-From:-suffix-alist
(defvar dp-From:-suffix-obarray (make-vector 32 0)
  "Obarray for holding generated symbols used by my mail From:
rewriting rules.")

(defun dp-generate-tmp (&optional arg oba)
  (let ((obarray (or oba obarray)))
    (gentemp arg)))

(defun dp-setq-tmp-name (val &optional arg oba)
  (let ((sym (dp-generate-tmp arg oba)))
    (set sym val)
    (format "%s" sym)))

(defun dp-deref-symbol-name (name &optional oba)
  (eval (intern name oba)))

(defun dp-mail-setq-tmp-name (val)
  (dp-setq-tmp-name val "dp-mail-tmp-" dp-From:-suffix-obarray))

(defun dp-mail-deref-name (name)
  (dp-deref-symbol-name name dp-From:-suffix-obarray))



dp-From:-suffix-obarray
[0 0 G6132 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 G6104 G6105 G6106 G6107 0 0 0 0 0 0 0 0]

[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 G6104 0 0 0 0 0 0 0 0 0 0 0]

[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]


(symbolp (dp-generate-tmp nil dp-From:-suffix-obarray))
t

nil

G6105

G6104

(setq x `( "booo" . ,(dp-mail-setq-tmp-name '(1 2 3 4))))
("booo" . "dp-mail-tmp-6655")


("booo" . "G6132")

(dp-deref-mail-name "dp-mail-tmp-6655")
(1 2 3 4)

\,val

val

nil

t

(1 2 3 4)

(1 2 3 4)

(setq dp-From:-suffix-alist
      `(("To:\\|Cc:" ("xemacs" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".xemacs"))))
	("To:\\|Cc:" ("freebsd" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".freebsd"))))
	("To:\\|Cc:" ("mew" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".mew"))))
	("To:\\|Cc:" ("sawfish" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".sawfish"))))
	("To:\\|Cc:" ("amazon.com" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".amazon"))))
	("To:\\|Cc:" ("buy.com" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".buy.com"))))
	("To:\\|Cc:" ("chelmervalve" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".cvc"))))
	("To:\\|Cc:" ("uce@ftc.gov" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".uce"))))
	("To:\\|Cc:" ("2k3\\|2003" . 
		      ,(dp-mail-setq-tmp-name '(:user "chicxulub"
						:fullname ""))))
	("To:\\|Cc:" ("jobs\\|katz\\|bob@rail.com" . 
		      ,(dp-mail-setq-tmp-name '(suffix: ".jobs"
					        domain: "crickhollow.org"))))
	("To:\\|Cc:" (,dp-homeys . 
		      ,(dp-mail-setq-tmp-name '(:user "davep"
					        :domain "crickhollow.org"))))
	("To:\\|Cc:" ("classmates.com" . 
		      ,(dp-mail-setq-tmp-name '(:suffix ".classmates"))))
	("To:\\|Cc:" ("sonicfoundry.com" .
		      ,(dp-mail-setq-tmp-name '(:user 
						"annoying.and.intrusive.registrations"))))
	("To:" ("@crickhollow.org" . 
		,(dp-mail-setq-tmp-name '(:user "davep"
					 :domain "crickhollow.org"))))
	)
      )
(pprint dp-From:-suffix-alist)
(("To:\\|Cc:"
  ("xemacs" . "dp-mail-tmp-6978"))
 ("To:\\|Cc:"
  ("freebsd" . "dp-mail-tmp-6979"))
 ("To:\\|Cc:"
  ("mew" . "dp-mail-tmp-6980"))
 ("To:\\|Cc:"
  ("sawfish" . "dp-mail-tmp-6981"))
 ("To:\\|Cc:"
  ("amazon.com" . "dp-mail-tmp-6982"))
 ("To:\\|Cc:"
  ("buy.com" . "dp-mail-tmp-6983"))
 ("To:\\|Cc:"
  ("chelmervalve" . "dp-mail-tmp-6984"))
 ("To:\\|Cc:"
  ("uce@ftc.gov" . "dp-mail-tmp-6985"))
 ("To:\\|Cc:"
  ("2k3\\|2003" . "dp-mail-tmp-6986"))
 ("To:\\|Cc:"
  ("jobs\\|katz\\|bob@rail.com" . "dp-mail-tmp-6987"))
 ("To:\\|Cc:"
  ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "dp-mail-tmp-6988"))
 ("To:\\|Cc:"
  ("classmates.com" . "dp-mail-tmp-6989"))
 ("To:\\|Cc:"
  ("sonicfoundry.com" . "dp-mail-tmp-6990"))
 ("To:"
  ("@crickhollow.org" . "dp-mail-tmp-6991")))
"((\"To:\\\\|Cc:\"
  (\"xemacs\" . \"dp-mail-tmp-6978\"))
 (\"To:\\\\|Cc:\"
  (\"freebsd\" . \"dp-mail-tmp-6979\"))
 (\"To:\\\\|Cc:\"
  (\"mew\" . \"dp-mail-tmp-6980\"))
 (\"To:\\\\|Cc:\"
  (\"sawfish\" . \"dp-mail-tmp-6981\"))
 (\"To:\\\\|Cc:\"
  (\"amazon.com\" . \"dp-mail-tmp-6982\"))
 (\"To:\\\\|Cc:\"
  (\"buy.com\" . \"dp-mail-tmp-6983\"))
 (\"To:\\\\|Cc:\"
  (\"chelmervalve\" . \"dp-mail-tmp-6984\"))
 (\"To:\\\\|Cc:\"
  (\"uce@ftc.gov\" . \"dp-mail-tmp-6985\"))
 (\"To:\\\\|Cc:\"
  (\"2k3\\\\|2003\" . \"dp-mail-tmp-6986\"))
 (\"To:\\\\|Cc:\"
  (\"jobs\\\\|katz\\\\|bob@rail.com\" . \"dp-mail-tmp-6987\"))
 (\"To:\\\\|Cc:\"
  (\"filko\\\\|mel@digital\\\\.net\\\\|thayer\\\\|be_unique@\\\\|gouge\\\\|buchner\\\\|woodruff\\\\|dake\\\\|page_lee\\\\|leep@\\\\|grotefend\\\\|borzner\\\\|mattison\\\\|lepper\\\\|ghofrani\\\\|auld\\\\|mattisjo@\" . \"dp-mail-tmp-6988\"))
 (\"To:\\\\|Cc:\"
  (\"classmates.com\" . \"dp-mail-tmp-6989\"))
 (\"To:\\\\|Cc:\"
  (\"sonicfoundry.com\" . \"dp-mail-tmp-6990\"))
 (\"To:\"
  (\"@crickhollow.org\" . \"dp-mail-tmp-6991\")))
"




(dp-deref-mail-name "G6630")
(:suffix ".xemacs")
(dp-deref-mail-name "dp-mail-tmp-6683")
(:suffix ".xemacs")


(plist-get (dp-deref-mail-name "dp-mail-tmp-6683") ':suffix)
".xemacs"


nil

".xemacs"

(dp-deref-mail-name "dp-mail-tmp-6640")
val


(defun dp-mail-generate-from-element (val def-val
				       &optional format-string)
;;    use (or list-val def-var-sym)
;;    on format.
;;    simple "%s"
;;    or "\"%s\" " for fullname
;;    suffix will need an extra . is present.
;;    nil format arg --> "%s"d
  (format (or format-string "%s") (or val def-val)))

(defun dp-mail-generate-fullname (val &optional def-val)
  (let ((v (or val def-val)))
    (if (and v
	     (not (string= v "")))
	(format "\"%s\" " v)
      "")))

(defun dp-mail-generate-from (from-suffix)
  "Create a From: value given FROM-SUFFIX.
If FROM-SUFFIX contains an `@', then the substring after the `@' is used
 instead of `dp-mail-domain' below.
If FROM-SUFFIX begins w/., then it is a user-name suffix and is composited 
with `dp-mail-fullname', `dp-mail-user' and `dp-mail-domain'.
Otherwise begins w/`dp-mail-user', then we format as with `.', except 
we assume that the FROM-SUFFIX contains the user name, too.
Otherwise the FROM-SUFFIX and the domain are used to form the return value."
  (let* ((suffix-plist (dp-mail-deref-name from-suffix)))
    (format "%s<%s%s@%s>" 
	    (dp-mail-generate-fullname (plist-get suffix-plist 
						  ':fullname)
				       dp-mail-fullname)
	    
	    (dp-mail-generate-from-element (plist-get suffix-plist 
						      ':user)
					   dp-mail-user)
	    (dp-mail-generate-from-element (plist-get suffix-plist
						      ':suffix)
					   "")
	    (dp-mail-generate-from-element (plist-get suffix-plist
						      ':domain)
					   dp-mail-domain))))
						  
	  

(dp-mail-generate-from "dp-mail-tmp-6989")
"\"David A. Panariti\" <davep.classmates@meduseld.net>"

"\"David A. Panariti\" <davep.xemacs@meduseld.net>"

(dp-mail-deref-name "dp-From:-suffix-alist")

(:user "chicxulub")


(format "")
""


========================
2004-07-31T13:31:04
--
(defun own-selection (data &optional type how-to-add data-type)
  "Make a window-system selection of type TYPE and value DATA.
The argument TYPE (default `PRIMARY') says which selection,
and DATA specifies the contents.  DATA may be any lisp data type
that can be converted using the function corresponding to DATA-TYPE
in `select-converter-alist'---strings are the usual choice, but
other types may be permissible depending on the DATA-TYPE parameter
\(if DATA-TYPE is not supplied, the default behavior is window
system specific, but strings are always accepted).
HOW-TO-ADD may be any of the following:

  'replace-all or nil -- replace all data in the selection.
  'replace-existing   -- replace data for specified DATA-TYPE only.
  'append or t        -- append data to existing DATA-TYPE data.

DATA-TYPE is the window-system specific data type identifier
\(see `register-selection-data-type' for more information).

The selection may also be a cons of two markers pointing to the same buffer,
or an overlay.  In these cases, the selection is considered to be the text
between the markers *at whatever time the selection is examined* (note
that the window system clipboard does not necessarily duplicate this
behavior - it doesn't on mswindows for example).
Thus, editing done in the buffer after you specify the selection
can alter the effective value of the selection.

The data may also be a vector of valid non-vector selection values.

Interactively, if no prefix arg, the selection value is promped for,
otherwise, the text of the region is used as the selection value."

  (interactive (if (not current-prefix-arg)
		   (progn
		     (message "no prefix arg")
		     (list (read-string "Store text for pasting: ")))
		 (message "prefix arg")
		 (list (buffer-substring (region-beginning) (region-end)))))

  ;; calling own-selection-internal will mess this up, so preserve it.
  (let ((zmacs-region-stays zmacs-region-stays))
					;FSFmacs huh??  It says:
    ;; "This is for temporary compatibility with pre-release Emacs 19."
					;(if (stringp type)
					;    (setq type (intern type)))
    (or type (setq type 'PRIMARY))
    (if (null data)
	(disown-selection-internal type)
      (own-selection-internal type data how-to-add data-type)
      (when (and (eq type 'PRIMARY)
		 selection-sets-clipboard)
	 (own-selection-internal 'CLIPBOARD data how-to-add data-type)))
    (cond ((eq type 'PRIMARY)
	   (setq primary-selection-extent
		 (select-make-extent-for-selection
		  data primary-selection-extent)))
	  ((eq type 'SECONDARY)
	   (setq secondary-selection-extent
		 (select-make-extent-for-selection
		  data secondary-selection-extent)))))
  ;; zmacs-region-stays is for commands, not low-level functions.
  ;; when behaving as the latter, we better not set it, or we will
  ;; cause unwanted sticky-region behavior in kill-region and friends.
  (if (interactive-p)
  (setq zmacs-region-stays t))
  data)
========================
2004-10-23T13:26:02
--

=
==
===



(defun dp-first-word ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    ;; skip whitespace
    (when (looking-at dp-ws)
      (goto-char (match-beginning 1)))
    ;; make sure we have a symbol character
    (when (looking-at "[a-z][A-Z_]+")
      (let ((word-one (match-string 1)))
        (if (or (string= word-one "extern")
                
========================
2004-11-04T21:29:58
--
       /  They are relatively good but absolutely terrible.
davep (|)                 -- Alan Kay, commenting on Apollos
       /  ly 
$         

(dp-string-join (dp-zip-lists-padded dp-sig-prefix 
				       (dp-exec-short-fortune)
				       'dp-exec-short-fortune
				       dp-baroque-sig-max-lines)
		  "\n")

(setq f "They are relatively good but absolutely terrible.
                -- Alan Kay, commenting on Apollos")
"They are relatively good but absolutely terrible.
                -- Alan Kay, commenting on Apollos"

"They are relatively good but absolutely terrible.
                -- Alan Kay, commenting on Apollos
"

"They are relatively good but absolutely terrible.
                -- Alan Kay, commenting on Apollos"

"They are relatively good but absolutely terrible.
                -- Alan Kay, commenting on Apollos
"

(dp-string-join (dp-zip-lists-padded dp-sig-prefix 
				       f
				       'dp-exec-short-fortune
				       dp-baroque-sig-max-lines)
		  "\n")
"       /  
davep (|) They are relatively good but absolutely terrible.
       /                  -- Alan Kay, commenting on Apollos
$         "




(defun execute-extended-command (prefix-arg)
  "Read a command name from the minibuffer using 'completing-read'.
Then call the specified command using 'command-execute' and return its
return value.  If the command asks for a prefix argument, supply the
value of the current raw prefix argument, or the value of PREFIX-ARG
when called from Lisp."
  (interactive "P")
  ;; Note:  This doesn't hack "this-command-keys"
  (let ((prefix-arg prefix-arg))
    (setq this-command (read-command
                        ;; Note: this has the hard-wired
                        ;;  "C-u" and "M-x" string bug in common
                        ;;  with all Emacs's.
			;; (i.e. it prints C-u and M-x regardless of
			;; whether some other keys were actually bound
			;; to `execute-extended-command' and 
			;; `universal-argument'.
                        (cond ((eq prefix-arg '-)
                               "- M-x ")
                              ((equal prefix-arg '(4))
                               "C-u M-x ")
                              ((integerp prefix-arg)
                               (format "%d M-x " prefix-arg))
                              ((and (consp prefix-arg)
                                    (integerp (car prefix-arg)))
                               (format "%d M-x " (car prefix-arg)))
                              (t
                               "M-x ")))))

  (if (and teach-extended-commands-p
	   (interactive-p))
      ;; Remember the keys, run the command, and show the keys (if
      ;; any).  The funny variable names are a poor man's guarantee
      ;; that we don't get tripped by this-command doing something
      ;; funny.  Quoth our forefathers: "We want lexical scope!"
      (let ((_execute_command_keys_ (where-is-internal this-command))
	    (_execute_command_name_ this-command)) ; the name can change
        (if extended-command-calls-pre-command-hook-p
            (run-hooks 'pre-command-hook))
	(command-execute this-command t)
        (if extended-command-calls-post-command-hook-p
            (run-hooks 'post-command-hook))
	(when _execute_command_keys_
	  ;; Normally the region is adjusted in post_command_hook;
	  ;; however, it is not called until after we finish.  It
	  ;; looks ugly for the region to get updated after the
	  ;; delays, so we do it now.  The code below is a Lispified
	  ;; copy of code in event-stream.c:post_command_hook().
	  (if (and (not zmacs-region-stays)
		   (or (not (eq (selected-window) (minibuffer-window)))
		       (eq (zmacs-region-buffer) (current-buffer))))
	      (zmacs-deactivate-region)
	    (zmacs-update-region))
	  ;; Wait for a while, so the user can see a message printed,
	  ;; if any.
	  (when (sit-for 1)
	    (display-message
		'no-log
	      (format (if (cdr _execute_command_keys_)
			  "Command `%s' is bound to keys: %s"
			"Command `%s' is bound to key: %s")
		      _execute_command_name_
		      (sorted-key-descriptions _execute_command_keys_)))
	    (sit-for teach-extended-commands-timeout)
	    (clear-message 'no-log))))
    ;; Else, just run the command.
    (if extended-command-calls-pre-command-hook-p
        (run-hooks 'pre-command-hook))
    (let ((ret (command-execute this-command t)))
      (if extended-command-calls-post-command-hook-p
          (run-hooks 'post-command-hook))
      ret)))


(defconst extended-command-calls-pre-command-hook-p t
  "*Should `execute-extended-command' call pre-command-hook functions before
executing the command read from the mini-buffer?")
extended-command-calls-pre-command-hook-p

(defconst extended-command-calls-post-command-hook-p t
  "*Should `execute-extended-command' call post-command-hook functions after
executing the command read from the mini-buffer?")
extended-command-calls-post-command-hook-p

(defmacro dp-isa-go-back (func)
  `(put ',func 'dp-pre-command-hook '(dp-push-go-back)))
dp-isa-go-back


(macroexpand '(dp-isa-go-back wah))

(setq wah 1)
1

(put (quote wah) (quote dp-pre-command-hook) (quote (dp-push-go-back)))
(dp-push-go-back)

(symbol-plist 'wah)
(dp-pre-command-hook (dp-push-go-back))


(funcall (car (get 'ff 'dp-pre-command-hook)))
(#<marker at 24149 in elisp-devel.el 0x8f3609c> #<marker at 65306 in dpmisc.el 0x8f664e4> #<marker at 1 in dpmisc.el 0x8ffbc3c> #<marker at 65274 in dpmisc.el 0x8ffbd14> #<marker at 2926 in dpmisc.el 0x8f6132c> #<marker at 1 in elisp-devel-1.el 0x8914ebc> #<marker in no buffer 0x8fd8b5c> #<marker in no buffer 0x908d80c> #<marker at 1 in elisp-devel.el 0x89ac01c> #<marker at 23878 in elisp-devel.el 0x8a519bc> #<marker at 1 in elisp-devel.el 0x8fd85d4> #<marker at 1 in dp-hooks.el 0x8a51adc>)

dp-push-go-back

(dp-push-go-back)
nil



(defun dp-pre-command-hook2 ()
  ;;(dmessage "pch:%s" this-command)
  ;;(if (eq 'find-function this-command) (dmessage("ff")))
  (let ((dp-data))
    (when (and this-command
               (symbolp this-command)
               (setq dp-data (get this-command 'dp-pre-command-hook)))
      (dmessage "dp-data>%s<" dp-data)
      (funcall (car dp-data)))))


(let ((this-command 'ff))
  (dp-pre-command-hook2))
(#<marker at 25097 in elisp-devel.el 0x908d74c> #<marker at 24149 in elisp-devel.el 0x89aba64> #<marker at 65306 in dpmisc.el 0x8f664e4> #<marker at 1 in dpmisc.el 0x8ffbc3c> #<marker at 65274 in dpmisc.el 0x8ffbd14> #<marker at 2926 in dpmisc.el 0x8f6132c> #<marker at 1 in elisp-devel-1.el 0x8914ebc> #<marker in no buffer 0x8fd8b5c> #<marker in no buffer 0x908d80c> #<marker at 1 in elisp-devel.el 0x89ac01c> #<marker at 23878 in elisp-devel.el 0x8a519bc> #<marker at 1 in elisp-devel.el 0x8fd85d4> #<marker at 1 in dp-hooks.el 0x8a51adc> #<marker at 24645 in elisp-devel.el 0x8f3a98c>)





========================
Sunday November 28 2004
--
(defmacro dp-defcustom-local (symbol value args docstring &rest body)

(defmacro defun-pre-go-back (name args docstring &rest body)
  (let (interactive)
    (if (stringp docstring)
        (setq docstring (format "%s\n(pre-go-back)" docstring))
      (setq args (cons docstring args))
      (setq docstring "(pre-go-back)"))
    (when (eq (car-safe (car-safe args)) 'interactive)
        (setq interactive (car-safe) args)
        (setq args (cdr-safe args)))
    `(defun ,name ,args
      ,interactive
      (dp-push-go-back)
      
    
========================
2004-11-30T11:02:08
--

(defun m-h-end ()
  (save-restriction
    (widen)
    (dmessage "mhe: bn>%s<, bfn>%s<, pmin: %d" 
              (buffer-name) (buffer-file-name) (point-min))
    (next-single-property-change (point-min) 'read-only)))

(defun mew-encode-make-header (&optional addsep resentp)
  (unless (mew-header-existp mew-mv:)
    (goto-char (m-h-end))
    (mew-header-insert mew-mv: mew-mv:-num))
  (mew-header-encode-region (point-min) (mew-header-end) resentp)
  (cond
   (addsep ;; reedit
    ;; To:
    ;; Content-*
    ;; ----
    (mew-header-clear) ;; mew-in-header-p() returns nil
    ;; To:
    ;; Content-*
    (insert "\n"))
   (t
    ;; To:
    ;; ----
    ;; Content-*
    (mew-header-clear) ;; mew-in-header-p returns nil
    ;; To:
    ;; Content-*
    ))
  (mew-header-goto-end)
  (mew-highlight-header-region (point-min) (point)))

(defun mew-smtp-encode-message (pnm case resentp fcc &optional privacy signer headerp)
  (dmessage "100: bn>%s<, bfn>%s<, pmin: %d" 
            (buffer-name) (buffer-file-name) (point-min))
  (mew-set-buffer-multibyte t)
  (if (buffer-modified-p) (save-buffer)) ;; to make backup
  (widen)
  (let (multip recipients msgid-logtime)
    (mew-smtp-set-raw-header
     pnm (mew-buffer-substring (point-min) (mew-header-end)))
    (unless headerp
      ;; Let's backup
      (if (mew-attach-p)
	  (progn
	    (setq multip t)
	    (mew-attach-clear))
	(unless mew-encode-syntax
	  (setq mew-encode-syntax
		(mew-encode-syntax-single "text.txt" (list mew-ct-txt)))))
      (mew-encode-make-backup))
    ;; Errors can be caused from here.
    (goto-char (point-min))
    (mew-encode-remove-invalid-fields)
    ;; Destination check
    (setq recipients (mew-encode-canonicalize-address resentp))
    ;; Bcc: is not included.
    (mew-smtp-set-recipients pnm recipients)
    (mew-smtp-set-orig-recipients pnm recipients)
    (cond
     ((null recipients)
      (mew-encode-error "No recipient!"))
     ((stringp recipients)
      (mew-encode-error (format "'%s' is not in the right form!" recipients))))
    ;; Header modifications which are not remained.
    (mew-header-delete-lines (list mew-fcc: mew-resent-fcc:)) ;; anyway
    (mew-smtp-set-dcc pnm (mew-encode-delete-dcc resentp))
    (mew-smtp-set-bcc pnm (mew-encode-delete-bcc resentp))
    (mew-smtp-set-fcc pnm fcc)
    ;;
    (mew-encode-check-sender resentp)
    (mew-encode-from case resentp)
    ;;
    (setq msgid-logtime (mew-encode-id-date pnm (mew-smtp-message-id case) resentp))
    (mew-smtp-set-msgid pnm (nth 0 msgid-logtime))
    (mew-smtp-set-logtime pnm (nth 1 msgid-logtime))
    ;;
    (goto-char (mew-header-end))
    (forward-line) ;; necessary for PGP
    ;;
    (message "Making a message...")
    ;; save syntax before setting privacy
    (dmessage "200: bn>%s<, bfn>%s<, pmin: %d" 
              (buffer-name) (buffer-file-name) (point-min))
    (unless headerp
      (mew-encode-set-privacy pnm privacy)
      (let ((mew-inherit-encode-signer (or signer (mew-get-my-address))))
	(goto-char (mew-header-end)) ;; due to invalid null lines in the header
	(forward-line)
	(if multip
	    (mew-encode-make-multi) ;;<<<<<<<<<<< changes current buffer
	  (mew-encode-make-single))))
    (dmessage "300: bn>%s<, bfn>%s<, pmin: %d" 
              (buffer-name) (buffer-file-name) (point-min))
    (mew-encode-make-header headerp resentp)
    ;; Learn aliases after no error occurred
    (mew-encode-learn-aliases resentp)
    (mew-encode-save-draft)
    (mew-overlay-delete-buffer)
    (message "Making a message...done")))

(defun mew-encode-multipart (syntax path depth &optional buffered)
  (let* ((boundary
	  (mew-boundary-get ;; 0 is nil for Next_Part
	   (if (> depth 0) (format "BOUNDARY%s" (int-to-string depth)))))
	 (fullname (expand-file-name (mew-syntax-get-file syntax) path))
	 (ctl (mew-syntax-get-ct syntax))
	 (ct (mew-syntax-get-value ctl 'cap))
	 (cd (mew-syntax-get-cd syntax))
	 (privacy (mew-syntax-get-privacy syntax))
	 (mew-inherit-7bit (mew-encode-limit-7bitp privacy))
	 (len (length syntax))
	 (beg (point))
	 (cnt mew-syntax-magic)
	 (8bit-cnt 0)
	 8bitp cte-pos cover)
    (mew-header-insert mew-ct: (list ct (list "boundary" boundary)))
    (setq cte-pos (point))
    (and cd (mew-header-insert mew-cd: cd))
    (while (< cnt len)
      (insert "\n--" boundary "\n")
      (if (mew-syntax-multipart-p (aref syntax cnt))
	  (setq 8bitp (mew-encode-multipart 
		       (aref syntax cnt)
		       fullname
		       (1+ depth)))
	(if (and (= depth 0) (= cnt mew-syntax-magic ))
	    (setq cover t)
	  (setq cover nil))
	(setq 8bitp (mew-encode-singlepart
		     (aref syntax cnt)
		     fullname
		     (1+ depth)
		     (if (eq cnt mew-syntax-magic) buffered nil)
		     cover)))
      (if 8bitp (setq 8bit-cnt (1+ 8bit-cnt)))
      (setq cnt (1+ cnt)))
    (insert "\n--" boundary "--\n")
    (save-excursion
      (goto-char cte-pos)
      (mew-header-insert mew-cte: (if (> 8bit-cnt 0) mew-8bit mew-7bit)))
    (when privacy 
      (mew-encode-security-multipart
       beg privacy depth (mew-syntax-get-decrypters syntax)))
    (goto-char (point-max))
    (> 8bit-cnt 0)))
========================
2004-12-03T17:44:32
--

(defun dp-copy-word (&optional delim-reg-exp)
  (interactive)
  (setq-ifnil delim-reg-exp " ")
  


(defun dp-copy-chars ()
  "Copy character from the line above the cursor to point."
  (interactive "*")
  (let (gotChar 
	(oldgCol temporary-goal-column) ;we want to go up in same col
	(col (current-column)))
    (save-excursion
      (setq temporary-goal-column (current-column))
      (previous-line 1)			; previous-line uses goal column
      ; if the col we were at is less than the col we've gone to,
      ; then we've moved up to the character *after* the virtual
      ; space printed when a tab is expanded on the screen,
      ; so we fake things by returning a space
      (if(< col (current-column))		; we've upped to a tab
	  (setq gotChar ?\ )
	(setq gotChar (following-char)))
    )
    (insert-char gotChar 1)
    (setq temporary-goal-column oldgCol)
    gotChar))

========================
2005-04-26T09:39:42
--
(defun dp-set-eof-spacing (&optional num-lines)
  "Add spacing to EOF to ensure `num-lines' blank lines at eof."
  (interactive)
  (let* (add-str
         (num-lines (or num-lines 1))
         (lines (mapconcat 'identity (make-list (1+ num-lines) "\n") ""))
         (bs0 (concat "[^" dp-ws+newline "]"))
         (bs (concat bs0 bs0 "*"))
         (fs (concat "[" dp-ws+newline "]*")))
    (goto-char (point-max))
    ;; ensure we have at least one newline to match at EOB
    (insert "\n")
    (dmessage "bs>%s<" bs)
    (re-search-backward bs)
    (forward-char)
    ;;(insert "<<<<<<<<<<<<<<<<<<<")
     (re-search-forward fs (point-max))
     (dmessage "match-string>%s<" (match-string 0))
     (replace-match lines)
))


(make-vector 4 "a")
["a" "a" "a" "a"]

(make-string 4 ?a)
"aaaa"

(make-list 4 "aa|")
("aa|" "aa|" "aa|" "aa|")

(concat (make-list 4 "aa|"))

(concat "aa|" "aa|" "aa|")
"aa|aa|aa|"

(mapconcat 'identity (make-list 4 "aa|") "")
"aa|aa|aa|aa|"

(concat "[" dp-ws+newline "]*")
"[

]*"


========================
Thursday June 02 2005
--
(defun py-outdent-p ()
  "Returns non-nil if the current line should dedent one level."
  (save-excursion
    (and (progn (back-to-indentation)
		(looking-at py-outdent-re))
	 ;; short circuit infloop on illegal construct
	 (not (bobp))
	 (progn (forward-line -1)
		(py-goto-initial-line)
		(back-to-indentation)
		(while (and (not (looking-at py-no-outdent-re))
                            (not (bobp)))
		  (backward-to-indentation 1))
		(not (looking-at py-no-outdent-re)))
	 )))





(defun py-indent-line (&optional arg)
  (interactive "P")
  (dmessage "WHY?")
  (let* ((ci (current-indentation))
	 (move-to-indentation-p (<= (current-column) ci))
	 (need (py-compute-indentation (not arg))))
    ;; see if we need to dedent
    (if (py-outdent-p)
	(setq need (- need py-indent-offset)))
    (if (/= ci need)
	(save-excursion
	  (beginning-of-line)
	  (delete-horizontal-space)
	  (indent-to need)))
    (if move-to-indentation-p (back-to-indentation))))

(py-indent-line)


========================
Friday July 22 2005
--

(symbol-value 'find-file-hooks)
(dp-add-default-buffer-endicator font-lock-set-defaults tramp-set-auto-save)

(variable-documentation 1062075)

find-file-hooks

(remove-hook 'find-file-hooks 'dp-add-default-buffer-endicator)
(font-lock-set-defaults tramp-set-auto-save)


(pop-to-buffer buffer t frame)
(pop-to-buffer buffer t frame)
(get-other-frame)
#<x-frame "XEmacs" 0x39852>

#<x-frame "XEmacs" 0x6d506>

(selected-frame)
#<x-frame "XEmacs" 0x6d506>

#<x-frame "XEmacs" 0x6d506>


(let ((of (get-other-frame)))
  (pop-to-buffer "*shell*" t of)
  (list of (selected-frame)))
(#<x-frame "XEmacs" 0x39852> #<x-frame "XEmacs" 0x6d506>)

#<x-frame "XEmacs" 0x39852>


(get-buffer "*shell*")
#<buffer "*shell*">






(condition-case nil
    (progn
      
      (pop-to-buffer buffer t (get-other-frame))

(defun dp-shell2 (&optional split-window-p)
  "Open/visit a shell buffer.
SPLIT-WINDOW-P t --> split window before switching to shell.
@todo this sucks: redo, possibly using sb, sb2 logic."
  (interactive "P")
  (if split-window-p
      (let ((sh-buffer (get-buffer "*shell*"))
            (if sh-buffer
                (condition-case nil
                    (pop-to-buffer sh-buffer t (get-other-frame))
                  (error
                   (switch-to-buffer-other-window "*shell*")))
              (split-window-vertically)))))
  (shell))


(defun dp-shell-xxx-input (get-pmark-fun
                           at-pmark-fun
                           after-pmark-fun
                           before-pmark-fun
                           mark-active-fun)
  "Retrieve from history or move cursor, depending on location of point.
Uses AFTER-PMARK-P-FUN to determine if point is on command line or in
old output area.  If on command line, and the mark is not active, use
XXX-INPUT-FUN to access history, otherwise use MOVE-FUN to move
cursor.
We assume that if the mark is active that we should use MOVE-FUN instead
of a XXX-INPUT-FUN."
  (interactive)
  (let ((fun 
         (if (dp-mark-active-p)
             mark-active-fun
           ;;else
           (let ((pmark (funcall get-pmark-fun))
                 (pt (point)))
             (cond 
              ((= pmark pt) at-pmark-fun)
              ((< pmark pt) after-pmark-fun)
              ((> pmark pt) before-pmark-fun))))))
    (dp-set-zmacs-region-stays t)
    (dmessage "call-interactively xxx-fun: %s" fun)
    (call-interactively fun)
    (setq this-command fun)
    (dp-term-set-mode-from-pos)))


(defun dp-shell-line-mode-bindings (variant &optional bind-up-n-down)
  "Bind some shell-mode keys."
  (dmessage "boop")
  (when bind-up-n-down
    (dmessage "yoop")
    (local-set-key "\C-p" `(lambda ()
                             (interactive)
                             (dp-shell-xxx-input
                              dp-comint-pmark
                              ;; at: up
                              'previous-line
                              ;; after: match
                              (dp-sls (quote ,variant) 
                                      '-previous-matching-input-from-input)
                              ;; before: up
                              'previous-line
                              ;; mark active: up
                              'previous-line)))
    (local-set-key [up] `(lambda ()
                           (interactive)
                           (dp-shell-xxx-input
                            'dp-comint-pmark
                            ;; at: prev input
                            (dp-sls (quote ,variant) '-previous-input)
                            ;; after: prev input
                            (dp-sls (quote ,variant) '-previous-input)
                            ;; before: up
                            'previous-line
                            ;; mark active: up
                            'previous-line)))
    
    (local-set-key [down] `(lambda ()
                             (interactive)
                             (dp-shell-xxx-input
                              (dp-sls (quote ,variant) '-after-pmark-p)
                              (dp-sls (quote ,variant) '-next-input)
                              'next-line)))
    )
  ;; meta ` is already used by OS X
  ;; replace it by something common to both.
  ;;(local-set-key "\e`" (dp-sls variant '-previous-matching-input-from-input))
  (local-set-key "\C-'" (dp-sls variant '-previous-matching-input-from-input))
  (local-set-key [home] (dp-sls variant '-bol))
  (local-set-key "\C-a" (dp-sls variant '-bol))
  ;;(local-set-key "\C-z" 'dp-shell-init-last-cmds)
  (local-set-key [(control space)] 'expand-abbrev)
  ;; take us back from whence we came.
  (local-set-key "\C-z" 'bury-buffer)
)


(dp-shell-line-mode-bindings 'comint t)
nil


========================
Sunday December 18 2005
--
(defun dpj-mk-external-bookmark ()
  (interactive)
  (let ((boundaries (dp-line-boundaries)))
    (dpj-clone-topic nil (buffer-substring (car boundaries) 
                                           (cdr boundaries)))))
    
        
(defun dp-choose-buffers (predicate &rest pred-args)
  (interactive "sreg-exp: ")
  (let* (regexp)
    (if (stringp predicate)
        (setq pred-args predicate       ;the regexp
              predicate 'string-match)) ;the function
    (delete nil
            (mapcar (lambda (buf)
                      (if (funcall predicate pred-args (buffer-name buf))
                          buf
                        nil))
                    (buffer-list)))))

(defun dp-choose-buffers-names (predicate &rest pred-args)
  (interactive "sreg-exp: ")
  (mapcar (lambda (buf)
            (buffer-name buf))
          (dp-choose-buffers predicate pred-args)))


(dp-choose-buffers ".el")

(#<buffer "elisp-devel.el"> #<buffer "*Help: function `delete'*"> #<buffer "*Help: function `funcall'*"> #<buffer "*Help: function `string-match'*"> #<buffer "dpmisc.el"> #<buffer "*Help: function `interactive'*"> #<buffer "*shell*"> #<buffer "*Hyper Help*">)

(dp-choose-buffers-names ".el")
("elisp-devel.el" "*Help: function `string-match'*" "dpmisc.el" "*Help: function `interactive'*" "*shell*" "*Hyper Help*")

(sort (dp-choose-buffers-names ".el") 'string<)
("*Help: function `interactive'*" 
 "*Help: function `sort'*" 
 "*Help: function `string-match'*" 
 "*Hyper Help*" "*shell*" 
 "dpmisc.el" 
 "elisp-devel.el")

(defun dp-make-command ()
  (interactive "P")
  (let* ((buf-name (car (sort (dp-choose-buffers-names
                               "[Mm]akefile\\(<[0-9]+>\\)?$") 'string<)))
         (file-name (if buf-name
                        (buffer-file-name (get-file-buffer buf-name)))))
    (format "make%s" (if file-name
                         (format " -f %s" file-name)
                       ""))))


(defun dp-make (&optional no-search)
  (interactive)
  (compile (dp-make-command)))

(dp-make)
#<buffer "*compilation*">

(dp-make-command)
"make -f /home/davep/lisp/devel/Makefile"




(defun dp-make ()
(car (sort (dp-choose-buffers-names "[Mm]akefile\\(<[0-9]+>\\)?$") 'string<))
"Makefile"

("Makefile" "Makefile<2>" "makefile")
("Makefile" "Makefile<2>" "makefile")
("Makefile" "makefile")
("Makefile")

(buffer-file-name
 (get-file-buffer (car (sort (dp-choose-buffers-names "[Mm]akefile\\(<[0-9]+>\\)?$") 'string<))))
"/home/davep/lisp/devel/Makefile"

(dp-make-command)
"make -f /home/davep/lisp/devel/makefile"

nil


========================
Saturday December 24 2005
--
(defun dp-maybe-select-other-frame ()
  "Select another frame it one exists."
  (interactive)
  (select-frame (next-frame)))


========================
Thursday December 29 2005
--

(defun next-list-mode-item (n)
  "Move to the next item in list-mode.
With prefix argument N, move N items (negative N means move backward)."
  (interactive "p")
  (while (and (> n 0) (not (eobp)))
    (let ((extent (extent-at (point) (current-buffer) 'list-mode-item))
	  (end (point-max)))
      ;; If in a completion, move to the end of it.
      (if extent (goto-char (extent-end-position extent)))
      ;; Move to start of next one.
      (or (extent-at (point) (current-buffer) 'list-mode-item)
	  (goto-char (next-single-char-property-change (point) 'list-mode-item
						  nil end))))
    (setq n (1- n)))
  (while (and (< n 0) (not (bobp)))
    (let ((extent (extent-at (point) (current-buffer) 'list-mode-item))
	  (end (point-min)))
      ;; If in a completion, move to the start of it.
      (if extent (goto-char (extent-start-position extent)))
      ;; Move to the start of that one.
      (if (setq extent (extent-at (point) (current-buffer) 'list-mode-item
				  nil 'before))
	  (goto-char (extent-start-position extent))
	(goto-char (previous-single-char-property-change
		    (point) 'list-mode-item nil end))
	(if (setq extent (extent-at (point) (current-buffer) 'list-mode-item
				    nil 'before))
	    (goto-char (extent-start-position extent)))))
    (setq n (1+ n))))

(defun switch-to-completions ()
  "Select the completion list window."
  (interactive)
  ;; Make sure we have a completions window.
  (or (get-buffer-window "*Completions*")
      (minibuffer-completion-help))
  (if (not (get-buffer-window "*Completions*"))
      nil
    (select-window (get-buffer-window "*Completions*"))
    (goto-char (next-single-char-property-change 
                (point-min) 'list-mode-item nil (point-max)))))


next-single-char-property-change


========================
Friday December 30 2005
--
(c-hanging-semi&comma-criteria c-semi&comma-inside-parenlist)

(defconst test-c-style
  '((c-tab-always-indent           . nil)
    (c-basic-offset                . 4)
    (c-comment-only-line-offset    . 0)
    (c-cleanup-list                . (scope-operator
				      empty-defun-braces
				      defun-close-semi
				      list-close-comma
				      brace-else-brace
				      brace-elseif-brace
				      knr-open-brace  ; my own addition
				      ))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-offsets-alist               . ((arglist-intro     . +)
				      (substatement-open . 0)
				      (inline-open       . 0)
				      (cpp-macro-cont    . +)
				      (access-label      . /)
				      (statement-cont    . c-lineup-math)
				      (case-label        . +)))
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "Lincoln Labs indentation style")
(c-add-style "test-c-style" test-c-style)

(defun cc-test-style ()
  "Set up ll C/C++ style."
  (interactive)
  (c-set-style "test-c-style"))

(defun dp-c-semi&comma-nada ()
  "Suppress ALL ;-instigated new-linery.
I like the other things (e.g. cleanups) that are available in auto-newline
mode but not the new lines themselves.  Hence, this."
  (interactive)
  (if (eq last-command-char ?\;)
      'stop
    ;; not a semi, keep trying.
    nil))


========================
Sunday January 01 2006 <:dpci:>
--
;; Make this specific to indentation.
(defvar dp-colorize-indentation-faces
  '(dp-cifdef-face0 dp-cifdef-face1 dp-cifdef-face2 dp-cifdef-face3
		    dp-cifdef-face4 dp-cifdef-face5 dp-cifdef-face6)
  "List of faces to cycle thru when highlighting levels of indentation.")

(defvar dp-colorize-indentation-def-width 4)
(defun dp-compute-indentation-face (&optional indentation-width)
  (interactive)
  (dmessage "bip")
  (nth (% (/ (current-indentation) 
             (or indentation-width dp-colorize-indentation-def-width))
          (length dp-colorize-indentation-faces))
       dp-colorize-indentation-faces))

(defvar dp-colorize-indentation-font-lock-keywords
  (let ((matcher "^[ 	][ 	]*"))
    (list 
     (list "^[ 	]" '(0 dp-cifdef-face1)
           (list "[ 	][ 	]*" nil nil 
                 '(dp-compute-indentation-face))))))

(defun dp-setup-indentation-colorization (mode-symbol)
  (interactive)
  (require 'dp-colorize-ifdefs)
  (dmessage "in dp-setup-indentation-colorization")
  (make-local-variable 'font-lock-defaults)
  (dp-set-font-lock-defaults mode-symbol 
                             '(dp-colorize-indentation-font-lock-keywords 
                               t nil nil nil))
  (font-lock-set-defaults))

(dp-set-font-lock-defaults 'text-mode
                           '(dp-colorize-indentation-font-lock-keywords t))
(dp-colorize-indentation-font-lock-keywords t)

(dp-colorize-indentation-font-lock-keywords t)
(dp-compute-indentation-face)
dp-cifdef-face0

(symbol-plist 'c++-mode)
(font-lock-defaults (dp-colorize-indentation-font-lock-keywords t) c-mode-prefix "c++-")

(font-lock-defaults (dp-colorize-indentation-font-lock-keywords t) c-mode-prefix "c++-")

(font-lock-defaults (dp-colorize-indentation-font-lock-keywords t) c-mode-prefix "c++-")

(font-lock-defaults (dp-journal-mode-font-lock-keywords t) c-mode-prefix "c++-")

(font-lock-defaults ((c++-font-lock-keywords c++-font-lock-keywords-1 c++-font-lock-keywords-2 c++-font-lock-keywords-3) nil nil ((?_ . "w") (?~ . "w")) beginning-of-defun) c-mode-prefix "c++-")



========================
Monday January 02 2006 <:indentation-coloring:> <:inc:>
--
(setq orig-kws kws)

(setq ckw (font-lock-compile-keywords orig-kws))
(t ("^[ 	]*\\(a\\)$" (1 dp-cifdef-face0)) ("^[ 	]*" (dp-compute-indentation-face)))


(setq kws ckw)
(t ("^[ 	]*\\(a\\)$" (1 dp-cifdef-face0)) ("^[ 	]*" (dp-compute-indentation-face)))

(setq kwsx (cdr kws))
(("^[ 	]*\\(a\\)$" (1 dp-cifdef-face0)) ("^[ 	]*" (dp-compute-indentation-face)))
(setq kw (car kwsx) matcher (car kw))
"^[ 	]*\\(a\\)$"
kw
("^[ 	]*\\(a\\)$" (1 dp-cifdef-face0))
(car kw)
"^[ 	]*\\(a\\)$"
(setq hl (cdr kw))
((1 dp-cifdef-face0))
(car (car hl))
1



(setq kws (cdr ckw))
(("^[ 	]*\\(a\\)$" (1 dp-cifdef-face0)) ("^[ 	]*" (dp-compute-indentation-face)))

(setq kw (car kws) matcher (car kw))
"^[ 	]*"
kw
("^[ 	]*" (dp-compute-indentation-face))
matcher
"^[ 	]*"


(setq hl (cdr kw))
((dp-compute-indentation-face))

((dp-compute-indentation-face))

(car (car hl))
dp-compute-indentation-face

(setq kws (cdr kws))

(setq hl (cdr kw))
((1 dp-cifdef-face0))

(font-lock-keyword-face)
(car hl)
font-lock-keyword-face
(car (car hl))
(setq x '("^[ 	]*\\(a\\)$" 1 dp-cifdef-face0))
("^[ 	]*\\(a\\)$" 1 dp-cifdef-face0)
kw
("^[ 	]*" (dp-compute-indentation-face))


(car (car '("^[ 	]*\\(a\\)$" 1 dp-cifdef-face0)))

(cdr 
(setq kws dp-colorize-indentation-font-lock-keywords)
(("^[ 	]*\\(a\\)$" 1 dp-cifdef-face0) ("^[ 	]*" dp-compute-indentation-face))

orig-kws
(("^[ 	]*\\(a\\)$" 1 dp-cifdef-face0) ("^[ 	]*" dp-compute-indentation-face))
ckw
(t ("^[ 	]*\\(a\\)$" (1 dp-cifdef-face0)) ("^[ 	]*" (dp-compute-indentation-face)))

hl
((dp-compute-indentation-face))

(setq kws (car hl))
(dp-compute-indentation-face)
(nth 0 kws)
dp-compute-indentation-face
(nthcdr 3 kws)
nil

(nth 0 '(1 2 3 4 5))
1

2
(setq highlights hl)
((1 dp-cifdef-face0))
(numberp (car (car highlights)))
t
(car highlights)
(1 dp-cifdef-face0)

<:a:>
'((1 dp-cifdef-face0))
'((dp-compute-indentation-face))

(setq keywords (car '((dp-compute-indentation-face))))
(dp-compute-indentation-face)
(setq matcher (nth 0 keywords) 
      lowdarks (nthcdr 3 keywords)
      highlights nil
      pre-match-value-to-eval (nth 1 keywords))
nil
matcher
dp-compute-indentation-face
lowdarks
nil
pre-match-value-to-eval
nil
(hl0 hl1... hln)
 
 0       1   2 3
(matcher any x (lowdarks) x)
                  ==
               (highlights)
(matcher                                ; same as main matcher
 pre-match-form                         ; e.g. (beginning-of-line)
 post-match-form                        ; nil
 match-highlight...)                    ; '(dp-compute-indentation-face)


(eval (dmessage "hi"))
"hi"

(defun dm1 ()
  (dmessage "dm1 called!"))
dm1
(setq dm1 'dm1)
dm1
(eval 'dm1)
dm1
(eval '(dmessage "hi"))
"hi"

"hi"
(eval dm1)
dm1

dm1

(eval '(dp-compute-indentation-face))
dp-cifdef-face0

(defun tempf(x)
  (if (<= (dired-get-subdir-min x) here)
      (throw 'done (car x))))

(defun dired-current-directory (&optional localp)
  "Return the name of the subdirectory to which this line belongs.
This returns a string with trailing slash, like `default-directory'.
Optional argument means return a file name relative to `default-directory'.
In this it returns \"\" for the top directory."
  (let* ((here (point))
	 (dir (catch 'done
		(mapcar 'tempf
			dired-suqbdir-alist))))
    (if (listp dir) (error "DP: dired-subdir-alist seems to be mangled"))
    (if localp
	(let ((def-dir (expand-file-name default-directory)))
	  (if (string-equal dir def-dir)
	      ""
	    (dired-make-relative dir def-dir)))
      dir)))


========================
Saturday January 07 2006
--
(defun dp-c-indent-command ()
  "Indent region if active, otherwise indent if in indentation space, otherwise tabdent."
  (interactive "*")
  (if (dp-mark-active-p)
	(c-indent-region (mark) (point))
    (if (not c-tab-always-indent)
        ;; try to make the indenter smarter.  I like using TAB to space out
        ;; vars from types, e.g. int  x;
        ;; but it's a pain to indent a line properly.
        ;; this tried to do an indent if on non-space and tab over if 
        ;; over a space.  But there are times when this is wrong, so I
        ;; punt for now.
	(if (or (not (dp-isa-type-line-p))
                (dp-in-indentation-p))
	    (c-indent-line)             ;simple indentation
          ;; not so simple case...
          ;; lets try:
          ;; If over non-whitespace:
          ;;   going to beginning of current word and then indenting.
	  (if abbrev-mode
	      (expand-abbrev))
          (if (and (not (eolp))
                   (not (looking-at "[ 	]"))
                   (save-excursion 
                     (backward-char) 
                     (not (looking-at "[ 	]"))))
              (backward-word)
            (delete-region (point) 
                           (progn (skip-chars-forward " \t") (point))))
	  (dp-tabdent c-basic-offset)))))


========================
Tuesday January 31 2006
--

;; :(dp-eval-embedded-lisp "^dmessage")
;; :(dmessage "dm1"):

;; :(message "m1.1"):
;; :(message "m1.2"):

;; :(dmessage "dm2"):

========================
Saturday February 25 2006
--

(defun dp-toggle-capitalization (num-words)
  (interactive "p")
  (dp-capitalize-position-point)
  (call-interactively
   (if  (let ((case-fold-search))
          (string-match "[A-Z]" 
                        (substring (symbol-near-point) 0 1)))
       'downcase-region-or-word
     'capitalize-region-or-word)))

aaaaa
aaaaa

(let ((case-fold-search nil))
  (string-match "^[A-Z]" "A"))
0


(symbol-plist (current-buffer))

#<buffer "elisp-devel.el">





========================
Wednesday March 08 2006
--
(defun dp-c-flatten-func-def ()
  "Put all function parameters on the same line."
  (interactive)
  (undo-boundary)
  (save-excursion
    (while (not (re-search-forward "\\s-*{\\s-*" 
                                   (line-end-position) 'no-error))
      (beginning-of-line)
      (join-line))
    (replace-match "\n{")
    (beginning-of-line)
    (dp-c-indent-command)
    (beginning-of-line)
    (while (re-search-forward "\\s-*,\\s-*" (line-end-position) 'no-error)
      (replace-match ", "))))

(defun dp-c-format-func-def (&optional no-nl-after-open-paren)
  "Format a C/C++ function definition header *my* way."
  (interactive "P")
  (undo-boundary)
  (save-excursion
    (beginning-of-line)
    (dp-c-flatten-func-def)
    (when (and (not no-nl-after-open-paren)
               (search-forward "(" (line-end-position) 'no-error))
        (replace-match "(\n")
        (beginning-of-line)
        (dp-c-indent-command))
    (while (re-search-forward "[,:]" (line-end-position) 'no-error)
      (if (string= (match-string 0) ":")
          (save-excursion
            (replace-match "\n:\n")
            (forward-line -1)
            (beginning-of-line)
            (dp-c-indent-command))
        (replace-match ",\n"))
      (beginning-of-line)
      (dp-c-indent-command))
    (beginning-of-line)
    (dp-c-indent-command)
    (when (re-search-forward ")\\s-*{\\s-*$"  (line-end-position) 'no-error)
      (replace-match ")\n{")
      (beginning-of-line)
      (dp-c-indent-command))))

(defun dp-C-format-func-call ()
  "Format a C/C++ function call *my* way."
  (interactive)
  (undo-boundary)
  (save-excursion
    (beginning-of-line)
    (dp-C-format-func-def)
    (while (not (re-search-forward ")\\s-*[;]\\s-*$" ;??? Only ; ???
                                   (line-end-position) 'no-error))
      (beginning-of-line)
      (join-line)
      (if (<= (- (line-end-position) (line-beginning-position)) 
              (or fill-column 79))
          ()
        (c-context-line-break)))))
========================
2006-07-25T21:35:18
--
:::::::::
---
|
-
|
|
-
-
|
---<<<estart

-
-
-V
hide me, baby.

(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x51dd77>0x51dd75> dp-buffer-endicator t);

(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x51dd77>0x51dd75> dp-buffer-endicator t);(detachable t end-open t read-only t invisible t dp-hidden-dhr-extent t dp-extent-id dp-hidden-dhr-extent dp-extent t dph-op hide dp-hidden-invisible t);


========================
Friday July 28 2006
--

;; move to .emacs .ll
(defvar dp-tss-info
  '(tss in ("tss") (".")))
(defvar dp-tss.in-info
  '(in tss ("in") (".") dp-in-to-tss-file))


(defun dp-in-to-tss-file (base-dir dir file ext)
  (interactive)
  ;;@todo  Return just new-name and let caller format???
  (format "%s%s/%s.%s"
          base-dir dir
          (progn
            (posix-string-match "\\(.*?\\)\\." (concat file "."))
            (match-string 1 file))
          ext))
                                            
(defun dp-find-corresponding-file (&optional file-name file-info)
  "Find the corresponding file: *.c-type <--> *.h-type"
  (interactive)
  (setq-ifnil file-name (buffer-file-name)
	      file-info (dp-classify-file file-name))
  (let ((co-info (assoc (nth 1 file-info) dp-file-infos))
        (base-dir (file-name-directory file-name))
         (file (file-name-sans-extension (file-name-nondirectory file-name)))
         (file-fmt "%s%s/%s.%s")
	candidate)
    ;; find new name in list of dirs.  try all exts and all dirs
    (catch 'found-it
      (mapc (lambda (dir)
	      (mapc (lambda (ext)
                      (setq candidate
                            (if (not (nth 4 co-info))
                                (format file-fmt base-dir dir file ext)
                              (funcall (nth 4 file-info) 
                                       base-dir dir file ext)))
                            ;;(dmessage "cand>%s<" candidate)
                      (when (file-exists-p candidate)
                        ;;(dmessage "candidate>%s<" candidate)
                        (throw 'found-it candidate)))
		    (nth 2 co-info)))
	    (nth 3 co-info))
      nil)))

(defun dp-find-corresponding-file-old (&optional file-name file-info)
  "Find the corresponding file: *.c-type <--> *.h-type"
  (interactive)
  (setq-ifnil file-name (buffer-file-name)
	      file-info (dp-classify-file file-name))
  (let ((co-info (assoc (nth 1 file-info) dp-file-infos))
	(base-dir (file-name-directory file-name))
	(file (file-name-sans-extension (file-name-nondirectory file-name)))
	(file-fmt "%s%s/%s.%s")
	candidate)
    ;; find new name in list of dirs.  try all exts and all dirs
    (catch 'found-it
      (mapc (lambda (dir)
	      (mapc (lambda (ext)
		      (setq candidate (format file-fmt base-dir dir file ext))
		      ;;(dmessage "cand>%s<" candidate)
		      (if (file-exists-p candidate)
			  (throw 'found-it candidate)))
		    (nth 2 co-info)))   ;Extensions of corresponding files.
	    (nth 3 co-info))            ;Dirs of corresponding files.
      nil)))
(dp-find-corresponding-file "/home/davep/x.1.2.3.in")
nil
tj
(dp-find-corresponding-file 
 "/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients/unix/qos1-dagg.56.in")
"/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients/unix/./qos1-dagg.tss"



nil

nil

nil


nil


(add-to-list 'non-existing 'hello)


nil

(dp-in-to-tss-file "base-dir" "dir" "x.1.2.3." "tss")
(dp-in-to-tss-file "base-dir" "dir" "x.1.2.3." "tss")
(dp-in-to-tss-file "base-dir" "dir" "qos1-dagg.56." "tss")
"base-dirdir/qos1-dagg.tss"


x.1.2.3.tss



========================
Monday August 07 2006
--

in eval, (setq cwc (current-window-configuration))
then (set-window-configuration cwc)
#<buffer "daily-2006-08.jxt">





========================
Tuesday August 08 2006
--


(defun hack-one-local-variable2 (var val)
  "\"Set\" one variable in a local variables spec.
A few variable names are treated specially."
  (cond ((eq var 'mode)
	 (funcall (intern (concat (downcase (symbol-name val))
				  "-mode"))))
	((eq var 'coding)
	 ;; We have already handled coding: tag in set-auto-coding.
	 nil)
	((memq var ignored-local-variables)
	 nil)
	;; "Setting" eval means either eval it or do nothing.
	;; Likewise for setting hook variables.
	((or (get var 'risky-local-variable)
	     (and
	      (string-match "-hooks?$\\|-functions?$\\|-forms?$\\|-program$\\|-command$\\|-predicate$"
			    (symbol-name var))
	      (not (get var 'safe-local-variable))))

         ;; Allow user to eval things from their own files w/o asking.
         

	 ;; Permit evalling a put of a harmless property.
	 ;; if the args do nothing tricky.
	 (if (or (and (eq var 'eval)
		      (consp val)
		      (eq (car val) 'put)
		      (hack-one-local-variable-quotep (nth 1 val))
		      (hack-one-local-variable-quotep (nth 2 val))
		      ;; Only allow safe values of lisp-indent-hook;
		      ;; not functions.
		      (or (numberp (nth 3 val))
			  (equal (nth 3 val) ''defun))
		      (memq (nth 1 (nth 2 val))
			    '(lisp-indent-hook)))
		 ;; Permit eval if not root and user says ok.
		 (and (not (zerop (user-uid)))
		      (or (eq enable-local-eval t)
			  (and enable-local-eval
			       (save-window-excursion
				 (switch-to-buffer (current-buffer))
				 (save-excursion
				   (beginning-of-line)
				   (set-window-start (selected-window) (point)))
				 (setq enable-local-eval
				       (y-or-n-p (format "Process `eval' or hook local variables in %s? "
							 (if buffer-file-name
							     (concat "file " (file-name-nondirectory buffer-file-name))
							   (concat "buffer " (buffer-name)))))))))))
	     (if (eq var 'eval)
		 (save-excursion (eval val))
	       (make-local-variable var)
	       (set var val))
	   (message "Ignoring `eval:' in the local variables list")))
	;; Ordinary variable, really set it.
	(t (make-local-variable var)
	   (set var val))))

(defun dp-get-file-owner (file-name)
  "Get a file's owner"
  (interactive "fFile name? ")
  (dp-nuke-newline (shell-command-to-string 
                    (format dp-get-file-owner-program file-name))))

(defun dp-user-owns-this-file-p (file-name)
  "Return non-nil if the current user own FILENAME."
  (interactive "fFile name? ")
  (string= (user-login-name)
           (dp-get-file-owner file-name)))
dp-user-owns-this-file-p


(dp-user-owns-this-file-p "elisp-devel.el")
nil


nil

nil

dp-get-file-owner-program file-name))))

nil





nil

nil

(shell-command-to-string (format dp-get-file-owner-program )

(defun dp-balance-horizontal-windows ()
  "Assumes windows are all from horizontal splits."
  (interactive)
  (let* ((win-list (window-list nil 'no-minibufs-at-all))
         (num-wins (length win-list))
         (total-cols (apply '+ (mapcar (lambda (w)
                                         (window-width w))
                                       win-list)))
         (min-width (+ window-min-width 3))
         (target-win-inc (- (/ total-cols num-wins) min-width))
         win
         (wl win-list))
    (while wl
      (setq win (car wl)
            wl (cdr wl))
      (shrink-window (- (window-width win) min-width) 'horiz win)
      (enlarge-window target-win-inc 'horiz win))))
(dp-balance-horizontal-windows)
nil

nil





nil
nil

nil

nil

nil

nil








    
  

(defun dp-rotate-windows (&optional to-vertical-set)
  "Convert a horizontal(vertical) set of windows into the 
equivalent vertically(horizontally) split set."
  (interactive "P")
  (let* ((split-func (if to-vertical-set 
                         'split-window-horizontally
                       'split-window-vertically))
         (win-list (window-list nil 'no-minibufs-at-all))
         (num-wins (length win-list))
         (buf-list (mapcar (lambda (win)
                             (window-buffer win))
                          win-list)))
    (delete-other-windows)
    (while (> num-wins 1)
      (funcall split-func)
      (setq num-wins (1- num-wins)))
    (balance-windows)
    (while buf-list
      (switch-to-buffer (buffer-name (car buf-list)))
      (other-window 1)
      (setq buf-list (cdr buf-list)))))
dp-rotate-windows


(defun dp-one-frame-opened-p (&optional device)
  (eq 1 (length (device-frame-list device))))

(defun dp-pop-up-frame-p (buf &optional pop-up-frames)
  (or pop-up-frames
      (and (dp-one-frame-opened-p)
           (not (get-buffer-window buf t))
           (< (frame-width) dp-2w-frame-width))))

(dp-pop-up-frame-p (current-buffer))
nil

(dp-pop-up-frame-p (get-buffer "diary"))
t


nil





========================
Tuesday August 15 2006
--

(defun dp-multiple-windows-on-frame-p (&optional frame)
  (interactive)
  (> (length (window-list frame 'dont-count-minibuf)) 1))

(defun dp-pop-up-window-p (buf &optional pop-up-wins frame)
  (interactive)
  (when 
  (or pop-up-wins
      ;; t if (not frame) , else frame
      ;; t --> check all frames
      (and (not (get-buffer-window buf (or (not x) x)))
           (dp-multiple-windows-on-frame-p))))

;; Usage example
(let* ((pop-up-windows (dp-pop-up-window-p buf))
       (pop-up-frames (and (not pop-up-windows)
                           (dp-pop-up-frame-p buf)))))
                           
(defun dp-pop-up-info (buf)
  (let* ((pop-up-windows (dp-pop-up-window-p buf))
         (pop-up-frames (and (not pop-up-windows)
                             (dp-pop-up-frame-p buf))))
    (list 'wins: pop-up-windows 'frames: pop-up-frames)))

(dp-pop-up-info (get-buffer "TAGS"))
(wins: nil frames: nil)

(wins: t frames: nil)

(wins: nil frames: nil)


(wins: nil frames: nil)


(wins: t frames: nil)





((wins . t) frames)

(t)

(defun pre-display-buffer-function buffer (&optional not-this-window-p override-frame shrink-to-fit)

  
(defvar ll-tc-le.ifaces 
  '(
    "fe80::207:e9ff:fe17:dbf6" "tc-le4/eth1"
    "fe80::207:e9ff:fe17:dbf7" "tc-le4/eth0"
    "fe80::207:e9ff:fe07:fb" "tc-le4/eth2"
    
    "fe80::207:e9ff:fe17:f660" "tc-le5/eth1"
    "fe80::207:e9ff:fe17:f661" "tc-le5/eth0"
    "fe80::207:e9ff:fe06:fafd" "tc-le5/eth2"
    
    "fe80::204:23ff:fec1:f1e0" "tc-le6/eth1"
    "fe80::204:23ff:fec1:f1e1" "tc-le6/eth0"
    "fe80::207:e9ff:fe07:19" "tc-le6/eth2")
  "Mapping from inet6 addr to machine/interface")


(mapconcat 'identity
           (loop for (ip info) on ll-tc-le.ifaces by 'cddr
             collect (format "nsock --name='%s' --addr='%s' --ip-proto=46 --comment='%s'; " info ip info)) "\n")
nsock --name='tc-le4/eth0' --addr='fe80::207:e9ff:fe17:dbf7' --ip-proto=46 --comment='tc-le4/eth0'; 
nsock --name='tc-le4/eth1' --addr='fe80::207:e9ff:fe17:dbf6' --ip-proto=46 --comment='tc-le4/eth1'; 
nsock --name='tc-le4/eth2' --addr='fe80::207:e9ff:fe07:fb' --ip-proto=46 --comment='tc-le4/eth2'; 
nsock --name='tc-le5/eth0' --addr='fe80::207:e9ff:fe17:f661' --ip-proto=46 --comment='tc-le5/eth0'; 
nsock --name='tc-le5/eth1' --addr='fe80::207:e9ff:fe17:f660' --ip-proto=46 --comment='tc-le5/eth1'; 
nsock --name='tc-le5/eth2' --addr='fe80::207:e9ff:fe06:fafd' --ip-proto=46 --comment='tc-le5/eth2'; 
nsock --name='tc-le6/eth0' --addr='fe80::204:23ff:fec1:f1e1' --ip-proto=46 --comment='tc-le6/eth0'; 
nsock --name='tc-le6/eth1' --addr='fe80::204:23ff:fec1:f1e0' --ip-proto=46 --comment='tc-le6/eth1'; 
nsock --name='tc-le6/eth2' --addr='fe80::207:e9ff:fe07:19' --ip-proto=46 --comment='tc-le6/eth2';



(defun dp-multiple-windows-on-frame-p (&optional frame)
  (interactive)
  (> (length (window-list frame 'dont-count-minibuf)) 1))

(defun dp-pop-up-window-p (buf &optional pop-up-wins frame)
  (interactive)
  (when 
  (or pop-up-wins
      ;; t if (not frame) , else frame
      ;; t --> check all frames
      (and (not (get-buffer-window buf (or (not frame) frame)))
           (dp-multiple-windows-on-frame-p)))))

;;(defadvice display-buffer (around dp-display-buffer act)
  ;;(let* ((buf (ad-get-arg 0))
         ;;(pop-up-windows (dp-pop-up-window-p buf))
         ;;(pop-up-frames (and (not pop-up-windows)
                             ;;(dp-pop-up-frame-p buf))))
    ;;ad-do-it))




========================
Wednesday August 16 2006
--

(defvar dp-max-preferred-frames 2
  "Don't let any commands implicity make more frames than this.")

(defun dp-max-preferred-frames-opened-p (&optional num device op)
  (funcall (or op '<=) (or num dp-max-preferred-frames)
      (length (device-frame-list device))))

(defun dp-display-buffer-new (buffer &optional not-this-window-p 
                              override-frame shrink-to-fit)
  (interactive "sBuffer name: ")
  ;; buffer can be a name
  (setq buffer (get-buffer-create buffer))
  (unless
      ;; We always want to visit the buffer where it is already
      ;; visible.
      (let ((buf-win (get-buffer-window buffer t))
            (orig-frame (window-frame (get-buffer-window (current-buffer)))))
        (when buf-win
          (select-frame (window-frame buf-win))
          (select-window buf-win)
          (when (not (equal orig-frame
                            (window-frame)))
            (raise-frame (window-frame)))))

    (let* ((orig-frame (window-frame (get-buffer-window (current-buffer))))
           (one-window-p (one-window-p))
           (pop-up-frames (and one-window-p
                               (not (dp-max-preferred-frames-opened-p))))
           (pop-up-windows (and one-windw-p
                                dp-likes-other-windows-p))
           (new-frame (if (not one-window-p)
                          orig-frame
                        (and (not pop-up-frames) (next-frame)))))
      ;; already in some window on some frame, select that frame.
      ;;(pop-to-buffer buffer nil new-frame)
      (let ((display-buffer-function nil))  ;Called from within `display-buffer'.
        (select-window (display-buffer buffer nil new-frame nil)))
      (when (not (equal orig-frame
                        (window-frame)))
        (raise-frame (window-frame))))))
(setq display-buffer-function 'dp-display-buffer-new)

      

========================
Thursday August 17 2006
--


  (let ((syntax (save-excursion
                  (end-of-line)
                  (dp-c-get-syntactic-region))))
     ((memq syntax 
            '(topmost-intro topmost-intro-cont arglist-intro arglist-cont
              func-decl-cont))

(defun dp-open-below ()
  "Add a new line below the current one, ala `o' in vi."
  (interactive "*")
  (end-of-line)
  (if (and (save-excursion
             (dp-in-syntactic-region '(topmost-intro topmost-intro-cont 
                                       arglist-intro arglist-cont 
                                       func-decl-cont)))
             t ) ;;(dp-point-follows-regexp ")\\s-*"))
        (dp-c-format-func-decl)
    (save-excursion
      (if (and (dp-in-c)
               (or (and (dp-in-syntactic-region 
                         '(member-init-intro member-init-cont func-decl-cont))
                        (not (dp-point-follows-regexp ",\\s-*$")))
                   (progn
                     (beginning-of-line)
                     (not (re-search-forward 
                           "\\(^\\s-*#\\s-*[ie]\\)\\|\\([):;,.}{]\\s-*$\\)\\|\\(^\\s-*$\\)" 
                           (line-end-position) 'no-error))))
               (progn
                 (end-of-line)
                 (or (and (dp-in-c-statement)
                          (not (dp-in-c-iostream-statement)))
                     (dp-in-syntactic-region 
                      dp-c-add-comma-@-eol-of-regions))))
          (progn
            (beginning-of-line)
            (re-search-forward "\\s-*$" (line-end-position))
            (replace-match ","))))
    (end-of-line)
    (if (dp-in-c)
        (c-context-line-break)
      (newline-and-indent))))

========================
Monday August 21 2006
--


(defmacro dp-defvar-sym-icky (name init-val &optional docstring)
  "Define a variable and make it buffer local."
  (setq docstring (or docstring "dp-defvar-sym"))
  `(progn
    (when (or (interactive-p)
              (not (boundp ,name)))
      (set ,name ,init-val)
      (put ,name 'variable-documentation ,docstring))))
(put 'dp-defvar-sym 'lisp-indent-function lisp-body-indent)

(defmacro dp-defvar-sym (name init-val &optional docstring)
  (setq docstring (or docstring "dp-defvar-sym"))
  `(defvar ,(eval name) ,init-val ,docstring))
(put 'dp-defvar 'lisp-indent-function lisp-body-indent)
                   
(defun dp-add-font-patterns (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES."
  (loop for mode in list-o-modes do
    (let ((save-sym (dp-ify-symbol mode))
          (mode-val (symbol-value mode)))
      (when (not (boundp save-sym))
        (dp-defvar-sym save-sym mode-val
          (format "Original value of %s's font-lock keywords." mode)))
      (set mode (append (symbol-value save-sym) list-o-keys)))))
dp-add-font-patterns

(dp-add-font-patterns '(python-font-lock-keywords) 
                      dp-font-lock-line-too-long-element '(aaa bbb))
nil

nil

python-font-lock-keywords
(("^[ 	]*\\(@.+\\)" 1 (quote py-decorators-face)) ("\\b\\(and\\|assert\\|break\\|class\\|continue\\|def\\|del\\|elif\\|else\\|except\\|exec\\|for\\|from\\|global\\|if\\|import\\|in\\|is\\|lambda\\|not\\|or\\|pass\\|print\\|raise\\|return\\|while\\|yield\\)\\b[ 
	(]" . 1) ("\\([^. 	]\\|^\\)[ 	]*\\b\\(__debug__\\|__import__\\|__name__\\|abs\\|apply\\|basestring\\|bool\\|buffer\\|callable\\|chr\\|classmethod\\|cmp\\|coerce\\|compile\\|complex\\|copyright\\|delattr\\|dict\\|dir\\|divmod\\|enumerate\\|eval\\|execfile\\|exit\\|file\\|filter\\|float\\|getattr\\|globals\\|hasattr\\|hash\\|hex\\|id\\|input\\|int\\|intern\\|isinstance\\|issubclass\\|iter\\|len\\|license\\|list\\|locals\\|long\\|map\\|max\\|min\\|object\\|oct\\|open\\|ord\\|pow\\|property\\|range\\|raw_input\\|reduce\\|reload\\|repr\\|round\\|setattr\\|slice\\|staticmethod\\|str\\|sum\\|super\\|tuple\\|type\\|unichr\\|unicode\\|vars\\|xrange\\|zip\\)\\b[ 
	(]" 2 py-builtins-face) ("\\b\\(else:\\|except:\\|finally:\\|try:\\)[ 
	(]" . 1) ("\\b\\(ArithmeticError\\|AssertionError\\|AttributeError\\|DeprecationWarning\\|EOFError\\|EnvironmentError\\|Exception\\|FloatingPointError\\|FutureWarning\\|IOError\\|ImportError\\|IndentationError\\|IndexError\\|KeyError\\|KeyboardInterrupt\\|LookupError\\|MemoryError\\|NameError\\|NotImplemented\\|NotImplementedError\\|OSError\\|OverflowError\\|OverflowWarning\\|PendingDeprecationWarning\\|ReferenceError\\|RuntimeError\\|RuntimeWarning\\|StandardError\\|StopIteration\\|SyntaxError\\|SyntaxWarning\\|SystemError\\|SystemExit\\|TabError\\|TypeError\\|UnboundLocalError\\|UnicodeDecodeError\\|UnicodeEncodeError\\|UnicodeError\\|UnicodeTranslateError\\|UserWarning\\|ValueError\\|Warning\\|ZeroDivisionError\\)[ 
	:,(]" 1 py-builtins-face) ("[ 	]*\\(\\bfrom\\b.*\\)?\\bimport\\b.*\\b\\(as\\)\\b" . 2) ("\\bclass[ 	]+\\([a-zA-Z_]+[a-zA-Z0-9_]*\\)" 1 font-lock-type-face) ("\\bdef[ 	]+\\([a-zA-Z_]+[a-zA-Z0-9_]*\\)" 1 font-lock-function-name-face) ("\\b\\(self\\|None\\|True\\|False\\|Ellipsis\\)\\b" 1 py-pseudo-keyword-face) (".\\{79\\}\\(.*\\)$" 1 (quote dp-default-line-too-long-face) t) (aaa bbb))


(setq bad python-font-lock-keywords)

(setq python-font-lock-keywords dp-orig-python-font-lock-keywords)


(setq x '(("^[ 	]*\\(@.+\\)" 1 (quote py-decorators-face))))
(("^[ 	]*\\(@.+\\)" 1 (quote py-decorators-face)))


(append x (list dp-font-lock-line-too-long-element))
(("^[ 	]*\\(@.+\\)" 1 (quote py-decorators-face)) (".\\{79\\}\\(.*\\)$" 1 (quote dp-default-line-too-long-face) t))


(append '((a b)) '((1 2)))
((a b) (1 2))


((a b) (1 2))

`(,dp-font-lock-line-too-long-element)
(append dp-orig
((".\\{79\\}\\(.*\\)$" 1 (quote dp-default-line-too-long-face) t))

dp-font-lock-line-too-long-element
(".\\{79\\}\\(.*\\)$" 1 (quote dp-default-line-too-long-face) t)

boo-sym
boo
(makunbound 'boo)
boo

(symbol-plist 'boo)
(variable-documentation "bsym-doc-a")


"boo"


(dp-defvar-sym boo-sym "bsv" "bsd")
boo
"bsv"


boo
"new boo"


boo

boo
"new boo"



dp-font-lock-line-too-long-element
(".\\{79\\}\\(.*\\)$" 1 (quote dp-default-line-too-long-face) t)

(dp-add-font-patterns '(python-font-lock-keywords) 
                      `(,dp-font-lock-line-too-long-element))
nil

boo-sym
boo

(list 'defvar boo-sym "boo-val" "boo-doc")
(eval (defvar boo "boo-val" "boo-doc"))
"new boo"


(eval (list 'defvar boo-sym "boo-val" "boo-doc"))
boo
"new boo"



boo
"new boo"

(defvar boo "boo-val" "boo-doc")

(list 'defvar (format "%s" (eval boo-sym)) "boo-val" "boo-doc")


(defvar "new boo")



(makunbound 'dp-orig-python-font-lock-keywords)
dp-orig-python-font-lock-keywords

(setq KEEP-python-font-lock-keywords python-font-lock-keywords)

(makunbound 'boo)
boo

(setq boo-sym 'boo)
boo
(cl-macroexpand-all '(dp-defvar boo-sym "new boo" "new boo doc"))
(defvar boo "new boo" "new boo doc")
boo


(cl-macroexpand-all '(dp-defvar boo "new boo" "new boo doc"))
(defvar "new boo" "new boo" "new boo doc")

(defvar "boo" "new boo" "new boo doc")

(defvar boo "new boo" "new boo doc")

(defvar boo init-val docstring)

(dp-defvar boo-sym "new boo" "new boo doc")
boo


(dp-defvar-sym boo-sym "new boo" "new boo doc")
"new boo doc"
boo
"new boo"

nil

boo
"boo-val"

(symbol-plist 'python-mode)
(font-lock-defaults (python-font-lock-keywords))


(eval '(defvar yadda "yaddaval" "yadda doc"))
yadda


(defun dp-save-n-set-var (var-sym var-new-val &optional docstring)
  (interactive)
  (let ((docstring (or docstring
                       (format "Original value of %s" var-sym))))
    (dp-defvar-sym (dp-ify-symbol var-sym) (symbol-value var-sym) docstring)
    (set var-sym var-new-val)))

(setq yadda "init-yadda")
"init-yadda"
(dp-save-n-set-var 'yadda "new-yadda" "new-yadda-val")
"new-yadda"


yadda
"new-yadda"


(setq lisp-font-lock-keywords-2 dp-orig-lisp-font-lock-keywords-2)


(defmacro dp-save-n-set-var-GOOD (var-name var-new-val &optional docstring)
  (let ((docstring (or docstring
                       (format "Original value of %s." var-name))))
    (list 'progn 
          (list 'defvar (dp-ify-symbol var-name) 
                (list 'and `(boundp (quote ,var-name)) var-name) docstring)
          (list 'setq var-name var-new-val))))


(defmacro dp-save-n-set-var (var-name var-new-val &optional docstring)
  (let ((docstring (or docstring
                       (format "Original value of `%s'." var-name))))
    (list 'progn 
          (list 'defvar (dp-ify-symbol var-name) 
                `(and (boundp (quote ,var-name)) ,var-name) docstring)
          (list 'setq var-name var-new-val))))
(progn
  (makunbound 'dp-orig-yadda)
  (setq yadda "init-yadda"))
(cl-macroexpand-all '(dp-save-n-set-var yadda "new-yadda"))
(progn 
  (defvar dp-orig-yadda (and (boundp (quote yadda)) yadda) 
    "Original value of `yadda'.") 
  (setq yadda "new-yadda"))

(cl-macroexpand-all '(dp-defvar-sym boo-sym "blah"))
(defvar boo "blah" "dp-defvar-sym")

boo
"blah"




(setq boo-sym 'boo)
boo

(symbol-value 'boo-sym)
boo


boo-sym
boo
(makunbound 'boo)
boo

(eval boo-sym)

(dp-save-n-set-var (symbol-value boo-sym) "newbs")

"newbs"

boo-sym
"newbs"





(progn 
  (defvar dp-orig-yadda (and (boundp (quote yadda)) yadda) 
    "Original value of yadda.") 
  (setq yadda "new-yadda"))



(makunbound 'x)
x

(cl-macroexpand-all '(and-boundp 'x x))
(progn nil (and (boundp (quote x)) x))

(progn nil (and (boundp x) x))

(dp-save-n-set-var zazz "new-zazz2")
"new-zazz2"




========================
Wednesday August 23 2006
--

(defun getbs (m p)
  (interactive "r")
  (let ((s (buffer-substring m p)))
    (dmessage "s>%s<" s)
    s))
getbs


(defadvice cscope-extract-symbol-at-cursor (around
                                            dp-cscope-extract-symbol-at-cursor
                                            act)
  (if (dp-mark-active-p)
      (setq ad-return-value (buffer-substring (mark) (point)))
    ad-do-it))

cscope-extract-symbol-at-cursor

(cscope-extract-symbol-at-cursor nil)
"nil"

"nil"

(getbs 1 3)
"12"

"01"

(symbol-plist 'dp-cscope-extract-symbol-at-cursor)
nil



========================
Thursday September 07 2006
--
(defun ll-teth-back-section ()
  (interactive)
  (re-search-backward "^Frame"))

(dp-define-buffer-local-keys '([(meta left)] ll-teth-back-section))

========================
Friday September 08 2006
--

(defun compare-file-to-buffer (buffer filename)
  "compare BUFFER to FILENAME and see if they are really the same. Returns nil
if not, BUFFER if they are"
  (interactive "FCompare FILE : 
bTo BUFFER : ")
  ;; (print (format "%s %s " buffer filename))
  (if (bufferp filename)
      (setq filename (buffer-file-name filename)))
  (if (and (stringp filename) (bufferp buffer))
      ;;this is relative to the compilation buffer's dir
      (if (equal (file-truename filename)
                 (with-current-buffer buffer
                   (file-truename (buffer-file-name))))
          buffer
        nil)
    nil)
)

(cl-prettyexpand '(with-narrow-to-region (point) (point-max)
                   (c-fill-paragraph)))

(save-restriction (narrow-to-region (point) (point-max)) (c-fill-paragraph))nil

(defun dp-find-function-after-hook ()
  "Add symbol to history."
  (
                             

(self-insert-internal ?\\;)
?\\
(char-int ? )
32
(self-insert-internal (string-to-char ";"))
;nil

?\;

?\;

xnil

?\;

========================
2006-10-15T17:16:41
--
(defun dp-c-mode-l (&optional arg)
  "Change )l to ); since it is so likely to be a mistake."
  (interactive "p")
  (if (dp-looking-back-at ")\\s-*")
      ;; Ugly, but I can't find another way to quote a semi.
      (self-insert-internal (string-to-char ";"))
    (call-interactively 'self-insert-command)))
dp-c-mode-l


(dp-define-buffer-local-keys '(?l dp-c-mode-l))
nil

                            
                            
  

========================
Tuesday October 17 2006
--

(nth 0 (split-string-by-char "aaa bb c" ? ))
"aaa"

("aaa" "bb" "c")

(defun dp-ssh (&optional shell-id)
  (interactive "P")
  (let* ((hostname (format "tc-le%s" shell-id))
         (func 'ssh)
         (do-shell (string= hostname (dp-short-hostname)))
         buf)
    (if (not do-shell)
        (setq buf (get-buffer (format "*ssh-tc-le%s*<%s>"
                                      shell-id
                                      shell-id))))
    (cond
     (do-shell (dp-shell))
     (buf (switch-to-buffer buf))
     (t (call-interactively func)))))
dp-ssh

dp-ssh


(defvar dp-next-shell-buf-list '()
  "List we are currently traversing."
(defvar dp-next-shell-buf-list-cursor '()
  "Position in list we are currently traversing."
  
(defun dp-next-shell-buf ()
  "Move to the next consecutive shell buffer"
  (if (not (eq last-command 'dp-next-shell-buf))
      (setq dp-next-shell-buf-list (dp-choose-buffers 
                                    "\\*\\(\\([0-9]*\\)?shell\\*\\|ssh-.*?\\*\\(<[0-9]+>\\)?\\)"
                                    (buffer-list))
            dp-next-shell-buf-list-cursor dp-next-shell-buf-list))
  (if (not dp-next-shell-buf-list-cursor)
      (setq dp-next-shell-buf-list-cursor dp-next-shell-buf-list))
  (when dp-next-shell-buf-list-cursor
    (let ((buf (car dp-next-shell-buf-list-cursor))
          (dp-next-shell-buf-list-cursor (cdr dp-next-shell-buf-list-cursor)))
      (set-buffer buf))))
dp-next-shell-buf


(dp-choose-buffers 
 "\\*\\(\\([0-9]*\\)?shell\\*\\|ssh-.*?\\*\\(<[0-9]+>\\)?\\)"
 (buffer-list))
(#<buffer "*2shell*"> #<buffer "*shell*"> #<buffer "*ssh-tc-le6*<6>"> #<buffer "*ssh-tc-le4*<4>">)

                                    

========================
Wednesday October 18 2006
--

(defmacro dp-if-functionp (func args &rest body)
  "If \(functionp FUNC\) call it w/ARGS.
Else execute body."
  `(if (functionp ,func)
        (apply ,func ,args)
      ,@body))
dp-if-functionp

dp-if-functionp

dp-if-functionp

dp-if-functionp

(cl-prettyexpand '(dp-if-functionp 'message '("ima function!")
                   (dmessage "not a functionp")))

(if (functionp 'message)
    (apply 'message '("ima function!"))
  (dmessage "not a functionp"))
"ima function!"

(dp-if-functionp 'message 
    '("ima function!")
  (dmessage "not a functionp"))
"ima function!"
o0






(if (functionp 'xx) 
    (apply 'xx '(boo)) 
  (dmessage "not a functionp"))
"not a functionp"




(if (functionp 'x) 
    (apply 'xxx '(boo)) 
  (dmessage "not a functionp"))
;;



(if (functionp 'xxx) 
    (apply 'xxx (boo)) 
  (dmessage "not a functionp"))




(if (functionp 'xxx) (apply 'xxx (boo)) (dmessage "not a functionp"))nil



(if (functionp 'xxx) (apply (boo)) (dmessage "not a functionp"))nil



(if (functionp xxx) (apply (boo)) (dmessage "not a functionp"))nil



((if (functionp xxx) (apply (boo)) (dmessage "not a functionp")))nil



((dp-if-functionp xxx (boo) (dmessage "not a functionp")))nil


                                    
                   
    
    

========================
Thursday October 19 2006
--

(defmacro dp-def-history-list (list-var &rest forms)
  (let* ((docstring (if (stringp (car forms))
                        (progn
                          (setq forms (cdr forms))
                          (format "%s\n(dp-def-history-list)."
                                  (car forms)))
                      "(dp-def-history-list) var."))
         (no-save-p (or (not (feature 'savehist)
                             (and (symbolp (car forms))
                                  (prog1
                                      (car forms)
                                    (setq (forms (cdr forms)))

  (defva

    
nah

(defmacro dp-def-history-list (list-var &optional docstring no-save-p)
  
  


========================
Friday October 20 2006
--

(defun dp-shift-windows ()
  (interactive)
  (let* ((win-list (window-list nil 'no-minibufs))
         (buf-list (dp-get-win-list-buffers win-list))
         w b)
    (setq buf-list (append (cdr buf-list) (list (car buf-list))))
    (while win-list
      (setq w (car win-list)
            win-list (cdr win-list)
            b (car buf-list)
            buf-list (cdr buf-list))
      (set-window-buffer w b))
    (other-window 1)))
dp-shift-windows

dp-shift-windows



========================
Thursday October 26 2006
--
(defun dp-limit-comint-output (output-string &optional max)
  (if (and (not (and dp-shell-output-char-count
                     (< dp-shell-output-char-count dp-shell-output-max-chars)))
           (not (and dp-shell-output-max-lines
                     (< dp-shell-output-line-count ))))
      (progn
        ;;(dmessage "adding %s to %s" (length s) dp-shell-output-line-count)
        (setq dp-shell-output-line-count 
              (+ dp-shell-output-line-count
                 ;; matches newline by default
                 (dp-count-matches-string output-string))
              dp-shell-output-char-count
              (+ dp-shell-output-char-count
                 (length output-string))))
    (process-send-signal 'SIGINT nil 'CURRENT-GROUP)
    (dmessage "SIGINT-ing: pid: %s @ %s of %s lines." (process-id process)
              dp-shell-output-line-count
              dp-shell-output-max-lines)
    (ding)
    ;; Stop this from repeating ferever.
    (setq dp-shell-output-line-count 0
          dp-shell-output-char-count 0)))

========================
Tuesday November 07 2006
--

(abbrev-symbol "wrt")
wrt
(abbrev-expansion "bin" dp-shell-mode-abbrev-table)
"/home/davep/bin/"
(abbrev-symbol "bin" table)

nil

"with respect to"
(abbrev-expansion "tjr" dp-go-abbrev-table)
"/home/davep/work/ll/rsvp/RSVP2-testjig/"

"/home/davep/work/ll/rsvp/RSVP2-testjig/"

"/home/davep/bin/"

nil

nil

(expand-abbrev 
'(nil)
(nil)

(abbrev-expansion "bin")

(setq global-abbrev-table 'dp-glo
(dolist (x '(a b c d))
  (if (eq x 'z)
      (return (list x x))))
nil

(c c)

(abbrev-expansion "tjr" dp-go-abbrev-table)
"/home/davep/work/ll/rsvp/RSVP2-testjig/"

with respect to
/home/davep/work/ll/rsvp/RSVP2-testjig/

(defvar dp-expand-abbrev-default-tables (list nil dp-go-abbrev-table)
  "All abbrev tables to check by default.")

(defun dp-expand-abbrev (&rest tables)
  "Try to expand an abbrev using all of TABLES.
Tried in order given and first match wins."
  (interactive)
  (let* ((tables (cond
                  ((eq tables '(nil)) nil)  ; "Real" nil vs nil --> defaults
                  ((null tables) dp-expand-abbrev-default-tables)
                  (t tables)))
         (sym-near-pt (symbol-near-point)))
    (dolist (table tables)
      (let ((expansion (abbrev-expansion sym-near-pt table)))
        (when expansion
          (backward-delete-char (length sym-near-pt))
          (insert expansion)
          (return (list sym-near-pt expansion table)))))))
dp-expand-abbrev

dp-expand-abbrev




(cl-prettyexpand '(dolist (table '(a b))
                   (when (abbrev-expansion "boo")
                     (expand-abbrev)
                     (return (abbrev-symbol "boo")))))

(block nil
  (let ((--dolist-temp--99561 '(a b))
        table)
    (while --dolist-temp--99561
      (setq table (car --dolist-temp--99561))
      (if (abbrev-expansion "boo")
          (progn
            (expand-abbrev)
            (cl-block-throw '--cl-block-nil-- (abbrev-symbol "boo"))))
      (setq --dolist-temp--99561 (cdr --dolist-temp--99561)))
    nil))nil



  

========================
Sunday November 12 2006
--
(defun hargs:read-match (prompt table &optional
				predicate must-match default val-type)
  "PROMPTs with completion for a value in TABLE and returns it.
TABLE is an alist where each element's car is a string, or it may be an
obarray for symbol-name completion.
Optional PREDICATE limits table entries to match against.
Optional MUST-MATCH means value returned must be from TABLE.
Optional DEFAULT is a string inserted after PROMPT as default value.
Optional VAL-TYPE is a symbol indicating type of value to be read."
  (if (and must-match (null table))
      nil
    (dmessage "hargs:read-match:Enter----------------------")
    (dmessage "hargs:read-match:1:window-list>%s<" (window-list))
    (let ((prev-reading-p hargs:reading-p)
	  (completion-ignore-case t)
          (nada0 (dmessage "hargs:read-match:2:window-list>%s<" (window-list)))
	  (owind (selected-window))
          (nada (dmessage "hargs:read-match:3:window-list>%s<" (window-list)))
	  (obuf (current-buffer)))
      (dmessage "hargs:read-match:4:window-list>%s<" (window-list))
      (setq Global-owind owind
            Global-obuf obuf)
      (unwind-protect
	  (progn
            (dmessage "hargs:read-match:6:window-list>%s<, owind>%s<" (window-list) owind)
	    (setq hargs:reading-p (or val-type t))
            (dmessage "hargs:read-match:7:window-list>%s<\nowind>%s<\nsel-win>%s" (window-list) owind (selected-window))
	    (prog1
                (completing-read prompt table predicate must-match default)
              (dmessage "hargs:read-match:7:window-list>%s<\nowind>%s<\nsel-win>%s" (window-list) owind (selected-window)))
              
            )
        (dmessage "hargs:read-match:9:window-list>%s<, owind>%s<" (window-list) owind)
	(setq hargs:reading-p prev-reading-p)
        (dmessage "hargs:read-match:10:window-list>%s<, owind>%s<" (window-list) owind)
	(select-window owind)
	(switch-to-buffer obuf)
	))))

========================
Monday November 13 2006
--

(defun number-lines-regexp (&optional regexp to-string number-format)
  (interactive)
  (setq-ifnil regexp "^\\s-*\\(\\(send\\|exp\\)[a-zA-Z0-9_-]+\\)"
              number-format " --comment=cmd-num-%s")
  (let ((count 1))
    (while (re-search-forward regexp nil 'NOERROR)
      (goto-char (match-end 1))
      (insert (format number-format count))
      (setq count (1+ count)))))


========================
Thursday November 16 2006
--

(if-and-boundp 'x ==> if (and (boundp 'x) x)

(defmacro if-and-boundp (var then &rest else)
  `(if (and (boundp ,var) ,var)
    ,then
    ,@else))
(put 'if-and-boundp 'lisp-indent-function lisp-body-indent)

if-and-boundp

if-and-boundp
(cl-prettyexpand '(if-and-boundp 'var-to-check
                     x-is-t var-to-check
                   x-is-nil
                   nil-I-say))

(if (and (boundp 'var-to-check) 'var-to-check)
    x-is-t
  var-to-check
  x-is-nil
  nil-I-say)nil







(if (and (boundp 'x) x) x-is-t x x-is-nil nil-I-say)nil



(if (and (boundp var) x) x-is-t x x-is-nil nil-I-say)nil



(if (and (boundp x) x) x-is-t x x-is-nil nil-I-say)nil





(if (and (boundp 'x x)) 
    x-is-t x x-is-nil nil-I-say)nil

(cl-prettyexpand '(if-and-boundp x
    (princ "x is\n")
   (princ "x is ")
   (princ "not\n")))

2

2

(cl-prettyexpand '
(let ((x t))
  (if-and-boundp x
      (progn (princ "x is.\n") '===)
    (princ "x is ")
    (princ "not\n")
    '---)))

(let ((x nil))
  (if (and (boundp 'x) x) (progn (princ "x is.
") '===) (princ "x is ") (princ "not
") '---))
x is not
---

x is not
---

x is.
===



x is.
===


x is.
===

x is.
===

x is not
---

x is not
---

x is.
nil

x is.
nil

x is.
"x is.
"

x is not
nil

x is not
nil

x is not
"not
"

x is not
"not
"

x is
"x is
"

x is not
"not
"


========================
Thursday November 30 2006
--


(defun dpj-alt-exp (limit n max)
  (interactive)
  (catch 'done
    (while (re-search-forward dpj-alt-regexp limit t)
      (setq n-th (mod (string-to-int (match-string 1)) max))
      (when (memq (line-number) '(58 59 65 69)))
      (if (= n-th n)
          (throw 'done t)))
    nil))

1.1) 



========================
Monday December 04 2006
--

(global-set-key "\e1" (kb-lambda (insert "e")))
nil
(global-set-key "\e2" (kb-lambda (insert "c")))
nil



(defun gdb-w/ssh (path &optional corefile)
  "Run gdb on program FILE in buffer *gdb-FILE* on another host via ssh.
The directory containing FILE becomes the initial working directory
and source-file directory for GDB.  If you wish to change this, use
the GDB commands `cd DIR' and `directory'."
  (interactive "FRun gdb on file: ")
  (setq path (file-truename (expand-file-name path)))
  (let ((file (file-name-nondirectory path)))
    (switch-to-buffer (concat "*gdb-" file "*"))
    (setq default-directory (file-name-directory path))
    (or (bolp) (newline))
    (insert "Current directory is " default-directory "\n")
    (apply 'make-comint
	   (concat "gdb-" file)
	   "ssh"
	   nil
           "tc-le4"
           (substitute-in-file-name gdb-command-name)
	   "-fullname"
	   "-cd" default-directory
	   file
	   (and corefile (list corefile)))
    (set-process-filter (get-buffer-process (current-buffer)) 'gdb-filter)
    (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
    ;; XEmacs change: turn on gdb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (gdb-mode)
    (gdb-set-buffer)))



========================
Tuesday December 19 2006
--


(defun dp-usurp-gdb (&optional buffer)
  "Take control of a normal command-line gdb session in BUFFER.
If BUFFER is nil, use the current buffer.
@todo: Add code to tramp files from a remote host if not using a 
common source tree."
  (interactive)
  (setq-ifnil buffer (current-buffer))
  (set-process-filter (get-buffer-process buffer) 'gdb-filter)
  (set-process-sentinel (get-buffer-process buffer) 'gdb-sentinel)
  ;; XEmacs change: turn on gdb mode after setting up the proc filters
  ;; for the benefit of shell-font.el
  (gdb-mode)
  (gdb-set-buffer))




;;
;; FINISH THIS !!!!!
;;
(defun gdb-w/ssh (host path &optional corefile)
  "Run gdb on program FILE in buffer *gdb-FILE* on another host via ssh.
The directory containing FILE becomes the initial working directory
and source-file directory for GDB.  If you wish to change this, use
the GDB commands `cd DIR' and `directory'."
  (interactive "sHost: \nFRun gdb on file: ")
  (setq path (file-truename (expand-file-name path)))
  (let ((file (file-name-nondirectory path)))
    (switch-to-buffer (concat "*gdb-" file "*"))
    (setq default-directory (file-name-directory path))
    (or (bolp) (newline))
    (insert "Current directory is " default-directory "\n")
    (apply 'make-comint
	   (concat "gdb-" file)
	   "ssh"
	   nil
           host
           (substitute-in-file-name gdb-command-name)
	   "-fullname"
	   "-cd" default-directory
	   file
	   (and corefile (list corefile)))
    (set-process-filter (get-buffer-process (current-buffer)) 'gdb-filter)
    (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
    ;; XEmacs change: turn on gdb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (gdb-mode)
    (gdb-set-buffer)))
;;;
;;;
;;;
(provide 'dpmisc)


trying for sudoableness


(defun gdb-w/ssh (host path &optional corefile)
  "Run gdb on program FILE in buffer *gdb-FILE* on another host via ssh.
The directory containing FILE becomes the initial working directory
and source-file directory for GDB.  If you wish to change this, use
the GDB commands `cd DIR' and `directory'.
Prefix arg or host name beginning with a + means to sudo gdb."
  (interactive "sHost: \nFRun gdb on file: ")
  (setq path (file-truename (expand-file-name path)))
  (let* ((file (file-name-nondirectory path))
         (sudo (or current-prefix-arg
                   (posix-string-match "^\\+" host)))
         (path (if (posix-string-match "^\\+" host)
                   (substring host 1 host)
                 path))
         (cmd )
    (switch-to-buffer (concat "*gdb-" file "*"))
    (setq default-directory (file-name-directory path))
    (or (bolp) (newline))
    (insert "Current directory is " default-directory "\n")
    (apply 'make-comint
	   (concat "gdb-" file)
	   "ssh"
	   nil
           host
           cmd
	   "-fullname"
	   "-cd" default-directory
	   file
	   (and corefile (list corefile)))
    (set-process-filter (get-buffer-process (current-buffer)) 'gdb-filter)
    (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
    ;; XEmacs change: turn on gdb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (gdb-mode)
    (gdb-set-buffer))



(setq dp-gdb-cf-args 
      "-a -i -a /home/davep/tsat-bin/dbra-c1.rc")

(defun gdb-cf-w/ssh (host-name program &optional args)
  "Run PROGRAM \(\"cmd-factory\") using ${tsat-bin1}/simple-run-gdb.
This is a highly specific function, hence it inclusion is a fairly specific
rc file.
The purpose is to run a script \(simple-run-gdb) which sets up many useful
defaults for a gdb session and then runs sudo gdb on PROGRAM."
  (interactive (list
                (read-from-minibuffer "host-name: ")
                (read-file-name (format "Run %s on file: " 
                                        dp-gdb-sudo-cmd-name)
                                tsat-bin
                                nil
                                'non-nil-and-non-t
                                "cmd-factory"
                                'dp-gdb-sudo-history)
                (cond
                 ((Cu0p) dp-gdb-cf-Cu0-def-args)
                 (current-prefix-arg 
                  (setq dp-gdb-cf-args 
                        (progn
                          (let ((s (completing-read 
                                    "ARGS? " 
                                    dp-gdb-cf-configs-completion-list nil nil 
                                    dp-gdb-cf-args 
                                    dp-gdb-cf-history)))
                            (string-match "^\\(=[^:]+:\\)?\\(.*\\)$" s)
                            (match-string 2 s)))))
                 (t dp-gdb-cf-args))))
  (let ((gdb-command-name (mk-tsat-bin-name "run-gdb")))
    (setenv "PROGRAM_ARGS" args)
    (setenv "emacs_gdb" "t")
    ;;(setenv "out_of_date_ok" "y")
    (setq dp-gdb-buffer-name "*gdb-cmd-factory*")
    (gdb-w/ssh host-name (or program (mk-tsat-bin-name "cmd-factory")))))




========================
Tuesday January 02 2007
--
(defun dp-visit-or-switch-to-buffer (buf)
  "Switch to BUF's window if VISIBLE, ELSE switch to the buffer in the
current window."
  (interactive "bbuf? ")
  (unless (dp-display-buffer-if-visible buf)
    (switch-to-buffer buf)))
  
                              

========================
Wednesday January 03 2007
--
(defun dp-change-case-region (&optional down-p)
  (interactive "P")
  (if (C-u-p)
      (downcase-region-or-word)
    

========================
Monday January 08 2007
--

(defun dp-center-to-top (&optional arg recursing-p)
  (interactive "_P")
  (if (and (not (eq arg '-))
           (or (memq last-command 
                    '(dp-center-to-top dp-center-to-bottom))
               recursing-p))
      (setq dp-center-to-top-divisor (* 2 dp-center-to-top-divisor))
    (setq dp-center-to-top-divisor 2))
  (let* ((orig-arg arg)
         (arg-down (eq arg '-))
         (going-down (or arg-down
                         (eq last-command 'dp-center-to-bottom)))
         (arg (if arg-down nil arg))
         (win-start (window-start))
         (recenter-N (funcall (if going-down '- '+) 
                              (/ (window-height) dp-center-to-top-divisor))))
    (if arg
        (progn
          (recenter (prefix-numeric-value prefix-arg))
          (setq this-command 'recenter))
      (if (eq recenter-N 0)
          (progn
            (move-to-window-line nil)
            (setq dp-center-to-top-divisor 2))
        (recenter (if (eq dp-center-to-top-divisor 2) 
                      nil               ;redraws as per standard ^L
                    recenter-N))
        ;; don't recenter if we're already centered.
        (if (and (not recursing-p)
                 (= win-start (window-start)))
            (dp-center-to-top orig-arg 'recursing-p)))
      (setq this-command (if going-down 
                             'dp-center-to-bottom
                           'dp-center-to-top)))))





((arg-down (eq arg '-))
         (going-down (or arg-down)
                     (eq last-command 'dp-center-to-bottom))
         (arg (if (eq arg '-) nil arg))
         (win-start (window-start))
         (recenter-N (funcall (if going-down '- '+) 
                              (/ (window-height) dp-center-to-top-divisor))))

(if 'x 
    a
  b
   
 

========================
Wednesday January 10 2007
--


(defmacro dp-funcall-if  (func func-args &rest else-body)
  "Apply FUNC to FUNC-ARGS if FUNC is a function, otherwise do ELSE."
  `(if (functionp ,func)
    (funcall ,func ,@func-args)
    ,@else-body))
dp-funcall-if

(defmacro dp-apply-if (func func-args &rest else-body)
  "Apply FUNC to FUNC-ARGS if FUNC is a function, otherwise do ELSE."
  `(if (functionp ,func)
    (apply ,func ,@func-args)
    ,@else-body))
dp-apply-if


(cl-prettyexpand '(dp-funcall-if 'dmessage ("a: %s, b: %s" 
                                                    post-command-hook "hi")
                   (princ "not a")
                   (princ " function.\n")
                   nil))

(if (functionp 'dmessage) (funcall 'dmessage "a: %s, b: %s" post-command-hook "hi") (princ "not a") (princ " function.
") nil)
"a: (t flyspell-post-command-hook), b: hi"




(if (functionp 'dmessagex) (funcall 'dmessagex "a: %s, b: %s" post-command-hook "hi") (princ "not a") (princ " function.
") nil)
not a function.
nil


(cl-prettyexpand '(dp-apply-if 'dmessage ("a: %s, b: %s" 
                                                    (list post-command-hook "hi"))
                   (princ "not a")
                   (princ " function.\n")
                   nil))

(if (functionp 'dmessage) (apply 'dmessage "a: %s, b: %s" (list post-command-hook "hi")) (princ "not a") (princ " function.
") nil)
"a: (t flyspell-post-command-hook), b: hi"



(if (functionp 'dmessage) (apply 'dmessage "a: %s, b: %s" (list post-command-hook "hi")) (princ "not a") (princ " function.
") nil)




(if (functionp 'dmessage) 
    (apply 'dmessage "a: %s, b: %s" '(post-command-hook "hi")) 
  (princ "not a") 
  (princ " function.
") nil)
"a: post-command-hook, b: hi"




(if (functionp 'dmessage) 
    (apply 'dmessage (list "a: %s, b: %s" '(post-command-hook "hi"))) 
  (princ "not a") 
  (princ " function.
") nil)



(cl-prettyexpand '(dp-funcall-if 'dmessage ("a: %s, b: %s" 
                                                    post-command-hook "hi")
                   (princ "not a")
                   (princ " function.\n")
                   nil))



(defmacro dp-call-interactively-if (func func-args &rest else-body)
  "Apply FUNC to FUNC-ARGS if FUNC is a function, otherwise do ELSE."
  `(if (and (functionp ,func)
            (or (interactive-form ,func)
                (error 'invalid-function
                       (format "%s is a function, but not an interactive function." ,func))))
    (call-interactively ,func ,@func-args)
    ,@else-body))
dp-call-interactively-if
(symbol-plist 'dp-call-interactively-if)
(lisp-indent-function 2)

(cl-prettyexpand '(dp-call-interactively-if 'find-file nil
                   (princ "else ")
                   (princ "form.\n")))

(if (and (functionp 'find-file) (or (interactive-form 'find-file) (error 'invalid-function (format "%s is a function, but not an interactive function." 'find-file)))) (call-interactively 'find-file) (princ "else ") (princ "form.
"))



(if (and (functionp nil) (or (interactive-form nil) (error 'invalid-function (format "%s is a function, but not an interactive function." nil)))) (call-interactively nil) (princ "else ") (princ "form.
"))
else form.
"form.
"



(if (and (functionp fin) 
         (or (interactive-form 'dmessage) 
             (error 'invalid-function (format "%s is a function, but not an interactive function." 'dmessage)))) 
    (call-interactively 'dmessage) (princ "else ") (princ "form.
"))
else form.
"form.
"


========================
Tuesday January 16 2007
--

(current-keymaps)
(#<keymap size 5 0x16e5f> #<keymap size 7 0x2e1580> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>)


(dp-define-buffer-local-keys '("\C-j" eval-print-last-sexp))
nil

(setq l nil)
nil

(setq l (cons 'a l))
(a a)

(a)

(put 'undef 'blah t)
t
undef


(loop for (x y) on '(a b)  by 'cddr do
  (princ (format "x: %s, y: %s\n" x y)))
x: a, y: b
nil



x: a, y: b
x: b, y: nil
nil



(define-key compilation-minor-mode-map "\C-m" 'comint-send-input)
comint-send-input


l
#<keymap size 9 0x30aa3d6>
(describe-bindings-internal l)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil

(eq l l2)
nil

(describe-bindings-internal l2)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil


(describe-bindings-internal km1)

return          comint-send-input
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             comint-send-input
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file
nil

#<keymap size 3 0x33b0487>


kml1
(#<keymap compilation-minor-mode-map size 9 0x19825> #<keymap shell-mode-map size 6 0x615cc> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>)

(describe-bindings-internal (car kml1))

return          comint-send-input
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             comint-send-input
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil



(setq l (list kml1 kml2 kml3))
((#<keymap compilation-minor-mode-map size 9 0x19825> #<keymap shell-mode-map size 6 0x615cc> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>)

(#<keymap compilation-minor-mode-map size 9 0x19825> #<keymap shell-mode-map size 6 0x615cc> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>) 

(#<keymap compilation-minor-mode-map size 9 0x19825> #<keymap size 9 0x364e08e> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>))


(describe-bindings-internal (car kml1))

return          comint-send-input
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             comint-send-input
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil


(describe-bindings-internal (car kml2))

return          comint-send-input
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             comint-send-input
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil

(describe-bindings-internal (car kml3))

return          comint-send-input
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             comint-send-input
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil

(describe-bindings-internal km1)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil

(describe-bindings-internal clm-before)

tab             comint-dynamic-complete
return          comint-send-input
down            Anonymous Lambda
home            comint-bol
up              Anonymous Lambda
C-space         expand-abbrev
C-a             dp-shell-home
C-c             << Prefix Command >>
C-d             comint-delchar-or-maybe-eof
C-g             comint-previous-matching-input-from-input
C-i             comint-dynamic-complete
C-l             dp-center-to-top
C-m             comint-send-input
C-n             Anonymous Lambda
C-p             Anonymous Lambda
C-r             Anonymous Lambda
C-z             dp-shell-visit-whence
C-down          dp-scroll-up
C-up            dp-scroll-down
M-return        shell-resync-dirs
M--             dp-bury-or-kill-this-process-buffer
M-?             comint-dynamic-list-filename-completions
M-d             dp-shell-delete-line
M-n             bury-buffer
M-p             comint-previous-matching-input-from-input
M-r             comint-previous-matching-input
M-s             comint-next-matching-input
M-{             comint-previous-prompt
M-}             comint-next-prompt
M-left          dp-shell-goto-prev-cmd-pos
M-right         dp-shell-goto-next-cmd-pos
M-C-l           dp-clr-shell
M-C-m           shell-resync-dirs

C-c C-b         shell-backward-command
C-c C-f         shell-forward-command

C-c return      comint-copy-old-input
C-c C-\         comint-quit-subjob
C-c C-a         comint-bol
C-c C-c         comint-interrupt-subjob
C-c C-d         comint-send-eof
C-c C-e         comint-show-maximum-output
C-c C-l         comint-dynamic-list-input-ring
C-c C-m         comint-copy-old-input
C-c C-n         comint-next-prompt
C-c C-o         comint-kill-output
C-c C-p         comint-previous-prompt
C-c C-r         comint-show-output
C-c C-u         comint-kill-input
C-c C-w         backward-kill-word
C-c C-z         comint-stop-subjob
C-c M-o         Anonymous Lambda
nil


(describe-bindings-internal clm-kmap)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil

(describe-bindings-internal clm-after)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil


(describe-bindings-internal clm-after2)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil


(describe-bindings-internal clm-after3)

return          dp-enter-kb-lambda
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             dp-enter-kb-lambda
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil

ckm
(#<keymap compilation-minor-mode-map size 9 0x19825> #<keymap size 9 0x3acd3df> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>)

(car ckm)
#<keymap compilation-minor-mode-map size 9 0x19825>

(describe-bindings-internal (car ckm))

return          comint-send-input
C-return        Anonymous Lambda
C-c             << Prefix Command >>
C-m             comint-send-input
M-n             bury-buffer
M-o             dp-kill-ring-save
M-p             dp-shell-resync-dirs
M-{             compilation-previous-file
M-}             compilation-next-file

C-c C-c         comint-interrupt-subjob
C-c C-k         kill-compilation
nil
             


       (dmessage "current-line>%s<" (buffer-substring 
                                     (line-beginning-position) 
                                     (line-end-position)))
       (dmessage "1:pmin: %s, lbp: %s, pt: %s, lep: %s, pmax: %s, rest-o-line>%s<"
                 (point-min) (line-beginning-position)
                 (point)
                 (line-end-position) (point-max)
                 (buffer-substring (point) (line-end-position)))
       (beginning-of-line)
       (dmessage "2:pmin: %s, lbp: %s, pt: %s, lep: %s, pmax: %s, rest-o-line>%s<"
                 (point-min) (line-beginning-position)
                 (point)
                 (line-end-position) (point-max)
                 (buffer-substring (point) (line-end-position)))
       (forward-char (length text))
       (dmessage "3:pmin: %s, lbp: %s, pt: %s, lep: %s, pmax: %s, rest-o-line>%s<"
                 (point-min) (line-beginning-position)
                 (point)
                 (line-end-position) (point-max)
                 (buffer-substring (point) (line-end-position)))


(defun dp-ipython-dedent ()
  (interactive)
  (when (and (equal (point) (save-excursion (comint-bol nil) (point)))
             (dp-looking-back-at "     "))
    (delete-backward-char 4)
    t))

(defun dp-ipython-backward-delete-word ()
  (interactive)
  (unless (dp-ipython-dedent)
    (call-interactively 'dp-backward-delete-word)))

dp-ipython-dedent


In [50]: for x in [1,2,3]:
   ....:     print x
   ....:     for y in [7,8,9]:
   ....:         print "y:", y, "x:", x
   ....:     print "y done."
   ....:     




=================
(delete-backward-charnil


========================
Wednesday January 17 2007
--

(defvar dp-serialized-name-alist '())

(defun dp-serialized-name (prefix)
  (interactive)
  (let ((el (assoc prefix dp-serialized-name-alist))
        n)
    (if el
        (setcdr el (setq n (1+ (cdr el))))
      (setq n 0
            dp-serialized-name-alist (cons (cons prefix n)
                                           dp-serialized-name-alist)))
    (format "%s%d" prefix n)))

(dp-serialized-name "blah-")
"blah-2"

"blah-1"

"blah-0"

"boo-2"

"boo-1"

"boo--0"

      
                
dp-serialized-name-alist
(("blah-" . 2) ("boo-" . 2))

(("boo-" . 2))



========================
Monday January 22 2007
--

(defun dp-read-variable-name (&optional def-prompt prompt history-symbol)
  (let* ((v (variable-at-point))
         (val (let ((enable-recursive-minibuffers t))
                (completing-read
                 (if v
                     (format (or def-prompt "Describe variable (default %s): ") v)
                   (gettext (or prompt "Describe variable: ")))
                 obarray 'boundp t nil (or history-symbol 'variable-history)
                 (symbol-name v)))))
    (list (intern val))))
dp-read-variable-name


(dp-read-variable-name)
(bookmark-map)

nil


========================
Wednesday January 24 2007
--

;;                    0              1       2       3      4
(defun dp-extent-at (pos &optional object property before at-flag)
  (interactive)
  (when (and (eobp)
             (bufferp object)
             (dp-local-keymap-extent-p object)
             (eq at-flag nil))
    (setq at-flag 'at))
  (extent-at pos object property before at-flag))
dp-extent-at

(ad-unadvise 'extent-at)
nil


(ad-recover 'extent-at)

(defadvice extent-at (before dp-extent-at act)
  "Extend extent detection to EOF for our keymap extent"
  (when (and (eobp)
             (bufferp (ad-get-arg 1))
             (dp-local-keymap-extent-p (ad-get-arg 1))
             (eq (ad-get-arg 4) nil))
    (dmessage "YOPP!")
    (ad-set-arg 4 'at)))
extent-at

(defadvice current-keymaps (before dp-current-keymaps act)
  "Blah"
  (dmessage "YOPP!"))
current-keymaps

(current-keymaps)
(#<keymap size 5 0x16e5c> #<keymap lisp-interaction-mode-map size 12 0x2edce> #<keymap global-window-system-map size 4 0x232e> #<keymap global-map size 639 0x2322>)


(defun dp-comint-fubar-hack (str)
  (when (and (stringp str)
             (posix-string-match "^[0-9][0-9]*> " str))
    (insert str " ")
    (backward-char)
    (setq str "")))
dp-comint-fubar-hack

(add-hook 'comint-output-filter-functions 'dp-comint-fubar-hack)
(remove-hook 'comint-output-filter-functions 'dp-comint-fubar-hack)
(ipython-indentation-hook py-comint-output-filter-function comint-strip-ctrl-m dp-limit-comint-output py-pdbtrack-track-stack-file ansi-color-process-output comint-postoutput-scroll-to-bottom comint-watch-for-password-prompt)

key-translation-map
#<keymap key-translation-map size 0 0x233a>

(make-variable-buffer-local 'key-translation-map)
key-translation-map

(define-key key-translation-map "~" (kb-lambda nil))
(lambda (&optional arg) "" (interactive "P") nil)
(funcall (lambda (&optional arg) "" (interactive "P") nil))
nil

(lambda (&optional arg) "" (interactive "P") nil)



"~"

"~"
~~
"+"

(lambda (&optional arg) "" (interactive "P") (insert "~~"))

~~~~~~

(describe-bindings-internal key-translation-map)


(setq key-translation-map (make-sparse-keymap))
#<keymap size 0 0x723acbd>

(defun dp-def-buf-local-key )

    


========================
Friday January 26 2007
--


    (let ((map (cond
                ((memq dp-local-map-method 
                       '(nil dp-local-map-uses-use-local-map))
                 ;; Make our mods to a copy of this keymap
                 (cons (car (current-keymaps)) 'dp-use-local-map))
                ((eq dp-local-map-method 'dp-local-map-uses-extent)
                 (when (boundp dp-local-extent-keymap)
                   (cons 'dp-local-extent-keymap 'dp-set-local-extent-keymap)))
                ((eq dp-local-map-method 'dp-local-map-uses-minor-mode-map)
                 (cons 'dp-get-local-minor-mode-map 
                       'dp-set-local-minor-mode-map))
                t nil))))
    (if map
        map
      ;; CODE!
      )))

(function (cond
                    ((eq dp-local-map-method 'dp-local-map-uses-use-local-map)
                     (use-local-map new-map)
                     nil)
                    ((and (eq dp-local-map-method 'dp-local-map-uses-extent)
                          (or keymap dp-local-keymap))
                     'dp-set-local-extent-keymap)
                    ((eq dp-local-map-method 'dp-local-map-uses-minor-mode-map)
                     'dp-set-local-minor-mode-map)
                    (t (error 'invalid-argument 
                              (format "Unknown dp-local-map-method: %s" 
                                      dp-local-map-method)))))
(defun describe-bindings-1 (&optional prefix mouse-only-p)
  (let ((heading (if mouse-only-p
            (gettext "button          binding\n------          -------\n")
            (gettext "key             binding\n---             -------\n")))
        (buffer (current-buffer))
        (minor minor-mode-map-alist)
	(extent-maps (mapcar-extents
		      'extent-keymap
		      nil (current-buffer) (point) (point) nil 'keymap))
        (local (current-local-map))
        (shadow '()))
    (set-buffer standard-output)
    (while extent-maps
      (insert (format "Bindings for Text Region, map:\n %s\n" (car extent-maps))
	      heading)
      (describe-bindings-internal
       (car extent-maps) nil shadow prefix mouse-only-p)
       (insert "\n")
       (setq shadow (cons (car extent-maps) shadow)
	     extent-maps (cdr extent-maps)))
    (while minor
      (let ((sym (car (car minor)))
            (map (cdr (car minor))))
        (if (symbol-value-in-buffer sym buffer nil)
            (progn
              (insert (format "Minor Mode Bindings for `%s', map:\n %s\n" sym map)
                      heading)
              (describe-bindings-internal map nil shadow prefix mouse-only-p)
              (insert "\n")
              (setq shadow (cons map shadow))))
        (setq minor (cdr minor))))
    (if local
        (progn
          (insert (format "Local Bindings, map:\n %s\n" local) heading)
          (describe-bindings-internal local nil shadow prefix mouse-only-p)
          (insert "\n")
          (setq shadow (cons local shadow))))
    (if (console-on-window-system-p)
	(progn
	  (insert "Global Window-System-Only Bindings:\n" heading)
	  (describe-bindings-internal global-window-system-map nil
				      shadow prefix mouse-only-p)
	  (push global-window-system-map shadow))
      (insert "Global TTY-Only Bindings:\n" heading)
      (describe-bindings-internal global-tty-map nil
				  shadow prefix mouse-only-p)
      (push global-tty-map shadow))
    (insert "\nGlobal Bindings:\n" heading)
    (describe-bindings-internal (current-global-map)
                                nil shadow prefix mouse-only-p)
    (when (and prefix function-key-map (not mouse-only-p))
      (insert "\nFunction key map translations:\n" heading)
      (describe-bindings-internal function-key-map nil nil
				  prefix mouse-only-p))
    (set-buffer buffer)
    standard-output))


========================
2007-01-29T18:10:52
--


bury-buffer'd:  *Message-Log*
Fontifying *ssh-tc-le4*...
dp-comint-mode-hook, (not ignored) (major-mode-str)>comint-mode<, bn>*ssh-tc-le4*<
dp-shell-common-hook, (major-mode-str)>comint-mode<, bn>*ssh-tc-le4*< done.
dp-comint-mode-hook done.
~/lisp/ 
enter dp-shell-mode-hook, current-buffer: *ssh-tc-le4*
in dp-maybe-add-compilation-minor-mode *ssh-tc-le4*
is shell type buf
**nil, nil, shell-mode, >compilation-mode<, nil**
non compilation-buffer-p
bind and add mode, orig>comint-send-input<, mn>shell-mode<
enter dp-compilation-mode-hook
current-buffer: *ssh-tc-le4*
dp-bind-shell-type-enter-key: major-mode is nil
setting C-m to dp-com.... for mode>nil<
  the binding was: comint-send-input
dp-define-buffer-local-keys: current-buffer: *ssh-tc-le4*, buffer: nil
dp-define-buffer-local-keys0: current-buffer: *ssh-tc-le4*, buffer: *ssh-tc-le4*
  the binding is: dp-sh-enter-99185
dp-shell-mode-hook, (major-mode-str)>shell-mode<, bn>*ssh-tc-le4*<, done.
in dp-ssh-mode-hook
dp-specialized-shell-setup calling dp-comint-mode-hook
dp-comint-mode-hook, (not ignored) (major-mode-str)>ssh-mode<, bn>*ssh-tc-le4*<
dp-shell-common-hook, (major-mode-str)>ssh-mode<, bn>*ssh-tc-le4*< done.
dp-comint-mode-hook done.
current-buffer: *ssh-tc-le4*
Fontifying *ssh-tc-le4*... done.

 already bound >dp-sh-enter-99185<.



(cl-prettyexpand '(dp-funcall-if 'dp-refresh-my-aliases-p (abbrevs)
                 (setq local-abbrev-table dp-shell-mode-abbrev-table)))

(if (functionp 'dp-refresh-my-aliases-p)
    (funcall 'dp-refresh-my-aliases-p abbrevs)
  (setq local-abbrev-table dp-shell-mode-abbrev-table))

l

(interactive-form 'l)

(default-value 'comint-input-sender)
comint-simple-send


(defun interactive-functionp (sym)
  (and (functionp sym)
       (interactive-form sym)
       sym))

(defun dp-shell-send-input (variant)
  "MY send input function. Save buffer position of last command sent.
Then invoke original key binding if there was one, else try to call
xxx-send-input as a last resort."
  (interactive)
  ;; if we are above the prompt, or in a grep or compilation
  ;; buffer, then act like this is a goto-error request
;;; trying shell-mode w/o setting RET as a magic key
  ;; seems like some kind of magic is needed, since I want 
  ;; send-input after prompt and something like C-m before.
  ;;!<@todo can this be done more cleanly? 
  (if (or (dp-grep-like-buffer-p (major-mode-str))
	  (not (fboundp (dp-sls variant '-after-pmark-p)))
	  (not (funcall (dp-sls variant '-after-pmark-p))))
      (dp-shell-goto-this-error)
    ;; save the position in the buffer where the latest command was issued.
    (dp-save-last-command-pos)
    (setq dp-shell-output-line-count 0)
    ;; try to call the original binding, trying the more specific buffer local
    ;; function variable before the default mode -> func mapping.
    (call-interactively (or 
                         (interactive-functionp dp-shell-original-enter-binding)
                         (interactive-functionp (cdr (assoc (major-mode-str) dp-shell-enter-alist)))
                         (and (message "No func assoc w/mode %s, using defaults." (major-mode-str))
                              nil)
                         (interactive-functionp dp-shell-send-input-sender)
                         (interactive-functionp (dp-sls variant '-send-input))
                         (interactive-functionp (default-value 'comint-input-sender))
                         'comint-simple-send))
    ;; You can't say I didn't try.
    ))
                         
    (let* ((fun (or dp-shell-original-enter-binding
                    (cdr (assoc (major-mode-str) dp-shell-enter-alist)))))
      (if fun
	  (progn 
	    ;;(dmessage "calling fun>%s<" fun)
	    (call-interactively fun))
	;; getting here is baaaad.
	(message "No func assoc w/mode %s, using defaults." (major-mode-str))
	;(ding)
        (if (functionp 'dp-shell-send-input-sender)
            (call-interactively 'dp-shell-send-input-sender)
          (call-interactively (dp-sls variant '-send-input)))))))


(defun* dp-on-last-line-p (&optional (pt (point))
                           (buffer (current-buffer)))
  "Return if POINT is on the last line of the shell buffer."
  (interactive)
  (save-excursion
    (set-buffer buffer)
    (goto-char pt)
    (not (re-search-forward "\n" (point-max) 'NOERROR))))


========================
Friday February 09 2007
--

(regexp-opt '("&optional" "&rest" "&key" "&allow-other-keys" 
               "&aux" "&whole" "&body" "&environment"))
"&\\(?:a\\(?:llow-other-keys\\|ux\\)\\|body\\|environment\\|key\\|optional\\|rest\\|whole\\)"

  '(&optional &rest &key &allow-other-keys &aux &whole &body &environment))

(regexp-opt (mapconcat 
             'identity
             '("&optional" "&rest" "&key" "&allow-other-keys" 
               "&aux" "&whole" "&body" "&environment")
           " "))

(mapconcat (lambda (a)
             (format "\"%s\"" a))
           '(&optional &rest &key &allow-other-keys &aux &whole &body &environment)
           " ")
"\"&optional\" \"&rest\" \"&key\" \"&allow-other-keys\" \"&aux\" \"&whole\" \"&body\" \"&environment\""

"&optional &rest &key &allow-other-keys &aux &whole &body &environment"






(mapconcat 
             'identity
             '("&optional" "&rest" "&key" "&allow-other-keys" 
               "&aux" "&whole" "&body" "&environment")
           " ")
"&optional &rest &key &allow-other-keys &aux &whole &body &environment"

"&optional&rest&key&allow-other-keys&aux&whole&body&environment"


l
(169696 . 169763)

(defun tfc ()
  (interactive)
  (with-current-buffer (get-buffer "dpmisc.el")
    (dp-colorize-region 4 (car l) (cdr l) 
                        t 'dp-tfc-prop t)))
(tfc)
nil

nil

(defun tfunc ()
  (interactive)
  (with-current-buffer (get-buffer "dpmisc.el")
    (dp-uncolorize-region (car l) (cdr l) 
                          'PRESERVE-CURRENT-COLOR-P
                          'dp-tfc-prop)))

(tfunc)
nil

nil




(get-buffer "dpmisc.el")
#<buffer "dpmisc.el">

(defun py-pdbtrack-overlay-arrow-orig (activation)
  "Activate or de arrow at beginning-of-line in current buffer."
  ;; This was derived/simplified from edebug-overlay-arrow
  (cond (activation
	 (setq overlay-arrow-position (make-marker))
	 (setq overlay-arrow-string "=>")
	 (set-marker overlay-arrow-position (py-point 'bol) (current-buffer))
	 (setq py-pdbtrack-is-tracking-p t))
	(overlay-arrow-position
	 (setq overlay-arrow-position nil)
	 (setq py-pdbtrack-is-tracking-p nil))
	))

(defun py-pdbtrack-overlay-arrow-deact-old ()
  (interactive)
  (dp-uncolorize-region (plist-get dp-py-arrow-plist 'beg)
                        (plist-get dp-py-arrow-plist 'end)
                        'PRESERVE-CURRENT-COLOR-P
                        (plist-get dp-py-arrow-plist 'pid))
  (setq dp-py-arrow-plist '()))

(defun py-pdbtrack-overlay-arrow-old2 (activation)
  "Activate or de arrow at beginning-of-line in current buffer."
  ;; This was derived/simplified from edebug-overlay-arrow
  (cond (activation
         (setq dp-py-arrow-marker
               (dp-highlight-point :id-prop dp-py-arrow-id
                                   :pos (dp-mk-marker (py-point 'bol) 
                                                      (current-buffer)))
               py-pdbtrack-is-tracking-p t))
	(dp-py-arrow-marker
         (dp-unhighlight-point :id-prop dp-py-arrow-id :pos dp-py-arrow-marker)
	 (setq dp-py-arrow-marker nil
               py-pdbtrack-is-tracking-p nil))
	))

(defun* dp-mk-breakpoint-command (&optional &key (fmt "%s:%s") (pos (point)))
  (interactive)
  (format fmt buffer-file-name (line-number-at-pos)))

(defun* dp-kill-breakpoint-command (&optional &key (fmt "%s:%s") (pos (point)))
  (interactive)
  (kill-new (dp-mk-breakpoint-command)))


(buffer-file-name)
"/home/davep/lisp/devel/elisp-devel.el"

buffer-file-truename
"/home/davep/lisp/devel/elisp-devel.el"



========================
Tuesday February 13 2007
--
dotimes (var count [result]) forms

(dotimes (i 15)
  (beginning-of-line)
  (insert (format "%2d: " (1+ i)))
  (forward-line))

 1: cf-ctl --echo-cmds;
 2: cf-ctl --def-demo-dir=/home/tcwww/temp/ARSVP
 3: start-gator;
 4: mk-timer --name=dbra3a --file=dbra3aA.net2.arsvp.time
 5: echo "Running dbra3a-agg2.tss...";
 6: echo "DBRA3a: Flow1 setup"
 7: wait-for-file --comm-addr=dnstve1-man --comm-port=2
 8: send-e2e-path
 9: expect-new-agg-needed --sock-name=dagg3 --assert-compare --link
10: send-agg-path-msg --sock-name=ngprn1n2 --last-link
11: expect-agg-resv-msg --sock-name=ngprn1n2 --assert-compare --link
12: echo --comm-addr=dnstve1-man --comm-port=2 Event1: pass;
13: send-agg-resv-conf-msg --sock-name=ngprn1n2 --last-link
14: stop-gator;
15: echo "dbra3a-agg2 done";


========================
Tuesday February 20 2007
--

(defun dp-round-n-places (n &optional n-places)
  (interactive)
  (setq-ifnil n-places 2)
  (let ((factor (expt 10 n-places)))
    (/ (fround (* factor n)) factor)))
dp-round-n-places

(dp-round-n-places 11.23535 4)
11.2354

11.2353

11.24

11.23

11.2

(dp-round-n-places 12)
12.0

12.0

(+ 1/3 0)

(defun dp-round-to-1/4-hr (hours)
  (interactive)
  (* 0.25 (fround (/ (+ 0.001 hours) 0.25))))
dp-round-to-1/4-hr

(dp-round-to-1/4-hr 11.63)
11.75

11.5

11.25

(* 0.125  60)
7.5

2.0


dp-round-to-1/4-hr



========================
Tuesday February 27 2007
--

(defstruct dp-highlight-point-faces
  before                    ; Face for text before point on the current line.
  at                        ; Face for text at point on the current line.
  after                     ; Face for text after point on the current line.
  )


(defvar dp-highlight-point-default-faces
  (make-dp-highlight-point-faces :before 'dp-highlight-point-before-face
                                 :at 'dp-highlight-point-face
                                 :after'dp-highlight-point-after-face)
  "Default face list for dp-highlight-point.")

(defvar dp-highlight-point-other-window-faces
  (make-dp-highlight-point-faces 
   :before 'dp-highlight-point-other-window-before-face
   :at 'dp-highlight-point-other-window-at-face
   :after'dp-highlight-point-other-window-after-face)
  "Default face list for dp-highlight-point for current line in `other-window'
when changing windows.")

(defun* dp-highlight-point (&key (pos (point))
                            (id-prop dp-highlight-point-id-prop)
                            colors)
  "Highlight the line on which point resides.
The line is highlighted with three faces:
`dp-highlight-point-before-face'
`dp-highlight-point-face'
`dp-highlight-point-after-face'
This makes point very visible."
  (interactive)
  (let* ((buffer (or (and (markerp pos) 
                          (marker-buffer pos))
                     dp-highlight-point-buffer 
                     (current-buffer)))
         (colors (or colors dp-highlight-point-default-faces))
         (before-face (dp-highlight-point-faces-before colors))
         ;; Nil says to `inherit' previous color.
         (at-face (or (dp-highlight-point-faces-at colors)
                      before-face))
         (after-face (or (dp-highlight-point-faces-after colors) 
                         at-face))
         bol eol pp)
    (unless pos
      (setq pos (point)))
    (setq bol (line-beginning-position)
          eol (line-end-position)
          pp (+ pos (if (eobp) 0 1)))
    (when (buffer-live-p buffer)
      (with-current-buffer buffer
        (if (< bol pp)
            (dp-make-extent bol pp
                            id-prop
                            'face before-face))
        (if (<= pp eol)
            (dp-make-extent pos pp
                            id-prop
                            'end-open t
                            'start-open t
                            'face at-face))
        (if (> eol pp)
            (dp-make-extent pp eol
                            id-prop
                            'face after-face))
        (setq dp-highlight-point-buffer buffer
              dp-highlight-point-marker (dp-mk-marker pos buffer))
        ))))


(defun mic-paren-highlight-debug ()
  "The main-function of mic-paren. Does all highlighting, dinging, messages,
cleaning-up."
  ;; Remove any old highlighting
  (mic-delete-overlay mic-paren-forw-overlay)
  (mic-delete-overlay mic-paren-point-overlay)
  (mic-delete-overlay mic-paren-backw-overlay)

  ;; Handle backward highlighting (when after a close-paren or a paired
  ;; delimiter):
  ;; If (positioned after a close-paren, and
  ;;    not before an open-paren when priority=open, and
  ;;    (paren-match-quoted-paren is t or the close-paren is not escaped))
  ;;    or
  ;;    (positioned after a paired delimiter, and
  ;;    not before a paired-delimiter when priority=open, and
  ;;    the paired-delimiter is not escaped))
  ;; then
  ;;      perform highlighting
  (if (or (and (eq (char-syntax (preceding-char)) ?\))
               (not (and (eq (char-syntax (following-char)) ?\()
                         (eq paren-priority 'open)))
               (or paren-match-quoted-paren
                   (not (mic-paren-is-following-char-quoted (- (point)
                                                               2)))))
          (and paren-match-paired-delimiter
               (eq (char-syntax (preceding-char)) ?\$)
               (not (and (eq (char-syntax (following-char)) ?\$)
                         (eq paren-priority 'open)))
               (not (mic-paren-is-following-char-quoted (- (point) 2)))))
      (let (open matched-paren charquote)
        ;; if we want to match quoted parens we must change the syntax of
        ;; the escape or quote-char temporarily. This will be undone later.
        (setq charquote (mic-paren-uncharquote (- (point) 2)))
        ;; Find the position for the open-paren
        (save-excursion
          (save-restriction
            (if blink-matching-paren-distance
                (narrow-to-region
                 (max (point-min)
                      (- (point) blink-matching-paren-distance))
                 (point-max)))
            (condition-case ()
                (setq open (scan-sexps (point) -1))
              (error nil))))

        ;; we must call matching-paren because scan-sexps don't care about
        ;; the kind of paren (e.g. matches '( and '}). matching-paren only
        ;; returns the character displaying the matching paren in buffer's
        ;; syntax-table (regardless of the buffer's current contents!).
        ;; Below we compare the results of scan-sexps and matching-paren
        ;; and if different we display a mismatch.
        (setq matched-paren (matching-paren (preceding-char)))
        ;; matching-paren can only handle characters with syntax ) or (
        (if (eq (char-syntax (preceding-char)) ?\$)
            (setq matched-paren (preceding-char)))

        ;; if we have changed the syntax of the escape or quote-char we
        ;; must undo this and we can do this first now.
        (mic-paren-recharquote charquote)

        ;; If match found
        ;;    highlight expression and/or print messages
        ;; else
        ;;    highlight unmatched paren
        ;;    print no-match message
        (if open
            (let ((mismatch (or (not matched-paren)
                                (/= matched-paren (char-after open))
                                (if charquote
                                    (not (mic-paren-is-following-char-quoted
                                          (1- open)))
                                  (mic-paren-is-following-char-quoted
                                   (1- open)))))
                  ;; check if match-pos is visible
                  (visible (and (pos-visible-in-window-p open)
                                (mic-paren-horizontal-pos-visible-p open))))
              ;; If highlight is appropriate
              ;;    highlight
              ;; else
              ;;    remove any old highlight
              (if (or visible paren-highlight-offscreen paren-sexp-mode)
                  ;; If sexp-mode
                  ;;    highlight sexp
                  ;; else
                  ;;    highlight the two parens
                  (if (mic-paren-sexp-mode-p mismatch)
                      (progn
                        (setq mic-paren-backw-overlay
                              (mic-make-overlay open (point)))
                        (if mismatch
                            (mic-paren-overlay-set mic-paren-backw-overlay
                                                   paren-mismatch-face)
                          (mic-paren-overlay-set mic-paren-backw-overlay
                                                 paren-match-face)))
                    (setq mic-paren-backw-overlay
                          (mic-make-overlay
                           open
                           (+ open
                              (mic-char-bytes (char-after open)))))
                    (and paren-highlight-at-point
                         (setq mic-paren-point-overlay
                               (mic-make-overlay
                                (- (point)
                                   (mic-char-bytes (preceding-char)))
                                (point))))
                    (if mismatch
                        (progn
                          (mic-paren-overlay-set mic-paren-backw-overlay
                                                 paren-mismatch-face)
                          (and paren-highlight-at-point
                               (mic-paren-overlay-set mic-paren-point-overlay
                                                      paren-mismatch-face)))
                      (mic-paren-overlay-set mic-paren-backw-overlay
                                             paren-match-face)
                      (and paren-highlight-at-point
                           (mic-paren-overlay-set mic-paren-point-overlay
                                                  paren-match-face)))))
              ;; Print messages if match is offscreen
              (and (not (eq paren-display-message 'never))
                   (or (not visible) (eq paren-display-message 'always))
                   (not (window-minibuffer-p (selected-window)))
                   (not isearch-mode)
                   (mic-paren-is-new-location)
                   (let ((message-truncate-lines paren-message-truncate-lines))
                     (mic-paren-nolog-message "%s %s"
                                              (if mismatch "MISMATCH:" "Matches")
                                              (mic-paren-get-matching-open-text open))))
              ;; Ding if mismatch
              (and mismatch
                   paren-ding-unmatched
                   (mic-paren-is-new-location)
                   (ding)))
          (setq mic-paren-backw-overlay
                (mic-make-overlay (point)
                                  (- (point)
                                     (mic-char-bytes (preceding-char)))))
          (mic-paren-overlay-set mic-paren-backw-overlay
                                 paren-no-match-face)
          (and paren-message-no-match
               (not (window-minibuffer-p (selected-window)))
               (not isearch-mode)
               (mic-paren-is-new-location)
               (mic-paren-nolog-message "No opening parenthesis found"))
          (and paren-message-no-match
               paren-ding-unmatched
               (mic-paren-is-new-location)
               (ding)))))

  ;; Handle forward highlighting (when before an open-paren or a paired
  ;; delimiter):
  ;; If (positioned before an open-paren, and
  ;;    not after a close-paren when priority=close, and
  ;;    (paren-match-quoted-paren is t or the open-paren is not escaped))
  ;;    or
  ;;    (positioned before a paired delimiter, and
  ;;    not after a paired-delimiter when priority=close, and
  ;;    the paired-delimiter is not escaped))
  ;; then
  ;;      perform highlighting
  (if (or (and (eq (char-syntax (following-char)) ?\()
               (not (and (eq (char-syntax (preceding-char)) ?\))
                         (eq paren-priority 'close)))
               (or paren-match-quoted-paren
                   (not (mic-paren-is-following-char-quoted (1-
                                                             (point))))))
          (and paren-match-paired-delimiter
               (eq (char-syntax (following-char)) ?\$)
               (not (and (eq (char-syntax (preceding-char)) ?\$)
                         (eq paren-priority 'close)))
               (not (mic-paren-is-following-char-quoted (1- (point))))))
      (let (close matched-paren charquote)
        ;; if we want to match quoted parens we must change the syntax of
        ;; the escape or quote-char temporarily. This will be undone later.
        (setq charquote (mic-paren-uncharquote (1- (point))))
        ;; Find the position for the close-paren
        (save-excursion
          (save-restriction
            (if blink-matching-paren-distance
                (narrow-to-region
                 (point-min)
                 (min (point-max)
                      (+ (point) blink-matching-paren-distance))))
            (condition-case ()
                (setq close (scan-sexps (point) 1))
              (error nil))))

        ;; for an explanation look above.
        (setq matched-paren (matching-paren (following-char)))
        (if (eq (char-syntax (following-char)) ?\$)
            (setq matched-paren (following-char)))

        ;; if we have changed the syntax of the escape or quote-char we
        ;; must undo this and we can do this first now.
        (mic-paren-recharquote charquote)

        ;; If match found
        ;;    highlight expression and/or print messages
        ;; else
        ;;    highlight unmatched paren
        ;;    print no-match message
        (if close
            (let ((mismatch (or (not matched-paren)
                                (/= matched-paren (mic-char-before close))
                                (if charquote
                                    (not (mic-paren-is-following-char-quoted
                                          (- close 2)))
                                  (mic-paren-is-following-char-quoted
                                   (- close 2)))))
                  ;; check if match-pos is visible
                  (visible (and (pos-visible-in-window-p close)
                                (mic-paren-horizontal-pos-visible-p close))))
              ;; If highlight is appropriate
              ;;    highlight
              ;; else
              ;;    remove any old highlight
              (if (or visible paren-highlight-offscreen paren-sexp-mode)
                  ;; If sexp-mode
                  ;;    highlight sexp
                  ;; else
                  ;;    highlight the two parens
                  (if (mic-paren-sexp-mode-p mismatch)
                      (progn
                        (setq mic-paren-forw-overlay
                              (mic-make-overlay (point) close))
                        (if mismatch
                            (mic-paren-overlay-set mic-paren-forw-overlay
                                                   paren-mismatch-face)
                          (mic-paren-overlay-set mic-paren-forw-overlay
                                                 paren-match-face)))
                    (setq mic-paren-forw-overlay
                          (mic-make-overlay
                           (- close
                              (mic-char-bytes (mic-char-before close)))
                           close))
                    (if mismatch
                        (mic-paren-overlay-set mic-paren-forw-overlay
                                               paren-mismatch-face)
                      (mic-paren-overlay-set mic-paren-forw-overlay
                                             paren-match-face))))

              ;; Print messages if match is offscreen
              (and (not (eq paren-display-message 'never))
                   (or (not visible) (eq paren-display-message 'always))
                   (not (window-minibuffer-p (selected-window)))
                   (not isearch-mode)
                   (mic-paren-is-new-location)
                   (let ((message-truncate-lines paren-message-truncate-lines))
                     (mic-paren-nolog-message "%s %s"
                                              (if mismatch "MISMATCH:" "Matches")
                                              (mic-paren-get-matching-close-text close))))
              ;; Ding if mismatch
              (and mismatch
                   (mic-paren-is-new-location)
                   paren-ding-unmatched
                   (ding)))
          (setq mic-paren-forw-overlay
                (mic-make-overlay (point)
                                  (+ (point)
                                     (mic-char-bytes (following-char)))))
          (mic-paren-overlay-set mic-paren-forw-overlay
                                 paren-no-match-face)
          (and paren-message-no-match
               (not (window-minibuffer-p (selected-window)))
               (not isearch-mode)
               (mic-paren-is-new-location)
               (mic-paren-nolog-message "No closing parenthesis found"))
          (and paren-message-no-match
               paren-ding-unmatched
               (mic-paren-is-new-location)
               (ding)))))

  ;; Store the points position in mic-paren-previous-location
  ;; Later used by mic-paren-is-new-location
  (or (window-minibuffer-p (selected-window))
      (progn
        (aset mic-paren-previous-location 0 (point))
        (aset mic-paren-previous-location 1 (current-buffer))
        (aset mic-paren-previous-location 2 (selected-window))))
  )

========================
Monday March 05 2007
--

(ad-deactivate 'read-from-minibuffer)


;;
;; Need to hook other read functions, or better, hook the lowest level one.
;;
(defvar dp-use-region-as-INITIAL-CONTENTS nil
  "*If non-nil, then use region, if active, as `read-from-minibuffer's initia-contents, if not specified.")

(defadvice read-from-minibuffer (before dp-advised-read-from-minibuffer 
                                 activate)
    (when (and dp-use-region-as-INITIAL-CONTENTS
               (not (ad-get-arg 1))
               (dp-mark-active-p))
      (ad-set-arg 1 (cons (buffer-substring (mark) (point))
                          (abs (- (mark) (point)))))))




========================
Tuesday March 13 2007
--

(defmacro kb-binding-moved (new-keys)
  "Show a message telling to where the old binding has moved."
  (let* ((these-keys (this-command-keys))
         (this-desc (key-description these-keys))
         (new-desc (key-description new-keys))
         (new-binding (key-binding new-keys))
         (msg (format "the binding for %s has moved from %s to %s"
                      new-binding this-desc new-desc)))
    `(kb-warning "Binding has moved."
      ,msg)))
kb-binding-moved
(cl-prettyexpand '(kb-binding-moved "\C-cds"))

(function
 (lambda (&optional arg)
   "Binding has moved."
   (interactive "P")
   (error "kb-warning: %s"
          "the binding for dp-find-or-create-sb has moved from C-j to C-c d s")))nil


(global-set-key "\C-cz" (kb-binding-moved "\C-cd\C-s"))
nil

nil


nil




========================
Tuesday March 20 2007
--
(defmacro kb-binding-moved (new-keys)
  "Show a message telling to where the old binding has moved."
  `(let* ((these-keys (this-command-keys))
         (nada (dmessage "these keys: %s" these-keys))
         (this-desc (key-description these-keys))
         (new-desc (key-description new-keys))
         (new-binding (key-binding new-keys)))
    (kb-warning "Key has moved"
                (format "the binding for %s has moved from %s to %s"
                        new-binding this-desc new-desc))))
kb-binding-moved

(cl-prettyexpand '(kb-binding-moved "\C-cz"))

(let* ((these-keys (this-command-keys))
       (nada (dmessage "these keys: %s" these-keys))
       (this-desc (key-description these-keys))
       (new-desc (key-description new-keys))
       (new-binding (key-binding new-keys)))
  (function
   (lambda (&optional arg)
     "Key has moved"
     (interactive "P")
     (error "kb-warning: %s"
            (format "the binding for %s has moved from %s to %s"
                    new-binding
                    this-desc
                    new-desc)))))nil





(function
 (lambda (&optional arg)
   "Key has moved"
   (interactive "P")
   (error "kb-warning: %s" "the binding for nil has moved from C-j to C-c z")))nil



(dp-nslookup "man0")
"172.18.1.8"

"-which-alt"

"-which-alt"

"-"

nil



nil

nil

"-which-alt"

(shell-command-to-string "host man0")
"man0.netlab has address 172.18.1.8
"


========================
Wednesday March 21 2007
--

(defun dp-kb-binding-moved (arg new-keys)
  "Show a message telling to where the old binding has moved."
  (interactive)
  (let* ((these-keys (this-command-keys))
         (this-desc (key-description these-keys))
         (new-desc (if (functionp new-keys)
                       (let ((desc (with-temp-buffer
                                     (where-is new-keys 'INSERT)
                                     (buffer-substring))))
                         (posix-string-match "\\(^.*\\)\\s-*(" desc)
                         (match-string 1 desc))
                     (key-description new-keys)))
         (new-binding (if (functionp new-keys)
                          new-keys
                        (key-binding new-keys))))
    (ding)
    (message "The binding for `%s' has moved from \"%s\" to \"%s\""
             new-binding this-desc new-desc)))




(setq dpx1 (lambda () (dmessage "boo!")))
(lambda nil (dmessage "boo!"))

(setq dpx2 (lambda () (dmessage "boo!")))
(lambda nil (dmessage "boo!"))

(makunbound 'dpx2)
dpx2

dpx1

(equal dpx1 dpx2)
t

nil

(global-set-key "\C-c\C-z" (kb-lambda (kb-binding-moved "\C-cdp")))
nil

nil



========================
Thursday March 22 2007
--


(defmacro if-and-boundp (var then &rest else)
  `(if (and (boundp ,var) (symbol-value ,var))
    ,then
    ,@else))
if-and-boundp

(cl-prettyexpand '(if-and-boundp 'dp-ispell-program-name
    (setq ispell-program-name dp-ispell-program-name)
  (dp-init-spellin)))

(if (and (boundp 'dp-ispell-program-name)
         (symbol-value 'dp-ispell-program-name))
    (setq ispell-program-name dp-ispell-program-name)
  (dp-init-spellin))nil



========================
Monday April 02 2007
--

(regexp-quote "<5>")
"<5>"


(let ((regexp ".*<4>"))
  (some (lambda (x)
          (when (posix-string-match regexp x)
            (match-string 0 x)))
        '("123" "abc" "qw<4>")))
"qw<4>"

0


(let ((regexp ".*<8>"))
  (loop for shell in '("123" "abc" "qw<4> a<5>" "ab<4>" "asdf<4")
    when (posix-string-match regexp shell)
    collect (match-string 0 shell)))
nil

("qw<4>" "ab<4>")

("qw<4>")



(cl-prettyprint (buffer-list))

(#<buffer "*scratch*"
          >
          #<buffer
          "*ssh-tc-le4*"
          >
          #<buffer
          "*shell*"
          >
          #<buffer
          "*shell*<4>"
          >


(setq dp-shells-shell-buffers
      (list (get-buffer "*shell*") (get-buffer "*shell*<4>")
            (get-buffer "*ssh-tc-le4*")))
(#<buffer "*shell*"> nil #<buffer "*ssh-tc-le4*">)

(#<buffer "*shell*"> #<buffer "*shell*<4>"> #<buffer "*ssh-tc-le4*">)


 "\\*\\(shell\\*<4>\\|ssh-.*4*\\)$")
(dp-shells-find-matching-shell-buffers 
 nil
 (format "^\\*\\(shell\\*<%s>\\|ssh-.*%s*\\)$" 4 4))
("*shell*<4>" "*ssh-tc-le4*")


(format "^\\*\\(shell\\*<%s>\\|ssh-.*%s*\\)$" 4 4)
"^\\*\\(shell\\*<4>\\|ssh-.*4*\\)$"


(dp-shells-get-shell-buffer-name 'all ".*")
"*shell*"

"*shell*"


"*ssh-tc-le4*"


""


"c"

"*shell*"


"*ssh-tc-le4*"


"a"

"*shell*"

"*shell*"

"*shell*"

"*ssh-tc-le4*"

"q"

"q"

"*ssh-tc-le4*"

"*ssh-tc-le4*"


"*ssh-tc-le4*"

"*ssh-tc-le4*"



"*shell*<4>"

"goo"

(format "abc" 'a 'a)
"abc"




"yadda"







nil

("*shell*<4>")

(mapcar (lambda (x)
          (cons x t))
        '(a b c q))


(cadr '((a . t) (b . t) (c . t) (q . t)))
(b . t)

a




========================
Wednesday April 04 2007
--


(dp-ssh-new 11)


========================
Tuesday April 17 2007
--

diary-display-hook
nil

(dp-diary-display-hook (lambda nil (dp-define-buffer-local-keys (quote ("q" (quote kill-this-buffer))))) fancy-diary-display)

(setq diary-display-hook nil)
nil

nil

nil

nil

nil
(add-hook 'diary-display-hook 'fancy-diary-display)
(fancy-diary-display)

(fancy-diary-display)


(ignore)


(add-hook 'diary-display-hook 'fancy-diary-display)
(fancy-diary-display)
(add-hook 'diary-display-hook 'dp-diary-display-hook 'APPEND)
(fancy-diary-display dp-diary-display-hook)

(fancy-diary-display dp-diary-display-hook)

    (when buffer-read-only
      (dp-define-buffer-local-keys '("q" dp-maybe-kill-this-buffer)))
; This doesn't work, since here the name is "diary"
;    ((string= "*Fancy Diary Entries*" (buffer-name))
;     (dp-define-buffer-local-keys '("q" dp-maybe-kill-this-buffer)))


========================
Thursday April 19 2007
--

(progn
  (global-set-key [(meta ?1)] (kb-lambda (insert "e")))
  (global-set-key [(meta ?2)] (kb-lambda (insert "c")))
  (global-set-key [(control meta ?1)] (kb-lambda (insert "E")))
  (global-set-key [(control meta ?2)] (kb-lambda (insert "C"))))
EC

C
(defmacro dp-safe-alias (symbol newdef &optional fatal-p)
  `(if (or (and (functionp ,newdef) (fboundp ,symbol))
           (boundp ,symbol))
    (funcall (if ,fatal-p 'error 'message)
             "dp-safe-alias: %ssymbol: %s is already bound to %s."
             (if (functionp ,newdef) "function " "")
             ,symbol ,newdef)
    (defalias ,symbol ,newdef)))

(cl-prettyexpand '(dp-safe-alias 'ff0 'ff t))

(if (or (and (functionp 'ff) (fboundp 'ff0)) (boundp 'ff0))
    (funcall (if t 'error 'message)
             "dp-safe-alias: %ssymbol: %s is already bound to %s."
             (if (functionp 'ff) "function " "")
             'ff0
             'ff)
  (defalias 'ff0 'ff))



(if (or (and (functionp 'ff) (fboundp 'ff0)) (boundp 'ff0))
    (funcall (if nil 'error 'message)
             "dp-safe-alias: %ssymbol: %s is already bound to %s."
             (if (functionp 'ff) "function " "")
             'ff0
             'ff)
  (defalias 'ff0 'ff))
"dp-safe-alias: function symbol: ff0 is already bound to ff."








========================
Monday April 23 2007
--


(defun* mk-cntr(&optional (first 0))
  (lexical-let ((counter first))
    (function* (&optional (inc 1))
      (prog1
          counter
        (setq counter (1+ counter))))))
mk-cntr
(setq c (mk-cntr))
(lambda (&rest --cl-rest--) (apply (quote (lambda (G99136) (prog1 (symbol-value G99136) (set G99136 (1+ (symbol-value G99136)))))) (quote --counter--) --cl-rest--))


(funcall c)
2

1

0








========================
Tuesday April 24 2007
--
(defun dp-open-below ()
  "Add a new line below the current one, ala `o' in vi."
  (interactive "*")
  (end-of-line)
  (if (and (save-excursion
             (dp-in-syntactic-region '(arglist-intro arglist-cont
                                       topmost-intro topmost-intro-cont
                                       func-decl-cont)))
           (or (dp-point-follows-regexp ")\\s-*")
               (and (dp-point-follows-regexp 
                     "^\\s-*[a-zA-Z_][a-zA-Z_0-9]*\\(\\s-*\\)$")
                    (or (insert "(void)") t))
               (looking-at ".*)\\s-*")))
      (dp-c-format-func-decl)
    (save-excursion
      (if (and (dp-in-c)
               (or (and (dp-in-syntactic-region 
                         '(member-init-intro member-init-cont func-decl-cont))
                        (not (dp-point-follows-regexp "[\\\\&|,:;!@#$%^*'{}.]\\s-*$")))
                   (progn
                     (beginning-of-line)
                     (not (re-search-forward 
                           "\\(^\\s-*#\\s-*[ie]\\)\\|\\([)\\\\:;,.}{*!@#$%^&:|]\\s-*$\\)\\|\\(^\\s-*$\\)" 
                           (line-end-position) 'no-error))))
               (progn
                 (end-of-line)
                 (or (and (dp-in-c-statement)
                          (not (dp-in-c-iostream-statement)))
                     (dp-in-syntactic-region 
                      dp-c-add-comma-@-eol-of-regions))))
          (progn
            (beginning-of-line)
            (re-search-forward "\\s-*$" (line-end-position))
            (replace-match ","))))
    (end-of-line)
    (if (dp-in-c)
        (c-context-line-break)
      (newline-and-indent))))

========================
Friday April 27 2007
--


(defun* dp-shell0 (&optional arg &key other-window-p)
  "Open/visit a shell buffer.
SPLIT-P '(4) [C-u] --> Split window before switching to shell.
SPLIT-P '(16) [C-c C-u] --> Make new frame for shell."
  (interactive "P")
  (let* ((pnv (if (or (Cup arg) (not arg) (Cu0p arg))
                  nil
                (prefix-numeric-value arg)))
         (sh-name (if pnv
                      (format "*shell*<%s>" pnv)                      
                    (dp-shells-get-shell-buffer-name pnv)))
         (sh-buffer (get-buffer sh-name))
         (other-window-p (or other-window-p (Cup arg)))
         new-shell-p
         win)
    (dmessage "arg>%s<, sh-name>%s<" arg sh-name)
    (when (not sh-buffer)
      (when (and other-window-p (one-window-p 'NOMINI))
        (split-window))
      ;; exist one.
      (shell (setq sh-buffer (get-buffer-create sh-name)))
      (setq new-shell-p t
            dp-shell-isa-shell-buf-p 'shell
            other-window-p nil))
    (setq dp-shells-most-recent-shell (cons sh-buffer 'shell))
    (if other-window-p
        (switch-to-buffer-other-window sh-buffer)
      (dp-visit-or-switch-to-buffer sh-buffer))
    (when new-shell-p
      ;; new shell (I hope!)
      (add-to-list 'dp-shells-shell-buffer-list sh-buffer)
      (dmessage "Loading shell input ring")
      (comint-read-input-ring))))


;; This was mostly copied from shell-snarf-envar
;; Which says:
;; This was mostly copied from shell-resync-dirs.
;;
(defun dp-shells-setenv (var val)
  "Return as a string the shell's value of environment variable VAR."
  (interactive "svar? \nsval? ")
  (let* ((cmd (format "%s=%s; export %s\n" var val var))
	 (proc (get-buffer-process (current-buffer)))
	 (pmark (process-mark proc)))
    (goto-char pmark)
    (insert cmd)
    (sit-for 0)				; force redisplay
    (comint-send-string proc cmd)
    (set-marker pmark (point))
    (let ((pt (point)))			; wait for 1 line
      ;; This extra newline prevents the user's pending input from spoofing us.
      (insert "\n") (backward-char 1)
      (while (not (looking-at ".+\n"))
	(accept-process-output proc)
	(goto-char pt)))
    (goto-char pmark) (delete-char 1)	; remove the extra newline
    (buffer-substring (match-beginning 0) (1- (match-end 0)))))


(let ((sh-name "*shell*<2>"))
  (loop for sh-name in '("*shell*" "shell*<2>" "badddd<222\n>"
                         "shell3" "shell*<4>." "shell*<5>>")
    do (princf "sh-name: %s, " sh-name)
    (if (posix-string-match "\\(<[^>\n]*>\\)$"
                            sh-name)
        (princf "match: %s\n" (match-string 1 sh-name))
      (princf "nope\n"))))
sh-name: *shell*, nope
sh-name: shell*<2>, match: <2>
sh-name: badddd<222
>, nope
sh-name: shell3, nope
sh-name: shell*<4>., nope
sh-name: shell*<5>>, nope
nil

sh-name: *shell*, nope
sh-name: shell*<2>, match: <2>
sh-name: badddd<222
>, match: <222
>
sh-name: shell3, nope
sh-name: shell*<4>., nope
sh-name: shell*<5>>, nope
nil

sh-name: *shell*, nope
sh-name: shell*<2>, match: <2>
sh-name: shell3, nope
sh-name: shell*<4>., nope
sh-name: shell*<5>>, nope
nil

sh-name: *shell*, nope
sh-name: shell3, nope
sh-name: shell*<4>., nope
sh-name: shell*<5>>, nope
nil

sh-name: *shell*, nope
sh-name: shell3, nope
sh-name: shell*<4>., nope
sh-name: shell*<5>>, match: <5>>
nil



nil


"<2>"

"<2>"


"nope"

nil

nil

nil

(posix-string-match "*shell*" "\\(<.*>\\)$")


(let (sh-name)
  (loop for sh-name in '("*shell*" "shell*<2>" "badddd<222\n>"
                         "shell3" "shell*<4>." "shell*<5>>")
    do (princf "sh-name: %s, " sh-name)
    (princf "match: %s\n" (dp-shells-guess-suffix sh-name "sorry!"))))
sh-name: *shell*, match: sorry!
sh-name: shell*<2>, match: <2>
sh-name: badddd<222
>, match: sorry!
sh-name: shell3, match: sorry!
sh-name: shell*<4>., match: sorry!
sh-name: shell*<5>>, match: sorry!
nil

sh-name: *shell*, match: nil
sh-name: shell*<2>, match: <2>
sh-name: badddd<222
>, match: nil
sh-name: shell3, match: nil
sh-name: shell*<4>., match: nil
sh-name: shell*<5>>, match: nil
nil


sh-name: *shell*, match: nil
sh-name: shell*<2>, match: <2>
sh-name: badddd<222
>, match: nil
sh-name: shell3, match: nil
sh-name: shell*<4>., match: nil
sh-name: shell*<5>>, match: nil
nil

(defun dp-shells-set-envar (a b)
  (dmessage "who disturbs me?"))
dp-shells-set-envar

dp-shells-set-envar

(defun tramp-wait-for-regexp (proc timeout regexp)
  "Wait for a REGEXP to appear from process PROC within TIMEOUT seconds.
Expects the output of PROC to be sent to the current buffer.  Returns
the string that matched, or nil.  Waits indefinitely if TIMEOUT is
nil."
  (let ((found nil)
        (start-time (current-time)))
    (cond (timeout
           ;; Work around a bug in XEmacs 21, where the timeout
           ;; expires faster than it should.  This degenerates
           ;; to polling for buggy XEmacsen, but oh, well.
           (while (and (not found)
                       (< (tramp-time-diff (current-time) start-time)
                          timeout))
             (with-timeout (timeout)
               (while (not found)
                 (accept-process-output proc 1)
		 (unless (memq (process-status proc) '(run open))
		   (error "Process has died"))
                 (goto-char (point-min))
                 (setq found (when (re-search-forward regexp nil t)
                               (tramp-match-string-list)))))))
          (t
           (while (not found)
             (accept-process-output proc 1)
	     (unless (memq (process-status proc) '(run open))
	       (error "Process has died"))
             (goto-char (point-min))
             (setq found (when (re-search-forward regexp nil t)
                           (tramp-match-string-list))))))
    (when tramp-debug-buffer
      (append-to-buffer
       (tramp-get-debug-buffer tramp-current-multi-method tramp-current-method
                             tramp-current-user tramp-current-host)
       (point-min) (point-max))
      (when (not found)
        (save-excursion
          (set-buffer
           (tramp-get-debug-buffer tramp-current-multi-method tramp-current-method
                             tramp-current-user tramp-current-host))
          (goto-char (point-max))
          (insert "[[Regexp `" regexp "' not found"
                  (if timeout (format " in %d secs" timeout) "")
                  "]]"))))
    found))

(defun test-command (cmd)
  (interactive "scmd? ")
  (let* ((cmd (format "%s\n" cmd))
         (proc (get-buffer-process (current-buffer)))
	 (pmark (process-mark proc)))
    (goto-char pmark)
    (insert cmd)
    (sit-for 0)				; force redisplay
    (comint-send-string proc cmd)
    (set-marker pmark (point))
    (let ((pt (point)))			; wait for 1 line
      ;; This extra newline prevents the user's pending input from spoofing us.
      (insert "\n") (backward-char 1)
      (while (not (re-search-forward "^[0-9]+> " nil 'NOERROR))
	(accept-process-output proc)
	(goto-char pt)))
    (goto-char pmark) 
    (delete-char 1)
    (insert "booya!")))
test-command

test-command


    (dmessage "fwfr>%s<" (tramp-wait-for-regexp proc 5 "^[0-9]+> "))
    (goto-char (point-max))
    (comint-send-string proc "\n")))
test-command

test-command

(defun test-command2 (cmd)
  "Return as a string the shell's value of environment variable VAR."
  (let* ((cmd (format "%s\n" cmd))
         (proc (get-buffer-process (current-buffer)))
	 (pmark (process-mark proc)))
    (goto-char pmark)
    (insert cmd)
    (sit-for 0)				; force redisplay
    (comint-send-string proc cmd)
    (set-marker pmark (point))
    (let ((pt (point)))			; wait for 1 line
      ;; This extra newline prevents the user's pending input from spoofing us.
      (insert "\n") (backward-char 1)
      (while (not (looking-at ".+\n"))
	(accept-process-output proc)
	(goto-char pt)))
    (goto-char pmark) (delete-char 1)	; remove the extra newline
    (buffer-substring (match-beginning 0) (1- (match-end 0)))))

========================
Wednesday May 02 2007
--

(dp-go-back-ring-init)
(0 0 . [nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil])








(0 0 . [nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil])

<<<<start

<<<<end
(cl-pp dp-go-back-ring)

(56 2
    .
    [nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil (#<marker at 172652 in elisp-devel.el 0x97d125c> "dp-end-of-buffer" "elisp-devel.el") (#<marker at 168412 in elisp-devel.el 0x97d15bc> "dp-beginning-of-buffer" "elisp-devel.el") nil nil nil nil nil nil])nil



(0 2
   .
   [(#<marker at 168401 in elisp-devel.el 0x992c9d4> "dp-end-of-buffer" "elisp-devel.el") (#<marker at 172196 in elisp-devel.el 0x98c0a9c> "dp-beginning-of-buffer" "elisp-devel.el") nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil])nil



(63 2
    .
    [(#<marker at 168400 in elisp-devel.el 0x9a045ec> "dp-end-of-buffer" "elisp-devel.el") nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil (#<marker at 347 in elisp-devel.el 0x9d4295c> "dp-beginning-of-buffer" "elisp-devel.el")])nil



(0 2
   .
   [(#<marker at 168400 in elisp-devel.el 0x9a045ec> "dp-end-of-buffer" "elisp-devel.el") (#<marker at 171299 in elisp-devel.el 0x981f1fc> "dp-beginning-of-buffer" "elisp-devel.el") nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil])nil




========================
2007-05-02T13:29:30
--

(defun dp-push-go-back (&optional reason marker)
  "Push (or marker (point-marker)) onto the go-back-stack."
  (interactive)
  (if (not reason)
      (setq reason "unspecified"))
  (setq marker
        (if (not marker)
            (point-marker)
          (if (markerp marker)
              marker
            (dp-mk-marker marker))))
  (if (marker-buffer marker)
      (if (equal (marker-position marker)
                 (dp-gb-top-pos))
          (dmessage "Not pushing duplicate go-back marker.")
      (let ((buf-name (buffer-name (marker-buffer marker))))
        (if (or (string-match dp-go-back-allow-regexp buf-name)
                (not (and dp-go-back-inhibit-regexp
                     (string-match dp-go-back-inhibit-regexp buf-name))))
            ;;(dmessage "dp-push-go-back")
            ;;(ding)
            (ring-insert dp-go-back-ring (dp-mk-gbi reason marker)))))
    (message "Not pushing because (marker-buffer) is nil.")))


(defun dp-pop-go-back (&optional go-fwd-p)
  "Pop the top of `dp-go-back-ring' and go there."
  (interactive "P")
  (if (ring-empty-p dp-go-back-ring)
      (message "Go back ring is empty.")
    (if go-fwd-p
        (call-interactively 'dp-go-fwd)
      (let* ((gbi (ring-ref dp-go-back-ring 0)) ; get most recent item
             (marker (dp-gbi-marker gbi))
             (buffer (marker-buffer marker))
             (do-it t)
             (pop-it t))
        (if (not buffer)
            ;; pop-it is already true
            (message "Discarding marker into nil buffer which held %s."
                     (dp-gbi-buffer-name gbi))
          ;; dest buffer still exists
          (when (and dp-go-back-confirm-file-change
                     (not (equal buffer (current-buffer))))
            (ding)
            (setq do-it (y-or-n-p (format "Leave buffer for `%s'? " 
                                          (buffer-name buffer)))))
          (if do-it
              (progn
                ;; save where we were at end of ring
                ;; 1. toss-oldest
                (ring-remove dp-go-back-ring 0)
                ;; 2. save pos as oldest
                (ring-insert-at-beginning dp-go-back-ring 
                                          (dp-mk-gbi (dp-gbi-reason gbi)))
                (setq pop-it nil)
                ;;;(switch-to-buffer buffer)
                (dp-goto-marker marker)
                (message "back from %s" (dp-gbi-reason gbi))
                (set-marker marker nil))	; hasten GC of marker
            (setq pop-it (y-or-n-p "Discard marker?"))))
        (if pop-it
            (ring-remove dp-go-back-ring 0)))))) ; pop newest

(defun dp-go-fwd ()
  (interactive)
  (let ((t-point (dp-gbi-marker (ring-remove dp-go-back-ring))))
    (ring-insert dp-go-back-ring (dp-mk-gbi "*dp-go-fwd"))
    (goto-char t-point)))

========================
Thursday May 03 2007
--

+++ remove unprintable values from a (history) list.
(setq nch
(nreverse (delq nil (mapcar (lambda (s)
                              (condition-case nil
                                  (progn
                                    (princf "s: %s\n" s)
                                    s)
                                (error
                                 (princf "!!!\n")
                                 nil)))
                              command-history))))
========================
2007-05-03T18:18:36
--

(defun dp-sshify-name (name)
  "Convert a host name into a buffer name."
  (concat "*ssh-" name "*"))

(defun dp-ssh (&optional shell-id)
  "Find/create a shell buf, an existing ssh buf or create a ssh buf."
  (interactive "P")
  (if (and nil (not shell-id))
      (call-interactively 'ssh)
    (let* ((do-ssh-p (and (stringp shell-id) shell-id))
           (host-name (or do-ssh-p
                          (funcall dp-shells-make-ssh-host-name-fp shell-id)))
           (shell-id (or shell-id ""))  ; ?? needed any more?
           (do-shell (and host-name (string= host-name (dp-short-hostname))))
           ssh-buf-name
           ssh-buf-regexp
           isa-shell-buf-p
           buf)
      (if do-shell
          (dp-shell)
        (unless do-ssh-p
          ;; look for a buffer corresponding to the host-name.
          ;; 1st, exact match
          (setq ssh-buf-name (dp-shells-make-ssh-buf-name host-name shell-id)
                ;; possible matches
                ssh-buf-regexp (format "%s\\(<[0-9]+\\)?$" ssh-buf-name))
          ;;!<@todo try without <> first?
          ;; See if a specific ssh buffer exists.
          (setq buf (or (get-buffer ssh-buf-name)
                        (dp-re-find-buffer 
                         (if (functionp 'dp-shells-ssh-buf-name-fmt)
                             (apply dp-shells-ssh-buf-name-fmt shell-id)
                           ssh-buf-regexp))
                        ;; the see if there's a shell buf with the same id.
                        (dp-re-find-buffer 
                         (dp-funcall-if 'dp-ssh-shell-buf-name-fmt
                             shell-id
                           (format "\\*shell\\*<%s>" shell-id))))))
        (setq isa-shell-buf-p (and buf (buffer-local-value 
                                        'dp-shell-isa-shell-buf-p buf)))
        (when (and isa-shell-buf-p 
                   (not (eq 'ssh isa-shell-buf-p)))
          (ding)
          (unless (y-or-n-p (format "Non-ssh buffer [%s], go there? " 
                                    (buffer-name buf)))
            (setq shell-id nil   ; This will make `ssh' prompt for host name.
                  buf nil
                  do-ssh-p nil)))
        (if buf
            (dp-visit-or-switch-to-buffer buf)
          ;; We can use the completion list as a DNS!
          (unless do-ssh-p
            (setq shell-id (completing-read
                            "dp-ssh arguments (host-name first): "
                            dp-ssh-host-name-completion-list
                            nil nil host-name 'ssh-history)))
          (setq ssh-buf-name shell-id
                shell-id
                (let* ((el (assoc shell-id dp-ssh-host-name-completion-list))
                       (cdr (if el
                                (cdr el)
                              'not-found)))
                  (if (symbolp cdr)
                      shell-id
                    cdr)))
          (if (setq buf (get-buffer (dp-sshify-name ssh-buf-name)))
              (dp-visit-or-switch-to-buffer buf)
            (ssh shell-id)
            (when (not (string= shell-id ssh-buf-name))
              (setq ssh-buf-name (concat "*ssh-" ssh-buf-name "*"))
              (rename-buffer ssh-buf-name 'UNIQUE)
              (when (not (string= (buffer-name) ssh-buf-name))
                (ding)
                (dmessage "Name wasn't unique.  Name is: %s" (buffer-name))))
            (dp-shells-clear-n-setenv "PS1_prefix" "-SSH-")
            (dp-shells-clear-n-setenv 
             "PS1_host_suffix"
             (format "'%s'" (dp-shells-guess-suffix (buffer-name) "")))
            (setq dp-shell-isa-shell-buf-p 'ssh)
            (setq comint-input-ring-file-name 
                  (concat "/home/davep/.bash_history." ssh-host))
            (when (file-exists-p comint-input-ring-file-name)
              (comint-read-input-ring))))
        (setq dp-shells-most-recent-shell (cons (current-buffer) 'ssh))))))

========================
Friday May 04 2007
--

(progv '(x y) '(a  b) 
  (princf "x: %s, y: %s\n" x y))
x: a, y: b
"x: a, y: b
"


(append '(1 2) 'a)
(1 2 . a)

(setq x1 'aaa)
aaa

(nconc '(1 2) 'x1)
(1 2 . x1)

(1 . x1)


(list '(1 . 2) 'a)
((1 . 2) a)


(1 . a)


(cl-px '(progv '(buf-win frame orig-frame) 
         (append (get-buffer-window buffer t) 
                 (list (window-frame (get-buffer-window (current-buffer)))))
         (when buf-win
           (select-frame (window-frame buf-win))
           (select-window buf-win)
           (unless (equal orig-frame frame)
             (raise-frame frame)))
         buffer))

(let ((cl-progv-save nil))
  (unwind-protect
      (progn
        (cl-progv-before '(buf-win frame orig-frame)
                         (append (get-buffer-window buffer t)
                                 (list (window-frame (get-buffer-window (current-buffer))))))
        (if buf-win
            (progn
              (select-frame (window-frame buf-win))
              (select-window buf-win)
              (if (equal orig-frame frame) nil (raise-frame frame))))
        buffer)
    (cl-progv-after)))nil



`(,@(list 1 2) ,@(list 'a 'b))
(1 2 a b)



(1 2 @\,a)


; (defun dp-buffer-visible-p (buffer &optional which-frames which-devices)
;   "Return the list \(window frame\) in which BUFFER is visible, else nil.
; Optionals are as per `get-buffer-window'. "
;   (if (dp-buffer-live-p buffer)
;       (let ((buf-win (get-buffer-window buffer which-frames which-devices))
;             (orig-frame (window-frame (get-buffer-window (current-buffer)))))
;         (when buf-win
;           (list buf-win (window-frame buf-win))))))

; (defun dp-display-buffer-if-visible (buffer)
;   "If BUFFER is in a visible window, then select it's window and frame.
; The frame is raised if needed.
; Returns BUFFER if it was visible."
;   (interactive "Bbuffer name? ")
;   (if (dp-buffer-live-p buffer)
;       (progv '(buf-win frame orig-frame) 
;           (append (dp-buffer-visible-p buffer t) 
;                   (list (window-frame (get-buffer-window (current-buffer)))))
;         (when buf-win
;           (select-frame (window-frame buf-win))
;           (select-window buf-win)
;           (unless (equal orig-frame frame)
;             (raise-frame frame)))
;         buffer)
;     nil))

====
(defun dp-buffer-visible-p (buffer &optional which-frames which-devices)
  "Return the list \(window frame\) in which BUFFER is visible, else nil.
Optionals are as per `get-buffer-window'. "
  (if (dp-buffer-live-p buffer)
      (let ((buf-win (get-buffer-window buffer which-frames which-devices))
            (orig-frame (window-frame (get-buffer-window (current-buffer)))))
        (if buf-win
            (list buf-win (window-frame buf-win))
          (list nil nil)))
    (list nil nil)))

(defun dp-display-buffer-if-visible (buffer)
  "If BUFFER is in a visible window, then select it's window and frame.
The frame is raised if needed.
Returns BUFFER if it was visible."
  (interactive "Bbuffer name? ")
  (if (dp-buffer-live-p buffer)
      (progv '(buf-win frame orig-frame) 
          (append (dp-buffer-visible-p buffer t) 
                  (list (window-frame (get-buffer-window (current-buffer)))))
        (when buf-win
          (select-frame (window-frame buf-win))
          (select-window buf-win)
          (unless (equal orig-frame frame)
            (raise-frame frame)))
        buffer)
    nil))

(other-window 99)
nil

nil

nil

nil

if any other window visible, go there
else 

(count-windows nil)
2

1

2

(defun savehist-save ()
  "Save the histories from `savehist-history-variables' to `savehist-file'.
A variable will be saved if it is bound and non-nil."
  (interactive)
  (save-excursion
    ;; Is it wise to junk `find-file-hooks' just like that?  How else
    ;; should I avoid font-lock et al.?
    (let ((find-file-hooks nil)
	  (buffer-exists-p (get-file-buffer savehist-file)))
      (set-buffer (find-file-noselect savehist-file))
      (unwind-protect
	  (progn
	    (erase-buffer)
	    (insert
	     ";; -*- emacs-lisp -*-\n"
	     ";; Minibuffer history file.\n\n"
	     ";; This file is automatically generated by `savehist-save'"
	     " or when\n"
	     ";; exiting Emacs.\n"
	     ";; Do not edit.  Unless you really want to, that is.\n\n")
	    (let ((print-length nil)
		  (print-string-length nil)
		  (print-level nil)
		  (print-readably t))
	      (dolist (sym savehist-history-variables)
		(when (and (boundp sym)
			   (symbol-value sym))
		  (prin1
		   `(setq ,sym (quote ,(savehist-delimit (symbol-value sym)
							 savehist-length)))
		   (current-buffer))
		  (insert ?\n))))
	    (save-buffer)
	    (set-file-modes savehist-file savehist-modes))
	(or buffer-exists-p
	    (kill-buffer (current-buffer)))))))


(savehist-save)
nil



========================
Monday May 14 2007
--
(symbol-plist 'when-and-boundp)
(lisp-indent-function 1 lisp-indent-hook 1 edebug #<marker at 8431 in dpmisc.el 0x93a523c>)


(cddr '(1 2 3 4 5 6 7))
(3 4 5 6 7)
(cdr (cdr '(1 2 3 4 5 6 7)))
(3 4 5 6 7)

(edebug-form-spec (&rest form) lisp-indent-hook 1 lisp-indent-function 1)

(when blah
  )

(let ((z 'y))
  (when-and-boundp 'z
    (princf "z is bound and determined\n")))
z is bound and determined
"z is bound and determined
"


z is bound and determined
"z is bound and determined
"




(defun dp-put-pv-list (var-sym pv-list)
  (loop for (p v) in pv-list
    do (put var-sym p v)))
dp-put-pv-list

(setq x 1)
1
x
1

(dp-put-pv-list 'x '((p1 p1-v) (p2 p2-v)))
nil
(symbol-plist 'x)
(p2 p2-v p1 p1-v custom-loads ("x-faces") group-documentation "The X Window system." custom-group ((x-allow-sendevents custom-variable) (focus-follows-mouse custom-variable) (try-oblique-before-italic-fonts custom-variable)))


(cl-px '(if-and-boundp 'z
         nil
         (princf "z is bound and determined\n")
         'booya!))

(if (progn nil (and (boundp 'z) (symbol-value 'z))) nil (princf "z is bound and determined
") 'booya!)nil



(if (progn 
      nil 
      (and (boundp 'z) (symbol-value 'z)))
    (progn 
      (princf "z is bound and determined") 
      'booya!))

'nil
nil




(let ((z nil))
  (unless-and-boundp 'z
    (princf "z is bound and determined\n")
    'booya!))
z is bound and determined
booya!

nil

z is bound and determined
booya!

nil


nil

z is bound and determined
booya!

z is bound and determined
booya!

nil

nil

z is bound and determined
booya!
  
  
z is bound and determined
booya!


nil










(if (and (boundp 'z) 'z) (princf "z is bound and determined
"))

(cl-px '(when x 'yayayaya 'booya))

(if x (progn 'yayayaya 'booya))nil

(let ((z 'z))
  (if-and-boundp 'z 'whoops))
whoops
if-
nil


(if x 'yayayaya)nil


(symbol-function 'when)
(macro . #<subr when>)
(symbol-function 'when-and-boundp)
(macro lambda (var &rest body) "When version of `if-and-boundp'." (backquote (when (and (boundp (\, var)) (symbol-value (\, var))) (\,@ body))))




========================
2007-05-14T19:16:22
--

!! When we get into the screwed up isearch-mode mode.
   this is one of many things that happens.
Debugger entered--Lisp error: (args-out-of-range #<buffer " *Minibuf-1"> 1 2705)
  map-extents(#<compiled-function (extent ignored) "...(32)" [search-invisible end start to-be-unhidden extent extent-start-position extent-end-position open isearch-open-invisible nil t] 2> nil 1 2705 nil all-extents-closed invisible)
  isearch-range-invisible(1 2705)
  isearch-pop-state()
  #<compiled-function nil "...(17)" [isearch-cmds ding nil isearch-quit isearch-pop-state isearch-update] 3 1155186 nil>()
  call-interactively(isearch-delete-char)
  read-minibuffer-internal("dp:Switch-to-buf: (default *Completions*) ")
  byte-code("..." [standard-output standard-input prompt recursion-depth minibuffer-depth t read-minibuffer-internal] 2)
  ad-Orig-read-from-minibuffer("dp:Switch-to-buf: (default *Completions*) " nil #<keymap minibuffer-local-completion-map size 8 0x1e994> nil buffer-history nil "*Completions*")
  (setq ad-return-value (ad-Orig-read-from-minibuffer prompt initial-contents keymap readp history abbrev-table default))
  (let (ad-return-value) (when (and dp-use-region-as-INITIAL-CONTENTS ... ... ...) (setq initial-contents ...)) (setq ad-return-value (ad-Orig-read-from-minibuffer prompt initial-contents keymap readp history abbrev-table default)) ad-return-value)
  read-from-minibuffer("dp:Switch-to-buf: (default *Completions*) " nil #<keymap minibuffer-local-completion-map size 8 0x1e994> nil buffer-history nil "*Completions*")
  completing-read("dp:Switch-to-buf: (default *Completions*) " (("*scratch*" . #<buffer "*scratch*">) (" *Minibuf-1" . #<buffer " *Minibuf-1">) ("*Completions*" . #<buffer "*Completions*">) ("dpmisc.el" . #<buffer "dpmisc.el">) ("*Help: Debugger mode*" . #<buffer "*Help: Debugger mode*">) (" *Minibuf-0*" . #<buffer " *Minibuf-0*">) ("elisp-devel.el" . #<buffer "elisp-devel.el">) ("*Help: function `isearch-forward'*" . #<buffer "*Help: function `isearch-forward'*">) ("dp-dot-emacs.ll-spiral.el" . #<buffer "dp-dot-emacs.ll-spiral.el">) ("dpmacs.el" . #<buffer "dpmacs.el">) ("dp-shells.el" . #<buffer "dp-shells.el">) ("dp-hooks.el" . #<buffer "dp-hooks.el">) ("dp-common-abbrevs.el" . #<buffer "dp-common-abbrevs.el">) ("dp-abbrev-defs.el" . #<buffer "dp-abbrev-defs.el">) ("*Help: variable `abbrev-mode'*" . #<buffer "*Help: variable `abbrev-mode'*">) ("*Help: variable `global-abbrev-table'*" . #<buffer "*Help: variable `global-abbrev-table'*">) ("*Help: variable `dp-common-abbrevs'*" . #<buffer "*Help: variable `dp-common-abbrevs'*">) ("dp-keys.el" . #<buffer "dp-keys.el">) ("dp-journal.el" . #<buffer "dp-journal.el">) ("*Help: function `insert-abbrev-table-description'*" . #<buffer "*Help: function `insert-abbrev-table-description'*">) ("*Hyper Help*" . #<buffer "*Hyper Help*">) ("daily-2007-05.jxt" . #<buffer "daily-2007-05.jxt">) ("Man: send(2)" . #<buffer "Man: send(2)">) ("Man: tcp" . #<buffer "Man: tcp">) ("Man apropos: send(-k)" . #<buffer "Man apropos: send(-k)">) ("Man: sendfile(2)" . #<buffer "Man: sendfile(2)">) ("*Python*" . #<buffer "*Python*">) ("*shell*" . #<buffer "*shell*">) ("calc.el" . #<buffer "calc.el">) ("*Calendar*" . #<buffer "*Calendar*">) ("*igrep*" . #<buffer "*igrep*">) ("phonebook.py" . #<buffer "phonebook.py">) ("*Warnings*" . #<buffer "*Warnings*">) (" *Echo Area*" . #<buffer " *Echo Area*">) (" *Message-Log*" . #<buffer " *Message-Log*">) (" *pixmap conversion*" . #<buffer " *pixmap conversion*">) (" *substitute*" . #<buffer " *substitute*">) ("*journal-topics*" . #<buffer "*journal-topics*">) ("diary" . #<buffer "diary">) (" *Info-tmp*" . #<buffer " *Info-tmp*">) (" *info tag table*" . #<buffer " *info tag table*">) ("info.notes" . #<buffer "info.notes">) ("*IPython Indentation Calculation*" . #<buffer "*IPython Indentation Calculation*">) ("*Calculator*" . #<buffer "*Calculator*">) ("*Calc Trail*" . #<buffer "*Calc Trail*">) (" *Custom-Work*" . #<buffer " *Custom-Work*">) ("lisp" . #<buffer "lisp">) ("*Buffer List*" . #<buffer "*Buffer List*">) ("*Hyper Apropos*" . #<buffer "*Hyper Apropos*">) ("*info*" . #<buffer "*info*">)) nil nil nil buffer-history "*Completions*")
  read-buffer("dp:Switch-to-buf: " #<buffer "*Completions*">)
  call-interactively(dp-switch-to-buffer)

========================
2007-05-14T19:50:06
--

(defun dp-default-redefine-abbrev-table-pred (el)
  ;; old style: ("abbrv" "expansion"): Goes in 'common for explicit expansion.
  ;; new: (("abbrv" "expansion") table-names...)
  (if (or (and (not (cadr el))          ; old style
               (eq table-selector 'common)) ;Ick. table-selector is in caller.
          (memq table-selector (cdr el)))
      (car el)))

(defun dp-redefine-abbrev-table (table-name a-dp-abbrev-list table-selector
                                 &optional pred)
  (setq-ifnil pred 'dp-default-redefine-abbrev-table-pred)
;   (if (progn
;         nil
;         (and (boundp table-name) (symbol-value table-name)))
;       (if (arrayp (symbol-value table-name))
;           (clear-abbrev-table (symbol-value table-name))))
  (when-and-boundp table-name
    (when (arrayp (symbol-value table-name))
      (clear-abbrev-table (symbol-value table-name))))
  
  (let ((l (delq nil (mapcar pred dp-common-abbrevs))))
    (define-abbrev-table table-name l)))

(defun dp-aliases-new (&optional show-make-output no-make-p)
  "Load aliases and abbreviation files listed in `dp-alias-files'."
  (interactive "P")
  (save-some-buffers)
  (unless no-make-p
    (message "make'ing...")
    (apply (if show-make-output 
               'shell-command 
             'shell-command-to-string)
           '("cd $HOME; make go.emacs"))
        (message "make'ing... done."))
  ;;
  ;; since it is a defvar...
  ;; need it be one?
  ;; if defined in custom.el, then this function won't work anyway.
  ;; @todo do this with a hook
  (makunbound 'dp-common-abbrevs)
  
  (mapcar (function
	   (lambda (file)
	     (if (file-readable-p file)
		 (load file))))
	  dp-alias-files)
  (let ((f "~/lisp/dp-common-abbrevs.el"))
    (when (file-readable-p f)
      (load f)
      (when-and-boundp 'dp-common-abbrevs
        (dp-redefine-abbrev-table 'global-abbrev-table dp-common-abbrevs 
                                  'global)
        (dp-redefine-abbrev-table 'dp-common-abbrev-table dp-common-abbrevs 
                                  'common))))
  (when (file-readable-p "~/.abbrev_defs")
    (read-abbrev-file "~/.abbrev_defs")
    (setq save-abbrevs nil))
  (dp-aliases-refresh-buffers dp-go-abbrev-table))


(dp-aliases-new nil t)

dp-common-abbrev-table
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

global-abbrev-table
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]



========================
Thursday May 17 2007
--

(defvar dp-tag-stack '())

(defun dp-push-tag ()
  "Push file location, then goto tag."
  (interactive)
  (let ((from-mark (dp-mk-marker))
        (push-p (buffer-file-name)))
    (call-interactively 'find-tag)
    ;; push address *after* find tag since it seems to throw
    ;; an exception rather than return an error if the tag
    ;; isn't found
    ;; only push marker if the file part is OK. temp buffers don't
    ;; have associated file names.  I'll need to work this out later.
    (when push-p
      (dp-trace-tags (car find-tag-history) from-mark
                     (length tag-mark-stack1)))))


(make-string 0 ?.)
""

"....."


(line-number dp-mkr)
3


(defun dp-simple-marker-str (&optional marker)
  (setq-ifnil marker (dp-mk-marker))
  (let ((s (format "%s" marker)))
    (save-match-data
      (if (string-match "#<marker at \\([0-9]+\\) in \\(.*?\\) 0x[a-f0-9]*>" s)
          (format "%s:%s/%s/" (match-string 2 s) (line-number marker)
                  (match-string 1 s))
        "?:?"))))

(dp-simple-marker-str dp-mkr)
"*Hyper Apropos*:3/33/"



"elisp-devel.el:192533"

(defun dp-trace-tags (to-tag from-marker depth &optional indent)
  (let ((buf (get-buffer-create "*dp-tag-trace*")))
    (with-current-buffer buf
      (goto-char (point-max))
      (when (= 1 depth)
        (insert "\n" (make-string 77 ?=) "\n"))
      (insert (make-string (* (or indent 1) depth) ?.) to-tag 
              (format " [from %s]\n" (dp-simple-marker-str from-marker))))))

(dp-mk-marker)
#<marker at 192563 in elisp-devel.el 0x9352d14>

(setq find-tag-history nil)
nil

("main" "panic" "EarlyBird_t" "create_host_suffixed_filename" "open_host_suffixed_file" "DEBUG_ALLOCATOR_BP" "expect_chained_p" "building_cmd_chain_type_p" "get_raw_commandline" "until_seq_p" "undefer" "Cmd_chain_t" "deprecated" "complete_p" "cmd_chain_complete_p" "lopt_link_command" "recv_p" "Cmd_base_t" "Tmsg_base_t" "close_cmd_chain" "close_chain" "lopt_link_last_command" "DEFINE_FACTORY_OBJECT" "CTOR_TEMPLATE_coi" "CTOR_TEMPLATE_F_AND_COI" "building_chain_type_p" "building_cmd_chain_p" "open_and_sane_p" "set_link_option_present" "deque" "set_next_cmdp" "next_cmdp" "CTOR_TEMPLATE_obj" "CTOR_TEMPLATE_F_AND_O" "open_cmd_chain" "New_cmd_chain" "Get_cmd_chain" "add_to_linked_chain" "handle_sync_recv_flag" "sequence_complete_p" "get_first_chain_cmd" "CC_ASSERT_OPEN" "add_to_linked_sequence" "LL_ASSERT" "set_sequence_complete" "ll_printf" "dprintf" "read_bracketed_lines" "RSVP_message_t" "shut_down" "disable" "Hierarchy_obj_t" "build_hierarchy" "build_objects" "build" "emit" "message" "Trace_file_t" "trace_file" "Recognizer_base_t" "dump_a_seq" "Cmd_sequences" "queue_cmd_sequence" "dump_link_info" "dump_cop_chain" "show_commands" "dump_tables" "check_seqs" "waiting_for_this_message_p" "Ungettable_File" "RSVP_OBJECT_METHODS" "FLOWSPEC_Object" "FlowDescriptor" "RefObject" "FILTER_SPEC_Object" "TSpec" "FlowDescriptorList" "SENDER_Object" "SESSION_Object" "get_sender_addr" "sender_addrs_eq" "sender_tspecs_eq" "SESSION_Object::key_eq" "session_eq" "key_eq" "Msg_key_t::operator ==" "FLOWSPEC_Object::key_eq" "RSpec::key_eq" "flow_descriptors_eq" "Msg_key_t::policies_eq" "PPPE" "POLICY_DATA_Object" "policies_eq" "Message" "get_message" "next_frame" "read_frame_lines" "Frame_t" "Ungettable_StringIO" "Sleep_cmd_t" "ios_base::Init")


========================
Friday May 18 2007
--

(loop for x in '(a b c)
  do (princf "x: %s\n" x))
x: a
x: b
x: c
nil

(cadr '(1 2 3))
2

(assert (valid-plist-p '(z 2 )))
nil

nil


nil


(defun dp-redefine-abbrevs (dp-style-abbrev);; dp-reinitialized-abbrev-table-alist)
  (let ((abbrev (car dp-style-abbrev))
        (table-names (cdr dp-style-abbrev))
        full-table-name-str
        full-table-name table)
    (loop for table-name in table-names do
      (progn
        (setq full-table-name-str (if (and (listp table-name)
                                           (not (assert 
                                                 (valid-plist-p table-name))))
                                      (format "%s" 
                                              (plist-get table-name 'table-name))
                                    (format "%s-abbrev-table" table-name))
              full-table-name (intern-soft full-table-name-str))
        (unless-and-boundp full-table-name
          ;; New table... create an empty one.
          (setq full-table-name (intern full-table-name-str))
          (define-abbrev-table full-table-name '()))
        (setq table (symbol-value full-table-name))
        ;; Have we cleared it this time around?
        ;; This alist must be empty before this whole process begins.
        (unless (assoc full-table-name dp-reinitialized-abbrev-table-alist)
          (clear-abbrev-table table)
          (dp-add-to-alist 'dp-reinitialized-abbrev-table-alist 
                           (cons full-table-name t)))
        (define-abbrev table (car abbrev) (cadr abbrev))))))

(defun dp-redefine-abbrev-tables (a-dp-style-abbrev-list)
  (let ((dp-reinitialized-abbrev-table-alist '()))  ; "Parameter"
    (mapc 'dp-redefine-abbrevs a-dp-style-abbrev-list)))
          dp-reinitialized-abbrev-table-alist)))

(dp-redefine-abbrev-tables '(
;                             (("abbrev" "expansion") dummy-1 dummy-2)
;                             (("abbrev1" "expansion1") dummy-1)
;                             (("abbrev2" "expansion2") dummy-2)
                             (("abbrevJ" "expansionJ") (table-name table-j))
                             ))
((("abbrevJ" "expansionJ") (table-name table-j)))

((("abbrev" "expansion") dummy-1 dummy-2) (("abbrev1" "expansion1") dummy-1) (("abbrev2" "expansion2") dummy-2) (("abbrevJ" "expansionJ") (table-name table-j)))

((("abbrev" "expansion") dummy-1 dummy-2) (("abbrev1" "expansion1") dummy-1) (("abbrev2" "expansion2") dummy-2) (("abbrevJ" "expansionJ") (table-name agent-j)))



(loop for tbl in '(dummy-1-abbrev-table dummy-2-abbrev-table agent-j table-j)
  do (insert-abbrev-table-description tbl)
  (princf "-------\n"))
(define-abbrev-table 'dummy-1-abbrev-table '(
    ("abbrev" "expansion" nil 0)
    ("abbrev1" "expansion1" nil 0)
    ))

-------
(define-abbrev-table 'dummy-2-abbrev-table '(
    ("abbrev" "expansion" nil 0)
    ("abbrev2" "expansion2" nil 0)
    ))

-------
(define-abbrev-table 'agent-j '(
    ("abbrevJ" "expansionJ" nil 0)
    ))

-------
(define-abbrev-table 'table-j '(
    ("abbrevJ" "expansionJ" nil 0)
    ))

-------
nil

(define-abbrev-table 'dummy-1-abbrev-table '(
    ("abbrev" "expansion" nil 0)
    ("abbrev1" "expansion1" nil 0)
    ))

-------
(define-abbrev-table 'dummy-2-abbrev-table '(
    ("abbrev" "expansion" nil 0)
    ("abbrev2" "expansion2" nil 0)
    ))

-------
(define-abbrev-table 'agent-j '(
    ("abbrevJ" "expansionJ" nil 0)
    ))

-------
nil


(insert-abbrev-table-description 'dp-common-abbrev-table)
(define-abbrev-table 'dp-common-abbrev-table '(
    ("thru" "through" nil 0)
    ("reciever" "receiver" nil 0)
    ("mobo" "motherboard" nil 0)
    ("tho" "though" nil 0)
    ("gui" "GUI" nil 0)
    ("q" "queue" nil 0)
    ("lartc" "Linux Advanced Routing & Traffic Control HOWTO" nil 0)
    ("stl" "STL" nil 0)
    ("kb" "keyboard" nil 0)
    ("bups" "backups" nil 0)
    ("rxer" "receiver" nil 0)
    ("wheter" "whether" nil 0)
    ("enq" "enqueue" nil 0)
    ("eg" "e.g." nil 0)
    ("deq" "dequeue" nil 0)
    ("kbps" "Kbps" nil 0)
    ("IIR" "if I recall" nil 0)
    ("LARTC" "Linux Advanced Routing & Traffic Control HOWTO" nil 0)
    ("altho" "although" nil 0)
    ("ns" "nS" nil 0)
    ("appts" "appointments" nil 0)
    ("dap" "David A. Panariti" nil 0)
    ("wether" "whether" nil 0)
    ("te" "there exists" nil 0)
    ("bup" "backup" nil 0)
    ("nic" "NIC" nil 0)
    ("khz" "KHz" nil 0)
    ("yopp" "YOPP!" nil 0)
    ("appt" "appointment" nil 0)
    ("fo" "of" nil 0)
    ("pkt" "packet" nil 0)
    ("nb" "N.B." nil 0)
    ("e2ei" "RSVP-E2E-IGNORE" nil 0)
    ("thier" "their" nil 0)
    ("recieve" "receive" nil 0)
    ("ghz" "GHz" nil 0)
    ("thot" "thought" nil 0)
    ("iir" "if I recall" nil 0)
    ("probs" "problems" nil 0)
    ("tcp/ip" "TCP/IP" nil 0)
    ("teh" "the" nil 0)
    ("prob" "problem" nil 0)
    ("ms" "mS" nil 0)
    ("decls" "declarations" nil 0)
    ("decl" "declaration" nil 0)
    ("udp" "UDP" nil 0)
    ("wrt" "with respect to" nil 0)
    ("ok" "OK" nil 0)
    ("Iir" "if I recall" nil 0)
    ("mhz" "MHz" nil 0)
    ("rxor" "receiver" nil 0)
    ("repos" "repository" nil 0)
    ("linux" "Linux" nil 0)
    ("lenght" "length" nil 0)
    ("plz" "please" nil 0)
    ("gbps" "Gbps" nil 0)
    ("sthg" "something" nil 0)
    ))

""



(define-abbrev-table 'dp-common-abbrev-table '(
    ("thru" "through" nil 0)
    ("reciever" "receiver" nil 0)
    ("mobo" "motherboard" nil 0)
    ("tho" "though" nil 0)
    ("gui" "GUI" nil 0)
    ("q" "queue" nil 0)
    ("lartc" "Linux Advanced Routing & Traffic Control HOWTO" nil 0)
    ("stl" "STL" nil 0)
    ("kb" "keyboard" nil 0)
    ("bups" "backups" nil 0)
    ("rxer" "receiver" nil 0)
    ("wheter" "whether" nil 0)
    ("enq" "enqueue" nil 0)
    ("eg" "e.g." nil 0)
    ("deq" "dequeue" nil 0)
    ("kbps" "Kbps" nil 0)
    ("IIR" "if I recall" nil 0)
    ("LARTC" "Linux Advanced Routing & Traffic Control HOWTO" nil 0)
    ("altho" "although" nil 0)
    ("ns" "nS" nil 0)
    ("appts" "appointments" nil 0)
    ("dap" "David A. Panariti" nil 0)
    ("wether" "whether" nil 0)
    ("te" "there exists" nil 0)
    ("bup" "backup" nil 0)
    ("nic" "NIC" nil 0)
    ("khz" "KHz" nil 0)
    ("yopp" "YOPP!" nil 0)
    ("appt" "appointment" nil 0)
    ("fo" "of" nil 0)
    ("pkt" "packet" nil 0)
    ("nb" "N.B." nil 0)
    ("e2ei" "RSVP-E2E-IGNORE" nil 0)
    ("thier" "their" nil 0)
    ("recieve" "receive" nil 0)
    ("ghz" "GHz" nil 0)
    ("thot" "thought" nil 0)
    ("iir" "if I recall" nil 0)
    ("probs" "problems" nil 0)
    ("tcp/ip" "TCP/IP" nil 0)
    ("teh" "the" nil 0)
    ("prob" "problem" nil 0)
    ("ms" "mS" nil 0)
    ("decls" "declarations" nil 0)
    ("decl" "declaration" nil 0)
    ("udp" "UDP" nil 0)
    ("wrt" "with respect to" nil 0)
    ("ok" "OK" nil 0)
    ("Iir" "if I recall" nil 0)
    ("mhz" "MHz" nil 0)
    ("rxor" "receiver" nil 0)
    ("repos" "repository" nil 0)
    ("linux" "Linux" nil 0)
    ("lenght" "length" nil 0)
    ("plz" "please" nil 0)
    ("gbps" "Gbps" nil 0)
    ("sthg" "something" nil 0)
    ))

""

(clear-abbrev-table dp-common-abbrev-table)
nil



========================
Wednesday May 30 2007
--

(loop for x in '(a b c) do
  (when (eq x 'q)
    (return x)))
nil

a

c




========================
Tuesday June 05 2007
--
(defun comint-exec-1 (name buffer command switches)
  (let ((process-environment
	 (nconc
	  ;; If using termcap, we specify `emacs' as the terminal type
	  ;; because that lets us specify a width.
	  ;; If using terminfo, we specify `dumb' because that is
	  ;; a defined terminal type.  `emacs' is not a defined terminal type
	  ;; and there is no way for us to define it here.
	  ;; Some programs that use terminfo get very confused
	  ;; if TERM is not a valid terminal type.
	  (if (and (boundp 'system-uses-terminfo) system-uses-terminfo)
	      (list "TERM=dumb"
		    (format "COLUMNS=%d" (frame-width)))
	    (list "TERM=emacs"
		  (format "TERMCAP=emacs:co#%d:tc=unknown:" (frame-width))))
	  (if (getenv "EMACS") nil (list "EMACS=t"))
	  process-environment))
	(default-directory
	  (if (file-directory-p default-directory)
	      default-directory
	    "/")))
    (apply 'start-process name buffer command switches)))
comint-exec-1

(defun appt-frame-announce (&rest rest))
appt-frame-announce

(defun appt-make-appt

(defun appt-make-appt (&rest rest))
appt-make-appt


(defun dp-clean-savehist-list (list)
  (delq nil (mapcar (function 
                     (lambda (el)
                       
                                ))))
  ())


========================
Monday June 18 2007
--

(defun gdb-this-buffer ()
  "Add `gdb-mode', etc, to this buffer which already has gdb running.
Main idea is to be able to gdb on another host."
  (interactive)
  (kill-all-local-variables)
  (loop for v-sym in '(comint-dynamic-complete-functions 
                       comint-input-filter-functions 
                       comint-output-filter-functions)
    do (set v-sym nil))
  (set-process-filter (get-buffer-process (current-buffer)) 'gdb-filter)
  (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
  ;; XEmacs change: turn on gdb mode after setting up the proc filters
  ;; for the benefit of shell-font.el
  (gdb-mode)
  (gdb-set-buffer))

========================
Tuesday June 19 2007
--

(defun dp-gdb-run-to-here (&optional pos)
  (interactive)
  (save-excursion
    (when pos
      (goto-char pos))
    (gdb-break t)
    (gdb-call "c")))
(define-key c++-mode-map [(control x)(control space)] 'dp-gdb-run-to-here)



========================
Wednesday June 20 2007
--
(defun ssh-gdb (input-args path &optional corefile)
  (interactive "shost? \nFfile? ")
  (let* ((buffer nil)
         (process-connection-type ssh-process-connection-type)
         (args (ssh-parse-words input-args))
	 (host (car args))
	 (user (or (car (cdr (member "-l" args)))
                   (user-login-name)))
         (buffer-name (if (string= user (user-login-name))
                          (format "*ssh+gdb-%s*" host)
                        (format "*ssh+gdb-%s@%s*" user host)))
	 proc)
    
    (and ssh-explicit-args
         (setq args (append ssh-explicit-args args)))
    
    (cond ((null buffer))
	  ((stringp buffer)
	   (setq buffer-name buffer))
          ((bufferp buffer)
           (setq buffer-name (buffer-name buffer)))
          ((numberp buffer)
           (setq buffer-name (format "%s<%d>" buffer-name buffer)))
          (t
           (setq buffer-name (generate-new-buffer-name buffer-name))))
    
    (setq buffer (get-buffer-create buffer-name))
    (set-buffer buffer)
    (pop-to-buffer buffer-name)
    
    (cond
     ((comint-check-proc buffer-name))
     (t
      (comint-exec buffer buffer-name ssh-program nil args)
      (setq proc (get-buffer-process buffer))
      ;; Set process-mark to point-max in case there is text in the
      ;; buffer from a previous exited process.
      (set-marker (process-mark proc) (point-max))))
    
    (setq path (file-truename (expand-file-name path)))
    (let ((file (file-name-nondirectory path)))
    ;;; already done above (switch-to-buffer (concat "*gdb-" file "*"))
      (setq default-directory (file-name-directory path))
      (or (bolp) (newline))
      (insert "Current directory is " default-directory "\n")
      ;; gdb file-name -fullname -cd dir
      (comint-send-string (get-buffer-process (current-buffer))
                          (format "%s %s -fullname -cd %s\n"
                                  gdb-command-name
                                  (substitute-in-file-name path)
                                  default-directory))
      (set-process-filter 
       (get-buffer-process (current-buffer)) 'gdb-filter)
      (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
      ;; XEmacs change: turn on gdb mode after setting up the proc filters
      ;; for the benefit of shell-font.el
      (gdb-mode)
      (gdb-set-buffer))))


========================
Thursday June 21 2007
--
(defun dp-get-remote-name (&key shell-id exclusive-names-p mk-host-name-fun
                           host-name ssh-buf-name ssh-buf-regexp)
  "Find/create a shell buf, an existing ssh buf or create a ssh buf."
  (interactive "P")
  (let* ((do-ssh-p (and (stringp shell-id) shell-id))
         (host-name (or host-name do-ssh-p
                        (funcall (or mk-host-name-fun
                                     dp-shells-make-ssh-host-name-fp shell-id))))
         (shell-id (or shell-id ""))  ; ?? needed any more?
         (do-shell (and host-name (string= host-name (dp-short-hostname))))
         isa-shell-buf-p
         host-info
         buf)
    (if do-shell
        (lambda ()
          (dp-shell))
      ;; look for a buffer corresponding to the host-name.
      ;; 1st, exact match
      (setq ssh-buf-name (or ssh-buf-name
                             (dp-shells-make-ssh-buf-name host-name shell-id))
            ;; possible matches
            ssh-buf-regexp (or ssh-buf-regexp
                               (format "%s\\(<[0-9]+\\)?$" ssh-buf-name)))
      ;;!<@todo try without <> first?
      ;; See if a specific ssh buffer exists.
      (setq buf (or (get-buffer ssh-buf-name)
                    (dp-re-find-buffer 
                     (if (functionp 'dp-shells-ssh-buf-name-fmt)
                         (apply dp-shells-ssh-buf-name-fmt shell-id)
                       ssh-buf-regexp))
                    ;; the see if there's a shell buf with the same id.
                    (dp-re-find-buffer 
                     (dp-funcall-if 'dp-ssh-shell-buf-name-fmt
                         shell-id
                       (format "\\*shell\\*<%s>" shell-id)))))
      (setq isa-shell-buf-p (and buf (buffer-local-value 
                                      'dp-shell-isa-shell-buf-p buf)))
      (when (and isa-shell-buf-p 
                 (not (memq isa-shell-buf-p '(ssh dp-ssh))))
        (ding)
        (unless (y-or-n-p (format "Non-ssh buffer [%s], go there? " 
                                  (buffer-name buf)))
          (setq shell-id nil   ; This will make `ssh' prompt for host name.
                buf nil
                do-ssh-p nil)))
      (if buf
          (dp-switch-to-buffer buf)
        (unless do-ssh-p
          (setq shell-id (completing-read
                          "dp-ssh arguments (host-name first): "
                          dp-ssh-host-name-completion-list
                          nil nil host-name 'ssh-history)))
        (if (setq host-info 
                  (cdr-safe (assoc shell-id 
                                   dp-ssh-host-name-completion-list)))
            (if (and (valid-plist-p host-info)
                     (plist-get host-info 'ip-addr))
                (setq host-name shell-id
                      shell-id (plist-get host-info 'ip-addr))))
        (ssh shell-id)
        (dp-shells-clear-n-setenv "PS1_prefix" "-SSH-")
        (dp-shells-clear-n-setenv 
         "PS1_host_suffix"
         (format "'%s'" (dp-shells-guess-suffix (buffer-name) "")))
        (setq dp-shell-isa-shell-buf-p 'dp-ssh)
        (setq comint-input-ring-file-name 
              (concat "/home/davep/.bash_history." host-name))
        (when (file-exists-p comint-input-ring-file-name)
          (comint-read-input-ring)))
      (setq dp-shells-most-recent-shell (cons (current-buffer) 'dp-ssh))))))

========================
Friday June 22 2007
--

(defun dp-broken-kb-bs ()
  (interactive)

  (global-set-key "\e1" (lambda () (interactive) (insert "e")))
  (global-set-key "\e!" (lambda () (interactive) (insert "E")))
  (global-set-key "\e2" (lambda () (interactive) (insert "c")))
  (global-set-key "\e@" (lambda () (interactive) (insert "C")))

  (defun isearch-process-search-char-e ()
    ;; Append the char ?e to the search string, update the message and re-search.
    (interactive)
    (isearch-process-search-char ?e))
  (put 'isearch-process-search-char-e 'isearch-command t)
  (defun isearch-process-search-char-c ()
    ;; Append the char ?c to the search string, update the message and re-search.
    (interactive)
    (isearch-process-search-char ?c))
  (put 'isearch-process-search-char-c 'isearch-command t)
  (defun isearch-process-search-char-E ()
    ;; Append the char ?E to the search string, update the message and re-search.
    (interactive)
    (isearch-process-search-char ?E))
  (put 'isearch-process-search-char-E 'isearch-command t)
  (defun isearch-process-search-char-C ()
    ;; Append the char ?C to the search string, update the message and re-search.
    (interactive)
    (isearch-process-search-char ?C))
  (put 'isearch-process-search-char-C 'isearch-command t)
  
  (define-key isearch-mode-map "\e1" 'isearch-process-search-char-e)
  (define-key isearch-mode-map "\e2" 'isearch-process-search-char-c)
  (define-key isearch-mode-map "\e!" 'isearch-process-search-char-E)
  (define-key isearch-mode-map "\e@" 'isearch-process-search-char-C)
  (dmessage "EA!"))

(dp-broken-kb-bs)


(+ 1 2)




========================
Monday June 25 2007
--
(defmacro if-and-boundp-eval (var then &rest else)
  "If VAR is `boundp' and non-nil do THEN else do ELSE. See `if' for details."
  `(if (and-boundp ,var (eval ,var))
    ,then
    ,@else))

(setq dp-x 'a)

(cl-pe '(if-and-boundp-eval 'dp-x (princf "a")))

(if (progn nil (and (boundp 'dp-x) (eval 'dp-x))) (princf "a"))
a

(or (and (symbolp ,var)
         (boundp ,var))
    (atom ,var)

)
    

(boundp '(princf "hi!"))



(symbolp 4)
nil

(atom 4)
t

(atom dp-x)
t



(atom '(+ 4 5))
nil

(eval '(+ 4 5))

(eval 'x)



(boundp '(+ 4 5))

(boundp 5)

(atom 'x)
t

t

(defvar ffap-c-path
  ;; Need smarter defaults here!  Suggestions welcome.
  '("/usr/include" "/usr/local/include"))

(dp-add-list-to-list 'ffap-c-path
                     '("../include" "../src"))
nil

ffap-c-path
("../src" "../include" "/usr/include" "/usr/local/include")



========================
Tuesday June 26 2007
--

(defun dp-copy-chars (&optional arg action)
  "Copy character from the line above the cursor to point.
ARG == nil ==> one char,
ARG == '(4) ==> rest of word,
ARG == '(16) ==> rest of line (up til newline),
ARG is charp, copy up to but NOT including char ARG,
ARG is positive number of chars to copy.
ARG is negative number of chars to copy.
!<@todo Should just vector to routines which do what we want rather than
executing the cond again and again and..."
  (interactive "P")
  (let* ((num&action (cond 
                      (action (cons arg action))
                      ((not arg) (cons 1 'char))
                      ((integerp arg) 
                       (if (< arg 0)
                           (cons (abs arg) 'word)
                         (cons arg 'char)))
                      ((equal arg '(4)) (cons 1 'word))
                      ((equal arg '(16)) (cons 1 'line))
                      ((characterp arg) (cons 1 'up-to-arg))
                      (t (cons 1 'char))))
         (num (car num&action))
         (action (cdr num&action))
         char todo)
    (while (> num 0)
      (setq char (dp-copy-char 'NO-INSERT-P))
      (setq todo (cond
                  ((eq action 'char) '(insert count))
                  ((eq action 'up-to-arg)
                   (if (char= arg char) ;!<@todo Include target char?
                       '(insert-if-not-last count) 
                     '(insert)))
                  ((and (memq action '(line word))
                        (eq char ?\n)) ;; Newline ends lines and words.
                   '(insert-if-not-last count))
                  ((eq action 'line)
                   '(insert))
                   ((eq action 'word)
                    (if (eq (char-syntax char) ?\ )
                        '(insert count)
                      '(insert)))
                   (t (ding)
                      (error 'invalid-argument "bad action" ))))
      (when (memq 'insert todo)
        (insert char))
      (when (memq 'count todo)
        (setq num (1- num)))
      (when (and (memq 'insert-if-not-last todo)
                 (> num 0))
        (insert char))
      )
    )
  )


(defun dp-copy-chars (&optional arg)
  "Copy character from the line above the cursor to point.
   Copy character from the line above the cursor to point.
   Copy character from the line above the cursor to point.
   Copy character from the line above the cursor to point.
ARG == nil ==> one char,
ARG == '(4) ==> rest of word,
ARG == '(16) ==> rest of line (up til newline),
ARG is charp, copy up to but NOT including char ARG,
otherwise ARG is number of chars to copy."


"(re-search-forward \"\\\\(\\\\(<<\\\\|>>\\\\)\\\\s-*\\\\)?$\"
(line-end-position) t)" "(re-search-forward
\"\\\\(\\\\(<<\\\\|>>\\\\)\\\\s-*$\\\\)?\" (line-end-position) t)"
"(re-search-forward \"\\\\(\\\\(<<\\\\|>>\\\\)\\\\s-*$\\\\)\"
(line-end-position) t)" "(dp-in-syntactic-region '(stream-op))" "name" "t"
"(featurep 'dpmisc)" "(featurep 'dp-shells)" "(fmakunbound '



(defun dpx ()
  (interactive)
  (re-search-forward "\\(<<\\|>>\\)..*?\\(\\(<<\\|>>\\)\\s-*\\)?$" (line-end-position) t)
  (dmessage "ms0[%s], ms1[%s], ms2[%s], ms3[%s]"
            (match-string 0) (match-string 1) (match-string 2) (match-string 3)))
dpx

(defun dp-in-stream-op-p ()
  (interactive)
  (when (and (dp-in-c)
             (dp-in-syntactic-region '(stream-op))
             (save-excursion
               (re-search-forward "\\(<<\\|>>\\)..*?\\([^<>|,;:]\\s-*\\)$" 
                                  (line-end-position) t)))
    (dmessage "ms0[%s], ms1[%s], ms2[%s], ms3[%s]"
              (match-string 0) (match-string 1) (match-string 2) 
              (match-string 3))
    (match-string 1)))
dpx




dpx


========================
Wednesday June 27 2007
--

!!! Stupid bold face has wider characters.

(cl-pp ansi-color-map)

[
default
bold 
default 
italic 
underline 
bold 
bold-italic 
modeline 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
nil 
#<face black-foreground "Temporary face created by ansi-color.">
#<face red-foreground "Temporary face created by ansi-color."> 
#<face green-foreground "Temporary face created by ansi-color.">
#<face yellow-foreground "Temporary face created by ansi-color.">
#<face blue-foreground "Temporary face created by ansi-color.">
#<face magenta-foreground "Temporary face created by ansi-color.">
#<face cyan-foreground "Temporary face created by ansi-color.">
#<face white-foreground "Temporary face created by ansi-color.">
nil 
nil 
#<face black-background "Temporary face created by ansi-color.">
#<face red-background "Temporary face created by ansi-color.">
#<face green-background "Temporary face created by ansi-color.">
#<face yellow-background "Temporary face created by ansi-color.">
#<face blue-background "Temporary face created by ansi-color.">
#<face magenta-background "Temporary face created by ansi-color.">
#<face cyan-background "Temporary face created by ansi-color.">
#<face white-background "Temporary face created by ansi-color."> 
nil 
nil]


Debugger entered--Lisp error: (error "(OO-Browser):  Invalid feature entry, `[type]@= _Is_normal_iterator< __gnu_cxx::__normal_iterator<_Iterator,'")
  signal(error ("(OO-Browser):  Invalid feature entry, `[type]@= _Is_normal_iterator< __gnu_cxx::__normal_iterator<_Iterator,'"))
  cerror("(OO-Browser):  Invalid feature entry, `%s'" "[type]@= _Is_normal_iterator< __gnu_cxx::__normal_iterator<_Iterator,")
  apply(cerror "(OO-Browser):  Invalid feature entry, `%s'" "[type]@= _Is_normal_iterator< __gnu_cxx::__normal_iterator<_Iterator,")
  error("(OO-Browser):  Invalid feature entry, `%s'" "[type]@= _Is_normal_iterator< __gnu_cxx::__normal_iterator<_Iterator,")
  byte-code("..." [end-of-file-entries paths-alist signature path-counter entry path 1 read symbol-name int-to-string search-forward "" nil t looking-at 2 3 0 python-module-name "." princ format "(%S . [%S %S %S \"%d\"])\n" error "(OO-Browser):  Invalid feature entry, `%s'" class br-tag-fields-regexp python] 9)
  br-feature-make-htables()
  br-feature-build-htables()
  br-env-build("/home/davep/work/ll/ttnt/pkt-gen/OOBR" "pg" prompt t)
  br-env-cond-build("/home/davep/work/ll/ttnt/pkt-gen/OOBR" "pg" "Build Environment `%s' now? ")
  br-env-load("OOBR" nil prompt nil)
  br-env-try-load("OOBR" "OOBR")
  br-env-init("OOBR" t nil)
  c++-browse()
  #<compiled-function (&optional same-env-flag) "...(20)" [br-env-file same-env-flag br-lang-prefix intern-soft "browse" call-interactively br-env-browse] 3 ("/home/davep/yokel/lib/xemacs/xemacs-packages/lisp/oo-browser/br-start.elc" . 3587) (list (prog1 ... ...))>(t)
  call-interactively(oo-browser)

========================
Monday July 09 2007
--

(setq dpl 
      '((("wrt" "with respect to") dp-common) (("teh" "the") dp-common global)))
((("wrt" "with respect to") dp-common) (("teh" "the") dp-common global))

((("wrt" "with respect to") dp-common) (("teh" "the") dp-common global))



(append '((a b c)) '(1 2 3))
(nconc '((a b c)) '(1 2 3))
((a b c) 1 2 3)


((a b c) 1 2 3)

(a b c 1 2 3)
seqs
seqs
(defun* dp-add-abbrev0 (abbrev expansion abbrev-props &key
                        (write-p 'ask)
                        (abbrev-list 'dp-common-abbrevs) 
                        (abbrev-file "~/lisp/dp-common-abbrevs.el"))
  (find-file abbrev-file)
  (set abbrev-list
       (nconc (symbol-value abbrev-list) 
              (list (append (list (list abbrev expansion)) 
                                        abbrev-props))))
  (goto-char (point-min))
  (re-search-forward "(defconst dp-common-abbrevs\\s-*$")
  (beginning-of-line)
  (delete-region (point) (point-max))
  (insert ";;; hi there\n")
  (pprint `(defconst ,abbrev-list (quote ,(symbol-value abbrev-list)))
            (current-buffer))
  (if (or (eq write-p t)
          (and (eq write-p 'ask)
               (y-or-n-p "Save abbrev file? ")))
      (save-buffer)
    (message "Abbrevs will be temporary unless the abbrev file is saved."))
  ;; `dp-aliases' will use the abbrev files' buffer if there is one.
  ;; if we haven't saved, then the abbrev is only temporary
  (dp-aliases))


(defun dp-add-common-abbrev (abbrev expansion)
    (interactive "sabbrev: \nsexpansion: ")
    (dp-add-abbrev0 abbrev expansion '(dp-common)))

(defun dp-add-global-abbrev (abbrev expansion)
    (interactive "sabbrev: \nsexpansion: ")
    (dp-add-abbrev0 abbrev expansion '(global)))

(defun dp-add-abbrev (abbrev expansion)
    (interactive "sabbrev: \nsexpansion: ")
    (dp-add-abbrev0 abbrev expansion '(dp-common global)))
seqs

'((("wrt" "with respect to")
     dp-common))
((("wrt" "with respect to") dp-common))



(pp (let ((ab-list '((("wrt" "with respect to") dp-common))))
  (nconc ab-list (list (append (list (list "teh" "the")) '(dp-common global))))
  ab-list))
(defconst a 
  '((("wrt" "with respect to")
     dp-common)
    (("teh" "the")
     dp-common global))
  
(defconst blah
  '((("wrt" "with respect to")
     dp-common)
    ((("teh" "the")
      dp-common global)))





seqs









dpl
((("wrt" "with respect to") dp-common) (("teh" "the") dp-common global) (("qqq" "zzz")) (dp-common) (("sss" "eee")) (dp-common))

(defun dprs (sym)
  (interactive "Ssym: ")
  (princf "sym: %s\n" sym))
dprs

smactl

(intern-soft "smactl")
smactl

smactl



sym
 

dp-add-common-abbrev

(cl-pp (let ((dpl 
      '((("wrt" "with respect to") dp-common) 
        (("teh" "the") dp-common global))))
  (nconc dpl (list (list (list "aaa"  "bbb")) '(dp-common))))
(
 (("wrt" "with respect to") dp-common)
 (("teh" "the") dp-common global) 
 (("aaa" "bbb")) (dp-common))



(load "dp-common-abbrevs")
t

;; grabbed from etags.el
(defun* dp-visit-eval-data-file (eval-file &key eval-buffer-name
                                 revert-buffer-ignore-auto-p
                                 revert-buffer-noconfirm-p)
  "Visit containing eval'able lisp.  Used to save stuff like config info."
  (set-buffer (or (get-file-buffer eval-file)
		  (find-file-noselect eval-file)))
  (rename-buffer eval-buffer-name)
  (unless (verify-visited-file-modtime (get-file-buffer eval-file))
    (revert-buffer revert-buffer-ignore-auto-p revert-buffer-noconfirm-p t))
  (get-file-buffer eval-file))

(defun dp-read-eval-data-file (eval-file &key eval-buffer-name
                               revert-buffer-ignore-auto-p
                               revert-buffer-noconfirm-p)
  "Read and eval a file."
  (save-excursion
    (dp-visit-eval-data-file 
     eval-file
     :revert-buffer-ignore-auto-p revert-buffer-ignore-auto-p
     :revert-buffer-noconfirm-p revert-buffer-noconfirm-p)
    (eval-region (point-min) (point-max))))

========================
Wednesday July 11 2007
--


(defun* dpf(&optional &key r a b c &allow-other-keys)
  (princf "r>%s<, a>%s<, b>%s<, c>%s<\n" r a b c))
dpf
(dpf 1 2 3)
r>nil<, a>nil<, b>nil<, c>nil<
"r>nil<, a>nil<, b>nil<, c>nil<
"


(defun* dp-mark-embedded-lisp (&rest args)
  (interactive)
  (let ((be (apply 'dp-delimit-embedded-lisp args)))
    (when be
      (dp-set-mark (cdr be))
      (goto-char (car be)))))


(defun* dp-find-embedded-lisp-new (&key at-point limit regexp prefix suffix)
  "Search forward for an embedded lisp sexp.
Sets MATCH-DATA."
  (interactive)
  ;;(dmessage "pat>%s<" pat)
  (save-excursion
    (let* ((re (dp-embedded-lisp-regexp regexp prefix suffix))
           (be (dp-delimit-embedded-lisp :regexp regexp
                                         :prefix prefix
                                         :suffix suffix
                                         :limit (or limit
                                                    (line-end-position)))))
      (cond
       (at-point (eq (point) (car be))
                     (point)
                   nil)
       (be (car be))
       (t nil)))))
dp-find-embedded-lisp
(functionp nil)

nil

dp-find-embedded-lisp






(cond ('z 'q))
q

z

t



:(princf 
  "%s\n" "Well, Well"):



;;{{{;-COM-
;-COM-(defun* dpr (&rest rest)
;-COM-  (princf "%s\n" rest))
;-COM-dpr
;;}}}

(consp '())
nil

(consp '(a))
t

nil


dpr
(setq dpx 999)
setq dpx 999

999

(dpr :a 100 :b dpx)
(:a 100 :b 999)
nil


(defun fo (beg end)
  (interactive "r")
  (folding-fold-region beg end)
  (folding-shift-out)
  (folding-show-current-entry))

(defun cfo (beg end)
  (interactive "r")
  (fo beg end)
  (folding-comment-fold))



(defun dp-find-file-new)

(defun dp-cp-region-or-current-symbol-to-point ()
  (dp-region-or... ))

(symbol-function 'edebug-original-eval-defun)
#<compiled-function (eval-defun-arg-internal) "...(25)" [standard-output eval-defun-arg-internal t prin1 eval-interactive end-of-defun beginning-of-defun read] 4 1185273 "P">


(fset 'eval-defun (symbol-function 'edebug-original-eval-defun))
#<compiled-function (eval-defun-arg-internal) "...(25)" [standard-output eval-defun-arg-internal t prin1 eval-interactive end-of-defun beginning-of-defun read] 4 1185273 "P">



========================
Tuesday July 17 2007
--

(defvar dp-parenthesize-region-last-region nil
  "The boundaries of the last region we parenthesized.")

(defvar dp-parenthesize-region-paren-index 0
  "Next string pair to try to parenthesize region with.")

(defstruct dp-parenthesize-region-info
  (index 0)
  region
  pre-len
  suf-len)

(defvar dp-parenthesize-region-info (make-dp-parenthesize-region-info)
  "Information so that we can iterate of the various kinds of parens.")

(defvar dp-parenthesize-region-paren-list
  '(("(" . ")")                         ;0
    ("\"" . "\"")                       ;1
    ("'" . "'")                         ;2
    ("`" . "'")                         ;3
    ("{" . "}")                         ;4
    ("[" . "]")                         ;5
    ("<" . ">")                         ;6
    ("<:" . ":>")                       ;7
    ("" . "")                           ;8 (Undoish)
    )
  "Parenthesizing pairs to try, in order.")
  
;; "xxx z"
(defun dp-parenthesize-region-new (index &optional pre suf)
  "Wrap the region in paren like characters."
  (interactive "*P")
  ;; Some fixed alternatives  xxx
  (cond 
   ((numberp index) (setq index (prefix-numeric-value index)))
   ((equal index '(4)) (setq index 2)) ;C-u
   ((equal index '(16)) (setq pre "{\n" suf "}\n")))
  ;;(dmessage "lc: %s, tc: %s" last-command this-command)
  (let* ((iterating (eq last-command this-command))
         (index (cond
                 (index index)
                 (iterating (dp-parenthesize-region-info-index 
                             dp-parenthesize-region-info))
                 (t 0)))
         (parens (nth (% index (length dp-parenthesize-region-paren-list)) 
                      dp-parenthesize-region-paren-list))
         (pre (or pre (car parens)))
         (suf (or suf (cdr parens)))
         (beg-end (if iterating 
                      (dp-parenthesize-region-info-region dp-parenthesize-region-info)
                    (dp-mark-line-if-no-mark t t)
                    (dp-region-boundaries-ordered)))
         (beg (car beg-end))
         (end (dp-mk-marker (cdr beg-end))))
    (unless iterating
      (undo-boundary))
    (save-excursion
      (goto-char beg)
      (if iterating
          (delete-char (dp-parenthesize-region-info-pre-len 
                        dp-parenthesize-region-info)))
      (insert pre)
      (goto-char end)
      (if iterating
          (delete-char (dp-parenthesize-region-info-suf-len 
                        dp-parenthesize-region-info)))
      (insert suf)
      (when (dp-in-c)
        (c-indent-region beg (point))))
    (setq dp-parenthesize-region-info 
          (make-dp-parenthesize-region-info
           :index (1+ index)
           :region (cons (dp-mk-marker beg) end)
           :pre-len (length pre)
           :suf-len (length suf)))))

(put 'dp-parenthesize-region-new 'self-insert-defer-undo 
     (* 3 (length dp-parenthesize-region-paren-list)))


========================
Wednesday July 18 2007
--

(dp-timestamp-string (current-time))
"2007-07-18T00:46:34"


(18077 39636 980831)


(seconds-to-time (* 60 (* 60 5)))
(0 18000 0)

(dp-timestamp-string (time-add (current-time) (seconds-to-time (* 60 (* 60 1)))))
"2007-07-18T01:48:01"

"2007-07-18T05:47:46"

(18077 57785 999175)

(0 5 0)

(dp-timestamp-string dp-ll-first-emacs-start-time)
"2007-07-17T14:26:09"

(18077 2497)
(format-time-string
 dp-std-format-time-string-format
 (time-add dp-ll-first-emacs-start-time
                               (seconds-to-time (* 60 (* 60 10)))))
"Wed Jul 18 00:26:09 EDT 2007"




(dp-timestamp-string (time-add dp-ll-first-emacs-start-time
                               (seconds-to-time (* 60 (* 60 10)))))
"2007-07-18T00:26:09"


(defun dpx (new-appt-time new-appt-msg)
  "Add an appointment for the day at TIME and issue MESSAGE.
The time should be in either 24 hour format or am/pm format."
 
  (interactive "sTime (hh:mm[am/pm]): \nsMessage: ")
  (if (string-match "[0-9]?[0-9]:[0-9][0-9]\\(am\\|pm\\)?" new-appt-time)
      nil
    (error "Unacceptable time-string"))
  
  (let* ((appt-time-string (concat new-appt-time " " new-appt-msg))
         (appt-time (list (appt-convert-time new-appt-time)))
         (time-msg (cons appt-time (list appt-time-string))))
    time-msg))
dpx


(dpx "17:15" "blah")
((1035) "17:15 blah")

((15) "00:15 blah")


appt-time-msg-list
(((660) "11:00am: Neurontin") ((960) "4:00pm: Neurontin") ((1245) "8:45pm: Wood St gate closes at 9:00pm") ((1260) "9:00pm: Neurontin"))



(loop for th in dp-ll-emacs-session-thresholds do
  (time-add dp-ll-first-emacs-start-time
            (seconds-to-time (* 60 (* 60 th)))))


;; Convert threshold values to absolute time tuples
(mapcar 
 (function 
  (lambda (th)
    (time-add dp-ll-first-emacs-start-time
              (seconds-to-time (* 60 (* 60 th))))))
        '(8.0 9.0))
((18077 31297 0) (18077 34897 0))

(dp-timestamp-string '(18077 31297 0))
"2007-07-17T22:26:09"

;; Threshold has passed when threshold tuple is no longer less-p than the
;; current-time.
(time-less-p (time-add '(18077 31297 0)
                       (seconds-to-time (* 60 (* 60 3))))
             (current-time))
nil

t

t

nil

t




("Tue Jul 17 22:26:09 EDT 2007" "Tue Jul 17 23:26:09 EDT 2007")

nil

("Sat Aug  8 19:26:09 EDT 2009" "Mon Oct 29 15:26:09 EDT 2007")

((19070 2449 0) (18214 13265 0))


(defun dp-py-open-below ()
  (interactive)
  (beginning-of-line)
  ;; Need to prevent colon after [:,]
  (when (and (save-excursion
               ;; [:,]\s-*\(#\|$\)
               (not (re-search-forward "[:,]\\s-*\\(#\\|$\\)"
                                       (line-end-position) 'NOERROR)))
             (re-search-forward
              (concat                   ;For readbility
               "\\s-*\\<\\(def\\|for\\|if\\|else\\|while\\|class\\|try\\|except\\).*?"
               "\\(\\s-*\\(#\\|$\\)\\)")
                (line-end-position) 'NOERROR))
    (goto-char (match-end 2))
    (insert ":"))
  (end-of-line)
  (py-newline-and-indent))


else:

(defun dp-py-open-below ()
  (interactive)
  (beginning-of-line)
  ;; Need to prevent colon after [:,]
  (when (re-search-forward 
         "\\s-*\\<\\(def\\|for\\|if\\|else\\|while\\|class\\|try\\|except\\)[^:,]*\\s-*\\(#\\|$\\)"
         (line-end-position) 'NOERROR)
    (goto-char (match-end 2))
    (insert ":"))
  (end-of-line)
  (py-newline-and-indent))


(concat "aaa"
        "zzz")
"aaazzz"


"zzz"

========================
Tuesday July 24 2007
--

(defmacro dp-save-n-set-var (var-name new-var-value &optional docstring)
  (let ((docstring (or docstring
                       (format "Original value of `%s'." var-name))))
    `(progn
      (defvar (dp-ify-symbol ,var-name))
      (if-boundp ,var-name
          (eval ,var-name)
        'dp-save-n-set-var-previously-void-var)
      (set ,var-name new-var-value))))
dp-save-n-set-var

(put 'dp-save-n-set-var 'lisp-indent-function lisp-body-indent)

(defmacro dp-defvar-sym (name init-val &optional docstring)
    (setq docstring (or (eval docstring) "dp-defvar-sym"))
    `(defvar ,(eval name) ,init-val ,docstring))
dp-defvar-sym

(defun dp-z (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES."
  (loop for mode in list-o-modes do
    (let ((save-sym (dp-ify-symbol mode))
          (mode-val (symbol-value mode)))
      (when (not (boundp save-sym))
        (dp-defvar-sym save-sym mode-val
          (format "Original value of %s's font-lock keywords." mode)))
      (set mode (append (symbol-value save-sym) list-o-keys)))))
dp-z

(setq dp-v '("dee-pee-vee"))
("dee-pee-vee")


(cl-pe
'(dp-save-n-set-var 'dp-v "non-list"))

(progn
  (defvar (dp-ify-symbol 'dp-v))
  (progn
    nil
    (if (boundp 'dp-v) (eval 'dp-v) 'dp-save-n-set-var-previously-void-var))
  (set 'dp-v new-var-value))nil



(cl-pe
'(defun dp-zz (quoted-var new-val)
  (interactive "Ssymbol-name: ")
  (dp-save-n-set-var 'quoted-var new-val)))

(defun dp-zz (quoted-var new-val)
  (interactive "Ssymbol-name: ")
  (progn
    (defvar (dp-ify-symbol 'quoted-var))
    (progn
      nil
      (if (boundp 'quoted-var)
          (eval 'quoted-var)
        'dp-save-n-set-var-previously-void-var))
    (set 'quoted-var new-var-value)))nil



dp-zz

dp-zz




(dp-zz 'dp-vundef "new-dee-pee-vundef")
"non-list"

"non-list"

dp-orig-dp-v
("dee-pee-vee")


(dp-)

=====




(progn
  (defvar dp-orig-dp-v (and (boundp 'dp-v) dp-v) "Original value of `dp-v'.")
  (setq dp-v "non-list"))nil







mode
"shell-mode"

(cl-pe
'(dp-defvar-sym 'save-sym mode-val
    (format "Original value of %s's font-lock keywords." mode)))

(defvar save-sym
  mode-val
  "Original value of shell-mode's font-lock keywords.")nil




(defvar save-sym
  mode-val
  "Original value of shell-mode's font-lock keywords.")nil



(cl-pe
'(let ((mode 'xxxx-abc)
       (save-sym 'xxxx-123)
       (mode-val "mode-val"))
  (dp-defvar-sym 'save-sym mode-val
    (format "Original value of %s's font-lock keywords." mode))))

(let ((mode 'xxxx-abc)
      (save-sym 'xxxx-123)
      (mode-val "mode-val"))
  (defvar save-sym
    mode-val
    "Original value of shell-mode's font-lock keywords."))
save-sym

dp-orig-

(cl-pe 
'(defun dp-add-font-patterns (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES."
  (loop for mode in list-o-modes do
    (let ((save-sym (dp-ify-symbol mode))
          (mode-val (symbol-value mode)))
      (when (not (boundp save-sym))
        (dp-defvar-sym 'save-sym mode-val
          (format "Original value of %s's font-lock keywords." mode)))
      (set mode (append (symbol-value save-sym) list-o-keys))))))

(defun dp-add-font-patterns (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES."
  (block nil
    (let* ((G100308 list-o-modes)
           (mode nil))
      (while (consp G100308)
        (setq mode (car G100308))
        (let ((save-sym (dp-ify-symbol mode))
              (mode-val (symbol-value mode)))
          (if (not (boundp save-sym))
              (defvar save-sym
                mode-val
                "Original value of shell-mode's font-lock keywords."))
          (set mode (append (symbol-value save-sym) list-o-keys)))
        (setq G100308 (cdr G100308)))
      nil)))nil



dp-add-font-patterns

(byte-compile 'dp-add-font-patterns)











(let ((mode 'xxxx-abc)
      (save-sym 'xxxx-123)
      (mode-val "mode-val"))
  (defvar save-sym
    mode-val
    "Original value of shell-mode's font-lock keywords."))save-sym
save-sym
nil






(dp-add-line-too-long-font 'ruby-font-lock-keywords)
nil








(dp-add-line-too-long-font 'python-font-lock-keywords)
nil


(makunbound 'dp-orig-ruby-font-lock-keywords)
dp-orig-ruby-font-lock-keywords

(setq dp-Xorig-ruby-font-lock-keywords dp-orig-ruby-font-lock-keywords)

=============================================================================
(progn
  (makunbound 'dp-orig-dp-v)
  (setq dp-v '("dee-pee-vee")))
("dee-pee-vee")

("dee-pee-vee")

("dee-pee-vee")

("dee-pee-vee")

("dee-pee-vee")

("dee-pee-vee")



; (defmacro dp-save-n-set-var (var-name new-var-value &optional docstring)
;   (let ((docstring (or docstring
;                        (format "Original value of `%s'." var-name))))
;     `(progn
;       (defvar ,(eval ,(dp-ify-symbol ,var-name))
;         (if (boundp ,var-name)
;             (eval ,var-name)
;           'dp-save-n-set-var-previously-void-var)
;         ,docstring)
;       (set ,var-name ,new-var-value))))


; (defmacro dp-save-n-set-var (var-name new-var-value &optional docstring)
;   (let ((docstring (or docstring
;                        (format "Original value of `%s'." var-name))))
;     `(let ((save-sym (dp-ify-symbol ,var-name))
;            (sym-val (symbol-val ,var-name)))
;       (when (not (boundp save-sym))
;         (dp-defvar-sym save-sym sym-val ,docstring))
;       (set ,var-name ,new-var-value))))


(defmacro dp-defvar-sym (name init-val &optional docstring)
  (setq docstring (or (eval docstring) "dp-defvar-sym"))
  `(defvar ,(eval name) ,init-val ,docstring))
dp-defvar-sym


(defmacro dp-defvar-sym (name init-val &optional docstring)
    (setq docstring (or (eval docstring) "dp-defvar-sym"))
    `(defvar ,(eval name) ,init-val (eval ,docstring)))
dp-defvar-sym

(defun dp-save-n-set-var (var-name new-var-value &optional docstrin)
  (let ((docstrin (or docstrin
                 (format "Original value of `%s'." var-name)))
        (save-sym (dp-ify-symbol var-name))
        (sym-val (if (boundp var-name) 
                     (symbol-value var-name)
                   "variable was unbound.")))
      (unless (boundp save-sym)
        (dp-defvar-sym save-sym sym-val docstrin))
      (set var-name new-var-value)))

(cl-pe
'(progn
  (makunbound 'dp-orig-dp-v)
  (setq dp-v '("dee-pee-vee"))
  (dp-save-n-set-var 'dp-v "newnewnew")))

(progn
  (makunbound 'dp-orig-dp-v)
  (setq dp-v '("dee-pee-vee"))
  (dp-save-n-set-var 'dp-v "newnewnew" "blah"))
"newnewnew"





(progn
  (makunbound 'dp-orig-dp-v)
  (setq dp-v '("dee-pee-vee"))
  (dp-save-n-set-var 'dp-v "newnewnew" "booga"))nil


"newnewnew"




(let ((s 'dp-qq)
      (u 'dp-uu)
      (v "goober1")
      (doc "docdocdoc"))
  (makunbound 'dp-qq)
  (makunbound 'dp-uu)
  (makunbound 'dp-orig-dp-uu)
  (dp-save-n-set-var u "u1" doc)
  (dp-defvar-sym s v doc))
dp-qq

dp-qq

dp-qq

"goober1"

dp-qq

dp-qq

dp-qq







dp-qq


dp-qq



()



"newnewnew"

"newnewnew"


dp-v
"newnewnew"




(cl-pe
'(let ((q "qqq"))
  (dp-defvar-sym 'dp-q "booger" q)))

(cl-pe
'(let ((q "qqqq"))
  (if (boundp q) t) "NIL"))

(let ((q "qqqq"))
  (if (boundp q) t)
  "NIL")




(let ((q 'qqqq))
  (if (boundp q) t)
  "NIL")
"NIL"

(boundp dp-v)




dp-qq


(if-boundp kdkk "t" "nil")


"NIL"

"NIL"

(let ((doc "docdocdoc"))
  '(dp-defvar-sym 'dp-qq "booger" doc))
(dp-defvar-sym (quote dp-qq) "booger" doc)


(let ((s 'dp-qq)
      (doc "docdocdoc"))
  (makunbound 'dp-qq)
  (dp-defvar-sym s "booger6" doc))
dp-qq

dp-qq


dp-qq
"booger5"


dp-qq
"booger4"


dp-qq
"booger4"


dp-qq
"booger3"



(progn
  (fmakunbound 'dp-qq)
  (defvar dp-qq "booger3" "d"))
dp-qq
"booger2"






dp-qq
"booger2"


dp-qq
"booger2"



(defvar dp-qq "booger2" "d")
dp-qq
"booger2"




dp-qq
"booger"


dp-qq
"booger"



(defun dp-zz (quoted-var &optional new-val)
  (interactive "Ssymbol-name: ")
  (dmessage "boo, quoted-var>%s<" quoted-var)
  (dmessage "symbolp quoted-var>%s<" (symbolp quoted-var))
  (dp-save-n-set-var quoted-var new-val))
dp-zz


(dp-zz 'dp-v "new-val")
"new-val"

"new-val"

"new-val"

"new-val"

"new-val"

"new-val"


`x
x
`,x

`,dp-v
"new-val"





(symbolp (dp-ify-symbol 'quoted-var))
t

dp-orig-quoted-var



(eval dp-v-s)
"dp-zz-did-this"

(symbol-value 'dp-v-s)
dp-v

(setq orig-ruby-font-lock-keywords ruby-font-lock-keywords)
(("\\(^\\|[^_:.@$]\\|\\.\\.\\)\\b\\(alias\\|and\\|begin\\|break\\|case\\|catch\\|class\\|def\\|do\\|elsif\\|else\\|fail\\|ensure\\|for\\|end\\|if\\|in\\|module\\|next\\|not\\|or\\|raise\\|redo\\|rescue\\|retry\\|return\\|then\\|throw\\|super\\|unless\\|undef\\|until\\|when\\|while\\|yield\\)\\>\\([^_]\\|$\\)" . 2) ("\\(^\\|[^_:.@$]\\|\\.\\.\\)\\b\\(nil\\|self\\|true\\|false\\)\\b\\([^_]\\|$\\)" 2 font-lock-variable-name-face) ("\\(\\$\\([^a-zA-Z0-9 
]\\|[0-9]\\)\\)\\W" 1 font-lock-variable-name-face) ("\\(\\$\\|@\\|@@\\)\\(\\w\\|_\\)+" 0 font-lock-variable-name-face) (ruby-font-lock-docs 0 font-lock-comment-face t) (ruby-font-lock-maybe-docs 0 font-lock-comment-face t) ("\\(^\\|[^_]\\)\\b\\([A-Z]+\\(\\w\\|_\\)*\\)" 2 font-lock-type-face) ("^\\s *def\\s +\\([^( ]+\\)" 1 font-lock-function-name-face) ("\\(^\\|[^:]\\)\\(:\\([-+~]@?\\|[/%&|^`]\\|\\*\\*?\\|<\\(<\\|=>?\\)?\\|>[>=]?\\|===?\\|=~\\|\\[\\]=?\\|\\(\\w\\|_\\)+\\([!?=]\\|\\b_*\\)\\|#{[^}
\\\\]*\\(\\\\.[^}
\\\\]*\\)*}\\)\\)" 2 font-lock-reference-face) ("#\\({[^}
\\\\]*\\(\\\\.[^}
\\\\]*\\)*}\\|\\(\\$\\|@\\|@@\\)\\(\\w\\|_\\)+\\)" 0 font-lock-variable-name-face t))



(dp-add-line-too-long-font 'ruby-font-lock-keywords)


nil

ruby-font-lock-keywords
(("\\(^\\|[^_:.@$]\\|\\.\\.\\)\\b\\(alias\\|and\\|begin\\|break\\|case\\|catch\\|class\\|def\\|do\\|elsif\\|else\\|fail\\|ensure\\|for\\|end\\|if\\|in\\|module\\|next\\|not\\|or\\|raise\\|redo\\|rescue\\|retry\\|return\\|then\\|throw\\|super\\|unless\\|undef\\|until\\|when\\|while\\|yield\\)\\>\\([^_]\\|$\\)" . 2) ("\\(^\\|[^_:.@$]\\|\\.\\.\\)\\b\\(nil\\|self\\|true\\|false\\)\\b\\([^_]\\|$\\)" 2 font-lock-variable-name-face) ("\\(\\$\\([^a-zA-Z0-9 
]\\|[0-9]\\)\\)\\W" 1 font-lock-variable-name-face) ("\\(\\$\\|@\\|@@\\)\\(\\w\\|_\\)+" 0 font-lock-variable-name-face) (ruby-font-lock-docs 0 font-lock-comment-face t) (ruby-font-lock-maybe-docs 0 font-lock-comment-face t) ("\\(^\\|[^_]\\)\\b\\([A-Z]+\\(\\w\\|_\\)*\\)" 2 font-lock-type-face) ("^\\s *def\\s +\\([^( ]+\\)" 1 font-lock-function-name-face) ("\\(^\\|[^:]\\)\\(:\\([-+~]@?\\|[/%&|^`]\\|\\*\\*?\\|<\\(<\\|=>?\\)?\\|>[>=]?\\|===?\\|=~\\|\\[\\]=?\\|\\(\\w\\|_\\)+\\([!?=]\\|\\b_*\\)\\|#{[^}
\\\\]*\\(\\\\.[^}
\\\\]*\\)*}\\)\\)" 2 font-lock-reference-face) ("#\\({[^}
\\\\]*\\(\\\\.[^}
\\\\]*\\)*}\\|\\(\\$\\|@\\|@@\\)\\(\\w\\|_\\)+\\)" 0 font-lock-variable-name-face t))



(defmacro if-and-boundp (var then &rest else)
  "if var is `boundp' and non-nil do then else do else. see `if' for details."
  `(if (and-boundp ,var (symbol-value ,var))
    ,then
    ,@else))

(defmacro when-and-boundp (var &rest body)
  "when version of `if-and-boundp'."
  `(if-and-boundp ,var
    (progn
      ,@body)))


(cl-pe
'(when-and-boundp 'yaya 'boo))

(let ((yaya nil))
  (if (progn nil (and (boundp 'yaya) (symbol-value 'yaya))) 'boo))
nil

boo



nil

  (defmacro dp-defvar-sym (name init-val &optional docstring)
    (setq docstring (or (eval docstring) "dp-defvar-sym"))
    `(defvar ,(eval name) ,init-val ,docstring))
  (put 'dp-defvar-sym 'lisp-indent-function lisp-body-indent)

(defmacro dp-defvar-sym (name init-val &optional docstring)
  `(progn
    (set ,name ,init-val)
    (put ,name 'variable-documentation doc)))
dp-defvar-sym



  
    (format "%s" ,docstring)))

(defmacro* dpm1 (n v &optional doc)
  `(progn
    (set ,n ,v)
    (put ,n 'variable-documentation doc)))
dpm1
(cl-pe
'(let ((aaa (dp-ify-symbol 'yyy))
       (doc "docstr"))
  (dpm1 aaa "set to aaa")))

(let ((aaa (dp-ify-symbol 'yyy))
      (doc "docstr"))
  (progn
    (set aaa "set to aaa")
    (put aaa 'variable-documentation doc)))
"docstr"




(let ((aaa (dp-ify-symbol 'yyy)))
  (progn
    (set aaa "set to aaa")
    (put aaa 'variable-documentation doc)))nil












(let ((aaa (dp-ify-symbol 'yyy)))
  (defvar (eval n) "set to aaa" "boo"))nil


(let ((aaa (dp-ify-symbol 'yyy)))
  (dpm1 aaa "set to aaa")
  (cl-pe '(dpm1 aaa "aaa")))

(cl-pe
'(defun dpx (n v)
  (let ((aaa (dp-ify-symbol n)))
    (dpm1 aaa ,v))))




dpxnil


dpx



(defvar yyy "aaa" "boo")nil
yyy
"set to aaa"






(defun dp-save-n-set-var (var-name new-var-value &optional docstrin)
  (let ((save-sym (dp-ify-symbol var-name)))
    (unless (boundp save-sym)
      (set save-sym (if (boundp var-name) 
                        (symbol-value var-name)
                      (format "%s was unbound." var-name)))
      (put save-sym 'variable-documentation 
           (or docstrin
               (format "Original value of `%s'." var-name))))
    (set var-name (if (functionp new-var-value)
                      (funcall new-var-value save-sym)
                    new-var-value))))



;     (describe-variable save-sym)
;     (dmessage "buf: %s, var-name: %s, var's val: %s" 
;               (current-buffer) var-name (symbol-value var-name))
;     (dmessage "docstrin>%s<" docstrin)))
; dp-save-n-set-var





(let ((s 'dp-qq)
      (u 'dp-uu)
      (v "goober1")
      (doc "docdocdoc"))
  (makunbound 'dp-qq)
  (makunbound 'dp-uu)
  (makunbound 'dp-orig-dp-uu)
  (dp-save-n-set-var 'dp-qq "whatq? newq!" "doc: what about qq??")
  (dp-save-n-set-var u "u1" doc))
"u1"



(describe-variable 'dp-orig-dp-qq)
t

t


(makunbound 'dp-orig-dp-qq)
dp-orig-dp-qq





(progn
  (makunbound 'dp-orig-dp-v)
  (setq dp-v '("dee-pee-vee"))
  (put 'dp-v 'variable-documentation "dp-v original doc")
  (dp-save-orig-n-set-new 'dp-v "newnewnew"))
"newnewnew"

"newnewnew"

"newnewnew"





(cl-pe
'(dp-funcall-if 'dp-ssh-shell-buf-name-fmt
  (a b c shell-id)
  (format "\\*shell\\*<%s>" shell-id)))



(if (functionp 'dp-ssh-shell-buf-name-fmt)
    (funcall 'dp-ssh-shell-buf-name-fmt shell-id)
  (format "\\*shell\\*<%s>" shell-id))nil





========================
Wednesday July 25 2007
--

(dp-save-n-set-var 'c-font-lock-keywords-3 c-font-lock-keywords-3)
(("\\(\\=\\|\\(\\=\\|[^\\]\\)[
]\\)\\s *#\\s *\\(error\\|warning\\)\\>\\s *\\(.*\\)$" 4 font-lock-string-face) ("\\(\\=\\|\\(\\=\\|[^\\]\\)[
]\\)\\s *#\\s *\\(import\\|include\\)\\>[ 	
]*\\(\\(/\\(/[^
]*[
]\\|\\*\\([^*
]\\|\\*[^/
]\\)*\\*/\\)\\|\\\\[
]\\)[ 	
]*\\)*\\(<[^>
]*>?\\)" (8 font-lock-string-face) (#<compiled-function (limit) "...(50)" [c->-as-paren-syntax c-<-as-paren-syntax ext beg-pos end-pos pos 8 ?> c-put-char-property-fun syntax-table extent-at nil delete-extent] 5>)) (#<compiled-function (limit) "...(153)" [parse-sexp-lookup-properties limit -match-end-pos- face start end nil boundp re-search-forward "\\(\\=\\|\\(\\=\\|[^\\]\\)[
]\\)\\s *#\\s *define\\>[ 	
]*\\(\\(/\\(/[^
]*[
]\\|\\*\\([^*
]\\|\\*[^/
]\\)*\\*/\\)\\|\\\\[
]\\)[ 	
]*\\)*\\([a-zA-Z_][a-zA-Z0-9_$]*\\)\\(\\((\\)\\|\\([^(]\\|$\\)\\)" t 0 c-skip-comments-and-strings match-data ((store-match-data match-data)) 9 7 font-lock-function-name-face put-nonduplicable-text-property font-lock c-forward-sws looking-at font-lock-variable-name-face ?\, match-data c-symbol-key] 5>) (#<compiled-function (limit) "...(79)" [parse-sexp-lookup-properties face start end -match-end-pos- limit nil boundp re-search-forward "\\(\\=\\|\\(\\=\\|[^\\]\\)[
]\\)\\s *#\\s *\\(if\\|elif\\)\\>\\(\\\\\\(.\\|[
]\\)\\|[^
]\\)*" t 0 c-skip-comments-and-strings 3 match-data ((store-match-data match-data)) "\\<\\(defined\\)\\>\\s *(?" move 1 put-nonduplicable-text-property font-lock match-data c-preprocessor-face-name] 5>) (#<compiled-function (limit) "...(62)" [parse-sexp-lookup-properties face limit start end -match-end-pos- nil boundp re-search-forward "\\(\\=\\|\\(\\=\\|[^\\]\\)[
]\\)\\(\\s *#\\s *[a-zA-Z0-9_$]+\\)" t 0 c-skip-comments-and-strings match-data ((store-match-data match-data)) 3 put-nonduplicable-text-property font-lock match-data c-preprocessor-face-name] 5>) (eval list "-A " 0 (progn (unless (c-face-name-p (quote c-nonbreakable-space-face)) (c-make-inverse-face c-invalid-face-name (quote c-nonbreakable-space-face))) (quote c-nonbreakable-space-face))) #<compiled-function (limit) "...(41)" [match-data parse-sexp-lookup-properties limit -match-end-pos- nil boundp re-search-forward ".\\(\\s\"\\|\\s|\\)" t 0 c-skip-comments-and-strings match-data ((store-match-data match-data)) c-font-lock-invalid-string] 4> (eval list "\\<\\(NULL\\|false\\|true\\)\\>" 1 c-constant-face-name) ("\\<\\(__\\(?:a\\(?:sm__\\|ttribute__\\)\\|declspec\\)\\|a\\(?:sm\\|uto\\)\\|break\\|c\\(?:ase\\|on\\(?:st\\|tinue\\)\\)\\|d\\(?:efault\\|o\\)\\|e\\(?:lse\\|num\\|xtern\\)\\|for\\|goto\\|i\\(?:f\\|nline\\)\\|re\\(?:gister\\|strict\\|turn\\)\\|s\\(?:izeof\\|t\\(?:atic\\|ruct\\)\\|witch\\)\\|typedef\\|union\\|volatile\\|while\\)\\([^a-zA-Z0-9_$]\\|$\\)" 1 font-lock-keyword-face) c-font-lock-complex-decl-prepare c-font-lock-declarations ("\\<\\(_\\(?:Bool\\|Complex\\|Imaginary\\)\\|char\\|double\\|float\\|int\\|long\\|s\\(?:hort\\|igned\\)\\|unsigned\\|void\\)\\>" 1 (quote font-lock-type-face)) (#<compiled-function (limit) "...(49)" [c-specifier-key c-record-type-identifiers c-record-ref-identifiers c-promote-possible-types parse-sexp-lookup-properties limit t nil boundp re-search-forward "\\<\\(enum\\|struct\\|union\\)\\>" c-skip-comments-and-strings c-forward-sws looking-at c-forward-keyword-clause c-forward-type c-fontify-recorded-types-and-refs] 5>) (#<compiled-function (limit) "...(59)" [match-data parse-sexp-lookup-properties limit -match-end-pos- nil boundp re-search-forward "}[ 	]*\\(/\\*\\([^*
]\\|\\*[^/
]\\)*\\*/[ 	]*\\)*\\(\\([*(]\\|\\(const\\|restrict\\|volatile\\)\\>\\)\\([^=]\\|$\\)\\|[a-zA-Z_][a-zA-Z0-9_$]*\\)" t 0 c-skip-comments-and-strings c-put-char-property-fun c-type c-decl-id-start 3 match-data ((store-match-data match-data)) c-font-lock-declarators] 4>) (#<compiled-function (limit) "...(68)" [match-data match-data parse-sexp-lookup-properties limit -match-end-pos- nil boundp re-search-forward "\\<\\(enum\\)\\>[^][{}();,/#=]*{" t 0 c-skip-comments-and-strings match-data ((store-match-data match-data)) c-put-char-property-fun c-type c-decl-id-start c-forward-sws ((store-match-data match-data)) c-font-lock-declarators] 4>) (eval list "\\<\\(goto\\)\\>\\s *\\([a-zA-Z_][a-zA-Z0-9_$]*\\)" (list 2 c-label-face-name nil t)) c-font-lock-labels)


(dp-muck-with-fontification)
dp-fdp-f
  (fmakunbound 'dp-f)
dp-f

dp-f


(progn
  (fmakunbound 'dp-f)
  (end-of-defun)
  (edebug-defun))
(defun dp-f ()
  (dmessage "hi"))
dp-f


(dp-f)
"hi"

"hi"

"hi"


(let ((extras 
       (list (cons
              (dp-mk-font-lock-type-re dp-c-font-lock-extra-types)
              font-lock-type-face)
             dp-font-lock-line-too-long-element
             (cons (dp-mk-debug-like-patterns)
                   ;; ??? Which is better; just the match or the whole
                   ;;     line?
                   (list 1 'dp-debug-like-face t)))))
  ;;
  ;; Add some extra types to the xemacs gaudy setting.  Rebuild the
  ;; list each time rather than adding to the existing value.  This
  ;; makes reinitializing cleaner.
  (let ((appendor (function (lambda (save-sym &rest extras-list)
                              (append (symbol-value save-sym)
                                      (car extras-list))))))
    (dp-save-n-set-var 'c-font-lock-keywords-3 appendor nil extras)
    (dp-save-n-set-var 'c++-font-lock-keywords-3 appendor nil extras)))


(describe-bindings-internal emacs-lisp-mode-map)

M-tab           lisp-complete-symbol
M-;             lisp-indent-for-comment
M-C-i           lisp-complete-symbol
M-C-q           indent-sexp
M-C-x           eval-defun
nil



tab             dp-c-indent-command
linefeed        dp-c-newline-and-indent
return          dp-c-context-line-break
/               dp-c-electric-slash
l               self-insert-command
{               dp-c-electric-brace
}               dp-c-close-brace
delete          dp-delete
C-tab           lisp-complete-symbol
C-space         expand-abbrev
C-/             eldoc-doc
C-;             Anonymous Lambda
C-d             dp-delete
C-j             dp-c-newline-and-indent
C-m             c-context-line-break
C-x             << Prefix Command >>
C-y             dp-c-yank-pop
M-tab           lisp-complete-symbol
M-;             dp-c-indent-for-comment
M-a             dp-toggle-mark
M-e             find-file-at-point
M-j             join-line
M-q             dp-c-fill-paragraph
M-backspace     dp-delete-word
M-left          dp-beginning-of-defun
M-right         dp-end-of-defun
M-C-return      Anonymous Lambda
M-C-a           mark-defun
M-C-i           lisp-complete-symbol
M-C-q           indent-sexp
M-C-x           dp-eval-lisp@point

C-x left        dp-c-show-class-name
C-x right       Anonymous Lambda
C-x C-left      Anonymous Lambda
C-x C-right     Anonymous Lambda
nil


========================
Wednesday August 01 2007
--

(defun dp-string-var-grep (regexp &optional symbol-name-regexp)
  "Grep for REGEXP in all variables whose name matches SYMBOL-NAME-REGEXP."
  (interactive "sregexp: \nP")
  (when (and (interactive-p) current-prefix-arg)
    (setq symbol-name-regexp (car (dp-prompt-with-symbol-near-point-as-default
                                   "symbol regexp"))))
  (let (matches)
    (mapatoms 
     (function (lambda (atom)
                 (when (and (if symbol-name-regexp
                                (string-match symbol-name-regexp 
                                              (format "%s" atom))
                              t)
                            (boundp atom)
                            (stringp (symbol-value atom))
                            (string-match regexp (symbol-value atom)))
                   (setq matches (cons atom matches))))))
    matches))

(dp-string-var-grep "grep")
(isearch-message igrep-program isearch-string debugger-previous-backtrace ispell-grep-command grep-find-command igrep-program-default grep-command regexp)

(cl-pp (mapcar (lambda (sym)
          (and (boundp sym)             ; `dp-string-var-grep' will return `let' vars.
               (format "%s: %s" sym (symbol-value sym))))
       (dp-string-var-grep "efs")))

("abbrev-file-name: ~/.abbrev_defs" nil)nil







nil







(defmacro define-overload (name args docstring &rest body)
  "Define a new function, as with `defun' which can be overloaded.
NAME is the name of the function to create.
ARGS are the arguments to the function.
DOCSTRING is a documentation string to describe the function.  The
docstring will automatically had details about its overload symbol
appended to the end.
BODY is code that would be run when there is no override defined.  The
default is to call the function `NAME-default' with the appropriate
arguments.

BODY can also include an override form that specifies which part of
BODY is specifically overridden.  This permits to specify common code
run for both default and overridden implementations.
An override form is one of:

  1. (:override [OVERBODY])
  2. (:override-with-args OVERARGS [OVERBODY])

OVERBODY is the code that would be run when there is no override
defined.  The default is to call the function `NAME-default' with the
appropriate arguments deduced from ARGS.
OVERARGS is a list of arguments passed to the override and
`NAME-default' function, in place of those deduced from ARGS."
  `(eval-and-compile
     (defun ,name ,args
       ,docstring
       ,@(mode-local--overload-body name args body))
     (put ',name 'mode-local-overload t)))
define-overload


(cl-pe '(define-overload semantic-grammar-parsetable-builder ()
  "Return the parser table value."))

(progn
  (defun semantic-grammar-parsetable-builder nil
    "Return the parser table value."
    (let ((override (fetch-overload 'semantic-grammar-parsetable-builder)))
      (if override
          (funcall override)
        (semantic-grammar-parsetable-builder-default))))
  (put 'semantic-grammar-parsetable-builder 'mode-local-overload t))nil


(fetch-overload 'semantic-grammar-parsetable-builder)
nil


---------------------------

(defun semantic-grammar-parser-data ()
  "Return the parser table as a string value."
  (message "semantic-grammar-parser-data: builder override: %s" 
           (fetch-overload 'semantic-grammar-parsetable-builder))
  (describe-mode-local-bindings (current-buffer))
  (semantic-grammar-as-string
   (semantic-grammar-parsetable-builder)))


(defsubst fetch-overload (overload)
  "Return the current OVERLOAD function, or nil if not found.
First, lookup for OVERLOAD into locally bound mode local symbols, then
in those bound in current `major-mode' and its parents."
  (message "fetch-overload, overload: %s, x: %s" overload
           (mode-local-symbol-value overload nil 'override-flag))
  (or (mode-local-symbol-value overload nil 'override-flag)
      ;; If an obsolete overload symbol exists, try it.
      (and (overload-obsoleted-by overload)
           (mode-local-symbol-value
            (overload-obsoleted-by overload) nil 'override-flag))))

(defun mode-local-bind (bindings &optional plist mode)
  "Define BINDINGS in the specified environment.
BINDINGS is a list of (VARIABLE . VALUE).
Optional argument PLIST is a property list each VARIABLE symbol will
be set to.  The following properties have special meaning:

- `constant-flag' if non-nil, prevent to rebind variables.
- `mode-variable-flag' if non-nil, define mode variables.
- `override-flag' if non-nil, define override functions.

The `override-flag' and `mode-variable-flag' properties are mutually
exclusive.

If optional argument MODE is non-nil, it must be a major mode symbol.
BINDINGS will be defined globally for this major mode.  If MODE is
nil, BINDINGS will be defined locally in the current buffer, in
variable `mode-local-symbol-table'.  The later should be done in MODE
hook."
  ;; Check plist consistency
  (message "mode-local-bind, bindings: %s, plist: %s, mode: %s"
           bindings plist mode)
  (and (plist-get plist 'mode-variable-flag)
       (plist-get plist 'override-flag)
       (error "Bindings can't be both overrides and mode variables"))
  (let (table variable varname value binding)
    (if mode
        (progn
          ;; Install in given MODE symbol table.  Create a new one if
          ;; needed.
          (setq table (or (get mode 'mode-local-symbol-table)
                          (new-mode-local-bindings)))
          (put mode 'mode-local-symbol-table table))
      ;; Fail if trying to bind mode variables in local context!
      (if (plist-get plist 'mode-variable-flag)
          (error "Mode required to bind mode variables"))
      ;; Install in buffer local symbol table.  Create a new one if
      ;; needed.
      (setq table (or mode-local-symbol-table
                      (setq mode-local-symbol-table
                            (new-mode-local-bindings)))))
    (while bindings
      (setq binding  (car bindings)
            bindings (cdr bindings)
            varname  (symbol-name (car binding))
            value    (cdr binding))
      (if (setq variable (intern-soft varname table))
          ;; Binding already exists
          ;; Check rebind consistency
          (cond
           ((equal (symbol-value variable) value)
            ;; Just ignore rebind with the same value.
            )
           ((get variable 'constant-flag)
            (error "Can't change the value of constant `%s'"
                   variable))
           ((and (get variable 'mode-variable-flag)
                 (plist-get plist 'override-flag))
            (error "Can't rebind override `%s' as a mode variable"
                   variable))
           ((and (get variable 'override-flag)
                 (plist-get plist 'mode-variable-flag))
            (error "Can't rebind mode variable `%s' as an override"
                   variable))
           (t
            ;; Merge plist and assign new value
            (setplist variable (append plist (symbol-plist variable)))
            (set variable value)))
        ;; New binding
        (setq variable (intern varname table))
        ;; Set new plist and assign initial value
        (setplist variable plist)
        (set variable value)))
    ;; Return the symbol table used
    table))


!!!!!!!!!!!!!!!!!!!!!!!!!!!
mode-local-bind, bindings: ((semantic-grammar-parsetable-builder . wisent-grammar-parsetable-builder) (semantic-grammar-setupcode-builder . wisent-grammar-setupcode-builder)), plist: (constant-flag t override-flag t), mode: nil



========================
Thursday August 02 2007
--

(defun lgrep0 (command-args &optional dont-grab-default-p extra-globs)
  "Grep my lisp files."
  (setq command-args (format "%s %s" 
			     command-args
                             (concat (dp-string-join dp-lisp-globs)
                                     (if extra-globs
                                         (dp-string-join extra-globs)
                                       ""))))
  (save-some-buffers)
  (grep command-args))

(defvar dp-frame-title-format (format "%%S@%s: %%f" (dp-short-hostname))
  "Base frame title format.")

dp-frame-title-format
"%S@tc-le4: %f"

(setq dp-short-hostname (dp-short-hostname))
"tc-le4"


(setq frame-title-format '("" dp-short-hostname ":" buffer-file-truename))
("" dp-short-hostname ":" buffer-file-truename)

("" dp-short-hostname ":" buffer-file-truename)

(dp-short-hostname)
global-mode-string
("" display-time-string appt-mode-line-string working-mode-line-message)

dp-frame-title-format
"%S@tc-le4: %f"


(setq frame-title-format dp-frame-title-format)
("" "tc-le4:" buffer-file-truename)

("" "tc-le4::::" buffer-file-truename)

<:step1 semantic:>
(progn
  (cd "/home/davep/lisp/contrib/cedet-1.0pre4/semantic")
  (shell-command-to-string "yes y | cp -p ~/tmp/semantic-grammar-wy.el . && touch semantic-grammar.wy")
  (load "/home/davep/lisp/contrib/cedet-1.0pre4/semantic/grammar-make-script")
  (setq command-line-args-left '("semantic-grammar.wy"))
  (defun semantic-grammar-noninteractive () t)
  (find-file "semantic-grammar.el")
  (find-file "semantic.el")
  (eval-and-compile
    ;; Other package depend on this value at compile time via inversion.
    
    (defvar semantic-version "2.0pre4"
      "Current version of Semantic.")
    
    )
  (require 'working)
  (require 'assoc)
  (require 'semantic-tag)
  (require 'semantic-lex)
  (require 'inversion)
;   (find-file "semantic-grammar.el")
;   (goto-char (point-min))
;   (re-search-forward (regexp-quote "(defun semantic-grammar-lex-buffer ()") nil t)
  (dp-push-go-back "semantic testing.")
  (find-file "semantic-lex.el")
  (goto-char (point-min))
  (re-search-forward (regexp-quote "(defun semantic-lex-init ()") nil t)
  )

#<buffer "semantic-grammar.el">


semantic-grammar-noninteractive

dpxx
";;; semantic-grammar-wy.el --- Generated parser support file

;; Copyright (C) 2002, 2003, 2004 David Ponce

;; Author: David A. Panariti <davep@meduseld.net>
;; Created: 2007-08-02 21:00:27z
;; Keywords: syntax
;; X-RCS: $Id$

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.
;;
;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; PLEASE DO NOT MANUALLY EDIT THIS FILE!  It is automatically
;; generated from the grammar file semantic-grammar.wy.

;;; History:
;;

;;; Code:
"


dpxx-prologue
""
(fetch-overload 'semantic-parse-region)
nil


(cl-pe '(define-overload semantic-parse-region
  (start end &optional nonterminal depth returnonerror)
  "Parse the area between START and END, and return any tags found.
If END needs to be extended due to a lexical token being too large, it
will be silently ignored.

Optional arguments:
NONTERMINAL is the rule to start parsing at.
DEPTH specifies the lexical depth to decend for parser that use
lexical analysis as their first step.
RETURNONERROR specifies that parsing should stop on the first
unmatched syntax encountered.  When nil, parsing skips the syntax,
adding it to the unmatched syntax cache.

Must return a list of semantic tags wich have been cooked
\(repositioned properly) but which DO NOT HAVE OVERLAYS associated
with them.  When overloading this function, use `semantic--tag-expand'
to cook raw tags."))

(progn
  (defun semantic-parse-region (start end
                                &optional
                                nonterminal
                                depth
                                returnonerror)
    "Parse the area between START and END, and return any tags found.
If END needs to be extended due to a lexical token being too large, it
will be silently ignored.

Optional arguments:
NONTERMINAL is the rule to start parsing at.
DEPTH specifies the lexical depth to decend for parser that use
lexical analysis as their first step.
RETURNONERROR specifies that parsing should stop on the first
unmatched syntax encountered.  When nil, parsing skips the syntax,
adding it to the unmatched syntax cache.

Must return a list of semantic tags wich have been cooked
(repositioned properly) but which DO NOT HAVE OVERLAYS associated
with them.  When overloading this function, use `semantic--tag-expand'
to cook raw tags."
 (let ((override (fetch-overload 'semantic-parse-region)))
 (if override
 (funcall override start end nonterminal depth returnonerror)
 (semantic-parse-region-default start end nonterminal depth returnonerror))))
 (put 'semantic-parse-region 'mode-local-overload t))nil


(defun semantic-read-event ()
        (let ((event (next-command-event)))
          (if (key-press-event-p event)
              (let ((c (event-to-character event)))
                (if (char-equal c (quit-char))
                    (keyboard-quit)
                  c)))
          event))


(global-set-key "\C-x\C-c" (kb-lambda (ding) (dmessage "disabled")))
nil

nil

-----------------------------------------------------------------------------
(cl-pe '(define-lex semantic-grammar-lexer
  "Lexical analyzer that handles Semantic grammar buffers.
It ignores whitespaces, newlines and comments."
  semantic-lex-ignore-newline
  semantic-lex-ignore-whitespace
  ;; Must detect prologue/epilogue before other symbols/keywords!
  semantic-grammar-lex-prologue
  semantic-grammar-lex-epilogue
  semantic-grammar-wy--<keyword>-keyword-analyzer
  semantic-grammar-wy--<symbol>-regexp-analyzer
  semantic-grammar-wy--<char>-regexp-analyzer
  semantic-grammar-wy--<string>-sexp-analyzer
  ;; Must detect comments after strings because `comment-start-skip'
  ;; regexp match semicolons inside strings!
  semantic-lex-ignore-comments
  ;; Must detect prefixed list before punctuation because prefix chars
  ;; are also punctuations!
  semantic-grammar-wy--<qlist>-sexp-analyzer
  ;; Must detect punctuations after comments because the semicolon can
  ;; be a punctuation or a comment start!
  semantic-grammar-wy--<punctuation>-string-analyzer
  semantic-grammar-wy--<block>-block-analyzer
  semantic-grammar-wy--<sexp>-sexp-analyzer
  ))

<:step2: lexer:>
(defun semantic-grammar-lexer (start end &optional depth length)
  "Lexical analyzer that handles Semantic grammar buffers.
It ignores whitespaces, newlines and comments.
See `semantic-lex' for more information."
  (setq semantic-lex-block-streams nil)
  (run-hook-with-args 'semantic-lex-reset-hooks start end)
  (let* ((starting-position (point))
         (semantic-lex-token-stream nil)
         (semantic-lex-block-stack nil)
         (tmp-start start)
         (semantic-lex-end-point start)
         (semantic-lex-current-depth 0)
         (semantic-lex-maximum-depth (or depth semantic-lex-depth))
         (semantic-lex-analysis-bounds (cons start end))
         (parse-sexp-lookup-properties nil))
    (if (> end (point-max))
        (error "semantic-grammar-lexer: end (%d) > point-max (%d)"
               end
               (point-max)))
    (let ((table (syntax-table))
          (buffer (current-buffer)))
      (unwind-protect
          (progn
            (set-syntax-table (copy-syntax-table semantic-lex-syntax-table))
            (goto-char start)
            (while (and (< (point) end)
                        (or (not length)
                            (<= (length semantic-lex-token-stream) length)))
              (cond ((looking-at "\\s-*\\(
\\|\\s>\\)")
                     (setq semantic-lex-end-point (match-end 0)))
                    ((looking-at "\\s-+")
                     (setq semantic-lex-end-point (match-end 0)))
                    ((looking-at "\\<%{")
                     (progn
                       (setq semantic-lex-token-stream (cons (cons 'PROLOGUE
                                                                   (cons (point)
                                                                         (save-excursion (if (and debug-on-error
                                                                                                  semantic-lex-debug-analyzers)
                                                                                             (progn
                                                                                               (forward-char)
                                                                                               (forward-sexp 1)
                                                                                               (point))
                                                                                           (condition-case nil
                                                                                               (progn
                                                                                                 (forward-char)
                                                                                                 (forward-sexp 1)
                                                                                                 (point))
                                                                                             (error (semantic-lex-unterminated-syntax-detected 'PROLOGUE)))))))
                                                             semantic-lex-token-stream))
                       (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))
                    ((looking-at "\\<%%\\>")
                     (let ((start (match-beginning 0))
                           (end (match-end 0))
                           (class 'PERCENT_PERCENT))
                       (if (>= start (semantic-grammar-epilogue-start))
                           (setq class 'EPILOGUE end (point-max)))
                       (progn
                         (setq semantic-lex-token-stream (cons (cons class
                                                                     (cons start
                                                                           end))
                                                               semantic-lex-token-stream))
                         (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream))))))
                    ((and (looking-at "\\(\\sw\\|\\s_\\)+")
                          (let ((key (semantic-lex-keyword-p (match-string 0))))
                            (if key
                                (progn
                                  (setq semantic-lex-token-stream (cons (cons key
                                                                              (cons (match-beginning 0)
                                                                                    (match-end 0)))
                                                                        semantic-lex-token-stream))
                                  (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream))))))))
                    ((and (looking-at ":?\\(\\sw\\|\\s_\\)+")
                          (let* ((val (match-string 0))
                                 (pos (match-beginning 0))
                                 (end (match-end 0))
                                 (lst '((PERCENT_PERCENT . "\\`%%\\'")))
                                 elt)
                            (while (and lst (not elt))
                              (if (string-match (cdar lst) val)
                                  (setq elt (caar lst))
                                (setq lst (cdr lst))))
                            (progn
                              (setq semantic-lex-token-stream (cons (cons (or elt
                                                                              'SYMBOL)
                                                                          (cons pos
                                                                                end))
                                                                    semantic-lex-token-stream))
                              (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))))
                    ((looking-at semantic-grammar-lex-c-char-re)
                     (progn
                       (setq semantic-lex-token-stream (cons (cons 'CHARACTER
                                                                   (cons (match-beginning 0)
                                                                         (match-end 0)))
                                                             semantic-lex-token-stream))
                       (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))
                    ((looking-at "\\s\"")
                     (progn
                       (setq semantic-lex-token-stream (cons (cons 'STRING
                                                                   (cons (point)
                                                                         (save-excursion (if (and debug-on-error
                                                                                                  semantic-lex-debug-analyzers)
                                                                                             (progn
                                                                                               (forward-sexp 1)
                                                                                               (point))
                                                                                           (condition-case nil
                                                                                               (progn
                                                                                                 (forward-sexp 1)
                                                                                                 (point))
                                                                                             (error (semantic-lex-unterminated-syntax-detected 'STRING)))))))
                                                             semantic-lex-token-stream))
                       (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))
                    ((looking-at semantic-lex-comment-regex)
                     (let ((comment-start-point (point)))
                       (forward-comment 1)
                       (if (eq (point) comment-start-point)
                           (skip-syntax-forward "-.'"
                                                (save-excursion (end-of-line)
                                                                (point)))
                         (if (bolp) (backward-char 1)))
                       (if (eq (point) comment-start-point)
                           (error "Strange comment syntax prevents lexical analysis"))
                       (setq semantic-lex-end-point (point))))
                    ((looking-at "\\s'\\s-*(")
                     (progn
                       (setq semantic-lex-token-stream (cons (cons 'PREFIXED_LIST
                                                                   (cons (point)
                                                                         (save-excursion (if (and debug-on-error
                                                                                                  semantic-lex-debug-analyzers)
                                                                                             (progn
                                                                                               (forward-sexp 1)
                                                                                               (point))
                                                                                           (condition-case nil
                                                                                               (progn
                                                                                                 (forward-sexp 1)
                                                                                                 (point))
                                                                                             (error (semantic-lex-unterminated-syntax-detected 'PREFIXED_LIST)))))))
                                                             semantic-lex-token-stream))
                       (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))
                    ((and (looking-at "\\(\\s.\\|\\s$\\|\\s'\\)+")
                          (let* ((val (match-string 0))
                                 (pos (match-beginning 0))
                                 (end (match-end 0))
                                 (len (- end pos))
                                 (lst '((GT . ">") (LT . "<") (OR . "|") (SEMI . ";") (COLON . ":")))
                                 elt)
                            (while (and (> len 0)
                                        (not (setq elt (rassoc val lst))))
                              (setq len (1- len) val (substring val 0 len)))
                            (if elt (setq elt (car elt) end (+ pos len)))
                            (progn
                              (setq semantic-lex-token-stream (cons (cons (or elt
                                                                              'punctuation)
                                                                          (cons pos
                                                                                end))
                                                                    semantic-lex-token-stream))
                              (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))))
                    ((and (looking-at "\\s(\\|\\s)")
                          (let ((val (match-string 0))
                                (lst '((("(" LPAREN PAREN_BLOCK) ("{" LBRACE BRACE_BLOCK)) (")" RPAREN) ("}" RBRACE)))
                                elt)
                            (cond ((setq elt (assoc val (car lst)))
                                   (if (or (not semantic-lex-maximum-depth)
                                           (< semantic-lex-current-depth
                                              semantic-lex-maximum-depth))
                                       (progn
                                         (setq semantic-lex-current-depth (1+ semantic-lex-current-depth))
                                         (progn
                                           (setq semantic-lex-token-stream (cons (cons (nth 1
                                                                                            elt)
                                                                                       (cons (match-beginning 0)
                                                                                             (match-end 0)))
                                                                                 semantic-lex-token-stream))
                                           (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))
                                     (progn
                                       (setq semantic-lex-token-stream (cons (cons (nth 2
                                                                                        elt)
                                                                                   (cons (match-beginning 0)
                                                                                         (save-excursion (if (and debug-on-error
                                                                                                                  semantic-lex-debug-analyzers)
                                                                                                             (progn
                                                                                                               (forward-list 1)
                                                                                                               (point))
                                                                                                           (condition-case nil
                                                                                                               (progn
                                                                                                                 (forward-list 1)
                                                                                                                 (point))
                                                                                                             (error (semantic-lex-unterminated-syntax-detected (nth 2
                                                                                                                                                                    elt))))))))
                                                                             semantic-lex-token-stream))
                                       (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream))))))
                                  ((setq elt (assoc val (cdr lst)))
                                   (setq semantic-lex-current-depth (1- semantic-lex-current-depth))
                                   (progn
                                     (setq semantic-lex-token-stream (cons (cons (nth 1
                                                                                      elt)
                                                                                 (cons (match-beginning 0)
                                                                                       (match-end 0)))
                                                                           semantic-lex-token-stream))
                                     (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream)))))))))
                    ((looking-at "\\=")
                     (progn
                       (setq semantic-lex-token-stream (cons (cons 'SEXP
                                                                   (cons (point)
                                                                         (save-excursion (if (and debug-on-error
                                                                                                  semantic-lex-debug-analyzers)
                                                                                             (progn
                                                                                               (forward-sexp 1)
                                                                                               (point))
                                                                                           (condition-case nil
                                                                                               (progn
                                                                                                 (forward-sexp 1)
                                                                                                 (point))
                                                                                             (error (semantic-lex-unterminated-syntax-detected 'SEXP)))))))
                                                             semantic-lex-token-stream))
                       (setq semantic-lex-end-point (semantic-lex-token-end (car semantic-lex-token-stream))))))
              (if (eq semantic-lex-end-point tmp-start)
                  (error "semantic-grammar-lexer: endless loop at %d, after %S"
                         tmp-start
                         (car semantic-lex-token-stream)))
              (setq tmp-start semantic-lex-end-point)
              (goto-char semantic-lex-end-point)
              (semantic-lex-debug-break (car semantic-lex-token-stream))))
        (save-current-buffer (set-buffer buffer) (set-syntax-table table))))
    (if semantic-lex-block-stack
        (let* ((last (car (prog1
                              semantic-lex-block-stack
                            (setq semantic-lex-block-stack (cdr semantic-lex-block-stack)))))
               (blk last))
          (while blk
            (message "semantic-grammar-lexer: `%s' block from %S is unterminated"
                     (car blk)
                     (cadr blk))
            (setq blk (car (prog1
                               semantic-lex-block-stack
                             (setq semantic-lex-block-stack (cdr semantic-lex-block-stack))))))
          (semantic-lex-unterminated-syntax-detected (car last))))
    (goto-char starting-position)
    (nreverse semantic-lex-token-stream)))

<:step3 build:>
(semantic-grammar-batch-build-packages)

!!!!!!!!!!!! syntax-table is hosing lexer

semantic-grammar-syntax-table
#s(char-table type syntax data (?\n 524300 ?\" 7 ?\# 6 ?% 2 ?\' 6 ?\, 6 ?- 3 ?\. 3 ?: 1 ?\; 10485761 ?< 1 ?> 1 ?\\ 9 ?\` 6 ?| 1))

#s(char-table type syntax data (?\n 524300 ?\" 7 ?\# 6 ?% 2 ?\' 6 ?\, 6 ?- 3 ?\. 3 ?: 1 ?\; 10485761 ?< 1 ?> 1 ?\\ 9 ?\` 6 ?| 1))

semantic-lex-syntax-table
nil
dp-st                                   ; semantic-lex-syntax-table in WY mode buffer
#s(char-table type syntax data (?\n 524300 ?\" 7 ?\# 6 ?% 2 ?\' 6 ?\, 6 ?- 3 ?\. 3 ?: 1 ?\; 10485761 ?< 1 ?> 1 ?\\ 9 ?\` 6 ?| 1))



(describe-syntax-table semantic-grammar-syntax-table standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t

(describe-syntax-table (standard-syntax-table) standard-output)
^@ ..  	  	meaning: whitespace
!	. 	meaning: punctuation
"	" 	meaning: string-quote
#	. 	meaning: punctuation
$ .. %	w 	meaning: word-constituent
&	_ 	meaning: symbol-constituent
'	. 	meaning: punctuation
(	()	meaning: open-paren, matches )
)	)(	meaning: close-paren, matches (
* .. +	_ 	meaning: symbol-constituent
,	. 	meaning: punctuation
-	_ 	meaning: symbol-constituent
.	. 	meaning: punctuation
/	_ 	meaning: symbol-constituent
0 .. 9	w 	meaning: word-constituent
: .. ;	. 	meaning: punctuation
< .. >	_ 	meaning: symbol-constituent
? .. @	. 	meaning: punctuation
A .. Z	w 	meaning: word-constituent
[	(]	meaning: open-paren, matches ]
\	\ 	meaning: escape
]	)[	meaning: close-paren, matches [
^	. 	meaning: punctuation
_	_ 	meaning: symbol-constituent
`	. 	meaning: punctuation
a .. z	w 	meaning: word-constituent
{	(}	meaning: open-paren, matches }
|	_ 	meaning: symbol-constituent
}	){	meaning: close-paren, matches {
~	. 	meaning: punctuation
^?	  	meaning: whitespace
\200 .. \237	  	meaning: whitespace
-A 	_ 	meaning: symbol-constituent
-A!	. 	meaning: punctuation
-A" .. *	_ 	meaning: symbol-constituent
-A+	(;	meaning: open-paren, matches ;
-A, .. :	_ 	meaning: symbol-constituent
-A;	)+	meaning: close-paren, matches +
-A< .. ?	_ 	meaning: symbol-constituent
-A@ .. V	w 	meaning: word-constituent
-AW	_ 	meaning: symbol-constituent
-AX .. v	w 	meaning: word-constituent
-Aw	_ 	meaning: symbol-constituent
-Ax .. 	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
katakana-jisx0201	w 	meaning: word-constituent
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	. 	meaning: punctuation
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~	. 	meaning: punctuation
~ .. ~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~	( 	meaning: open-paren
~ .. ~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~	) 	meaning: close-paren
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
chinese-gb2312, rows 33 .. 34	. 	meaning: punctuation
chinese-gb2312, rows 35 .. 40	w 	meaning: word-constituent
chinese-gb2312, row 41	. 	meaning: punctuation
chinese-gb2312, rows 42 .. 126	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~	(~	meaning: open-paren, matches ~
~	)~	meaning: close-paren, matches ~
~ .. ~	_ 	meaning: symbol-constituent
~	(~	meaning: open-paren, matches ~
~	)~	meaning: close-paren, matches ~
~	(~	meaning: open-paren, matches ~
~	)~	meaning: close-paren, matches ~
~ .. ~	_ 	meaning: symbol-constituent
~	(~	meaning: open-paren, matches ~
~	)~	meaning: close-paren, matches ~
~	(~	meaning: open-paren, matches ~
~	)~	meaning: close-paren, matches ~
~ .. ~	_ 	meaning: symbol-constituent
japanese-jisx0208, row 34	_ 	meaning: symbol-constituent
japanese-jisx0208, rows 35 .. 39	w 	meaning: word-constituent
japanese-jisx0208, row 40	_ 	meaning: symbol-constituent
japanese-jisx0208, rows 41 .. 126	w 	meaning: word-constituent
korean-ksc5601, rows 33 .. 34	. 	meaning: punctuation
korean-ksc5601, rows 35 .. 37	w 	meaning: word-constituent
korean-ksc5601, rows 38 .. 41	. 	meaning: punctuation
korean-ksc5601, rows 42 .. 126	w 	meaning: word-constituent
japanese-jisx0212	w 	meaning: word-constituent
chinese-cns11643-1	w 	meaning: word-constituent
chinese-cns11643-2	w 	meaning: word-constituent
chinese-big5-1	w 	meaning: word-constituent
chinese-big5-2	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~	" 	meaning: string-quote
~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~	w 	meaning: word-constituent
~	(~	meaning: open-paren, matches ~
~	w 	meaning: word-constituent
~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~ .. ~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	" 	meaning: string-quote
~ .. ~	_ 	meaning: symbol-constituent
~ .. ~	w 	meaning: word-constituent
~	)~	meaning: close-paren, matches ~
~ .. ~	w 	meaning: word-constituent
vietnamese-viscii-upper	w 	meaning: word-constituent
vietnamese-viscii-lower	w 	meaning: word-constituent
chinese-cns11643-3	w 	meaning: word-constituent
chinese-cns11643-4	w 	meaning: word-constituent
chinese-cns11643-5	w 	meaning: word-constituent
chinese-cns11643-6	w 	meaning: word-constituent
chinese-cns11643-7	w 	meaning: word-constituent
thai-xtis, rows 33 .. 78	w 	meaning: word-constituent
thai-xtis, row 79	_ 	meaning: symbol-constituent
thai-xtis, row 80	w 	meaning: word-constituent
thai-xtis, rows 82 .. 83	w 	meaning: word-constituent
thai-xtis, row 95	_ 	meaning: symbol-constituent
thai-xtis, rows 96 .. 101	w 	meaning: word-constituent
thai-xtis, row 102	_ 	meaning: symbol-constituent
thai-xtis, row 111	_ 	meaning: symbol-constituent
thai-xtis, rows 112 .. 121	w 	meaning: word-constituent
thai-xtis, rows 122 .. 123	_ 	meaning: symbol-constituent
t


(describe-syntax-table dp-st-in-lex-debug standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t

#s(char-table type syntax data (?\n 524300 ?\" 7 ?\# 6 ?% 2 ?\' 6 ?\, 6 ?- 3 ?\. 3 ?: 1 ?\; 10485761 ?< 1 ?> 1 ?\\ 9 ?\` 6 ?| 1))

(describe-syntax-table dp-st-not-in-lex-debug standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t

#s(char-table type syntax data (?\n 524300 ?\" 7 ?\# 6 ?% 2 ?\' 6 ?\, 6 ?- 3 ?\. 3 ?: 1 ?\; 10485761 ?< 1 ?> 1 ?\\ 9 ?\` 6 ?| 1))



(describe-syntax-table semantic-grammar-syntax-table standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t


(describe-syntax-table bubba standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t


(describe-syntax-table bubba standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t


========================
Monday August 06 2007
--


(progn
  (defun dpf ()
    (message "1")
    (message "2"))
  (edebug-on-entry 'dpf)
  (dpf))
"2"


:(cfl "semantic.el" 12032 "^    (semantic-lex-init)"):
:(cfl "semantic-lex.el" 31060 "^(defun semantic-lex-init ()"):
:(cfl "semantic-grammar.el" 2977 "^  (semantic-lex-init)"):


(map-syntax-table (lambda (key val)
                   (princf "key: %s \t==> val: %s\n" key val))
                  G-lex-table
                  )
key: ?\n 	==> val: 524300
key: ?\" 	==> val: 7
key: ?\# 	==> val: 6
key: ?% 	==> val: 2
key: ?\' 	==> val: 6
key: ?\, 	==> val: 6
key: ?- 	==> val: 3
key: ?\. 	==> val: 3
key: ?: 	==> val: 1
key: ?\; 	==> val: 10485761
key: ?< 	==> val: 1
key: ?> 	==> val: 1
key: ?\\ 	==> val: 9
key: ?\` 	==> val: 6
key: ?| 	==> val: 1
nil


(map-syntax-table (lambda (key val)
                   (princf "key: %s \t==> val: %s\n" key val))
                  G-table
                  )
key: ?\n 	==> val: 524300
key: ?\" 	==> val: 7
key: ?\# 	==> val: 6
key: ?% 	==> val: 2
key: ?\' 	==> val: 6
key: ?\, 	==> val: 6
key: ?- 	==> val: 3
key: ?\. 	==> val: 3
key: ?: 	==> val: 1
key: ?\; 	==> val: 10485761
key: ?< 	==> val: 1
key: ?> 	==> val: 1
key: ?\\ 	==> val: 9
key: ?\` 	==> val: 6
key: ?| 	==> val: 1
nil


(char-syntax ?, G-table)
?\'

(char-syntax ?$ G-lex-table)
?w

?w


?w

?w

(describe-syntax-table G-lex-table standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t


(describe-syntax-table G-table standard-output)
^J	>  	meaning: comment-end, style A
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
%	w 	meaning: word-constituent
'	' 	meaning: expression-prefix
,	' 	meaning: expression-prefix
- .. .	_ 	meaning: symbol-constituent
:	. 	meaning: punctuation
;	. 12	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-start sequence A
<	. 	meaning: punctuation
>	. 	meaning: punctuation
\	\ 	meaning: escape
`	' 	meaning: expression-prefix
|	. 	meaning: punctuation
t

(describe-syntax-code ?w standard-output)
**invalid**"**invalid**"

(let ((features (copy-seq features)))
  (setq features (delq 'mule features))
  (char-syntax ?, G-lex-table))
?w

?w

(featurep 'mule)
t


(setq v (make-vector 256 1))
[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]

(syntax-table-p v)
nil

(char-table-type G-lex-table)
syntax


(mirror-syntax-table (get-buffer "semantic-grammar.wy"))

(setq s (make-syntax-table 'sklsjkjd))
#s(char-table type syntax data ())

(char-syntax ?, s)
?\.


#s(char-table type syntax data ())

#s(char-table type syntax data ())


G-table
#s(char-table type syntax data (?\n 524300 ?\" 7 ?\# 6 ?% 2 ?\' 6 ?\, 6 ?- 3 ?\. 3 ?: 1 ?\; 10485761 ?< 1 ?> 1 ?\\ 9 ?\` 6 ?| 1))
G-lex-table
#s(char-table type syntax data 
(?\n 524300 
     ?\" 7 
     ?\# 6 
     ?% 2 
     ?\' 6 
     ?\, 6 
     ?- 3 
     ?\. 3 
     ?: 1 
     ?\; 10485761 
     ?< 1 
     ?> 1 
     ?\\ 9 
     ?\` 6 
     ?| 1))

(char-syntax ?, G-table)
(char-syntax ?, G-lex-table)


(let ((n 0))
  (while (< n 256)
    (princf "%s \y==> %s\t==> %s\n" (int-char n)
            (char-syntax (int-char n) G-lex-table)
            (char-syntax (int-char n) G-table))
    (setq n (1+ n))))
?\^@ y==> ?w	==> ?\ 
?\^A y==> ?w	==> ?\ 
?\^B y==> ?w	==> ?\ 
?\^C y==> ?w	==> ?\ 
?\^D y==> ?w	==> ?\ 
?\^E y==> ?w	==> ?\ 
?\^F y==> ?w	==> ?\ 
?\^G y==> ?w	==> ?\ 
?\^H y==> ?w	==> ?\ 
?\t y==> ?w	==> ?\ 
?\n y==> ?w	==> ?>
?\^K y==> ?w	==> ?\ 
?\^L y==> ?w	==> ?\ 
?\r y==> ?w	==> ?\ 
?\^N y==> ?w	==> ?\ 
?\^O y==> ?w	==> ?\ 
?\^P y==> ?w	==> ?\ 
?\^Q y==> ?w	==> ?\ 
?\^R y==> ?w	==> ?\ 
?\^S y==> ?w	==> ?\ 
?\^T y==> ?w	==> ?\ 
?\^U y==> ?w	==> ?\ 
?\^V y==> ?w	==> ?\ 
?\^W y==> ?w	==> ?\ 
?\^X y==> ?w	==> ?\ 
?\^Y y==> ?w	==> ?\ 
?\^Z y==> ?w	==> ?\ 
?\^[ y==> ?w	==> ?\ 
?\^\\ y==> ?w	==> ?\ 
?\^] y==> ?w	==> ?\ 
?\^^ y==> ?w	==> ?\ 
?\^_ y==> ?w	==> ?\ 
?\  y==> ?w	==> ?\ 
?! y==> ?w	==> ?\.
?\" y==> ?w	==> ?\"
?\# y==> ?w	==> ?\'
?$ y==> ?w	==> ?w
?% y==> ?w	==> ?w
?& y==> ?w	==> ?_
?\' y==> ?w	==> ?\'
?\( y==> ?w	==> ?\(
?\) y==> ?w	==> ?\)
?* y==> ?w	==> ?_
?+ y==> ?w	==> ?_
?\, y==> ?w	==> ?\'
?- y==> ?w	==> ?_
?\. y==> ?w	==> ?_
?/ y==> ?w	==> ?_
?0 y==> ?w	==> ?w
?1 y==> ?w	==> ?w
?2 y==> ?w	==> ?w
?3 y==> ?w	==> ?w
?4 y==> ?w	==> ?w
?5 y==> ?w	==> ?w
?6 y==> ?w	==> ?w
?7 y==> ?w	==> ?w
?8 y==> ?w	==> ?w
?9 y==> ?w	==> ?w
?: y==> ?w	==> ?\.
?\; y==> ?w	==> ?\.
?< y==> ?w	==> ?\.
?= y==> ?w	==> ?_
?> y==> ?w	==> ?\.
?\? y==> ?w	==> ?\.
?@ y==> ?w	==> ?\.
?A y==> ?w	==> ?w
?B y==> ?w	==> ?w
?C y==> ?w	==> ?w
?D y==> ?w	==> ?w
?E y==> ?w	==> ?w
?F y==> ?w	==> ?w
?G y==> ?w	==> ?w
?H y==> ?w	==> ?w
?I y==> ?w	==> ?w
?J y==> ?w	==> ?w
?K y==> ?w	==> ?w
?L y==> ?w	==> ?w
?M y==> ?w	==> ?w
?N y==> ?w	==> ?w
?O y==> ?w	==> ?w
?P y==> ?w	==> ?w
?Q y==> ?w	==> ?w
?R y==> ?w	==> ?w
?S y==> ?w	==> ?w
?T y==> ?w	==> ?w
?U y==> ?w	==> ?w
?V y==> ?w	==> ?w
?W y==> ?w	==> ?w
?X y==> ?w	==> ?w
?Y y==> ?w	==> ?w
?Z y==> ?w	==> ?w
?\[ y==> ?w	==> ?\(
?\\ y==> ?w	==> ?\\
?\] y==> ?w	==> ?\)
?^ y==> ?w	==> ?\.
?_ y==> ?w	==> ?_
?\` y==> ?w	==> ?\'
?a y==> ?w	==> ?w
?b y==> ?w	==> ?w
?c y==> ?w	==> ?w
?d y==> ?w	==> ?w
?e y==> ?w	==> ?w
?f y==> ?w	==> ?w
?g y==> ?w	==> ?w
?h y==> ?w	==> ?w
?i y==> ?w	==> ?w
?j y==> ?w	==> ?w
?k y==> ?w	==> ?w
?l y==> ?w	==> ?w
?m y==> ?w	==> ?w
?n y==> ?w	==> ?w
?o y==> ?w	==> ?w
?p y==> ?w	==> ?w
?q y==> ?w	==> ?w
?r y==> ?w	==> ?w
?s y==> ?w	==> ?w
?t y==> ?w	==> ?w
?u y==> ?w	==> ?w
?v y==> ?w	==> ?w
?w y==> ?w	==> ?w
?x y==> ?w	==> ?w
?y y==> ?w	==> ?w
?z y==> ?w	==> ?w
?{ y==> ?w	==> ?\(
?| y==> ?w	==> ?\.
?} y==> ?w	==> ?\)
?~ y==> ?w	==> ?\.
?\^? y==> ?w	==> ?\ 
?\^-A@ y==> ?w	==> ?\ 
?\^-AA y==> ?w	==> ?\ 
?\^-AB y==> ?w	==> ?\ 
?\^-AC y==> ?w	==> ?\ 
?\^-AD y==> ?w	==> ?\ 
?\^-AE y==> ?w	==> ?\ 
?\^-AF y==> ?w	==> ?\ 
?\^-AG y==> ?w	==> ?\ 
?\^-AH y==> ?w	==> ?\ 
?\^-AI y==> ?w	==> ?\ 
?\^-AJ y==> ?w	==> ?\ 
?\^-AK y==> ?w	==> ?\ 
?\^-AL y==> ?w	==> ?\ 
?\^-AM y==> ?w	==> ?\ 
?\^-AN y==> ?w	==> ?\ 
?\^-AO y==> ?w	==> ?\ 
?\^-AP y==> ?w	==> ?\ 
?\^-AQ y==> ?w	==> ?\ 
?\^-AR y==> ?w	==> ?\ 
?\^-AS y==> ?w	==> ?\ 
?\^-AT y==> ?w	==> ?\ 
?\^-AU y==> ?w	==> ?\ 
?\^-AV y==> ?w	==> ?\ 
?\^-AW y==> ?w	==> ?\ 
?\^-AX y==> ?w	==> ?\ 
?\^-AY y==> ?w	==> ?\ 
?\^-AZ y==> ?w	==> ?\ 
?\^-A[ y==> ?w	==> ?\ 
?\^-A\ y==> ?w	==> ?\ 
?\^-A] y==> ?w	==> ?\ 
?\^-A^ y==> ?w	==> ?\ 
?\^-A_ y==> ?w	==> ?\ 
?-A  y==> ?w	==> ?_
?-A! y==> ?w	==> ?\.
?-A" y==> ?w	==> ?_
?-A# y==> ?w	==> ?_
?-A$ y==> ?w	==> ?_
?-A% y==> ?w	==> ?_
?-A& y==> ?w	==> ?_
?-A' y==> ?w	==> ?_
?-A( y==> ?w	==> ?_
?-A) y==> ?w	==> ?_
?-A* y==> ?w	==> ?_
?-A+ y==> ?w	==> ?\(
?-A, y==> ?w	==> ?_
?-A- y==> ?w	==> ?_
?-A. y==> ?w	==> ?_
?-A/ y==> ?w	==> ?_
?-A0 y==> ?w	==> ?_
?-A1 y==> ?w	==> ?_
?-A2 y==> ?w	==> ?_
?-A3 y==> ?w	==> ?_
?-A4 y==> ?w	==> ?_
?-A5 y==> ?w	==> ?_
?-A6 y==> ?w	==> ?_
?-A7 y==> ?w	==> ?_
?-A8 y==> ?w	==> ?_
?-A9 y==> ?w	==> ?_
?-A: y==> ?w	==> ?_
?-A; y==> ?w	==> ?\)
?-A< y==> ?w	==> ?_
?-A= y==> ?w	==> ?_
?-A> y==> ?w	==> ?_
?-A? y==> ?w	==> ?_
?-A@ y==> ?w	==> ?w
?-AA y==> ?w	==> ?w
?-AB y==> ?w	==> ?w
?-AC y==> ?w	==> ?w
?-AD y==> ?w	==> ?w
?-AE y==> ?w	==> ?w
?-AF y==> ?w	==> ?w
?-AG y==> ?w	==> ?w
?-AH y==> ?w	==> ?w
?-AI y==> ?w	==> ?w
?-AJ y==> ?w	==> ?w
?-AK y==> ?w	==> ?w
?-AL y==> ?w	==> ?w
?-AM y==> ?w	==> ?w
?-AN y==> ?w	==> ?w
?-AO y==> ?w	==> ?w
?-AP y==> ?w	==> ?w
?-AQ y==> ?w	==> ?w
?-AR y==> ?w	==> ?w
?-AS y==> ?w	==> ?w
?-AT y==> ?w	==> ?w
?-AU y==> ?w	==> ?w
?-AV y==> ?w	==> ?w
?-AW y==> ?w	==> ?_
?-AX y==> ?w	==> ?w
?-AY y==> ?w	==> ?w
?-AZ y==> ?w	==> ?w
?-A[ y==> ?w	==> ?w
?-A\ y==> ?w	==> ?w
?-A] y==> ?w	==> ?w
?-A^ y==> ?w	==> ?w
?-A_ y==> ?w	==> ?w
?-A` y==> ?w	==> ?w
?-Aa y==> ?w	==> ?w
?-Ab y==> ?w	==> ?w
?-Ac y==> ?w	==> ?w
?-Ad y==> ?w	==> ?w
?-Ae y==> ?w	==> ?w
?-Af y==> ?w	==> ?w
?-Ag y==> ?w	==> ?w
?-Ah y==> ?w	==> ?w
?-Ai y==> ?w	==> ?w
?-Aj y==> ?w	==> ?w
?-Ak y==> ?w	==> ?w
?-Al y==> ?w	==> ?w
?-Am y==> ?w	==> ?w
?-An y==> ?w	==> ?w
?-Ao y==> ?w	==> ?w
?-Ap y==> ?w	==> ?w
?-Aq y==> ?w	==> ?w
?-Ar y==> ?w	==> ?w
?-As y==> ?w	==> ?w
?-At y==> ?w	==> ?w
?-Au y==> ?w	==> ?w
?-Av y==> ?w	==> ?w
?-Aw y==> ?w	==> ?_
?-Ax y==> ?w	==> ?w
?-Ay y==> ?w	==> ?w
?-Az y==> ?w	==> ?w
?-A{ y==> ?w	==> ?w
?-A| y==> ?w	==> ?w
?-A} y==> ?w	==> ?w
?-A~ y==> ?w	==> ?w
?-A y==> ?w	==> ?w
nil

const unsigned char syntax_code_spec[] =  " .w_()'\"$\\/<>@!|";


(defun dp-grep-var-names (symbol-name-regexp)
  (interactive "ssymbol name regexp: ")
  (when (and (interactive-p) current-prefix-arg)
    (setq symbol-name-regexp (car (dp-prompt-with-symbol-near-point-as-default
                                   "symbol name regexp"))))
  (let (matches)
    (mapatoms 
     (function (lambda (atom)
                 (when (and (if symbol-name-regexp
                                (string-match symbol-name-regexp 
                                              (format "%s" atom))
                              t)
                            (boundp atom))
                   (setq matches (cons atom matches))))))
    matches))

(dp-grep-var-names nil "firefox")

(dp-grep-string-vars "firefox")
((browse-url-firefox-program "firefox") (dabbrev--last-expansion "firefox") (debugger-previous-backtrace "Debugger entered--Lisp error: (void-function dp-grep-var-names)
  (dp-grep-var-names nil \"firefox\")
  eval((dp-grep-var-names nil \"firefox\"))
  eval-interactive((dp-grep-var-names nil \"firefox\"))
  eval-last-sexp(t)
  #<compiled-function nil \"...(13)\" [standard-output terpri eval-last-sexp t] 2 1223620 nil>()
  call-interactively(eval-print-last-sexp)
"))




(cl-pe '(let ((default nil)
              (default-args nil))
         (dp-apply-if 
             default default-args
           default)))

(let ((default 'dp-nop)
      (default-args '(nil)))
  (if (functionp default) 
      (apply default default-args) 
    default))
(nil)

nil


nil




(let ((default nil)
      (default-args t))
  (if (functionp default) (apply default default-args) default))nil




(progn
  (lisp-interaction-mode)
  (font-lock-set-defaults))

(define-key read-expression-map [(control tab)

(defun* dp-get-buffer-local-value (&optional var buffer 
                                   &key (pred 'dp-nilop)
                                   (default nil)
                                   (default-args nil))
  (interactive "svar: \nbbuffer: ")
  (with-current-buffer (if buffer
                           (get-buffer buffer)
                         (current-buffer))
    
    (setq default (dp-apply-if 
                      default default-args
                    default))
    (cond
     ((and (symbolp var)
              (boundp var))
      (symbol-value var))
     ((not var) default)
     ((funcall pred var) var)
     ((stringp var)
      (if (string= var "") 
          default
        (setq var (intern-soft var))
        (if var
            (setq var (symbol-value var))
          (error (format "var not found: %s" var)))))
     ;; Or do we just want to return var here?
     (t var)
     (nil (error (format "can't figure out what var >%s< is." var))))))


(defun dp-get-buffer-local-syntax-table (&optional tab buffer)
  (interactive "ssyntax-table name: \nbbuffer: ")
  (dp-get-buffer-local-value tab buffer
                             :pred 'syntax-table-p
                             :default 'syntax-table))
                             


(defalias 'dpf 'dp-get-buffer-local-syntax-table)
dp-get-buffer-local-syntax-table


(dpf "semantic-lex-original-syntax-table" "semantic-lex.el")

(dpf 'yadda "semantic-lex.el")
yadda

(dp-get-buffer-local-value 'buffer-file-truename "semantic-lex.el" 
                           :default 'eval
                           :default-args '(buffer-file-truename))



lisp-interaction-mode



(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x34b4725>0x34b4723> dp-buffer-endicator t) [raw:#<extent [1, 342420]* dp-buffer-endicator 0x98768d0 in buffer dpmisc.el>]

(detachable t end-open t text-prop lazy-lock lazy-lock t) [raw:#<extent [236424, 245907) lazy-lock text-prop 0x9776a14 in buffer dpmisc.el>]

(detachable t end-open t face font-lock-comment-face text-prop face) [raw:#<extent [239766, 239864) text-prop 0x90f92dc in buffer dpmisc.el>]

(detachable t end-open t text-prop font-lock font-lock t) [raw:#<extent [239766, 239864) font-lock text-prop 0x90f9288 in buffer dpmisc.el>]

(detachable t end-open t face dp-highlight-point-before-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent [239766, 239830) dp-extent dp-extent-id dp-sel2-arrow-id 0x963442c in buffer dpmisc.el>]



;; While paste buf is open
(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x34b4725>0x34b4723> dp-buffer-endicator t) [raw:#<extent [1, 342399]* dp-buffer-endicator 0x98768d0 in buffer dpmisc.el>];(detachable t end-open t text-prop lazy-lock lazy-lock t) [raw:#<extent [238330, 242176) lazy-lock text-prop 0x987c22c in buffer dpmisc.el>];(detachable t end-open t face font-lock-comment-face text-prop face) [raw:#<extent [239794, 239843) text-prop 0x90547dc in buffer dpmisc.el>];(detachable t end-open t text-prop font-lock font-lock t) [raw:#<extent [239794, 239843) font-lock text-prop 0x90547c0 in buffer dpmisc.el>];(detachable t end-open t face dp-highlight-point-before-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent [239794, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x905539c in buffer dpmisc.el>];(detachable t start-open t end-open t face dp-highlight-point-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent (239803, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x9055380 in buffer dpmisc.el>];
-----------------
;; After paste selected
(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x34b4725>0x34b4723> dp-buffer-endicator t) [raw:#<extent [1, 342399]* dp-buffer-endicator 0x98768d0 in buffer dpmisc.el>];(detachable t end-open t text-prop lazy-lock lazy-lock t) [raw:#<extent [238330, 242176) lazy-lock text-prop 0x987c22c in buffer dpmisc.el>];(detachable t end-open t face font-lock-comment-face text-prop face) [raw:#<extent [239794, 239843) text-prop 0x90547dc in buffer dpmisc.el>];(detachable t end-open t text-prop font-lock font-lock t) [raw:#<extent [239794, 239843) font-lock text-prop 0x90547c0 in buffer dpmisc.el>];(detachable t end-open t face dp-highlight-point-before-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent [239794, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x905539c in buffer dpmisc.el>];(detachable t start-open t end-open t face dp-highlight-point-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent (239803, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x9055380 in buffer dpmisc.el>];

=============================================================================
=============================================================================
(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x34b4725>0x34b4723> dp-buffer-endicator t) [raw:#<extent [1, 342399]* dp-buffer-endicator 0x98768d0 in buffer dpmisc.el>];(detachable t end-open t text-prop lazy-lock lazy-lock t) [raw:#<extent [238330, 240715) lazy-lock text-prop 0x987c22c in buffer dpmisc.el>];(detachable t end-open t face font-lock-comment-face text-prop face) [raw:#<extent [239794, 239843) text-prop 0x8abf504 in buffer dpmisc.el>];(detachable t end-open t text-prop font-lock font-lock t) [raw:#<extent [239794, 239843) font-lock text-prop 0x8abf4b0 in buffer dpmisc.el>];
-----------------
calling, in dpmisc.el, dp-del-ext(1, 342399, dp-sel2-arrow-id)
42 items. Press 'h' for help.
Quit
(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x34b4725>0x34b4723> dp-buffer-endicator t) [raw:#<extent [1, 342399]* dp-buffer-endicator 0x98768d0 in buffer dpmisc.el>];(detachable t end-open t text-prop lazy-lock lazy-lock t) [raw:#<extent [238330, 242176) lazy-lock text-prop 0x987c22c in buffer dpmisc.el>];(detachable t end-open t face font-lock-comment-face text-prop face) [raw:#<extent [239794, 239843) text-prop 0x8abf504 in buffer dpmisc.el>];(detachable t end-open t text-prop font-lock font-lock t) [raw:#<extent [239794, 239843) font-lock text-prop 0x8abf4b0 in buffer dpmisc.el>];(detachable t end-open t face dp-highlight-point-before-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent [239794, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x97222f8 in buffer dpmisc.el>];(detachable t start-open t end-open t face dp-highlight-point-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent (239803, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x97222a4 in buffer dpmisc.el>];
-----------------
Quit
Quit
(end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [string :data "[EOF]"]) ((stream) . [string :data "[EOF]"])) fallback=((nil . [nothing])) 0x34b4725>0x34b4723> dp-buffer-endicator t) [raw:#<extent [1, 342399]* dp-buffer-endicator 0x98768d0 in buffer dpmisc.el>];(detachable t end-open t text-prop lazy-lock lazy-lock t) [raw:#<extent [238330, 240715) lazy-lock text-prop 0x987c22c in buffer dpmisc.el>];(detachable t end-open t face font-lock-comment-face text-prop face) [raw:#<extent [239794, 239843) text-prop 0x968cdc8 in buffer dpmisc.el>];(detachable t end-open t text-prop font-lock font-lock t) [raw:#<extent [239794, 239843) font-lock text-prop 0x968cdac in buffer dpmisc.el>];(detachable t end-open t face dp-highlight-point-before-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent [239794, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x97222f8 in buffer dpmisc.el>];(detachable t start-open t end-open t face dp-highlight-point-face dp-sel2-arrow-id t dp-extent-id dp-sel2-arrow-id dp-extent t) [raw:#<extent (239803, 239804) dp-extent dp-extent-id dp-sel2-arrow-id 0x97222a4 in buffer dpmisc.el>];

^\s-*(
^\\s-*(
       
(dp-looking-back-at "^\\s-*(")

(re-search-backward "^\\s-*(" nil 'no-error)
(dp-looking-back-at "^\\s-*(")
214286


(defun dp-comment-sexp ()
  "Comment out the sexp we are in without clobbering parens from enclosing sexps."
  (interactive)
  (unless (dp-looking-back-at "^\\s-*")
    (newline-and-indent))
  (save-excursion 
    (paren-forward-sexp)
    (when (looking-at ")")
      (forward-char)
      (newline-and-indent)))
  (mark-sexp)
  (dp-comment-out-region)
  (dp-deactivate-mark))


========================
Friday August 24 2007
--

(defsubst dp-in-c++-class ()
  "Are we in a C++ class definition?"
  ;; Don't look for inclass's syntax-subclass.
  (save-excursion
    (c-beginning-of-defun)
    (forward-line 1)
    (dp-in-syntactic-region '(inclass class-open) 'ignore-inclass)))

(defun dp-in-c++-class ()
  "Are we in a C++ class definition?"
  (let ((bpos (c-least-enclosing-brace (c-parse-state))))
    (when bpos
      (save-excursion
        (goto-char bpos)
        (dp-in-syntactic-region '(class-open)))))) 




((mode-name obarray)
 
(setq dp-c++-mode-obarray (make-vector 32 0))
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

(defun dp-mk-mode-obarray-name (mode-name-or-sym)
  "Make a mode specific obarray name."
  (format "dp-%s-obarray" mode-name-or-sym))

(defun dp-mode-local-obarray (mode-name-or-sym)
  "Get the mode specific obarray for MODE-NAME-OR-SYM if there is one."
  (let ((mob-name (dp-mk-mode-obarray-name mode-name-or-sym)))
    (intern-soft mob-name)))

(defun dp-mk-mode-obarray (mode-name-or-sym &optional (size 32))
  "Create a new mode specific obarray."
  (let ((mob-name (dp-mk-mode-obarray-name mode-name-or-sym)))
    (unless (intern-soft mob-name)
      (set (intern mob-name) (make-vector size 0)))
    (intern mob-name)))

(defun dp-mode-local-value (var-sym &optional mode-name-or-sym)
  "Get a mode local variable VAR-SYM's value.
Returns nil if there is either no mode obarray or no VAR-SYM in the mode's obarray.
!<@todo Should this throw an error?"
  (let* ((mob (dp-mode-local-obarray (or mode-name-or-sym major-mode)))
         (vsym (when mob (intern-soft (format "%s" var-sym)
                                      (symbol-value mob)))))
    (if vsym
      (symbol-value vsym))))

(defun dp-set-mode-local-value (var-sym value &optional mode-name-or-sym)
  "Set VAR-SYM to VALUE in the mode local obarray.  The MLO will be created if needed."
  (let* ((mob (symbol-value (dp-mk-mode-obarray (or mode-name-or-sym major-mode))))
         (vsym (intern (format "%s" var-sym) mob)))
    (set vsym value)
    (when vsym
      (symbol-value vsym))))

(defun dp-)
(dp-mk-mode-obarray-name (buffer-local-value 'major-mode 
                                             (get-buffer "control-plane.hh")))
"dp-c++-mode-obarray"


dp-mk-mode-obarray

(dp-mk-mode-obarray 'c++-mode)
(dp-mk-mode-obarray 'bubba-mode)
(dp-mk-mode-obarray 'rob-mode)
dp-rob-mode-obarray

(dp-mk-mode-obarray 'x-mode)

(intern "x-x" (dp-mode-local-obarray 'x-mode))


x-x

[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

dp-x-mode-obarray
[0 0 0 x-x 0 new-x-var 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[0 0 0 x-x 0 new-x-var 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

(dp-mode-local-value 'new-x-var "x-mode")
"New Rob!"

"Rob!"

(dp-set-mode-local-value 'new-x-var "New Rob!" 'x-mode)

"New Rob!"

(dp-set-mode-local-value 'new-x3-var "Rob3!" 'x3-mode)
"Rob3!"




"Rob2!"

(dp-mode-local-value 'new-x3-var 'x3-mode)
"Rob3!"

"Rob2!"



"Rob!"

nil


nil

nil

nil


(symbol-value (intern "new-x-var" dp-x-mode-obarray))
"Rob!"

"Rob!"

"Rob!"

dp-x-mode-obarray
[0 0 0 x-x 0 new-x-var 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

nil

new-x-var


[0 0 0 x-x 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

(dp-set-mode-local-value 'new-x-var "Rob!" "x-mode")




dp-bubba-mode-obarray
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]



(dp-set-mode-local-value 'rob-val "Rob!" "rob-mode2")


()

(makunbound 'dp-rob-mode-obarray)

(intern "dp-rob-mode-obarray")
dp-rob-mode-obarray


dp-rob-mode-obarray




dp-rob-mode-obarray

(vectorp obarray)
t

<:dp-emacs-lisp-mode-obarray:>
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 dp-parenthesize-region-paren-list 0 0 0 0 0 0 0 0 0]


========================
Thursday September 06 2007
--

(let ((str "file:///sundry/davep/MH/trash/1461"))
  (when (string-match "^\\([a-zA-Z_0-9]+\\)://\\(.*\\)$" str)
    (princf "match-data: %S\n" (match-data))
    (princf "proto(1): %s\n" (match-string 1 str))
    (princf "file(2): %s\n" (match-string 2 str))))
match-data: (0 34 0 4 7 34)
proto(1): file
file(2): /sundry/davep/MH/trash/1461
nil

match-data: (0 34 0 4 7 34)





nil


(grep COMMAND-ARGS))
grep-command
(let ((grep-command "beagle-query"))
  (grep "beagle-query singlepower"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;<:dp-beagle-query:>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar dp-beagle-query-history '()
  "Yes, it is.")


;; See `compilation-error-regexp-alist'
;; (REGEXP FILE-IDX LINE-IDX [COLUMN-IDX FILE-FORMAT...])
;; query response:
;; file:///home/davep/notes/daily-2007-04.jxt
(defvar dp-beagle-query-regexp-alist 
  ;; We may want to handle each url's proto individually.
  '(("^\\([a-zA-Z_0-9]+\\)://\\(.*\\)$" 1 2 nil))
  "Format: list of lists.  Each sublist is defined thus:
\(Regexp match-num-of-url-proto match-num-of-url-file.)")


(defvar dp-beagle-query-command "beagle-query")


(defun dp-beagle-query-mode-hook ()
  (when dp-beagle-p
    (dp-define-buffer-local-keys '([return] find-file-at-point))))


(defun* dp-beagle-query (command-args &optional (command-name dp-beagle-query-command))
  (interactive (dp-prompt-with-symbol-near-point-as-default "Beagle query: " ))
  ;; (compile-internal COMMAND ERROR-MESSAGE &optional NAME-OF-MODE PARSER
  ;; REGEXP-ALIST NAME-FUNCTION)
  (let ((dp-beagle-mode-p t))
    (add-one-shot-hook 'compilation-mode 'dp-beagle-query-command)
    (compile-internal (concat command-name " " command-args)
                      "No more beagle-query hits."
                      "beagle-query" 
                      nil
                      ".*")))   ;Accept everything... let `ffap' figure it out.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun dp-beagle-compilation-filter-hook ()
  (dp-message-no-echo "cfh, pm: %s, p: %s, subs>%s<\nstring>%s<\n"
                      (process-mark (get-buffer-process (current-buffer))) 
                      (point)
                      (buffer-substring 
                       (process-mark (get-buffer-process (current-buffer))) (point))
                      string))

example output:
cfh, pm: #<marker at 100 in *beagle-query* 0xa88d74c>, p: 100, subs><
string>file:///sundry/davep/notes-pre-SVN/daily-2005-07.jxt<
cfh, pm: #<marker at 1124 in *beagle-query* 0xa88d74c>, p: 1124, subs><
string>
file:///sundry/davep/MH/oldgang/3193#0
file:///sundry/davep/MH/oldgang/3194#0
file:///yokel/yokel/archive-cvsroot/davep/notes/daily-2005-07.jxt,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/inb/newegg-amd64-2G-corsair.ps,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/inb/newegg-athlon64-dfi-mobo.ps,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/david.panariti-bookmarks.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/david.panariti-bookmarks2.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/david.panariti-bookmarks4.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/helm-bookmarks.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/david.panariti-bookmarks3.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/helm-bookmarks3.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/helm-bookmarks4.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/david.panariti-bookmarks5.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/etc/bookmarks5.html,v
file:///sundry/dav<
cfh, pm: #<marker at 2148 in *beagle-query* 0xa88d74c>, p: 2148, subs><
string>ep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/david.panariti-bookmarks.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/david.panariti-bookmarks5.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/david.panariti-bookmarks4.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/david.panariti-bookmarks3.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/david.panariti-bookmarks2.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/helm-bookmarks.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/helm-bookmarks3.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/helm-bookmarks4.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc-pre-SVN/bookmarks5.html,v
file:///sundry/davep/Firefox/adi7ooz7.KDE/breadcrumbs/pages/www<
cfh, pm: #<marker at 3172 in *beagle-query* 0xa88d74c>, p: 3172, subs><
string>.head-fi.org/forums/showthread.php_QUEST_t237474__bc
file:///sundry/davep/Firefox/adi7ooz7.KDE/breadcrumbs/pages/www.head-fi.org/forums/showthread.php_QUEST_t233954
file:///sundry/davep/Firefox/adi7ooz7.KDE/breadcrumbs/pages/www.head-fi.org/forums/showthread.php_QUEST_t237474
file:///yokel/yokel/home/davep/MH/etail/372
file:///yokel/yokel/home/davep/MH/etail/373
file:///yokel/yokel/home/davep/MH/etail/318
file:///yokel/yokel/home/davep/MH/etail/318#0
file:///yokel/yokel/home/davep/MH/etail/375
file:///yokel/yokel/home/davep/MH/etail/375#0
file:///yokel/yokel/home/davep/MH/etail/370
file:///yokel/yokel/home/davep/MH/etail/369
file:///yokel/yokel/home/davep/MH/oldgang/2#0
file:///yokel/yokel/home/davep/MH/oldgang/2#49
file:///yokel/yokel/home/davep/inb/tc-le4A-my-notes.tar.bz2#./notes/daily-2002-12.jxt
file:///yokel/yokel/home/davep/inb/tc-le4-my-notes.tar.bz2#./notes/daily-2002-12.jxt
file:///yokel/yokel/home/davep/notes/daily-2002-12.jxt
file:///yokel/yokel/home/davep/notes/daily-2005-07.jxt
file:///yokel/yok<
cfh, pm: #<marker at 4196 in *beagle-query* 0xa88d74c>, p: 4196, subs><
string>el/home/davep/notes/daily-2007-05.jxt
file:///yokel/yokel/home/davep/MH/inbox/34517
file:///yokel/yokel/home/davep/MH/inbox/34534
file:///yokel/yokel/home/davep/MH/inbox/34534#0
file:///yokel/yokel/home/davep/MH/inbox/27475
file:///yokel/yokel/home/davep/MH/inbox/27475#0
file:///yokel/yokel/home/davep/MH/inbox/27476
file:///yokel/yokel/home/davep/MH/inbox/33387
file:///yokel/yokel/home/davep/MH/inbox/31698
file:///yokel/yokel/home/davep/MH/inbox/31698#0
file:///yokel/yokel/home/davep/MH/inbox/30228
file:///yokel/yokel/home/davep/MH/inbox/33165
file:///yokel/yokel/home/davep/MH/inbox/34812
file:///yokel/yokel/home/davep/MH/inbox/34812#0
file:///yokel/yokel/home/davep/MH/inbox/32632
file:///yokel/yokel/home/davep/MH/inbox/32666
file:///yokel/yokel/home/davep/MH/inbox/32666#0
file:///yokel/yokel/home/davep/MH/inbox/27489
file:///yokel/yokel/home/davep/MH/inbox/27489#0
file:///yokel/yokel/home/davep/MH/inbox/30263
file:///yokel/yokel/home/davep/MH/inbox/30236
file:///yokel/yokel/home/davep/MH/inbox/30263#0
file:/<
cfh, pm: #<marker at 5220 in *beagle-query* 0xa88d74c>, p: 5220, subs><
string>//yokel/yokel/home/davep/MH/inbox/30236#0
file:///yokel/yokel/home/davep/MH/inbox/27516
file:///yokel/yokel/home/davep/MH/inbox/33193
file:///yokel/yokel/home/davep/MH/inbox/33193#0
file:///yokel/yokel/home/davep/MH/inbox/30627
file:///yokel/yokel/home/davep/MH/inbox/30627#0
file:///yokel/yokel/home/davep/MH/inbox/27496
file:///yokel/yokel/home/davep/MH/inbox/27496#0
file:///yokel/yokel/home/davep/MH/inbox/28067#0
file:///yokel/yokel/home/davep/MH/inbox/27613
file:///yokel/yokel/home/davep/MH/inbox/27613#0
file:///yokel/yokel/home/davep/MH/inbox/34632
file:///yokel/yokel/home/davep/MH/inbox/34632#0
file:///yokel/yokel/home/davep/MH/inbox/32642
file:///yokel/yokel/home/davep/MH/inbox/32642#0
file:///yokel/yokel/home/davep/MH/inbox/30630
file:///yokel/yokel/home/davep/MH/inbox/30630#0
file:///yokel/yokel/home/davep/MH/inbox/30617
file:///yokel/yokel/home/davep/MH/inbox/30617#0
file:///yokel/yokel/home/davep/MH/inbox/27653
file:///yokel/yokel/home/davep/MH/inbox/27653#0
file:///yokel/yokel/home/davep/MH/inbox/31<
cfh, pm: #<marker at 6244 in *beagle-query* 0xa88d74c>, p: 6244, subs><
string>697
file:///yokel/yokel/home/davep/MH/inbox/31697#0
file:///yokel/yokel/home/davep/MH/inbox/33177
file:///yokel/yokel/home/davep/MH/inbox/33177#0
file:///yokel/yokel/home/davep/MH/inbox/27614
file:///yokel/yokel/home/davep/MH/inbox/27614#0
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/david.panariti-bookmarks.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/helm-bookmarks3.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/david.panariti-bookmarks5.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/david.panariti-bookmarks4.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/helm-bookmarks4.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/bookmarks5.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/david.panariti-bookmarks3.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/david<
cfh, pm: #<marker at 6430 in *beagle-query* 0xa88d74c>, p: 6430, subs><
string>.panariti-bookmarks2.html,v
file:///sundry/davep/RCS/RCS.vilya/home.davep/yokel/yokel/home/davep/etc/helm-bookmarks.html,v
file:///yokel/yokel/home/davep/tmp/newegg-athlon64-dfi-mobo.ps
<
cfh, pm: #<marker at 6928 in *beagle-query* 0xa88d74c>, p: 6928, subs><
string>kbookmark:///Other Bookmarks/Helm, old laptop, IE/old links/ttla/my hardware/;title=newegg.com
kbookmark:///Other Bookmarks/Helm, old laptop, IE/cases/;title=newegg.com - ahanix cases
kbookmark:///My hardware/Potential purchases/;title=Newegg.com - Lian-Li PC-7 USB2 Cases (Computer Cases, ATX Form)
kbookmark:///Other Bookmarks/Helm, old laptop, IE/cases/;title=newegg.com
kbookmark:///My hardware/Potential purchases/;title=Newegg.com - A-TOP Technology AT860-YE Cases (Computer Cases, ATX Form)
<
(add-hook 'compilation-filter-hook 'dp-beagle-compilation-filter-hook)
(dp-beagle-compilation-filter-hook)


(dp-beagle-query "swapoff")
#<buffer "*beagle-query-mode*">

#<buffer "*beagle-query-mode*">

?????????????? DO (OR CAN) I USE THIS: `compilation-shell-minor-mode' ?????????????????????

========================
Thursday September 13 2007
--
spongebob "the bird brains" "The Bottom of the Sea"
back to the future

trompe-l~~il.

(setq dpl 
`(([(control /)]        . ,(kb-lambda (setq display-buffer-function nil)))
  ([?C]           . dp-make-temp-c++-mode-buffer)
  ([(control f)]        . dp-face-at)
  ([(meta c)]         . ,(kb-lambda (dp-uncolorize-region nil nil (C-u-p))))
  ([(meta n)]         . ,(kb-lambda (dp-goto-next-dp-extent-from-point '(4))))
  ([?b]           . dp-point-to-bottom)
  ([(control b)]        . dp-kill-breakpoint-command)
  ([?s]           . dp-ssh)
  ([?f]           . dp-show-buffer-file-name)
  ([?g]           . dp-sel2:bm)	
  ([?i]           . dp-ifdef-region)
  ([?k]          . dp-mark-to-end-of-line)
  ([?n]           . dp-goto-next-dp-extent-from-point)
  ([(control p)]        . dp-set-extent-priority)
  ([?r]           . dp-rotate-windows)
  ([(control s)]        . dp-find-or-create-sb)
  ([(control v)]           . dp-show-variable-value)
  ("p"           . dp-python-shell)
  ([right]       . dp-shift-windows)
  ([(meta \')]   . dp-copy-up-to-char)
  ([(meta r)]    . ,(kb-lambda (dp-rotate-windows t)))
  ([(meta s)]    . dp-try-to-fix-effin-isearch)
  ([(control q)] . dp-rw/ro-region)
  ([(shift tab)] . dp-goto-next-dp-extent-from-point)
  ([?`]          . dp-bq-rest-of-line)
  ([tab]         . ,(kb-lambda (dp-goto-next-dp-extent-from-point '(4))))))

dpl

(car dpl)
("" lambda (&optional arg arg1 arg2 arg3 arg4 arg5) "" (interactive "P") (setq display-buffer-function nil))

(caar dpl)
""
(cdar dpl)
(lambda (&optional arg arg1 arg2 arg3 arg4 arg5) "" (interactive "P") (setq display-buffer-function nil))


("C" . dp-make-temp-c++-mode-buffer)



"\C-/"
""

========================
Friday September 14 2007
--

========================
Sunday September 16 2007
--

========================
Wednesday September 19 2007
--

(defun dp-hanoi1 (s-peg d-peg t-peg)
  (while s-peg
    (destructuring-bind (s-peg1 d-peg1 t-peg1)
        ;; mv n-1 disks from s-peg to t-peg
        (dp-hanoi1 (cdr s-peg) t-peg d-peg)
      ;; mv bottom of s-peg to d-peg
      (setq d-peg (cons (car s-peg) d-peg)
            s-peg (cdr s-peg))
      ;; mv disks from t-peg to d-peg.
      (dp-hanoi1 t-peg d-peg s-peg)
            
  ()
)
(defun dp-hanoi (num-disks)
  (let ((s-peg (loop for x to 10 collect x))
        (d-peg '())
        (t-peg '()))
    (dp-hanoi1 s-peg d-peg t-peg) 
))

(destructuring-bind (a b d) '(44 55 66)
  (princf "a: %s, b: %s, d: %s\n" a b d)
    )
a: 44, b: 55, d: 66
nil

(cl-pe '(destructuring-bind (a b d) '(44 55 66)
  (princf "a: %s, b: %s, d: %s\n" a b d)
    ))

(let* ((--rest--47989 '(44 55 66))
       (a (if (= (length --rest--47989) 3)
              (car (prog1
                       --rest--47989
                     (setq --rest--47989 (cdr --rest--47989))))
            (signal 'wrong-number-of-arguments
                    (list nil (length --rest--47989)))))
       (b (car (prog1
                   --rest--47989
                 (setq --rest--47989 (cdr --rest--47989)))))
       (d (car --rest--47989)))
  (princf "a: %s, b: %s, d: %s
" a b d))nil

(cl-pe '(destructuring-bind (a b d f) '(44 55 66 77)
  (princf "a: %s, b: %s, d: %s, f:\n" a b d f)
    ))

(let* ((--rest--47990 '(44 55 66 77))
       (a (if (= (length --rest--47990) 4)
              (car (prog1
                       --rest--47990
                     (setq --rest--47990 (cdr --rest--47990))))
            (signal 'wrong-number-of-arguments
                    (list nil (length --rest--47990)))))
       (b (car (prog1
                   --rest--47990
                 (setq --rest--47990 (cdr --rest--47990)))))
       (d (car (prog1
                   --rest--47990
                 (setq --rest--47990 (cdr --rest--47990)))))
       (f (car --rest--47990)))
  (princf "a: %s, b: %s, d: %s, f:
" a b d f))nil

(setq vs 'q)
q
vs
q


dp-symvals

fvar

(setq q "i am q")
(fset 'q 'fvar)
fvar


(message "%s" (dp-symvals 'q))
"q: val: \"i am q\", func: fvar"

"q: v: i am q, func: fvar"

"q: v: i am q, func: fvar"

"q: val: \"i am q\", func: fvar"

"q: val: \"i am q\", function: fvar"

"q: val: \"i am q\", function: fvar"

"q: val: \"i am q\", function: fvar"


(princf "%s" (fvar vs))
q: val: "i am q", function: fvarnil

"q: val: \"i am q\", function: fvar"

"q: val: i am q, function: fvar"




(defun dp-princ-symvals (vsym &rest rest &key &allow-other-keys)
  (princf "%s\n" (apply 'dp-symvals vsym rest)))
dp-princ-symvals

(dp-princ-symvals 'q)
q: val: "i am q", func: fvar
nil




                       
                       

(let ((l '(1 2 3))
      (m '(a b)))
  (defun f (fl)
    (setf fl (cons (car fl) fl))
    (dp-princ-symvals 'fl))
  (f l)
  (princf "f: l>%S<" l)
  (f 'l)
  (princf "f: l>%S<" l)
)
fl: val: (1 1 2 3), func: fume-list-functions
f: l>(1 2 3)<
fl: val: (1 1 2 3), func: fume-list-functions
f: l>(1 2 3)<nil

(setq dpx 100)
(setq dpxp 'dpx)
(setq dpxl (list dpx))
(102)

(defsetf symbol-value set)

(symbol-plist 'symbol-value)
(byte-opcode byte-symbol-value byte-compile byte-compile-one-arg setf-method #<compiled-function (&rest args) "...(32)" [store --store--temp-- --args--temp-- args mapcar gensym "--store--" set append symbol-value] 7 "
Common Lisp lambda list:
  (symbol-value &rest ARGS)

">)

(setf (symbol-value dpxp) 900)
900
 dpx
900


(cl-pe '(incf (car dpxl)))

(setcar dpxl (+ (car dpxl) 1))nil

(cl-pe '(incf dpx))

(setq dpx (1+ dpx))nil

(cl-pe '(incf dpxp))

(setq dpxp (1+ dpxp))nil

(cl-pe '(letf ((p dpxp))
         (incf p)))

(let ((p dpxp))
  (setq p (1+ p)))nil
(symbolp dpxp)
nil

nil
dpxp
zzz
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setg

setg

(loop for a q in '(1 2 3 4)
  collect (cons a q))

          (loop for x on '(1 2 3 4) collect x)

(defmacro setg (&rest var-forms)
  (cons 'progn
        (loop for x on  var-forms by 'cddr
          collect `(cond
                   ((not (boundp (car x))) 
                    (setq ,(car x) ,(cadr x)))
                   ((symbolp (eval (car x)))
                    (set ,(car x) ,(cadr x)))
                   (t
                    (setf ,(car x) ,(cadr x)))))))
setg

setg

(cl-pe '(setg a1 2 dpxp 3 a3 4 dpx 5 a4 6))

(progn
  (cond ((not (boundp (car x)))
         (setq a1 2))
        ((symbolp (eval (car x)))
         (set a1 2))
        (t (setq a1 2)))
  (cond ((not (boundp (car x)))
         (setq dpxp 3))
        ((symbolp (eval (car x)))
         (set dpxp 3))
        (t (setq dpxp 3)))
  (cond ((not (boundp (car x)))
         (setq a3 4))
        ((symbolp (eval (car x)))
         (set a3 4))
        (t (setq a3 4)))
  (cond ((not (boundp (car x)))
         (setq dpx 5))
        ((symbolp (eval (car x)))
         (set dpx 5))
        (t (setq dpx 5)))
  (cond ((not (boundp (car x)))
         (setq a4 6))
        ((symbolp (eval (car x)))
         (set a4 6))
        (t (setq a4 6))))nil

(cl-pe '(defun x (dpx)
         (setf (car dpx) 100)))

(defun x (dpx) (setcar dpx 100))nil



(setcar dpx 100)




(setq dpx 100)nil




(progn
  (setq a1 2)
  (set dpxp 3)
  (setq a3 4)
  (setq dpx 5)
  (setq a4 6))nil

(cl-pe '(setq-ifnil dpx 99 a 1 b 2 d 4))

(progn
  (if dpx nil (setq dpx 99))
  (if a nil (setq a 1))
  (if b nil (setq b 2))
  (if d nil (setq d 4)))nil

(cons '() '())

(string-match (regexp-quote "lo") "global")
1



(if dpx nil (setq dpx 99))nil




((setq a1 2)
 (set dpxp 3)
 (setq a3 4)
 (setq dpx 5)
 (setq a4 6))nil

(cl-pe '(setf dpx 89))

(setq dpx 89)nil


222



((setq a1 2)
 (set dpxp 3)
 (setq a3 4)
 (setq a4 5)
 (setq a4 6))nil



((setq a1 2)
 (setq a2 3)
 (setq a3 4)
 (setq a4 5)
 (setq a4 6))



((setq a1 2)
 (setq a23 4)
 (setq a3 5)
 (setq a4 6))nil



((setq (car x) \, (cadr x))
 (progn
   (setcar x \,)
   (setcar (cdr x) nil))
 (progn
   (setcar x \,)
   (setcar (cdr x) nil))
 (progn
   (setcar x \,)
   (setcar (cdr x) nil)))nil




((setq (car x) \, (cadr x))
 (progn
   (setcar x \,)
   (setcar (cdr x) nil))
 (progn
   (setcar x \,)
   (setcar (cdr x) nil))
 (progn
   (setcar x \,)
   (setcar (cdr x) nil)))nil











  collect (list 'setq (car x) (cadr x)))


((setq 1 2) (setq 3 4) (setq 5 6))

((1 2) (3 4) (5 6))

((1 . 2) (3 . 4) (5 . 6))

                                   
                                   ) collect (list x x))



(cl-pe '(setg dpxp 333))

(set dpxp 333)nil

(set dpxp 333)
333

dpx
333

(cl-pe '(setg dpx 444))

(setq dpx 444)
444

(setg dpx 111)
111
dpx
111

(setg dpxp 222)
222
dpx
222

dpxp
dpx





(set dpx 333)nil




(set place value)nil




t

zzz

dpx
102


(setf dpxp "zzz")
"zzz"

zzz




(let ((p dpxp)))nil







104

103
 dpx
102
dpxl
(103)

dp-serialized-name-alist
(("dp-blm-map-Fundamental-" 0 rest: (keymap: "#<keymap size 0 0x93c941c>") maj-mode: "text-mode" bufname: " *appt-buf*") ("dp-blm-map-Shell-" 0 rest: (keymap: "#<keymap size 0 0x19b2245>") maj-mode: "nil" bufname: "*shell*") ("dp-blm-map-Text-" 2 rest: (keymap: "#<keymap size 0 0x2527a1>") maj-mode: "text-mode" bufname: "diary") ("dp-blm-minor-mode-" 7 rest: nil maj-mode: "lisp-interaction-mode" bufname: "*scratch*") ("dp-blm-map-Lisp Interaction-" 0 rest: (keymap: "#<keymap size 0 0x241a7b>") maj-mode: "lisp-interaction-mode" bufname: "*scratch*"))


(setq dpl (copy-seq dp-serialized-name-alist))
(("dp-blm-map-Fundamental-" 0 rest: (keymap: "#<keymap size 0 0x93c941c>") maj-mode: "text-mode" bufname: " *appt-buf*") ("dp-blm-map-Shell-" 0 rest: (keymap: "#<keymap size 0 0x19b2245>") maj-mode: "nil" bufname: "*shell*") ("dp-blm-map-Text-" 2 rest: (keymap: "#<keymap size 0 0x2527a1>") maj-mode: "text-mode" bufname: "diary") ("dp-blm-minor-mode-" 7 rest: nil maj-mode: "lisp-interaction-mode" bufname: "*scratch*") ("dp-blm-map-Lisp Interaction-" 0 rest: (keymap: "#<keymap size 0 0x241a7b>") maj-mode: "lisp-interaction-mode" bufname: "*scratch*"))

(cadr (assoc "dp-blm-minor-mode-" dpl))
5

"dp-blm-minor-mode-"

(incf (cadr (assoc "dp-blm-minor-mode-" dpl)))
7
(dp-serialized-name "zoq")
"zoq1"

"zoq0"

"booga2"

"booga1"

"booga0"

6


("dp-blm-minor-mode-" 5 rest: nil maj-mode: "lisp-interaction-mode" bufname: "*scratch*")


102



101
dpx
101





========================
Friday September 21 2007
--

(dp-string-var-grep "firefox" ".br")
nil

(dp-grep-string-vars "f.*fox")
((browse-url-firefox-program "firefox"))

((browse-url-firefox-program "firefox"))

nil

((browse-url-firefox-program "firefox"))


((browse-url-firefox-program "firefox"))

((browse-url-firefox-program "firefox") (regexp "firefox"))

((regexp "ffox"))

(regexp)

(regexp)

(regexp)


(browse-url-firefox-program regexp)


========================
Saturday September 22 2007
--

(setq dpl '(1 2 3)
      dplp 'dpl)
dpl

dplp
dpl
(1 2 3)

(pop dplp)

(push 9 dpl)
(9 1 2 3)

(defun dpf (l)
  (pop l))
dpf

(dpf dpl)
9
dpl
(9 1 2 3)
(cl-pe '(prog1))

dplp
dpl
(1 2 3)


(macroexpand '(popg dplp))
(prog1 (car (symbol-value dplp)) (set dplp (cdr (symbol-value dplp))))


dpl
(33 1 2 3)
dplp
dpl


(pushg 33 dplp)
(33 1 2 3)
dpl
(33 1 2 3)

(popg 'dpl)
1

33
dpl
(2 3)
doom release date
yes discography
rush discography
(1 2 3)





(defmacro pushg (el l)
  `(set ,l (cons ,el (symbol-value ,l))))

(defmacro popg (l)
  `(prog1 
      (car (symbol-value ,l))
    (set ,l (cdr (symbol-value ,l)))))
popg




(defun hanoi0 (s d t)
  (when (> (length s) 0)
    (if (= (length s) 1)
        (pushg (pop s) d)
      (if (= (length s) 2)
          (progn
            (pushg (pop s) t)
            (pushg (pop s) d)
            (pushg (pop t) d))
        (hanoi (cdr s) d t)))))

(defun hanoi (s d t)
  (hanoi 's 'd 't)
  (list s d t))

========================
Friday September 28 2007
--

========================
Saturday October 13 2007
--

(let ((s "ltl -1"))
  (if (string-match 
       "^[ \t]*\\<\\(ls1?\\|ltl\\|lsl\\|lth\\)\\>\\(?:[ \t]*\\)\\(.*\\)$" s)
      (princf "m0>%s<\nm1>%s<\nm2>%s<"
              (match-string 0 s)
              (match-string 1 s)
              (match-string 2 s))
    (princf "No match.\n")))
m0>ltl -1<
m1>ltl<
m2>-1<nil

m0>ltl<
m1>ltl<
m2><nil




  






========================
Monday October 29 2007
--

(defmacro dp-with-region-op-flash (flash-time &rest body)
  (unless (numberp flash-time)
    (setq body (cons flash-time body)
          flash-time 1))
  `(block nil
    (dp-activate-mark)
    ,@body
    (when (sit-for ,flash-time)
      (dp-deactivate-mark))))


(cl-pe
'(dp-with-region-op-flash 
  (dp-nop)))

(block nil 
  (dp-activate-mark) 
  (dp-nop) 
  (if (sit-for 1) 
      (dp-deactivate-mark)))



(block nil (dp-activate-mark) dp-nop (if (sit-for 1) (dp-deactivate-mark)))nil






(block nil nil dp-nop (if (sit-for 1) (dp-deactivate-mark)))nil



(progn
  nil
  (dp-nop)
  (if (sit-for 1) (dp-deactivate-mark)))nil



(progn
  nil
  (dp-nop)
  (if (sit-for 99) (dp-deactivate-mark)))nil



(progn
  nil
  (dp-nop)
  (if (sit-for 1) (dp-deactivate-mark)))nil








========================
Saturday November 10 2007
--

========================
Sunday November 25 2007
--

(defun dp-python-pluck-arg ()
  (interactive)
  (save-excursion
    (id-select-word)
    ;; Save beginning of word.  However, in a Python arglist, an arg may be
    ;; preceded by 0-2 `*'s
    (let (point (point)))
    )
  
)

========================
Friday December 14 2007
--

(defun dp-python-add-self. ()
  "Put a (tiresome :-) self before the current symbol if needed."
  (interactive)
  (save-excursion
    (backward-word)
    (unless (dp-looking-back-at "self\\.")
      (insert "self.")))))

========================
Thursday February 21 2008
--



========================
Monday March 24 2008
--
(defmacro setq-ifnil (&rest arglist)
  "Setup default values for args which are nil."
  (if (not (= 0 (mod (length arglist) 2)))
      (error "setq-ifnil: arglist len must be a multiple of 2."))
  (let (arg init-val result)
    (while arglist
      (setq arg (car arglist)
            arglist (cdr arglist)
            init-val (car arglist)
            arglist (cdr arglist))
      (setq new-elem `(if ,arg ,arg (setq ,arg ,init-val)))
      (setq result (cons new-elem result)))
    (cons 'progn (reverse result))))

(defmacro setq-ifunbound (&rest arglist)
  "Setup default values for args which are nil."
  (if (not (= 0 (mod (length arglist) 2)))
      (error "setq-ifnil: arglist len must be a multiple of 2."))
  (let (arg 
        init-val
        result)
    (while arglist
      (setq arg (car arglist)
            arglist (cdr arglist)
            init-val (car arglist)
            arglist (cdr arglist))
      (if-boundp arg
          ()
        (setq new-elem `(setq ,arg ,init-val))
        (setq result (cons new-elem result))))
    (cons 'progn (reverse (delq nil result)))))
setq-ifunbound

(cl-pe
'(let ((c 100)
      a b)
  (setq-ifnil ;;c 999
              ;;b 'bbbbbb
              a 'aaaa)))

(let ((c 100)
      a
      b)
  (if a a (setq a 'aaaa)))nil



(let ((c 100)
      a
      b)
  (progn
    (if c c (setq c 999))
    (if b b (setq b 'bbbbbb))
    (if a a (setq a 'aaaa))))nil


aaaa

(makunbound 'dp-i-am-bound)
dp-i-am-bound

dp-i-am-bound

(makunbound 'dp-i-am-UNbound)
dp-i-am-UNbound

dp-i-am-bound
(setq dp-i-am-bound "bound!")
"bound!"

"bound!"


(cl-pe
 '(setq-ifunbound dp-i-am-bound "howdee"
   dp-i-am-UNbound "so I'll have a setq")
 )

(progn
  (setq dp-i-am-bound "howdee")
  (setq dp-i-am-UNbound "so I'll have a setq"))nil



(setq dp-i-am-UNbound "so I'll have a setq")nil



(setq dp-i-am-UNbound "so I'll have a setq")nil



(setq dp-i-am-UNbound "so I'll have a setq")nil






consing, 'progn and ((setq dp-i-am-bound howdee) (setq dp-i-am-UNbound so I'll have a setq))
(progn
  (setq dp-i-am-bound "howdee")
  (setq dp-i-am-UNbound "so I'll have a setq"))nil



(cons 'progn '((setq dp-i-am-bound howdee)))
(progn (setq dp-i-am-bound howdee))



consing
(setq dp-i-am-bound "howdee")nil



========================
Tuesday April 22 2008
--
(defun* dp-bracket-region (beg end &optional 
                           (pre "<blockquote>") 
                           (post "</blockquote>"))
  (interactive "r")
  (goto-char end)
  (insert post)
  (goto-char beg)
  (insert pre))
dp-bracket-region




========================
Wednesday May 14 2008
--



========================
Thursday July 24 2008
--

journal command:

dpj-thread-topic

(defun dpj-clone-topic (&optional link-too initial-text)
  "Clone the current topic with a new timestamp.
Allows for an indication of time flow within a continuing topic or 
continuation of a topic at a later time."
  (interactive "P")
  (let ((topic (dpj-current-topic dpj-todo/done-re 'no-quote))
	(current-prefix-arg nil)) ;bleaghhhh dpj-no-spaced-append uses this
    (if (not (string= topic ""))
        (dpj-new-topic topic nil link-too 'is-a-clone)
      (dp-set-eof-spacing 2))
    (when initial-text
      (insert initial-text "\n"))))


========================
Friday August 22 2008
--

_cls

_
_c
_cl
_cls

"\\(_\\(c\\(l\\(s\\)?\\)?\\)?\\)?"


(progn
  (string-match "^\\(_\\(c\\(l\\(s\\)?\\)?\\)?\\)?$" "")
  (match-string 1 "_cls"))
nil

"_"

"_cl"

"_cls"


nil

0

0

0

0

nil

0

0


(split-string "ab")
("ab")

("" "a" "b" "")

(mapconcat (lambda (c)
             (format "\\(%c" c))
           "abc"
           "|")
"\\(a|\\(b|\\(c"

\(a\(b\(c"\\(a|\\(b|\\(c"



(defun dp-mk-prefix-match-regexp (l)
  (if l
      (format "\\(%c%s\\)?" (car l)
              (dp-mk-prefix-match-regexp (cdr l)))
    ""))

(defun dp-mk-bounded-prefix-match-regexp (l)
  (concat "^" (dp-mk-prefix-match-regexp l) "$"))

(dp-mk-abbrev-regexp '("a" "b" "c"))
"\\(a\\(b\\(c\\)?\\)?\\)?"

(dp-mk-bounded-prefix-match-regexp (string-to-list "_cls"))
"^\\(_\\(c\\(l\\(s\\)?\\)?\\)?\\)?$"

"\\(_\\(c\\(l\\(s\\)?\\)?\\)?\\)?"
"\\(_\\(c\\(l\\(s\\)?\\)?\\)?\\)?"

(defun dp-complete-prefix-remainder (prefix str)
  (when (string-match 
         (dp-mk-bounded-prefix-match-regexp (string-to-list prefix))
         str)
    (let ((matched (match-string 1 str)))
      ;; 1234
      ;; 12..
      ;; 01   <<< offset
      ;; remainder len = len(str) - len(matched)
      (substring prefix (length matched)))))
dp-complete-prefix-remainder

(dp-complete-prefix-remainder "_cls" "_cls")
""

nil

"ls"

"ls"


""








\(a\(b\(c"abc"

\(?a\(?b\(?c"abc"

"abc"

        
?A?B?C"ABC"


========================
Sunday August 24 2008
--

(defun* dp-py-code-text-ends-with-special-char-p (&key except special-chars new-pos)
  "Are we on a \"special\" character? E.g. one which should not be followed by a comma.
The characters are classified as good or bad by `looking-at' and so EXCEPT
must be compatible with that function.
Chars in EXCEPT are always OK. 
There is a standard `looking-at' type string which is filled with all kinds
of naughty characters `dp-py-special-chars'.  This can be overridden by
passing SPECIAL-CHARS."
  (save-match-data
    (when new-pos (goto-char new-pos))
    ;; Goto the end of the code text on this line, if any.
    (dp-py-goto-end-of-code)
    ;; Will we even be here if we're on a comment line?
    (if (bolp)
        t
      ;;(error "In a comment; is this OK???")
      ;; We're just after the last char, so...
      (forward-char -1)
      ;; If I skipped forward, then the character was in the except list
      ;; and therefor should be considered as non special (I need a better
      ;; term than special.)
      (if (and except 
               (/= 0 (skip-chars-forward except)))
          nil                         ; Not special.
        ;; If we skip forward then we were on a spay-shul character.
        ;; and so should return true
        (/= 0 (skip-chars-forward
               (or special-chars dp-py-special-chars)))))))

dp-py-special-chars
"[][,~`!@#$%^&*()+={}:;<>.?|/-/-]"

True-


(skip-chars-forward "[][,~`!@#$%^&*()+={}:;<>.?|/-/-]")

========================
Sunday September 07 2008
--

(lambda ()
  (if (Cu--p)
      'previous-line
    (dp-sls 'dp
            (quote ,variant) 
            '-previous-matching-input-from-input)))

(defun dp-shells-comint-previous-or-matching-input ()
  (interactive)
  (if (Cu--p)
      (previous-line)
    (when (eq last-command 'dp-shells-comint-previous-or-matching-input)
      (setq last-command 'comint-previous-matching-input-from-input))
    (call-interactively 'comint-previous-matching-input-from-input)))
  
(dp-shell-xxx-input 'previous-line
                    '(lambda nil 
                       (if (Cu--p) 
                           (quote previous-line) 
                         (dp-sls (quote comint)
                                 (quote -previous-matching-input-from-input))))
                    'previous-line
                    'previous-line))


(mapconcat (lambda (s)
             (format "%s" s))
           '(a list of symbols)
             "")
"alistofsymbols"

(dp-sls (quote comint)
        (quote -previous-matching-input-from-input))
comint-previous-matching-input-from-input

comint-previous-matching-input-from-input


========================
Monday September 08 2008
--

(last '(a b c))
(c)
(nbutlast '(a b c))
(a b)




(defun* dp-make-comma-and-x-list0 (list final-sep &optional (inital-sep ", "))
  (let* ((last (last list))
         (rest (nbutlast list)))
    (concat
     (if rest
         (concat
          (mapconcat (function
                      (lambda (x)
                        (format "%s" x)))
                     rest
                     (format "%s" inital-sep))
          (format "%s" final-sep))
       "")
     (if last
         (format "%s" (car last))
       ""))))


(defun* dp-make-comma-and-x-list (list final-sep &optional (inital-sep ", "))
  (setq final-sep (format "%s" final-sep)
        inital-sep (format "%s" inital-sep))
  (let* ((final-sep (cond
                     ((string-match "^\\( \\)?\\(.*?\\)\\( \\)?$" final-sep)
                      (concat (or (match-string 1 final-sep) " ")
                              (or (match-string 2 final-sep) "")
                              (or (match-string 3 final-sep) " ")))))
         (inital-sep (cond
                      ((string-match "\\(.*?\\)\\( \\)?$" inital-sep)
                       (concat (or (match-string 1 inital-sep) "")
                               (or (match-string 2 inital-sep) " "))))))
    (dp-make-comma-and-x-list0 list final-sep inital-sep)))

(defun* dp-make-comma-and-or-list (list &optional (inital-sep ", "))
  (dp-make-comma-and-x-list list "or"))

(defun* dp-make-comma-and-and-list (list &optional (inital-sep ", "))
  (dp-make-comma-and-x-list list "and"))  

dp-make-comma-and-x-list

(dp-make-comma-and-x-list '(1 2 3) "and")
"1, 2 and 3"

(dp-make-comma-and-x-list '(1 2 3) "and" "/")
"1/ 2 and 3"

(dp-make-comma-and-x-list0 '(1 2 3) "and" "/")
"1/2and3"

(dp-make-comma-and-x-list '(1 2 3) "and " ", ")
"1, 2 and 3"

"1, 2 and 3"






    
    
(format " %s " (regexp-quote final-sep))))
(format " %s " (regexp-quote final-sep))))))
(dp-make-comma-and-x-list '(a b c) "and")
"a, b and c"
(dp-make-comma-and-x-list '(a b c) 'scooby)
"a, b scooby c"
(dp-make-comma-and-x-list '(a b c) 'scooby)
"a, b scooby c"
(dp-make-comma-and-x-list '(a b c) 'scooby 'shaggy)
"ashaggyb scooby c"

(dp-make-comma-and-x-list '(a b c) " scooby " " shaggy ")
"a shaggy b  scooby  c"

"ashaggy b  scooby  c"






(dp-make-comma-and-x-list '(a b) "or")
"a or b"

"a and b"

(dp-make-comma-and-x-list '(a) "zuzz")
"a"

"a"

(dp-make-comma-and-x-list '() 'scooby)
""

""








(defun dpf (l)
  
)

========================
Thursday September 11 2008
--


(append-expand-filename "$TERM" "")


"/home/davep/"

"~lisp"

map


(dp-insert-cwd)
/home/davep/nil


/home/davep/nil

(expand-file-name (substitute-in-file-name default-directory))
"/home/davep/"
/home/davep/
(file-relative-name "bin" "~")
"bin"

(substitute-in-file-name (expand-file-name default-directory))
"/home/davep/"

"bin"

"../../bin"

"../../bin"

(expand-file-name "bin" "var")
"/home/davep/var/bin"

"/home/davep/bin"

"/home/davep/bin"

"/home/davep/"

"/home/davep/"

"/home/davep/"

"/home/davep/"
(expand-file-name "/var" "~")
"/var"
(expand-file-name "var" "~")
"/home/davep/var"

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
(defconst dp-common-abbrevs
  '((("wrt" "with respect to")
     dp-manual)
    (("teh" "the")
     dp-manual global)
    (("st" "such that" dp-manual))
    (("wether" "whether")
     dp-manual global)
    (("wheter" "whether")
     dp-manual global)
    (("thru" "through")
     dp-manual global)
    (("thot" "thought")
     dp-manual global)
    (("tho" "though")
     dp-manual global)
    (("dap" "David A. Panariti")
     dp-manual)
    (("te" "there exists")
     dp-manual)
    (("stl" "STL")
     dp-manual global)
    (("mobo" "motherboard")
     dp-manual)
    (("altho" "although")
     dp-manual global)
    (("kb" "keyboard")
     dp-manual)
    (("eg" "e.g.")
     dp-manual global)
    (("qv" "q.v.")
     dp-manual global)
    (("ie" "i.e.")
     dp-manual global)
    (("nb" "N.B.")
     dp-manual global)
    (("plz" "please")
     dp-manual global)
    (("sthg" "something")
     dp-manual global)
    (("iir" "if I recall")
     dp-manual global)
    (("Iir" "if I recall")
     dp-manual global)
    (("IIR" "if I recall")
     dp-manual global)
    (("appt" "appointment")
     dp-manual)
    (("appts" "appointments")
     dp-manual)
    (("ok" "OK")
     dp-manual global)
    (("fo" "of")
     dp-manual global)
    (("decl" "declaration")
     dp-manual global)
    (("decls" "declarations")
     dp-manual global)
    (("prob" "problem")
     dp-manual)
    (("probs" "problems")
     dp-manual)
    (("gui" "GUI")
     dp-manual global)
    (("bup" "backup")
     dp-manual global)
    (("bups" "backups")
     dp-manual global)
    (("khz" "KHz")
     dp-manual global)
    (("mhz" "MHz")
     dp-manual global)
    (("ghz" "GHz")
     dp-manual global)
    (("kbps" "Kbps")
     dp-manual global)
    (("gbps" "Gbps")
     dp-manual global)
    (("ns" "nS")
     dp-manual)
    (("ms" "mS")
     dp-manual)
    (("linux" "Linux")
     dp-manual global)
    (("thier" "their")
     dp-manual global)
    (("beleive" "believe")
     dp-manual global)
    (("yopp" "YOPP!")
     dp-manual)
    (("repos" "repository")
     dp-manual)
    (("e2ei" "RSVP-E2E-IGNORE")
     dp-manual)
    (("LARTC" "Linux Advanced Routing & Traffic Control HOWTO")
     dp-manual)
    (("lartc" "Linux Advanced Routing & Traffic Control HOWTO")
     dp-manual)
    (("pkt" "packet")
     dp-manual)
    (("lenght" "length")
     dp-manual global)
    (("recieve" "receive")
     dp-manual global)
    (("reciever" "receiver")
     dp-manual global)
    (("rxer" "receiver")
     dp-manual global)
    (("rxor" "receiver")
     dp-manual global)
    (("recv" "receive")
     dp-manual)
    (("nic" "NIC")
     dp-manual)
    (("tcp/ip" "TCP/IP")
     dp-manual global)
    (("udp" "UDP")
     dp-manual)
    (("q" "queue")
     dp-manual)
    (("enq" "enqueue")
     dp-manual)
    (("deq" "dequeue")
     dp-manual)
    (("xlation" "translation")
     dp-manual global)
    (("xmission" "transmission")
     dp-manual global)
    (("xmit" "transmit")
     dp-manual global)
    (("tx" "transmit")
     dp-manual)
    (("rx" "receive")
     dp-manual)
    (("seqs" "sequences")
     dp-manual)
    (("seq" "sequence")
     dp-manual)
    (("foriegn" "foreign")
     dp-manual global)
    (("yeild" "yield")
     global)
    (("peice" "piece")
     global)
    (("govt" "government")
     dp-manual global)
    (("wadr" "with all due respect")
     dp-manual global)
    (("atow" "at time of writing")
     dp-manual global)
    (("FHR" "for historical reasons")
     dp-manual)
    (("provate" "private")
     dp-manual global)
    (("yko" "echo")
     dp-manual global)
    (("lenght" "length")
     global)
    (("strenght" "strength")
     dp-manual global)
    (("WH" "White House")
     dp-manual)
    (("xemacs" "XEmacs")
     dp-manual global)
    (("python" "Python")
     dp-manual global)
    (("tcp" "TCP")
     dp-manual global)
    (("init" "initial")
     dp-manual global)))
;; We could just use the non-void-ness of dp-common-abbrevs, but I
;; like suspenders with my belt.
(put 'dp-common-abbrevs 'dp-I-am-a-dp-style-abbrev-file t)
(defconst dp-I-am-a-dp-style-abbrev-file t)

(nconc nil '(1 2 3))
(1 2 3)

(symbol-value nil)
nil

(intern-soft "nannynannybooboo")
nannynannybooboo

nil

(intern-soft 'nannynannybooboo)
nannynannybooboo



nil


(dp-add-abbrev0 "boo" "boo-ya-m-fers" '(dp-test-table global))

(dp-abbrevs)



(boundp (intern-soft "dp-manual-abbrev-table"))
nil

(boundp (intern "wallwallljdj"))
nil

(intern-soft "wallwallljdj")
wallwallljdj

(setq dp-111111 100)
100

(intern-soft "dp-111111")
dp-111111

dp-111111

(makunbound 'dp-111111)
dp-111111

dp-manual-abbrev-table


nil


t

nil

(boundp nil)
t

dp-manual-abbrev-table












(boundp 'dp-manual-abbrev-table)
dp-manual-abbrev-table
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

t

nil



(let ((doc-string "A string!!!")
      (new-table-name 'dp-bubba-abbrev-table))
  (eval `(defconst ,new-table-name ,(make-abbrev-table) ,doc-string)))
dp-bubba-abbrev-table

(define-abbrev-table)
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

dp-bubba-abbrev-table

"Blah!"

dp-bubba-abbrev-table
"Blah!"



(symbolp '(a))
nil

(and table-name
     (symbolp table-name)
     (not (intern-soft (format "%s-abbrev-table" table-name))))
t
(makunbound 'dp-manual-abbrev-table)
dp-manual-abbrev-table

========================
Monday September 22 2008
--
??? Why does an XEmacs shell end up different than a regular shell?
Inside the shell after rc-s, SHELL == /bin/bash ?

========================
Wednesday October 01 2008
--
;; (save-buffer &optional ARGS)

(interactive-form 'save-buffer)
(interactive "_p")


(defun dp-icall-test (&rest r)
  (interactive)
  (dmessage "before: this-command: %s" this-command)
  (call-interactively 'buffer-menu)
  (dmessage "after: this-command: %s" this-command))
(dp-icall-test)
"after: this-command: eval-print-last-sexp"




(defun dp-save-buffer (&optional args)
  (interactive "_p")

  ;; `save-buffer' uses prefix arg, so call it when `current-prefix-arg' so
  ;; it can do the special actions requested.
  (if (or current-prefix-arg
          ;; >= 2nd consecutive save.
          (eq last-command this-command))
      (progn
        ;; Do a real write
        (call-interactively 'save-buffer)
        ;; And pretend we were called that way.
        (dmessage "real save.")
        (setq this-command 'save-buffer))
    ;; Nothing special, just one of my all-too-often saves.  Call the
    ;; autosave function, which will autosave *all* buffers, humoring my
    ;; paranoia even more. 2 in a row will really save the buffer.  Contrary
    ;; to my earlier belief, saving a lot does not churn through the bumbered
    ;; backups since the file is backed up only after the first save.  See if
    ;; I like this.  An alternative is to save the current buffer but still
    ;; autosave all else.
    ;; This may have strange effects on undo.
    (do-auto-save)
    (dmessage "auto save.")))


(user-real-login-name)
"davep"
(user-login-name)
"davep"

(concat (dp-mk-dropping-dir
                                        "xemacs-session-auto-saves" nil t)
                                       (format "/xemacs-saves-%s-%s-%s(as: %s)@%s"
                                               (emacs-pid)
                                               (current-time)
                                               (user-real-login-name)
                                               (user-login-name)
                                               (system-name)))
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d/xemacs-saves-9664-(18660 338 569448)-davep(as: davep)@timberwolves.vanu.com"

(truncate (float-time (current-time)))

float-time



(+ 0 1222902202.187246)
1222902202.187246
(dp-timestamp-string)
"2008-10-01T19:09:47"

(dp-timestamp-string nil t)
"2008-10Oct-01T19:10:23"

(concat (dp-mk-dropping-dir
                                        "xemacs-session-auto-saves" nil t)
                                       (format "/%s-%s-%s-aka-%s@%s"
                                               (emacs-pid)
                                               (dp-timestamp-string)
                                               (user-real-login-name)
                                               (user-login-name)
                                               (system-name)))
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d/9664-2008-10-01T19:13:21-davep-aka-davep@timberwolves.vanu.com"

"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d/xemacs-saves-9664-2008-10-01T19:12:17-davep-aka-davep@timberwolves.vanu.com"



========================
Wednesday October 01 2008
--
(dp-grep-vars "\\.autosave")
(auto-save-hash-directory command-history dp-grep-history expr file-name-history)

(dp-grep-stringified-sym-vals "\\.autosave")
(auto-save-hash-directory)
(dp-grep-vars "\\.save")
(auto-save-list-file-name auto-save-list-file-prefix expr file-name-history)



buffer-auto-save-file-name
"/home/davep/editor-droppings/XEmacs/xemacs-auto-saves.d/#=2Fhome=2Fdavep=2Flisp=2Fdevel=2Felisp-devel.el#"

(make-auto-save-file-name)

auto-save-list-file-name 
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d13805-2008-10-01T20:58:46-davep-aka-davep@timberwolves.vanu.com"

"/home/davep/.saves-13144-timberwolves.vanu.com"

blah!

2000/60 = 33
auto-save-timeout
960/60 = 16


(do-auto-save)
nil

nil

nil

auto-saved
inhibit-auto-save-session
nil
(dp-mk-dropping-dir
 "xemacs-session-auto-saves")
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d"

(setq auto-save-list-file-prefix (dp-mk-dropping-dir
                             "xemacs-session-auto-saves" nil 'creat))
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d"

(concat auto-save-list-file-prefix
                                       (format "/%s-%s-%s-aka-%s@%s"
                                               (emacs-pid)
                                               (dp-timestamp-string)
                                               (user-real-login-name)
                                               (user-login-name)
                                               (system-name)))
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d/13805-2008-10-01T21:27:16-davep-aka-davep@timberwolves.vanu.com"


command-history
((ld "/home/davep/lisp/devel/elisp-devel.el" nil) (find-function (quote repeat-complex-command)) (ff) (find-function (quote rcc)) (ff) (rcc 1) (mb nil) (co nil))

minibuffer-history
("" "rcc" "dp-save-buffer" "auto-save-mode" "auto-save-list-file-prefix" "dp-shell0" "sfh" "delete-auto-save-file-if-necessary" "normal-backup-enable-predicate" "filenames" "2x2" "2w" "dp-face-list-at" "dp-face-at" "eca" "dp-shell-buffer-p" "dp-apply-or-value" "savehist-autosave" "VI_WITH" "vilog4cpp" "VI_WITH_" "dp-set-or-goto-bm" "dp-ssh" "dp-shell" "dp-visit-whence" "dse" "dp-save-and-redefine-abbrevs" "VIPC_MODULE" "_MODULES" "LOG4CPP" "_WITH_" "VIPC" "WITH" "dp-shell-dirtrack-other" "/bin/bash" "shell" "call-process" "calendar" "calendar-load-hook" "-i" "vpw" "comint-watch-for-password-prompt" "71" "ego" "savehist-save" "list-mode")

(concat (dp-mk-dropping-dir
                                          "/xemacs-session-auto-saves.d/"
                                          'leave-it-alone 'creat)
                                         (format "%s-%s-aka-%s-"
                                                 (dp-timestamp-string)
                                                 (user-real-login-name)
                                                 (user-login-name)))
"/home/davep/editor-droppings/XEmacs/xemacs-session-auto-saves.d/2008-10-01T21:47:00-davep-aka-davep-"


========================
Friday October 03 2008
--
(let* ((bounds '(370578 . 370601))
         (s (car bounds))
         (e (cdr bounds)))
    (dp-mark-region bounds))

dp-cons-to-list
(dp-cons-to-list nil)
nil
(dp-cons-to-list '(1 . b))
(1 b)

(1 b)



    
(defun dp-DooM-ed ())
         
(fboundp 'dp-DooM-ed)
nil

nil

t

t

(defun dp-build-co-comment-start (&optional differentiator start end
                                  read-as-last-resort-p)
  (setq-ifnil differentiator "CO"
              start comment-start
              end comment-end)
  (cond
   ((or t (not end) (string= end ""))
    ;; e.g. ; --> ;C;, ;; --> ;;C;,
    (string-match "^\\(.*?\\)\\(\\s-*\\)$" start)
    (concat (match-string 1 start) differentiator (substring start 0 1) 
            (or (match-string 2 start) "")))
    (read-as-last-resort-p 
     (read-from-minibuffer "Comment start: " (format "#%s# " differentiator)))))
                           
(cl-pp dpld-shell-modes-comint-input-filter-functions)


(shell-directory-tracker dp-shell-lookfor-dirty-buffer-cmds
                         dp-shell-lookfor-g-a-cmd
                         dp-shell-lookfor-vc-cmd
                         dp-shell-lookfor-shell-max-lines
                         dp-shell-lookfor-ls
                         dp-shell-lookfor-cls
                         t)

(defvar dp-sudo-validate-command dp-sudo-edit-sudoer
  "Call regular sudoer when (re)validating ourself.")

(defvar dp-sudo-validate-args '("-v")
  "Arg to sudo (specifically) to (re)validate.  If `dp-sudo-edit-sudoer'
changes, this may need to change.")

(defvar dp-sudo-validate-def-timeout '(30 0)
  "How long we wait for the sudoer to cough up a password prompt.
See `accept-process-output' for details of specifying a timeout.")

;; comint-watch-for-password-prompt


(defun dp-sudo-validate-filter (proc string)
  (dmessage "dp-dummy-filter, proc>%s<, string>%s<" proc string)
  (when (string-match comint-password-prompt-regexp string)
    (when (string-match "^[ \n\r\t\v\f\b\a]+" string)
      (setq string (replace-match "" t t string)))
    (process-send-string proc (concat (read-passwd string) "\n"))))
  
(defun dp-sudo-validate-sentinel (proc status-msg)
  (dmessage "dp-sudo-edit-validate-sentinel, proc>%s<" proc)
  (dmessage "dp-sudo-edit-validate-sentinel, pstat>%s<" (process-status proc))
  (dmessage "dp-sudo-edit-validate-sentinel, status msg>%s<" status-msg)
  (unless (eq 'closed (process-status proc))
    (set-process-sentinel proc nil)
    (throw 'dp-sudo-validate-done (process-exit-status proc))))
;;
;; unexp --> no program output, quick exit
;; exp --> program output, prompt user, send input, exit.
(defun dp-sudo-validate ()
  "See man 8 sudo."
  (interactive)
  ;; start-process, add `comint-watch-for-password-prompt', wait for exit.
  ;; if `comint-watch-for-password-prompt' saw a password prompt, 
  ;; it should have handled it.
  (let ((sudo-proc (apply 'start-process 
                          "sudo validation"
                          nil
                          dp-sudo-validate-command  
                          dp-sudo-validate-args))
        pstat)
    (set-process-sentinel sudo-proc 'dp-sudo-validate-sentinel)
    (set-process-filter sudo-proc 'dp-sudo-validate-filter)
    (setq pstat
          (catch 'dp-sudo-validate-done
            (while t
              ;; Wait 30 sec for prompt to appear.
              (if (apply 'accept-process-output 
                         sudo-proc 'dp-sudo-validate-def-timeout)
                  (dmessage "got some input.  Bad passwd?")
                ;; No output rx'd.  Since we're just waiting for the program to
                ;; give us a prompt, something must be wrong.  If we do get
                ;; output, we'll handle it in the sentinel and that will throw
                ;; back to us.
                ;; Kill the sob.
                (dmessage "Timed out waiting for %s to start up." 
                          dp-sudo-validate-command)
                (process-send-signal 9 sudo-proc)
                (error 'process-error 
                       (format "Timed out waiting for %s to start up." 
                               dp-sudo-validate-command))))))
    (if (equal pstat 0)
        ;; This'll get stomped immediately by the file name prompt.
        (message "Validation successful.")
      (error 'process-error (format "%s: Validation failed: %s" 
                                    dp-sudo-validate-command pstat)))))

    
(call-process "exit-with-x" nil nil nil "5")
5


0

1




========================
Monday October 06 2008
--

hi there, parenthesize me!  No trailing spaces.
hi there, parenthesize me!  Some trailing spaces.!!!
hi there, parenthesize me!  Some trailing spaces.!!!
hi there, parenthesize me!  Some trailing spaces.   ^


(defun* dp-parenthesize-region-old (index &optional pre suf
                                (region-marker-func 'dp-to-end-of-line-cons)
                                (region-marker-func-args '()))
  "Wrap the region in paren like characters. INDEX is 1 based."
  (interactive "*P")
  ;;(dmessage "lc: %s, tc: %s" last-command this-command)
  (let* ((sticky-p (or (and (null index)
                            (dp-parenthesize-region-info-sticky-p
                             dp-current-parenthesize-region-info))))
         (iterating-p (eq last-command this-command))
         (paren-list (or (dp-mode-local-value 
                          'dp-parenthesize-region-paren-list 
                          major-mode)
                         dp-parenthesize-region-paren-list))
         (index (cond
                  ((eq index '-)
                   ;; INDEX doesn't matter since we check for pre and suf
                   ;; being set before we use INDEX.  But this must be done
                   ;; before INDEX is used numerically.
                   (setq pre "{\n" suf "}\n"))
                  ;; Set here so no other case may change it accidentally.
                  ((equal index 0) 0)
                  ;; We need to check for index < 0 down here and set
                  ;; sticky-p so that we can initialize INDEX rather than
                  ;; grabbing what is currently in the info structure.  But,
                  ;; if we have no INDEX set, then we want to use the last
                  ;; value of the sticky bit and, if set, the last value of
                  ;; INDEX.
                  ((and (numberp index) 
                       (< index 0))
                   (setq sticky-p t)
                   (abs index))
                  ((or iterating-p
                       sticky-p)
                   ;; Below, STICKY-P leaves index alone while ITERATING-P
                   ;; increments it.  In either case, INDEX is set properly.
                   (dp-parenthesize-region-info-index 
                    dp-current-parenthesize-region-info))
                  ((numberp index) (abs index))
                  ((and index (listp index)) (dp-num-C-u index))
                  ;; Make it one based so we can use C-0 to modify behavior.
                  (t 1)))
         (parens (nth (% (1- index) (length paren-list)) paren-list))
         (pre (or pre (car parens)))
         (suf (or suf (cdr parens)))
         (beg-end (if iterating-p 
                      (dp-parenthesize-region-info-region 
                       dp-current-parenthesize-region-info)
                    (dp-region-or... :bounder 'rest-or-all-of-line-p)))
         (beg (car beg-end))
         (end (dp-mk-marker (cdr beg-end))))
    (if (and (equal index 0)
             dp-parenthesize-region-original-text-info
             iterating)
        (dp-parenthesize-region-restore-orginal-text)
      (unless iterating-p
        (setq dp-parenthesize-region-original-text-info
              (list (buffer-substring beg end) beg end))
        (undo-boundary))
      (save-excursion
        (goto-char beg)
        (if iterating-p
            (delete-char (dp-parenthesize-region-info-pre-len 
                          dp-current-parenthesize-region-info)))
        (insert pre)
        (goto-char end)
        (if iterating-p
            (delete-char (dp-parenthesize-region-info-suf-len 
                          dp-current-parenthesize-region-info)))
        (insert suf)
        (when (dp-in-c)
          (c-indent-region beg (point))))
      (setq dp-current-parenthesize-region-info
            (make-dp-parenthesize-region-info
             :sticky-p sticky-p
             :index (if sticky-p
                        index
                      (1+ index))
             :region (cons (dp-mk-marker beg) end)
             :pre-len (length pre)
             :suf-len (length suf))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


========================
Tuesday October 07 2008
--

(loop for x in (list (standard-syntax-table) text-mode-syntax-table c-mode-syntax-table
                     emacs-lisp-mode-syntax-table) do
                     (describe-syntax-table x (current-buffer))
                     (princf "---------------------------------"))
^@ .. ^H	. 	meaning: punctuation
^I	  	meaning: whitespace
^J .. ^K	. 	meaning: punctuation
^L .. ^M	  	meaning: whitespace
^N .. ^_	. 	meaning: punctuation
 	  	meaning: whitespace
!	. 	meaning: punctuation
"	" 	meaning: string-quote
#	. 	meaning: punctuation
&	_ 	meaning: symbol-constituent
'	. 	meaning: punctuation
(	()	meaning: open-paren, matches )
)	)(	meaning: close-paren, matches (
* .. +	_ 	meaning: symbol-constituent
,	. 	meaning: punctuation
-	_ 	meaning: symbol-constituent
.	. 	meaning: punctuation
/	_ 	meaning: symbol-constituent
: .. ;	. 	meaning: punctuation
< .. >	_ 	meaning: symbol-constituent
? .. @	. 	meaning: punctuation
[	(]	meaning: open-paren, matches ]
\	\ 	meaning: escape
]	)[	meaning: close-paren, matches [
^	. 	meaning: punctuation
_	_ 	meaning: symbol-constituent
`	. 	meaning: punctuation
{	(}	meaning: open-paren, matches }
|	_ 	meaning: symbol-constituent
}	){	meaning: close-paren, matches {
~ .. ^?	. 	meaning: punctuation
\200 .. \237	. 	meaning: punctuation
-A 	_ 	meaning: symbol-constituent
-A!	. 	meaning: punctuation
-A" .. *	_ 	meaning: symbol-constituent
-A+	. 	meaning: punctuation
-A, .. :	_ 	meaning: symbol-constituent
-A;	. 	meaning: punctuation
-A< .. ?	_ 	meaning: symbol-constituent
-AW	. 	meaning: punctuation
-Aw	. 	meaning: punctuation
-B 	_ 	meaning: symbol-constituent
-B"	_ 	meaning: symbol-constituent
-B$	_ 	meaning: symbol-constituent
-B' .. (	_ 	meaning: symbol-constituent
-B-	_ 	meaning: symbol-constituent
-B0	_ 	meaning: symbol-constituent
-B2	_ 	meaning: symbol-constituent
-B4	_ 	meaning: symbol-constituent
-B7 .. 8	_ 	meaning: symbol-constituent
-B=	_ 	meaning: symbol-constituent
-BW	. 	meaning: punctuation
-Bw	. 	meaning: punctuation
-B	_ 	meaning: symbol-constituent
-C 	_ 	meaning: symbol-constituent
-C" .. $	_ 	meaning: symbol-constituent
-C' .. (	_ 	meaning: symbol-constituent
-C-	_ 	meaning: symbol-constituent
-C0	_ 	meaning: symbol-constituent
-C2 .. 5	_ 	meaning: symbol-constituent
-C7 .. 8	_ 	meaning: symbol-constituent
-C=	_ 	meaning: symbol-constituent
-CW	. 	meaning: punctuation
-Cw	. 	meaning: punctuation
-C	_ 	meaning: symbol-constituent
-D 	_ 	meaning: symbol-constituent
-D$	_ 	meaning: symbol-constituent
-D' .. (	_ 	meaning: symbol-constituent
-D-	_ 	meaning: symbol-constituent
-D0	_ 	meaning: symbol-constituent
-D2	_ 	meaning: symbol-constituent
-D4	_ 	meaning: symbol-constituent
-D7 .. 8	_ 	meaning: symbol-constituent
-DW	. 	meaning: punctuation
-Dw	. 	meaning: punctuation
-D	_ 	meaning: symbol-constituent
-F 	_ 	meaning: symbol-constituent
-F! .. "	. 	meaning: punctuation
-F# .. *	_ 	meaning: symbol-constituent
-F+	. 	meaning: punctuation
-F, .. -	_ 	meaning: symbol-constituent
-F/ .. 5	_ 	meaning: symbol-constituent
-F7	_ 	meaning: symbol-constituent
-F;	. 	meaning: punctuation
-F=	_ 	meaning: symbol-constituent
[2]-H [0]	w 	meaning: word-constituent
[2]-H`[0] .. [2]z[0]	w 	meaning: word-constituent
katakana-jisx0201	w 	meaning: word-constituent
-L 	_ 	meaning: symbol-constituent
-L-	_ 	meaning: symbol-constituent
-Lp	. 	meaning: punctuation
-L}	_ 	meaning: symbol-constituent
-M 	_ 	meaning: symbol-constituent
-M!	. 	meaning: punctuation
-M" .. *	_ 	meaning: symbol-constituent
-M+	. 	meaning: punctuation
-M, .. :	_ 	meaning: symbol-constituent
-M;	. 	meaning: punctuation
-M< .. ?	_ 	meaning: symbol-constituent
-M@ .. V	w 	meaning: word-constituent
-MW	. 	meaning: punctuation
-MX .. v	w 	meaning: word-constituent
-Mw	. 	meaning: punctuation
-Mx .. 	w 	meaning: word-constituent
-b 	_ 	meaning: symbol-constituent
-b!	. 	meaning: punctuation
-b" .. %	_ 	meaning: symbol-constituent
-b&	w 	meaning: word-constituent
-b'	_ 	meaning: symbol-constituent
-b(	w 	meaning: word-constituent
-b) .. *	_ 	meaning: symbol-constituent
-b+	. 	meaning: punctuation
-b, .. 3	_ 	meaning: symbol-constituent
-b4	w 	meaning: word-constituent
-b5 .. 7	_ 	meaning: symbol-constituent
-b8	w 	meaning: word-constituent
-b9 .. :	_ 	meaning: symbol-constituent
-b;	. 	meaning: punctuation
-b< .. >	w 	meaning: word-constituent
-b?	_ 	meaning: symbol-constituent
-b@ .. V	w 	meaning: word-constituent
-bW	. 	meaning: punctuation
-bX .. v	w 	meaning: word-constituent
-bw	. 	meaning: punctuation
-bx .. 	w 	meaning: word-constituent
chinese-gb2312, rows 33 .. 34	. 	meaning: punctuation
chinese-gb2312, rows 35 .. 40	w 	meaning: word-constituent
chinese-gb2312, row 41	. 	meaning: punctuation
chinese-gb2312, rows 42 .. 126	w 	meaning: word-constituent
$(B!!(B .. $(B!*(B	_ 	meaning: symbol-constituent
$(B!+(B .. $(B!,(B	w 	meaning: word-constituent
$(B!-(B .. $(B!2(B	_ 	meaning: symbol-constituent
$(B!3(B .. $(B!<(B	w 	meaning: word-constituent
$(B!=(B .. $(B!I(B	_ 	meaning: symbol-constituent
$(B!J(B	($(B!K(B	meaning: open-paren, matches $(B!K(B
$(B!K(B	)$(B!J(B	meaning: close-paren, matches $(B!J(B
$(B!L(B .. $(B!M(B	_ 	meaning: symbol-constituent
$(B!N(B	($(B!O(B	meaning: open-paren, matches $(B!O(B
$(B!O(B	)$(B!N(B	meaning: close-paren, matches $(B!N(B
$(B!P(B	($(B!Q(B	meaning: open-paren, matches $(B!Q(B
$(B!Q(B	)$(B!P(B	meaning: close-paren, matches $(B!P(B
$(B!R(B .. $(B!U(B	_ 	meaning: symbol-constituent
$(B!V(B	($(B!W(B	meaning: open-paren, matches $(B!W(B
$(B!W(B	)$(B!V(B	meaning: close-paren, matches $(B!V(B
$(B!X(B	($(B!Y(B	meaning: open-paren, matches $(B!Y(B
$(B!Y(B	)$(B!X(B	meaning: close-paren, matches $(B!X(B
$(B!Z(B .. $(B!~(B	_ 	meaning: symbol-constituent
japanese-jisx0208, row 34	_ 	meaning: symbol-constituent
japanese-jisx0208, rows 35 .. 39	w 	meaning: word-constituent
japanese-jisx0208, row 40	_ 	meaning: symbol-constituent
japanese-jisx0208, rows 41 .. 126	w 	meaning: word-constituent
korean-ksc5601, rows 33 .. 34	. 	meaning: punctuation
korean-ksc5601, rows 35 .. 37	w 	meaning: word-constituent
korean-ksc5601, rows 38 .. 41	. 	meaning: punctuation
korean-ksc5601, rows 42 .. 126	w 	meaning: word-constituent
japanese-jisx0212	w 	meaning: word-constituent
chinese-cns11643-1	w 	meaning: word-constituent
chinese-cns11643-2	w 	meaning: word-constituent
chinese-big5-1	w 	meaning: word-constituent
chinese-big5-2	w 	meaning: word-constituent
-_ 	_ 	meaning: symbol-constituent
-_#	_ 	meaning: symbol-constituent
-_'	_ 	meaning: symbol-constituent
-_)	_ 	meaning: symbol-constituent
-_- .. .	_ 	meaning: symbol-constituent
-_6	_ 	meaning: symbol-constituent
-f 	_ 	meaning: symbol-constituent
-f$	_ 	meaning: symbol-constituent
-f%	. 	meaning: punctuation
-f'	_ 	meaning: symbol-constituent
-f)	_ 	meaning: symbol-constituent
-f+	. 	meaning: punctuation
-f-	_ 	meaning: symbol-constituent
-f0 .. 1	_ 	meaning: symbol-constituent
-f5	. 	meaning: punctuation
-f6 .. 7	_ 	meaning: symbol-constituent
-f;	. 	meaning: punctuation
vietnamese-viscii-upper	w 	meaning: word-constituent
vietnamese-viscii-lower	w 	meaning: word-constituent
chinese-cns11643-3	w 	meaning: word-constituent
chinese-cns11643-4	w 	meaning: word-constituent
chinese-cns11643-5	w 	meaning: word-constituent
chinese-cns11643-6	w 	meaning: word-constituent
chinese-cns11643-7	w 	meaning: word-constituent
thai-xtis, rows 33 .. 78	w 	meaning: word-constituent
thai-xtis, row 79	_ 	meaning: symbol-constituent
thai-xtis, row 80	w 	meaning: word-constituent
thai-xtis, rows 82 .. 83	w 	meaning: word-constituent
thai-xtis, row 95	_ 	meaning: symbol-constituent
thai-xtis, rows 96 .. 101	w 	meaning: word-constituent
thai-xtis, row 102	_ 	meaning: symbol-constituent
thai-xtis, row 111	_ 	meaning: symbol-constituent
thai-xtis, rows 112 .. 121	w 	meaning: word-constituent
thai-xtis, rows 122 .. 123	_ 	meaning: symbol-constituent
---------------------------------
"	. 	meaning: punctuation
'	w 	meaning: word-constituent
\	. 	meaning: punctuation
---------------------------------
^J	> b	meaning: comment-end, style B
^M	> b	meaning: comment-end, style B
% .. &	. 	meaning: punctuation
'	" 	meaning: string-quote
*	. 23	meaning: punctuation,
				 second character of comment-start sequence A,
				 first character of comment-end sequence A
+	. 	meaning: punctuation
-	. 	meaning: punctuation
/	. 1456	meaning: punctuation,
				 first character of comment-start sequence A,
				 second character of comment-end sequence A,
				 first character of comment-start sequence B,
				 second character of comment-start sequence B
< .. >	. 	meaning: punctuation
\	\ 	meaning: escape
_	_ 	meaning: symbol-constituent
|	. 	meaning: punctuation
-A 	. 	meaning: punctuation
---------------------------------
^@ .. ^H	_ 	meaning: symbol-constituent
^I	  	meaning: whitespace
^J	>  	meaning: comment-end, style A
^K	_ 	meaning: symbol-constituent
^L	  	meaning: whitespace
^M	>  	meaning: comment-end, style A
^N .. ^_	_ 	meaning: symbol-constituent
 	  	meaning: whitespace
!	_ 	meaning: symbol-constituent
"	" 	meaning: string-quote
#	' 	meaning: expression-prefix
$ .. &	_ 	meaning: symbol-constituent
'	' 	meaning: expression-prefix
(	()	meaning: open-paren, matches )
)	)(	meaning: close-paren, matches (
* .. +	_ 	meaning: symbol-constituent
,	' 	meaning: expression-prefix
- .. /	_ 	meaning: symbol-constituent
:	_ 	meaning: symbol-constituent
;	<  	meaning: comment-begin, style A
< .. @	_ 	meaning: symbol-constituent
[	(]	meaning: open-paren, matches ]
\	\ 	meaning: escape
]	)[	meaning: close-paren, matches [
^ .. _	_ 	meaning: symbol-constituent
`	' 	meaning: expression-prefix
{ .. ^?	_ 	meaning: symbol-constituent
---------------------------------
nil




========================
Wednesday October 08 2008
--
(dp-get-locale-rcs)
("Linux" "vanu" "vanu-linux" "timberwolves" "xscale_port")


(dp-regexp-concat (dp-get-locale-rcs))
"Linux\\|vanu\\|vanu-linux\\|timberwolves\\|xscale_port"


(defun dp-rc-file-list (&rest dp-flatten-list-args)
  (apply 'dp-flatten-list
         (mapcar (lambda (locale)
                   (mapcar (lambda (rc-file)
                             (concat rc-file "." locale))
                           ;;!<@todo make this a var or a parameter. 
                           '("func" "alias" "env")))
                 (dp-get-locale-rcs))
         dp-flatten-list-args))
(dp-rc-file-list)
        
(defvar dp-shell-hostile-chars
  (concat dp-ws+newline "{}()\\/!@#$%^&*;'\"<>?|")
  "Characters that require escaping or other annoyances in the shell.")

(defvar dp-shell-hostile-chars-regexp
  (concat "\\([" dps "]\\)" "\\|"  "\\(\\|\\[\\|\\]" "]\\)")
  "Detect those bothersome characters.")

(defvar dp-default-shellify-replacement-str ""
  "Use this string by default when cleaning up a string to be used as a file name.")

(defun dp-shellify-shell-name (name &optional args)
  (let* ((replacement-str (or (car args) dp-default-shellify-replacement-str))
         (new-name (replace-regexp-in-string dp-shell-hostile-chars-regexp
                                             replacement-str
                                             name)))
    
    (concat "dp-shell-session-" new-name (dp-timestamp-string))))

(dp-timestamp-string)
"2008-10-08T14:54:14"



(defun dp-auto-save-buffer-contents* (&optional 
                                      (name-transformer 'dp-shellify-shell-name)
                                      (transformer-args '()))
  "Useful as a `kill-buffer-hook' for buffers with no associated file, esp shell buffers."
  (let (file-name (apply 'name-transformer (buffer-name)
                         transformer-args))
    (if file-name
        (write-region (point) (point-max) file-name)
      (error 'invalid-argument "buffer name not transformed."))))

(dp-shellify-shell-name "*shell*<0>" '(""))
"dp-shell-session-shell02008-10-08T14:59:55"


"dp-shell-session-..s.h.e.l.l...0.2008-10-08T14:59:13"



