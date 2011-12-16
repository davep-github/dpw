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

[[[[[[[[[[[[[[[[[[[[!]]]]]]]]]]]]]]]]]]]]
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
(defun dp-C-flatten-func-def ()
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

(defun dp-C-format-func-def (&optional no-nl-after-open-paren)
  "Format a C/C++ function definition header *my* way."
  (interactive "P")
  (undo-boundary)
  (save-excursion
    (beginning-of-line)
    (dp-C-flatten-func-def)
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
Friday July 06 2007
--

(setq browse-url-browser-function 'browse-url-firefox)
browse-url-firefox


========================
Thursday July 26 2007
--
(defmacro dp-define-date-function (name docstring &rest body)
  "Macro to generate functions which take convenient date args."
  (unless (stringp docstring)
    (setq body (cons docstring body))
    (setq docstring "Lazy bastard provided no doc."))
  `(defun ,name (&optional start-month end-month start-year 
			   end-year)
     ,docstring
     (interactive)
     (unless start-month
       (setq start-month (dp-current-month)))
     (unless end-month
       (setq end-month start-month))
     (unless start-year
       (setq start-year (dp-current-year)))
     (unless end-year
       (setq end-year start-year))
     ,@body
     ))
dp-define-date-function

(cl-pe
'(dp-define-date-function dp-diary-entries-to-pcal
  "Convert diary entries to pcal entries."
  (let ((appts (dp-get-diary-entries start-month end-month 
				     start-year end-year))
	(buf-name (generate-new-buffer-name "*pcal-output*")))
    (switch-to-buffer buf-name)
    (erase-buffer)
    (dolist (diary-entry appts)
      (let ((date (third diary-entry))
	    (appt (second diary-entry)))
	;(dmessage "date>%s<, appt>%s<" date appt)
	(string-match "\\s-*\\(.*\\)" appt)
	(setq appt (match-string 1 appt))
	(insert (format "%s\t%s\n" date appt)))))))

(defun dp-diary-entries-to-pcal (&optional start-month
                                 end-month
                                 start-year
                                 end-year)
  "Convert diary entries to pcal entries."
  (interactive)
  (if start-month nil (setq start-month (dp-current-month)))
  (if end-month nil (setq end-month start-month))
  (if start-year nil (setq start-year (dp-current-year)))
  (if end-year nil (setq end-year start-year))
  (let ((appts (dp-get-diary-entries start-month
                                     end-month
                                     start-year
                                     end-year))
        (buf-name (generate-new-buffer-name "*pcal-output*")))
    (switch-to-buffer buf-name)
    (erase-buffer)
    (block nil (let ((--dolist-temp--44745 appts) diary-entry) (while --dolist-temp--44745 (setq diary-entry (car --dolist-temp--44745)) (let ((date (third diary-entry)) (appt (second diary-entry))) (string-match "\\s-*\\(.*\\)" appt) (setq appt (match-string 1 appt)) (insert (format "%s	%s
" date appt))) (setq --dolist-temp--44745 (cdr --dolist-temp--44745))) nil))))nil



(defun dp-diary-entries-to-pcal (&optional start-month
                                 end-month
                                 start-year
                                 end-year)
  "Convert diary entries to pcal entries."
  (interactive)
  (if start-month nil (setq start-month (dp-current-month)))
  (if end-month nil (setq end-month start-month))
  (if start-year nil (setq start-year (dp-current-year)))
  (if end-year nil (setq end-year start-year))
  (interactive)
  (let ((appts (dp-get-diary-entries start-month
                                     end-month
                                     start-year
                                     end-year))
        (buf-name (generate-new-buffer-name "*pcal-output*")))
    (switch-to-buffer buf-name)
    (erase-buffer)
    (block nil (let ((--dolist-temp--44742 appts) diary-entry) (while --dolist-temp--44742 (setq diary-entry (car --dolist-temp--44742)) (let ((date (third diary-entry)) (appt (second diary-entry))) (string-match "\\s-*\\(.*\\)" appt) (setq appt (match-string 1 appt)) (insert (format "%s	%s
" date appt))) (setq --dolist-temp--44742 (cdr --dolist-temp--44742))) nil))))nil






========================
Friday July 27 2007
--
(defun dp-sym-info (sym)
  (interactive "Ssym-name: ")
  (if (not (symbolp sym))
      (format "argument `%s' is not a symbol name." sym)
    (format "symbol: %s\nname: %s\nvalue: %S\nfunction: %S\nplist: %S"
            sym
            (symbol-name sym)
            (if (boundp sym)
                (symbol-value sym)
              '*void*)
            (if (fboundp sym)
                (symbol-function sym)
              '*void*)
            (symbol-plist sym))))

(put 'boo 'ima-boo 'of\ course)
of\ course

"of course"

(message "%s" (dp-sym-info 3))
"argument `3' is not a symbol name."

"3 is not a symbol name."

"symbol: noo
name: noo
value: *void*
function: *void*
plist: nil"

"symbol: boo
name: boo
value: \"hoo\"
function: *void*
plist: (ima-boo \"of course\")"

"symbol: boo
name: boo
value: \"hoo\"
function: \"not a function\"
plist: (ima-boo \"of course\")"


"symbol: foo
name: foo
value: \"*void*\"
function: \"not a function\"
plist: nil"



(setq boo "hoo")
"hoo"


(dp-sym-info 'dp-sym-info)
"symbol: dp-sym-info
name: dp-sym-info
value: \"*void*\"
function: (lambda (sym) (interactive \"Ssym-name: \") (if (not (symbolp sym)) (format \"%s is not a symbol name.\" sym) (format \"symbol: %s
name: %s
value: %S
function: %S
plist: %S\" sym (symbol-name sym) (if (boundp sym) (symbol-value sym) \"*void*\") (if (fboundp sym) (symbol-function sym) \"not a function\") (symbol-plist sym))))
plist: nil"

"symbol: boo
name: boo
value: \"hoo\"
function: \"not a function\"
plist: (ima-boo t)"




"symbol: boo
name: boo
value: \"hoo\"
function: not a function
plist: (ima-boo t)"

(princf "%s" "symbol: boo
name: boo
value: \"hoo\"
function: not a function
plist: (ima-boo t)\n")
symbol: boo
name: boo
value: "hoo"
function: not a function
plist: (ima-boo t)
nil

(message "%S" "symbol: boo
name: boo
value: \"hoo\"
function: not a function
plist: (ima-boo t)")
"\"symbol: boo
name: boo
value: \\\"hoo\\\"
function: not a function
plist: (ima-boo t)\""

"symbol: boo
name: boo
value: \"hoo\"
function: not a function
plist: (ima-boo t)"


"symbol: boo
name: boo
value: shoo
function: not a function
plist: (ima-boo t)"


(dp-sym-info 'dp-sym-info)
"symbol: dp-sym-info
name: dp-sym-info
value: *void*
function: (lambda (sym) (interactive Ssym-name: ) (if (not (symbolp sym)) (format %s is not a symbol name. sym) (format symbol: %s
name: %s
value: %s
function: %s
plist: %s sym (symbol-name sym) (if (boundp sym) (symbol-value sym) *void*) (if (fboundp sym) (symbol-function sym) not a function) (symbol-plist sym))))
plist: nil"



"symbol: shoo
name: shoo
value: *void*
function: not a function
plist: nil"

"symbol: boo
name: boo
value: shoo
function: not a function
plist: (ima-boo t)"

"symbol: boo
name: boo
value: hoo
function: not a function
plist: (ima-boo t)"

"symbol: boo
name: boo
value: *void*
function: not a function
plist: (ima-boo t)"

"symbol: boo
name: boo
value: *void*
function: not a function
plist: nil"




q

========================
Saturday July 28 2007
--
(setq bubba "bubba")

(mapatoms (lambda (sym)
            (when (and (boundp sym)
                       (stringp (symbol-value sym))
                       (string-match "optim" (symbol-value sym)))
              (princf "s>%s<, v>%s<\n" sym (symbol-value sym)))))
s>isearch-string<, v>byte-optimize<
s>isearch-message<, v>byte-optimize<
nil












(setq dp-orig-require-func 'require)
require NAME ARGLIST [DOCSTRING] BODY...)
(require FEATURE &optional FILENAME NOERROR))
(defun dp-require (feature &optional filename noerror)
  (when)
  
(defadvice require (before dp-require act)
  (when (ad-get-arg))
)
