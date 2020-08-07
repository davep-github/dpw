(defun magit-log-format-margin (author date)
  (-when-let (option (magit-margin-option))
    (-let [(_ style width details details-width)
           (or magit-buffer-margin
               (symbol-value option))]
      (magit-make-margin-overlay
       (concat (and details
                    (concat (propertize (truncate-string-to-width
                                         (or author "")
                                         details-width
                                         nil ?\s (make-string 1 magit-ellipsis))
                                        'face 'magit-log-author)
                            " "))
               (propertize
                (if (stringp style)
                    (format-time-string
                     style
                     (seconds-to-time (string-to-number date)))
                  (-let* ((abbr (eq style 'age-abbreviated))
                          ((cnt unit) (magit--age date abbr)))
                    (format (format (if abbr "%%2i%%-%ic" "%%2i %%-%is")
                                    (- (funcall width style details details-width)
				       (if details (1+ details-width) 0)))
                            cnt unit)))
                'face 'magit-log-date))))))


magit-log-margin-width
style details details-width

========================
Friday April 27 2018
--
(memq nil '(1 2 nil -))
(nil -)

(defvar redisplay-highlight-region-function
  (lambda (start end window rol)
    (if (not (overlayp rol))
        (let ((nrol (make-overlay start end)))
          (funcall redisplay-unhighlight-region-function rol)
          (overlay-put nrol 'window window)
          (overlay-put nrol 'face 'region)
          ;; Normal priority so that a large region doesn't hide all the
          ;; overlays within it, but high secondary priority so that if it
          ;; ends/starts in the middle of a small overlay, that small overlay
          ;; won't hide the region's boundaries.
          (overlay-put nrol 'priority '(999 . 10000))
          nrol)
      (unless (and (eq (overlay-buffer rol) (current-buffer))
                   (eq (overlay-start rol) start)
                   (eq (overlay-end rol) end))
        (move-overlay rol start end (current-buffer)))
      rol)))


========================
Wednesday May 09 2018
--
problem:
Debugger entered--Lisp error: (error "Invalid use of in replacement text"q)
  replace-match("\\\"" nil nil "\"" nil)
  replace-regexp-in-string("\"" "\\\"" "aa\\bb\"cc" nil nil)
  replace-in-string("aa\\bb\"cc" "\"" "\\\"")
  (let ((s "aa\\bb\"cc")) (princf "s>%s<" s) (message "s>%s<" s) (replace-in-string s "\"" "\\\""))
  eval((let ((s "aa\\bb\"cc")) (princf "s>%s<" s) (message "s>%s<" s) (replace-in-string s "\"" "\\\"")) nil)
  elisp--eval-last-sexp(t)
  eval-last-sexp(t)
  eval-print-last-sexp(nil)
  funcall-interactively(eval-print-last-sexp nil)
  call-interactively(eval-print-last-sexp nil nil)
  command-execute(eval-print-last-sexp)


simplification:
(let ((s "aa\\bb\"cc")
      (r "\\\"")
      (z 2))
  (princf "s>%s<" s)
  (message "s>%s<" s)
  ;;(replace-in-string s "\"" "\\\\\"")
  (setq z (replace-in-string s "\"" "\\\"" t))
  (princf "z>%s<" z)
  )
s>aa\bb"cc<
z>aa\bb\"cc<
nil

s>aa\bb"cc<
z>aa\bb\"cc<
nil

s>aa\bb"cc<
z>aa\bb\"cc<
nil

s>aa\bb"cc<
t>aa\bb\"cc<
nil

s>aa\bb"cc<
t>2<
nil

s>aa\bb"cc<






s>aa\bb"cc<
"aa\\bb\\\"cc"


s>aa\bb"cc<

s>aa\bb"cc<
"
(princf "s1>%s< s2>%s<" "\"" "\\\"")
s1>"< s2>\"<
nil
"
", \"

nil


s>ab\cd<
"ab\\cd"

s>ab\cd<

s>ab\cd<
"s>ab\\cd<"

(princf "\"")
"
nil
"
(princf "aa\\bb\"cc")
aa\bb"cc
nil

(princf "\\\"")
\"
nil

"
nil

\
nil


s>ab\cd<
nil

"
(comint-quote-filename "aaa\"bbb")
"aaa\"bbb"
  
"aaa\"bbb"

(defun dpa (@begin @end)
  (interactive)
  )
dpa

========================
Saturday May 19 2018
--

(read-file-name PROMPT
		&optional DIR DEFAULT-FILENAME MUSTMATCH INITIAL PREDICATE)

(read-file-name "prompt: " dp-sudo-edit-tramp-local-prefix
		"DEFAULT-FILENAME"
		nil
		default-directory)
"/sudo:root@localhost:/etc/init.d"


"/sudo:root@localhost:/home/davep/flisp/ec"


"/sudo:root@localhost:/etc/default/"



========================
Wednesday June 13 2018
--
(defun ffap-other-window ()
  "Like `ffap', but put buffer in another window.
Only intended for interactive use."
  (interactive)
  (pcase (save-window-excursion (call-interactively 'ffap))
    ((or (and (pred bufferp) b) `(,(and (pred bufferp) b) . ,_))
     (switch-to-buffer-other-window b))))
ffap-other-window


(cl-pe
'(pcase (save-window-excursion (call-interactively 'ffap))
    ((or (and (pred bufferp) b) `(,(and (pred bufferp) b) . ,_))
     (switch-to-buffer-other-window b)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let* ((val (let ((wconfig (current-window-configuration)))
	      (unwind-protect
		  (progn
		    (call-interactively 'ffap))
		(set-window-configuration wconfig)))))
  (cond ((bufferp val)
	 (let ((b val))
	   (switch-to-buffer-other-window b)))
	((consp val)
	 (let* ((x (car val)))
	   (if (bufferp x)
	       (let ((b x))
		 (switch-to-buffer-other-window b))
	     nil)))
	(t nil)))nil


(cl-pe '(pcase (save-window-excursion (call-interactively 'ffap))
    ((or (and (pred bufferp) b) `(,(and (pred bufferp) b) . ,_))
     (switch-to-buffer-other-window b)))
       )

(defun blah ()
  (interactive)
  (let* ((val (let ((wconfig (current-window-configuration)))
		(unwind-protect
		    (progn
		      (call-interactively 'ffap))
		  (set-window-configuration wconfig)))))
    (cond ((bufferp val)
	   (let ((b val))
	     (switch-to-buffer-other-window b)))
	  ((consp val)
	   (let* ((x (car val)))
	     (if (bufferp x)
		 (let ((b x))
		   (switch-to-buffer-other-window b))
	       nil)))
	  (t nil))))

(pred nil)

========================
Tuesday June 19 2018
--


(defun dp-add-font-patterns (list-o-modes buffer-local-p list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES.
This function is different from the XEmacs version which uses a
mechanism which restores a variable to its original state and
then applies changes."
  (setq list-o-modes (dp-listify-thing list-o-modes)
	list-o-keys (dp-listify-thing list-o-keys))
  (loop for mode in list-o-modes do
	(progn
	  (when buffer-local-p
	    (make-variable-buffer-local mode))
	  (font-lock-add-keywords mode list-o-keys 'append))))

(defun dp-add-to-font-patterns (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES.
This function uses a mechanism which restores a variable to its original
state and then applies changes. This is good... sometimes."
  ;; Icky... the lambda uses variables from the current environment.
  (loop for mode in list-o-modes do
    (loop for key in list-o-keys do
      (font-lock-add-keywords mode key t))))

;; (defun* dp-add-line-too-long-font (font-lock-var-syms
;;                                    &key (buffer-local-p t))
;;   "WARNING: This function uses `dp-add-font-patterns' which resets the fonts.
;; `dp-add-font-patterns' uses a mechanism which restores a variable to its
;; original state and then applies changes. This is good... sometimes."
;;   (interactive "Smode's font lock var? ")
;;   (dp-add-font-patterns font-lock-var-syms
;;                         buffer-local-p
;;                         (list dp-font-lock-line-too-long-error-element
;;                               dp-font-lock-line-too-long-warning-element)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nil


(defface dp-default-line-too-long-error-face
  '(
    (((class color) (background light)) (:background "gainsboro"))
    (((class color) (background dark)) (:foreground "green")))
  "Face for buffer lines which have gotten too long."
  :group 'faces
  :group 'dp-faces)

(setq dp-font-lock-line-too-long-error-element-for-tabs 'FOAD222)

(defvar dp-font-lock-line-too-long-error-element-for-tabs
  `( ;;list
   ,(format
    "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
    tab-width
    (1- tab-width)
    (/ dp-line-too-long-error-column tab-width)
    (let ((rem (% dp-line-too-long-error-column tab-width)))
      (if (zerop rem)
	  ""
	(format ".\\{%d\\}" rem))))
   (
     2					; line tail
     'dp-default-line-too-long-error-face))
  "As above, but works with tabs.
@todo XXX Seems to work with spaces, too.  \"But make sure, sure, sure\".")

(defvar dp-font-lock-line-too-long-error-element
  dp-font-lock-line-too-long-error-element-for-tabs
  "NB: Add mechanism for selecting (tabs or no), or make one element that
  works for both.")

(cl-pp (list dp-font-lock-line-too-long-error-element))

(("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" (2 dp-default-line-too-long-error-face)))nil




(progn
  (font-lock-add-keywords
   nil
   (list dp-font-lock-line-too-long-error-element-for-tabs)
   t)
  (font-lock-flush)
)
nil


(cl-pp font-lock-keywords)

(t (("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
	  (cond ((eq type 'var)
		 font-lock-variable-name-face)
		((eq type 'type)
		 font-lock-type-face)
		((or (not (match-string 2))
		     (and (match-string 2) (match-string 4)))
		 font-lock-function-name-face)))
	nil
	t))
    ("^;;;###\\([-a-z]*autoload\\)" 1 font-lock-warning-face prepend)
    ("\\[\\(\\^\\)" 1 font-lock-negation-char-face prepend)
    ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
    (lisp--el-match-keyword . 1)
    ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (2 font-lock-constant-face nil t))
    ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
							   prepend))
    ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
										prepend))
    ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
    ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" . font-lock-type-face)
    (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?")))
("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" (2 dp-default-line-too-long-error-face)))
("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
      (cond ((eq type 'var)
	     font-lock-variable-name-face)
	    ((eq type 'type)
	     font-lock-type-face)
	    ((or (not (match-string 2))
		 (and (match-string 2) (match-string 4)))
	     font-lock-function-name-face)))
    nil
    t))
("^;;;###\\([-a-z]*autoload\\)" (1 font-lock-warning-face prepend))
("\\[\\(\\^\\)" (1 font-lock-negation-char-face prepend))
("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
(lisp--el-match-keyword (1 font-lock-keyword-face))
("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (2 font-lock-constant-face nil t))
("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
						       prepend))
("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
									    prepend))
("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-type-face))
(#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?")))
("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" (2 dp-default-line-too-long-error-face)))nil




(t (("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
	  (cond ((eq type 'var)
		 font-lock-variable-name-face)
		((eq type 'type)
		 font-lock-type-face)
		((or (not (match-string 2))
		     (and (match-string 2) (match-string 4)))
		 font-lock-function-name-face)))
	nil
	t))
    ("^;;;###\\([-a-z]*autoload\\)" 1 font-lock-warning-face prepend)
    ("\\[\\(\\^\\)" 1 font-lock-negation-char-face prepend)
    ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
    (lisp--el-match-keyword . 1)
    ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (2 font-lock-constant-face nil t))
    ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
							   prepend))
    ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
										prepend))
    ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
    ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" . font-lock-type-face)
    (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))))
("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
      (cond ((eq type 'var)
	     font-lock-variable-name-face)
	    ((eq type 'type)
	     font-lock-type-face)
	    ((or (not (match-string 2))
		 (and (match-string 2) (match-string 4)))
	     font-lock-function-name-face)))
    nil
    t))
("^;;;###\\([-a-z]*autoload\\)" (1 font-lock-warning-face prepend))
("\\[\\(\\^\\)" (1 font-lock-negation-char-face prepend))
("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
(lisp--el-match-keyword (1 font-lock-keyword-face))
("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (2 font-lock-constant-face nil t))
("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
						       prepend))
("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
									    prepend))
("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-type-face))
(#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))))nil






(cl-assert 'zuzz)
(cl-signal
;;;###autoload




(re-search-forward "^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$")


(re-search-forward "^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}")



	xxxxxxxxxxxxxxx	xx  x x  x x   xxxxxxxx		xxxxx	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

========================
Wednesday June 20 2018
--
(defface whitespace-line
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "gray20" :foreground "violet"))
  "Face used to visualize \"long\" lines.

See `whitespace-line-column'."
  :group 'whitespace)

(defvar bline-minor-mode-font-lock-keywords
  ;; cf. `whitespace-color-on'
  (list
   (list
    (let ((line-column (or 72 fill-column)))
      (format
       "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
       8
       (1- 8)
       (/ line-column 8)
       (let ((rem (% line-column 8)))
         (if (zerop rem)
             ""
           (format ".\\{%d\\}" rem)))))
    (if t   ; was: (memq 'lines whitespace-active-style)
        0   ; whole line
      2)    ; line tail
    'whitespace-line t)))
(font-lock-add-keywords nil bline-minor-mode-font-lock-keywords t)
(font-lock-mode 1)
(font-lock-flush)

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

(cl-pp font-lock-keywords)

(t (("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type))) (cond ((eq type 'var) font-lock-variable-name-face) ((eq type 'type) font-lock-type-face) ((or (not (match-string 2)) (and (match-string 2) (match-string 4))) font-lock-function-name-face))) nil t)) ("^;;;###\\([-a-z]*autoload\\)" 1 font-lock-warning-face prepend) ("\\[\\(\\^\\)" 1 font-lock-negation-char-face prepend) ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face)) (lisp--el-match-keyword . 1) ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (2 font-lock-constant-face nil t)) ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face prepend)) ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face prepend)) ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face)) ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" . font-lock-type-face) (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend) (3 'font-lock-regexp-grouping-construct prepend)) (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))) ("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{9\\}\\(.+\\)$" 0 whitespace-line t)) ("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type))) (cond ((eq type 'var) font-lock-variable-name-face) ((eq type 'type) font-lock-type-face) ((or (not (match-string 2)) (and (match-string 2) (match-string 4))) font-lock-function-name-face))) nil t)) ("^;;;###\\([-a-z]*autoload\\)" (1 font-lock-warning-face prepend)) ("\\[\\(\\^\\)" (1 font-lock-negation-char-face prepend)) ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face)) (lisp--el-match-keyword (1 font-lock-keyword-face)) ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (2 font-lock-constant-face nil t)) ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face prepend)) ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face prepend)) ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face)) ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-type-face)) (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend) (3 'font-lock-regexp-grouping-construct prepend)) (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))) ("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{9\\}\\(.+\\)$" (0 whitespace-line t)))nil

jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj

(git-commit-summary-regexp)
"\\`\\(?:^\\(?:\\s-*\\|;.*\\)
\\)*\\(.\\{0,68\\}\\)\\(.*\\)\\(?:
;\\|
\\(.+\\)\\)?"

========================
Tuesday July 17 2018
--
error: patch failed: lisp/dpmacs.el:62
error: lisp/dpmacs.el: patch does not apply

========================
Monday October 15 2018
--
(defvar dp-whitespace-violation-rulettes
  (list (cons dp-trailing-whitespace-regexp 'dp-t)
        (cons dp-space-before-tab-regexp 'dp-t)
        (cons dp-too-many-spaces-in-a-row-regexp (lambda ()
                                                   indent-tabs-mode))
        ))
dp-whitespace-violation-rulettes

(mapcar (lambda (z)
          (if (funcall (cdr z))
              (car z)
            "NONONONONONONO!"))
        dp-whitespace-violation-rulettes)
("\\s-+$" " +[	]" "NONONONONONONO!")


(mapconcat (lambda (z)
             (if (funcall (cdr z))
                 (car z)
               nil))
           dp-whitespace-violation-rulettes
           "\\|")
"\\s-+$\\| +[	]\\|"

"\\s-+$\\| +[	]\\|"

"\\s-+$\\ +[	]\\"

(defun dset2 (&optional file-name)
  (interactive "Gfile-name: ")
  (find-file file-name)
  (dset))

========================
Wednesday November 28 2018
--
;; (defun ispell--\\w-filter (char)
;;   "Return CHAR in a string when CHAR doesn't have \"word\" syntax,
;; nil otherwise.  CHAR must be a character."
;;   (let ((str (string char)))
;;     (and
;;      (not (string-match "\\w" str))
;;      str)))

(defcustom dp-preferred-filename-char-regexp "[0-9a-zA-Z_.,:%~=-]"
  "For general cleanup of file names.  A bit over-conservative.
A set of names should be checked for duplicates after filtering.")

(defun dp-preferred-filename-char (char)
  "Return CHAR in a string when CHAR doesn't have \"word\" syntax,
nil otherwise.  CHAR must be a character."
  (let ((str (string char)))
    (and
     (not (string-match "\\w" str))
     str)))

(defun dp-leftize (&optional movement-type frame-or-window)
  "Move buffer in the right window to the leftmost window.
MOVEMENT-TYPE is 'shift|'move|'rotate as per \\[dp-shift-windows]
or 'slide as per \\[dp-slide-window-left].
@todo XXX Fix me to use (frame-first-window) as the destination
      of the right hand buffer rather than just shiifting or sliding."
  (interactive "P")
  (setq movement-type (or movement-type
			  (and current-prefix-arg
			       'slide)
			  'shift))
  (cond
   ((memq movement-type '(shift move rotate))
    (dp-shift-windows))
   ((memq movement-type '(slide))
    (dp-slide-window-left))
   (t (dp-shift-windows)))
  (set-buffer (frame-first-window frame-or-window))
  (select-current-buffer))

========================
Monday February 11 2019
--
;installed (defun dp-ibuffer-current-filename (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (if-let ((buf (ibuffer-current-buffer must-be-live-p)))
;installed       (buffer-file-name buf)
;installed     buf))

;installed (defun dp-ibuffer-current-filename-show (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (message "%s" (dp-ibuffer-current-filename must-be-live-p)))

;installed (defun dp-ibuffer-current-buffer-name (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (if-let ((buf (ibuffer-current-buffer must-be-live-p)))
;installed       (buffer-name buf)
;installed     buf))

;installed (defun dp-ibuffer-current-buffer-name-show (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (message "%s" (dp-ibuffer-current-buffer-name must-be-live-p)))

========================
Friday February 15 2019
--
(set-face-background 'scroll-bar "red")
nil



========================
Saturday February 23 2019
--
(custom-set-variables
 '(ibuffer-default-sorting-mode (quote alphabetic))
 '(ibuffer-fontification-alist
   (quote
    ((10 buffer-read-only ibuffer-locked-buffer)
     (15
      (and buffer-file-name
	   (string-match ibuffer-compressed-file-name-regexp buffer-file-name))
      font-lock-function-name-face)
     (20
      (string-match "^*"
		    (buffer-name))
      font-lock-constant-face)
     (25
      (and
       (string-match "^ "
		     (buffer-name))
       (null buffer-file-name))
      italic)
     (30
      (memq major-mode ibuffer-help-buffer-modes)
      font-lock-doc-face)
     (35
      (derived-mode-p
       (quote dired-mode))
      font-lock-function-name-face)
     (40
      (and
       (boundp
	(quote emacs-lock-mode))
       emacs-lock-mode)
      ibuffer-locked-buffer)
     (55
      (string-match "<dse>\\(<[0-9]+>\\)*$"
		    (buffer-name))
      dp-sudo-edit-bg-face)
     (33
      (and buffer-file-name
	   (string-match "^/.[^:]+:\\([^@]+@\\)?[^:]+:" buffer-file-name))
      dp-remote-buffer-face))))
)
nil


========================
Tuesday February 26 2019
--
(cl-pp default-frame-alist)
((tool-bar-lines . 0)
 (menu-bar-lines . 1)
 (width . 180)
 (height . 66)
 (background-color . "#1b182c")
 (vertical-scroll-bars . right))

(cl-pp initial-frame-alist)
((width . 180)
 (height . 66)
 (vertical-scroll-bars . right))

(setq initial-frame-alist
      '((width . 180)
	(height . 66)
	(fullscreen . fullheight)
	(vertical-scroll-bars . right)))

(setq default-frame-alist
      '((tool-bar-lines . 0)
	(menu-bar-lines . 1)
	(width . 180)
	(height . 66)
	(background-color . "#1b182c")
	(vertical-scroll-bars . right)))
((tool-bar-lines . 0) (menu-bar-lines . 1) (width . 180) (height . 66) (background-color . "#808080") (vertical-scroll-bars . right))



(set-frame-parameter nil 'fullscreen 'fullheight)
nil
(frame-parameter nil 'fullscreen)
fullheight
(frame-parameter nil 'fullscreen-restore)
fullheight


(set-frame-parameter nil 'fullscreen nil)
nil


(progn
  (set-frame-parameter nil 'fullscreen 'fullheight)
  (sit-for 0.1)
  (let ((height (frame-height)))
    (set-frame-parameter nil 'fullscreen nil)
    (sit-for 0.1)
    (set-frame-height nil (/ height 1))))
nil


(dp-set-to-max-vert-frame-height)
nil

nil




(toggle-frame-maximized)
(toggle-frame-fullscreen)

nil

nil

nil

nil

nil


========================
Thursday February 28 2019
--
(require 'emms)
emms

(cl-pp ido-common-completion-map)

(keymap (4 . ido-magic-delete-char)
	(6 . ido-magic-forward-char)
	(2 . ido-magic-backward-char)
	(63 . ido-completion-help)
	(left . ido-prev-match)
	(right . ido-next-match)
	(0 . ido-restrict-to-matches)
	(27 keymap (32 . ido-take-first-match))
	(67108896 . ido-restrict-to-matches)
	(26 . ido-undo-merge-work-directory)
	(20 . ido-toggle-regexp)
	(67108908 . ido-prev-match)
	(67108910 . ido-next-match)
	(19 . ido-next-match)
	(18 . ido-prev-match)
	(16 . ido-toggle-prefix)
	(13 . ido-exit-minibuffer)
	(10 . ido-select-text)
	(32 . ido-complete-space)
	(9 . ido-complete)
	(5 . ido-edit-input)
	(3 . ido-toggle-case)
	(1 . ido-toggle-ignore)
	keymap
	(M-up . switch-to-completions)
	(tab . minibuffer-complete)
	(14 . next-complete-history-element)
	(16 . previous-complete-history-element)
	(C-space . dp-expand-abbrev)
	(menu-bar keymap
		  (minibuf "Minibuf"
			   keymap
			   (previous menu-item
				     "Previous History Item"
				     previous-history-element
				     :help
				     "Put previous minibuffer history element in the minibuffer")
			   (next menu-item
				 "Next History Item"
				 next-history-element
				 :help
				 "Put next minibuffer history element in the minibuffer")
			   (isearch-backward menu-item
					     "Isearch History Backward"
					     isearch-backward
					     :help
					     "Incrementally search minibuffer history backward")
			   (isearch-forward menu-item
					    "Isearch History Forward"
					    isearch-forward
					    :help
					    "Incrementally search minibuffer history forward")
			   (return menu-item
				   "Enter"
				   exit-minibuffer
				   :key-sequence
				   ""
				   :help
				   "Terminate input and exit minibuffer")
			   (quit menu-item
				 "Quit"
				 abort-recursive-edit
				 :help
				 "Abort input and exit minibuffer")
			   "Minibuf"))
	(10 . exit-minibuffer)
	(13 . exit-minibuffer)
	(7 . minibuffer-keyboard-quit)
	(C-tab . file-cache-minibuffer-complete)
	(9 . self-insert-command)
	(XF86Back . previous-history-element)
	(up . previous-history-element)
	(prior . previous-history-element)
	(XF86Forward . next-history-element)
	(down . next-history-element)
	(next . next-history-element)
	(27 keymap
	    (119 . dp-rsh-cwd-to-minibuffer)
	    (101 . dp-rsh-cwd-to-minibuffer)
	    (111 . dp-kill-ring-save)
	    (57 lambda
		(&optional arg arg1 arg2 arg3 arg4 arg5)
		""
		(interactive "P")
		(dp-insert-parentheses nil))
	    (61 lambda
		(&optional arg arg1 arg2 arg3 arg4 arg5)
		""
		(interactive "P")
		(enqueue-eval-event 'eval
				    (nth (1- (prefix-numeric-value arg))
					 command-history))
		(top-level))
	    (39 . dp-copy-char-to-minibuf)
	    (44 . minibuffer-keyboard-quit)
	    (96 . previous-complete-history-element)
	    (45 . minibuffer-keyboard-quit)
	    (114 . previous-matching-history-element)
	    (115 . next-matching-history-element)
	    (112 . dp-parenthesize-region)
	    (110 . next-history-element)))


========================
Tuesday March 05 2019
--
(cl-pe
'(mingus-define-mpd->mingus mingus-pause
                           (mingus-minibuffer-feedback 'state)
                           (mingus-set-NP-mark t)))

(defalias 'mingus-pause
  (function
   (lambda (&rest args)
     (interactive)
     (apply (function mpd-pause) mpd-inter-conn args)
     (mingus-minibuffer-feedback 'state)
     (mingus-set-NP-mark t))))nil




========================
Wednesday March 06 2019
--
(defun ist (x)
  (eq t x))
(defun isplay (x)
  (message "isplay: %s" x)
  (eq x 'play))

(isplay 'ksjd)
nil

(pcase 'jdkhfkjdhf ;; (getf (mpd-get-status mpd-inter-conn) 'state)
  (pred 'isplay (message "IS_PLAY!: %s" pred))
  ('play (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
"IS_PLAY!: jdkhfkjdhf"

"IS_PLAY!"


"IS_PLAY!"

"IS_PLAY!"

"NONE of the above: jdkhfkjdhf"

"PLAY!"

"NONE of the above: jdkhfkjdhf"

"IS_PLAY!"

"IS_PLAY!"

(isplay 'xplay)
nil

t

t

(pcase (getf (mpd-get-status mpd-inter-conn) 'state)
  (pred 'isplay (message "IS_PLAY!"))
  ('play (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!")))
"IS_PLAY!"


"STOP!"
"PLAY!"
"PAUSE!"


(cl-pe
'(pcase 'jdkhfkjdhf ;; (getf (mpd-get-status mpd-inter-conn) 'state)
  ((pred isplay) (message "IS_PLAY!: %s" pred))
  ((or 'x 'play) (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
)

(cond ((isplay 'jdkhfkjdhf)
       (message "IS_PLAY!: %s" pred))
      ((memq 'jdkhfkjdhf '(play x))
       (message "PLAY!"))
      ((eq 'jdkhfkjdhf 'pause)
       (message "PAUSE!"))
      ((eq 'jdkhfkjdhf 'stop)
       (message "STOP!"))
      (t (let ((none-above 'jdkhfkjdhf))
	   (message "NONE of the above: %s" none-above))))nil



(cond ((isplay 'jdkhfkjdhf)
       (message "IS_PLAY!: %s" pred))
      ((eq 'jdkhfkjdhf 'play)
       (message "PLAY!"))
      ((eq 'jdkhfkjdhf 'pause)
       (message "PAUSE!"))
      ((eq 'jdkhfkjdhf 'stop)
       (message "STOP!"))
      (t (let ((none-above 'jdkhfkjdhf))
	   (message "NONE of the above: %s" none-above))))
"NONE of the above: jdkhfkjdhf"


(pcase 'x
  ((pred isplay) (message "IS_PLAY!"))
  ((or 'x 'play) (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
"PLAY!"

"PAUSE!"


(pcase 'pausex
  ((pred isplay) (message "IS_PLAY!: %s" pred))
  ((or 'x 'play) (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
"NONE of the above: pausex"

"PAUSE!"





(let ((pred 'jdkhfkjdhf))
  'isplay
  (message "IS_PLAY!: %s" pred))nil


(cond ((eq 'jdkhfkjdhf 'play)
       (message "PLAY!"))
      ((eq 'jdkhfkjdhf 'pause)
       (message "PAUSE!"))
      ((eq 'jdkhfkjdhf 'stop)
       (message "STOP!"))
      (t (let ((none-above 'jdkhfkjdhf))
	   (message "NONE of the above: %s" none-above))))

(cl-pe
'(defun grok/pcase (obj)
  (pcase obj
    ((or                                     ; line 1
      (and                                   ; line 2
       (pred stringp)                        ; line 3
       (pred (string-match                   ; line 4
	      "^key:\\([[:digit:]]+\\)$"))   ; line 5
       (app (match-string 1)                 ; line 6
	    val))                            ; line 7
      (let val (list "149" 'default)))       ; line 8
     val)))
)

(defalias 'grok/pcase
  (function
   (lambda (obj)
     (cond ((not (stringp obj))
	    (let* ((sym (list "149" 'default)))
	      (let ((val sym))
		val)))
	   ((string-match "^key:\\([[:digit:]]+\\)$" obj)
	    (let* ((x644 (match-string 1 obj)))
	      (let ((val x644))
		val)))
	   (t (let* ((sym (list "149" 'default))) (let ((val sym)) val)))))))

========================
Thursday March 21 2019
--
(defun dp-show-buffer-file-name (&optional kill-name-p buffer)
  (interactive "P")
  (let (name-name-type)
    (cond
     ((eq major-modw 'dired-mode)
      (save-excursion
	(goto-char (point-min))
	(dp-re-search-forward "\\(^\s-+\\)\\(\S-+\\)\\(:\\)"
			      (line-end-position))
	)
      (dp-get-buffer-file-name-info kill-name-p buffer))

      (if kill-name-p
	  ( (match-string-no-properties)))
      ))
    (message "%s%s: %s"
             (if kill-name-p
                 "Copied "
               "")
             (cdr name-name-type)
             (car name-name-type))))


========================
Tuesday March 26 2019
--

dp-fixed-corresponding-files
(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

;; To switch between dpmacs.el and dpmisc.el quickly, use
;; C-x M-b to run the command dp-edit-corresponding-file
;; Which the following sets up.
(dp-add-corresponding-file-pair "dpmisc.el" "dpmacs.el")

(dp-add-to-list 'dp-fixed-corresponding-files
		(cons "dp-fsf-fsf-compat.el" "dp-xemacs-fsf-compat.el"))
(("dp-bubba1.el" . "dp-bubba2.el") ("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-bubba1.el" . "dp-bubba2.el") ("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el"))

(dp-add-corresponding-file-pair "dp-bubba1.el"
				"dp-bubba2.el")
(("dp-bubba1.el" . "dp-bubba2.el") ("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))


========================
Wednesday March 27 2019
--

(cl-pe
 '(with-eval-after-load "bubba" (yadda)))

(eval-after-load "bubba" (function (lambda nil (yadda))))nil



========================
Thursday March 28 2019
--
(cl-pe
'(define-transient-command magit-commit ()
  "Create a new commit or replace an existing commit."
  :info-manual "(magit)Initiating a Commit"
  :man-page "git-commit"
  ["Arguments"
   ("-a" "Stage all modified and deleted files"   ("-a" "--all"))
   ("-e" "Allow empty commit"                     "--allow-empty")
   ("-v" "Show diff of changes to be committed"   ("-v" "--verbose"))
   ("-n" "Disable hooks"                          ("-n" "--no-verify"))
   ("-R" "Claim authorship and reset author date" "--reset-author")
   (magit:--author :description "Override the author")
   (7 "-D" "Override the author date" "--date=" transient-read-date)
   ("-s" "Add Signed-off-by line"                 ("-s" "--signoff"))
   (5 magit:--gpg-sign)
   (magit-commit:--reuse-message)]
  [["Create"
    ("c" "Commit"         magit-commit-create)]
   ["Edit HEAD"
    ("e" "Extend"         magit-commit-extend)
    ("w" "Reword"         magit-commit-reword)
    ("a" "Amend"          magit-commit-amend)
    (6 "n" "Reshelve"     magit-commit-reshelve)]
   ["Edit"
    ("f" "Fixup"          magit-commit-fixup)
    ("s" "Squash"         magit-commit-squash)
    ("A" "Augment"        magit-commit-augment)
    (6 "x" "Absorb changes" magit-commit-absorb)]
   [""
    ("F" "Instant fixup"  magit-commit-instant-fixup)
    ("S" "Instant squash" magit-commit-instant-squash)]]
  (interactive)
  (if-let ((buffer (magit-commit-message-buffer)))
      (switch-to-buffer buffer)
    (transient-setup 'magit-commit)))
)

(progn
  (defalias 'magit-commit
    (function
     (lambda nil
       (interactive)
       (let* ((buffer (and t (magit-commit-message-buffer))))
	 (if buffer
	     (switch-to-buffer buffer)
	   (transient-setup 'magit-commit))))))
  (put 'magit-commit
       'function-documentation
       "Create a new commit or replace an existing commit.")
  (put 'magit-commit
       'transient--prefix
       (transient-prefix :command
			 'magit-commit
			 :info-manual
			 "(magit)Initiating a Commit"
			 :man-page
			 "git-commit"))
  (put 'magit-commit
       'transient--layout
       '([1 transient-column (:description "Arguments") ((1 transient-switch (:key "-a" :description "Stage all modified and deleted files" :shortarg "-a" :argument "--all" :command transient:magit-commit:--all)) (1 transient-switch (:key "-e" :description "Allow empty commit" :argument "--allow-empty" :command transient:magit-commit:--allow-empty)) (1 transient-switch (:key "-v" :description "Show diff of changes to be committed" :shortarg "-v" :argument "--verbose" :command transient:magit-commit:--verbose)) (1 transient-switch (:key "-n" :description "Disable hooks" :shortarg "-n" :argument "--no-verify" :command transient:magit-commit:--no-verify)) (1 transient-switch (:key "-R" :description "Claim authorship and reset author date" :argument "--reset-author" :command transient:magit-commit:--reset-author)) (1 transient-suffix (:command magit:--author :description "Override the author")) (7 transient-option (:key "-D" :description "Override the author date" :argument "--date=" :command transient:magit-commit:--date= :reader transient-read-date)) (1 transient-switch (:key "-s" :description "Add Signed-off-by line" :shortarg "-s" :argument "--signoff" :command transient:magit-commit:--signoff)) (5 transient-suffix (:command magit:--gpg-sign)) (1 transient-suffix (:command magit-commit:--reuse-message)))] [1 transient-columns nil ([1 transient-column (:description "Create") ((1 transient-suffix (:key "c" :description "Commit" :command magit-commit-create)))] [1 transient-column (:description "Edit HEAD") ((1 transient-suffix (:key "e" :description "Extend" :command magit-commit-extend)) (1 transient-suffix (:key "w" :description "Reword" :command magit-commit-reword)) (1 transient-suffix (:key "a" :description "Amend" :command magit-commit-amend)) (6 transient-suffix (:key "n" :description "Reshelve" :command magit-commit-reshelve)))] [1 transient-column (:description "Edit") ((1 transient-suffix (:key "f" :description "Fixup" :command magit-commit-fixup)) (1 transient-suffix (:key "s" :description "Squash" :command magit-commit-squash)) (1 transient-suffix (:key "A" :description "Augment" :command magit-commit-augment)) (6 transient-suffix (:key "x" :description "Absorb changes" :command magit-commit-absorb)))] [1 transient-column (:description "") ((1 transient-suffix (:key "F" :description "Instant fixup" :command magit-commit-instant-fixup)) (1 transient-suffix (:key "S" :description "Instant squash" :command magit-commit-instant-squash)))])])))nil



========================
Monday April 29 2019
--
        (when (string-match
	       (concat "^\\(" dp-ws+cr+newline-regexp+-not "\\)" s)
          ;; Just set it, no sense in comparing to see if it changed.
          (setq default-directory


"^\\([^

]+\\)"
"^\\([^

]+\\)"


(concat "^\\(" dp-ws+cr+newline-regexp+-not "\\)" s)


========================
Tuesday April 30 2019
--

(read-extended-command)
(defun qqq (&optional expr)
  (interactive "Xexpr: ")
  (princf "expr>%s<" expr)
  expr)

(setq qqqv (qqq))
expr>nil<
nil


(setq qqqv (qqq '(c . d)))
expr>(c . d)<
(c . d)

qqqv
(c . d)
(car qqqv)
c
(cdr qqqv)
d


(eval (qqq '(a . b)))
expr>(a . b)<


expr>(a . b)<

expr>(a . b)<

expr>(a . b)<
(a . b)

expr>(a . b)<
(a . b)

expr>(a . b)<
nil

expr>(a . b)<
nil




(let ((a1 '((a . 1) (b . 2) (c . 4) (z . 26)))
      (a2 '((aa . 11) (d . 4) (c . 3)))
      (a9 '((aa . 99)))
      z)
  (princf "1, a1>%s<" a1)
  (princf "1, a2>%s<" a2)
  (princf "1, a9>%s<" a9)
  (setq z (dp-add-or-update-alist-with-alist 'a2 a9))
  (princf "2, z>%s<" z)
  (princf "2, a1>%s<" a1)
  (princf "2, a2>%s<" a2)
  (princf "2, a9>%s<" a9))
1, a1>((a . 1) (b . 2) (c . 4) (z . 26))<
1, a2>((aa . 11) (d . 4) (c . 3))<
1, a9>((aa . 99))<
2, z>((aa . 99) (d . 4) (c . 3))<
2, a1>((a . 1) (b . 2) (c . 4) (z . 26))<
2, a2>((aa . 99) (d . 4) (c . 3))<
2, a9>((aa . 99))<
nil

1, a1>((a . 1) (b . 2) (c . 4) (z . 26))<
1, a2>((aa . 11) (d . 4) (c . 3))<
1, a9>((aa . 99))<
2, z>((aa . 99) (a . 1) (b . 2) (c . 4) (z . 26))<
2, a1>((aa . 99) (a . 1) (b . 2) (c . 4) (z . 26))<
2, a2>((aa . 11) (d . 4) (c . 3))<
2, a9>((aa . 99))<
nil

1, a1>((a . 1) (b . 2) (c . 4) (z . 26))<
1, a2>((aa . 11) (d . 4) (c . 3))<
1, a9>((aa . 99))<
2, z>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3) (z . 26))<
2, a1>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3) (z . 26))<
2, a2>((aa . 11) (d . 4) (c . 3))<
2, a9>((aa . 99))<
nil



a1>((a . 1) (b . 2) (c . 4) (z . 26))<
a2>((aa . 11) (d . 4) (c . 3))<
z>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3) (z . 26))<
a1>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
a2>((aa . 11) (d . 4) (c . 3))<
z>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3) (z . 26))<
a1>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4))<
a2>((aa . 11) (d . 4) (c . 3))<
z>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3))<
a1>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3))<
nil

a1>((a . 1) (b . 2) (c . 4))<
a2>((aa . 11) (d . 4) (c . 3))<
z>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3))<
a1>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3))<
nil







========================
Monday December 09 2019
--


(defun dp-py-bound-arg-list ()
  (interactive)
  (save-excursion
    (python-nav-backward-statement)
    (python-nav-forward-statement)
    ;; Cannot be at start of keyword, e.g. `def'.
    (right-char 1)
    ;; Goto space after keyword.
    (python-nav-forward-sexp)
    ;; Move's us to open paren.
    (python-nav-forward-sexp)
    (let ((open-paren (point))
	  (close-paren (progn
			 (python-nav-forward-sexp)
			 (point))))
      (cons open-paren close-paren))))

========================
Thursday May 28 2020
--

(and-stringp "S" "x")
"S"

(and-stringp "" "x")
""

;;
(defmacro stringp-or-and (var &rest args)
  `(if (stringp ,var)
       ,var
     (and ,@args)))
stringp-or-and


(defmacro stringp-or (var &rest args)
  `(if (stringp ,var)
       ,var
     (or ,@args)))
stringp-or

(cl-pe '
 (stringp-or 'N "else" 1 'w "x" '(a))
 )

(if (stringp 'N) 'N (or "else" 1 'w "x" '(a)))
"else"




(if (stringp 'N) 'N (or nil nil 'w "x" '(a)))
w

1

"else"

(if (stringp 'N) 'N (or "else"))nil
(if 'N 'N (or "else"))nil
(if "S" "S" (or "else"))nil

(cl-pe '
 (stringp-or-and 'N "else" 1 'w "x" '(a))
 )

(if (stringp 'N) 'N (and "else" 1 'w "x" '(a)))nil



(listp (if (stringp 'N) 'N (and "else" 1 'w "x" '(a))))
t

(a)





(if (stringp 'N) 'N (or "else" 1 'w "x" '(a)))





========================
Thursday June 04 2020
--
(defun xah-python-2to3-current-file ()
  "Convert current buffer from python 2 to python 3.
This command calls python3's script 「2to3」.
URL `http://ergoemacs.org/emacs/elisp_python_2to3.html'
Version 2016-02-16"
  (interactive)
  (let* (
         (fName (buffer-file-name))
         (fSuffix (file-name-extension fName)))
    (when (buffer-modified-p)
      (save-buffer))
    (if (or (string-equal fSuffix "py") (string-equal fSuffix "py3"))
        (progn
          (shell-command (format "2to3-3.5 -w %s" fName))
          (revert-buffer  "IGNORE-AUTO" "NOCONFIRM" "PRESERVE-MODES"))
      (error "file 「%s」 doesn't end in “.py” or “.py3”." fName))))
xah-python-2to3-current-file



========================
Tuesday June 09 2020
--
(cl-pe '
(defun xgtags--call-global (buffer-dir option tagname)
  (message "Searching %s ..." tagname)
  (let ((tags nil))
    (xgtags--do-in-all-directories
     buffer-dir
     (lambda (dir)
       (when dir
         (message "Searching %s in %s ..." tagname dir))
       (let ((xgtags-rootdir (and dir (file-name-as-directory dir)))
             (global-args (append
                           (if (nCu-p 2)
                               '("--rgg-all-matches"))
                           xgtags-global-program-args
                           (xgtags--list-sans-nil
                            "--cxref"
                            (xgtags--option-string option)
                            (unless (eq xgtags-show-paths 'relative)
                              "--absolute")
                            tagname))))
         (message "xgtags--call-global(): global-args>%s<" global-args)
         (with-xgtags-environment
           (when xgtags-update-db
             (xgtags--update-db xgtags-rootdir))
           (with-temp-buffer
             (if (zerop (apply #'call-process xgtags-global-program nil t nil
                               global-args))
                 (setq tags (append tags (xgtags--collect-tags-in-buffer)))
               (message (buffer-substring (point-min)(1- (point-max))))))))))
    (message "Searching %s done" tagname)
    tags))

)

(defalias 'xgtags--call-global
  (function
   (lambda (buffer-dir option tagname)
     (message "Searching %s ..." tagname)
     (let ((tags nil))
       (xgtags--do-in-all-directories buffer-dir
				      (function
				       (lambda (dir)
					 (if dir
					     (progn
					       (message "Searching %s in %s ..."
							tagname
							dir)))
					 (let ((xgtags-rootdir (and dir
								    (file-name-as-directory dir)))
					       (global-args (append (if (nCu-p 2)
									'("--rgg-all-matches"))
								    xgtags-global-program-args
								    (xgtags--list-sans-nil "--cxref"
											   (xgtags--option-string option)
											   (if (eq xgtags-show-paths
												   'relative)
											       nil
											     "--absolute")
											   tagname))))
					   (message "xgtags--call-global(): global-args>%s<"
						    global-args)
					   (let ((process-environment (copy-alist process-environment)))
					     (if xgtags-rootdir
						 (progn
						   (setenv "GTAGSROOT"
							   xgtags-rootdir)))
					     (if xgtags-update-db
						 (progn
						   (xgtags--update-db xgtags-rootdir)))
					     (let ((temp-buffer (generate-new-buffer " *temp*")))
					       (save-current-buffer (set-buffer temp-buffer)
								    (unwind-protect
									(progn
									  (if (= 0
										 (apply (function call-process)
											xgtags-global-program
											nil
											t
											nil
											global-args))
									      (setq tags (append tags
												 (xgtags--collect-tags-in-buffer)))
									    (message (buffer-substring (point-min)
												       (1- (point-max))))))
								      (and (buffer-name temp-buffer)
									   (kill-buffer temp-buffer))))))))))
       (message "Searching %s done" tagname)
       tags))))nil


========================
Thursday June 11 2020
--
(dp-set-to-max-vert-frame-height)
"YOPP4, height: 53, ‘frame-height’: 53"

;; start
YOPP1, ‘frame-height’: 62
YOPP1.1, ‘frame-height’: 62
YOPP1.2, ‘frame-height’: 62
YOPP2, height: 62, ‘frame-height’: 62
YOPP3, height: 62, ‘frame-height’: 62
YOPP4, height: 62, ‘frame-height’: 62

;; after resize with mouse, running (dp-set-to-max-vert-frame-height)
YOPP1, ‘frame-height’: 38
YOPP1.1, ‘frame-height’: 53
YOPP1.2, ‘frame-height’: 53
YOPP2, height: 53, ‘frame-height’: 53
YOPP3, height: 53, ‘frame-height’: 53
YOPP4, height: 53, ‘frame-height’: 53

;; resize to bigger than screen
(dp-set-to-max-vert-frame-height)
"YOPP4, height: 53, ‘frame-height’: 53"

YOPP1, ‘frame-height’: 77
YOPP1.1, ‘frame-height’: 53
YOPP1.2, ‘frame-height’: 53
YOPP2, height: 53, ‘frame-height’: 53
YOPP3, height: 53, ‘frame-height’: 53
YOPP4, height: 53, ‘frame-height’: 53

  (message "YOPP1, `frame-height': %s" (frame-height frame))

(cl-pp load-path)

("~/" "/home/davep/dpw/dpw/lisp/elpa.vilya.d/hyperbole-7.0.6/kotl/"
 "/home/davep/dpw/dpw/lisp/elpa.vilya.d/hyperbole-7.0.6/"
 "/home/davep/flisp/contrib/xemacs.el-for-fsf-compat"
 "/home/davep/flisp/contrib/emacs-jabber"
 "/home/davep/flisp/contrib"
 "/usr/share/emacs/site-lisp/mu4e"
 "/home/davep/flisp/"
 "/home/davep/.emacs.d/elpa/0xc-20190219.117"
 "/home/davep/.emacs.d/elpa/ac-c-headers-20151021.834"
 "/home/davep/.emacs.d/elpa/ag-20190726.9"
 "/home/davep/.emacs.d/elpa/agtags-20200608.623"
 "/home/davep/.emacs.d/elpa/auto-overlays-0.10.9"
 "/home/davep/.emacs.d/elpa/bash-completion-20191126.1824"
 "/home/davep/.emacs.d/elpa/browse-at-remote-20200308.639"
 "/home/davep/.emacs.d/elpa/browse-kill-ring-20200210.921"
 "/home/davep/.emacs.d/elpa/comment-tags-20170910.1735"
 "/home/davep/.emacs.d/elpa/company-ctags-20200603.438"
 "/home/davep/.emacs.d/elpa/context-coloring-8.1.0"
 "/home/davep/.emacs.d/elpa/corral-20160502.701"
 "/home/davep/.emacs.d/elpa/counsel-gtags-20200101.1701"
 "/home/davep/.emacs.d/elpa/counsel-20200610.1631"
 "/home/davep/.emacs.d/elpa/dic-lookup-w3m-20180526.1621"
 "/home/davep/.emacs.d/elpa/dictcc-20200421.1422"
 "/home/davep/.emacs.d/elpa/dictionary-20191111.446"
 "/home/davep/.emacs.d/elpa/connection-20191111.446"
 "/home/davep/.emacs.d/elpa/diffview-20150929.511"
 "/home/davep/.emacs.d/elpa/dimmer-20200509.1718"
 "/home/davep/.emacs.d/elpa/dired-k-20200322.2035"
 "/home/davep/.emacs.d/elpa/ecb-20170728.1921"
 "/home/davep/.emacs.d/elpa/edebug-x-20130616.625"
 "/home/davep/.emacs.d/elpa/eide-20200507.2238"
 "/home/davep/.emacs.d/elpa/el-patch-20200404.1548"
 "/home/davep/.emacs.d/elpa/eldoc-overlay-20200328.619"
 "/home/davep/.emacs.d/elpa/electric-case-20150417.1112"
 "/home/davep/.emacs.d/elpa/elf-mode-20161009.748"
 "/home/davep/.emacs.d/elpa/elisp-sandbox-20131116.1842"
 "/home/davep/.emacs.d/elpa/elmacro-20191208.1057"
 "/home/davep/.emacs.d/elpa/elpa-audit-20141023.1331"
 "/home/davep/.emacs.d/elpa/elpy-20200527.2021"
 "/home/davep/.emacs.d/elpa/company-20200525.101"
 "/home/davep/.emacs.d/elpa/elpygen-20171225.1736"
 "/home/davep/.emacs.d/elpa/emacsagist-20140331.1830"
 "/home/davep/.emacs.d/elpa/emacsc-20190917.1102"
 "/home/davep/.emacs.d/elpa/emacsist-view-20160426.1223"
 "/home/davep/.emacs.d/elpa/emaps-20200508.1759"
 "/home/davep/.emacs.d/elpa/emms-info-mediainfo-20131223.1300"
 "/home/davep/.emacs.d/elpa/emms-mark-ext-20130529.327"
 "/home/davep/.emacs.d/elpa/emms-mode-line-cycle-20160221.1120"
 "/home/davep/.emacs.d/elpa/emms-state-20160504.805"
 "/home/davep/.emacs.d/elpa/emms-20200528.2116"
 "/home/davep/.emacs.d/elpa/emr-20200420.721"
 "/home/davep/.emacs.d/elpa/clang-format-20191121.1708"
 "/home/davep/.emacs.d/elpa/enwc-2.0"
 "/home/davep/.emacs.d/elpa/escreen-20170613.1534"
 "/home/davep/.emacs.d/elpa/flycheck-checkbashisms-20190403.218"
 "/home/davep/.emacs.d/elpa/flycheck-cstyle-20160905.2341"
 "/home/davep/.emacs.d/elpa/flycheck-cython-20170724.958"
 "/home/davep/.emacs.d/elpa/flycheck-pos-tip-20200516.1600"
 "/home/davep/.emacs.d/elpa/flycheck-rust-20190319.1546"
 "/home/davep/.emacs.d/elpa/flycheck-20200610.1809"
 "/home/davep/.emacs.d/elpa/flymake-cppcheck-20140415.1257"
 "/home/davep/.emacs.d/elpa/flymake-python-pyflakes-20170723.146"
 "/home/davep/.emacs.d/elpa/flymake-easy-20140818.755"
 "/home/davep/.emacs.d/elpa/flymd-20160617.1214"
 "/home/davep/.emacs.d/elpa/ggtags-20190320.2208"
 "/home/davep/.emacs.d/elpa/gh-md-20151207.1740"
 "/home/davep/.emacs.d/elpa/git-20140128.1041"
 "/home/davep/.emacs.d/elpa/git-attr-20180925.2003"
 "/home/davep/.emacs.d/elpa/git-timemachine-20200603.701"
 "/home/davep/.emacs.d/elpa/git-wip-timemachine-20150408.1006"
 "/home/davep/.emacs.d/elpa/gitconfig-20130718.935"
 "/home/davep/.emacs.d/elpa/gitconfig-mode-20180318.1956"
 "/home/davep/.emacs.d/elpa/gited-0.6.0"
 "/home/davep/.emacs.d/elpa/github-browse-file-20160205.1427"
 "/home/davep/.emacs.d/elpa/github-modern-theme-20171109.1251"
 "/home/davep/.emacs.d/elpa/global-tags-20200520.1816"
 "/home/davep/.emacs.d/elpa/goldendict-20180121.920"
 "/home/davep/.emacs.d/elpa/grin-20110806.658"
 "/home/davep/.emacs.d/elpa/grip-mode-20200312.1136"
 "/home/davep/.emacs.d/elpa/highlight-indentation-20181204.839"
 "/home/davep/.emacs.d/elpa/hyperbole-7.0.6"
 "/home/davep/.emacs.d/elpa/iedit-20200412.756"
 "/home/davep/.emacs.d/elpa/inline-docs-20170523.450"
 "/home/davep/.emacs.d/elpa/jedi-direx-20140310.936"
 "/home/davep/.emacs.d/elpa/direx-20170422.1327"
 "/home/davep/.emacs.d/elpa/leanote-20161223.139"
 "/home/davep/.emacs.d/elpa/let-alist-1.0.6"
 "/home/davep/.emacs.d/elpa/libgit-20200515.1759"
 "/home/davep/.emacs.d/elpa/link-20191111.446"
 "/home/davep/.emacs.d/elpa/list-utils-20200502.1309"
 "/home/davep/.emacs.d/elpa/lua-mode-20200508.1316"
 "/home/davep/.emacs.d/elpa/magit-annex-20200516.2028"
 "/home/davep/.emacs.d/elpa/magit-filenotify-20151116.2340"
 "/home/davep/.emacs.d/elpa/magit-find-file-20150702.830"
 "/home/davep/.emacs.d/elpa/magit-gerrit-20160226.930"
 "/home/davep/.emacs.d/elpa/magit-gh-pulls-20191230.1944"
 "/home/davep/.emacs.d/elpa/gh-20180308.2138"
 "/home/davep/.emacs.d/elpa/logito-20120225.2055"
 "/home/davep/.emacs.d/elpa/magit-gitflow-20170929.824"
 "/home/davep/.emacs.d/elpa/magit-imerge-20200516.2029"
 "/home/davep/.emacs.d/elpa/magit-lfs-20190831.118"
 "/home/davep/.emacs.d/elpa/magit-org-todos-20180709.1950"
 "/home/davep/.emacs.d/elpa/magit-popup-20200306.223"
 "/home/davep/.emacs.d/elpa/magit-stgit-20190313.1158"
 "/home/davep/.emacs.d/elpa/magit-tbdiff-20200519.418"
 "/home/davep/.emacs.d/elpa/magit-todos-20200310.28"
 "/home/davep/.emacs.d/elpa/hl-todo-20200103.1239"
 "/home/davep/.emacs.d/elpa/markdown-mode+-20170320.2104"
 "/home/davep/.emacs.d/elpa/markdown-preview-eww-20160111.1502"
 "/home/davep/.emacs.d/elpa/markdown-preview-mode-20181213.1339"
 "/home/davep/.emacs.d/elpa/markup-20170420.1129"
 "/home/davep/.emacs.d/elpa/markup-faces-20141110.817"
 "/home/davep/.emacs.d/elpa/marshal-20180124.1239"
 "/home/davep/.emacs.d/elpa/md-readme-20191112.1943"
 "/home/davep/.emacs.d/elpa/meson-mode-20200216.2254"
 "/home/davep/.emacs.d/elpa/mingus-20190106.1443"
 "/home/davep/.emacs.d/elpa/libmpdee-20160117.2301"
 "/home/davep/.emacs.d/elpa/mkdown-20140517.1418"
 "/home/davep/.emacs.d/elpa/markdown-mode-20200602.1433"
 "/home/davep/.emacs.d/elpa/mmm-mode-20200525.12"
 "/home/davep/.emacs.d/elpa/mo-git-blame-20160129.1759"
 "/home/davep/.emacs.d/elpa/mpdel-20200221.1316"
 "/home/davep/.emacs.d/elpa/libmpdel-20200105.1537"
 "/home/davep/.emacs.d/elpa/mu4e-alert-20190418.558"
 "/home/davep/.emacs.d/elpa/alert-20200303.2118"
 "/home/davep/.emacs.d/elpa/log4e-20200420.745"
 "/home/davep/.emacs.d/elpa/gntp-20141025.250"
 "/home/davep/.emacs.d/elpa/mu4e-jump-to-list-20190419.1442"
 "/home/davep/.emacs.d/elpa/navigel-20200202.1214"
 "/home/davep/.emacs.d/elpa/nhexl-mode-1.5"
 "/home/davep/.emacs.d/elpa/osx-dictionary-20191206.519"
 "/home/davep/.emacs.d/elpa/paredit-20191121.2328"
 "/home/davep/.emacs.d/elpa/pcache-20170105.2214"
 "/home/davep/.emacs.d/elpa/pcmpl-git-20170121.59"
 "/home/davep/.emacs.d/elpa/pcre2el-20161120.2103"
 "/home/davep/.emacs.d/elpa/pos-tip-20191227.1356"
 "/home/davep/.emacs.d/elpa/projectile-20200610.1221"
 "/home/davep/.emacs.d/elpa/pkg-info-20150517.1143"
 "/home/davep/.emacs.d/elpa/epl-20180205.2049"
 "/home/davep/.emacs.d/elpa/pungi-20150222.1246"
 "/home/davep/.emacs.d/elpa/jedi-20191011.1750"
 "/home/davep/.emacs.d/elpa/auto-complete-20170125.245"
 "/home/davep/.emacs.d/elpa/jedi-core-20191011.1750"
 "/home/davep/.emacs.d/elpa/epc-20140610.534"
 "/home/davep/.emacs.d/elpa/ctable-20171006.11"
 "/home/davep/.emacs.d/elpa/concurrent-20161229.330"
 "/home/davep/.emacs.d/elpa/py-autopep8-20160925.1052"
 "/home/davep/.emacs.d/elpa/py-yapf-20160925.1122"
 "/home/davep/.emacs.d/elpa/python-black-20200324.930"
 "/home/davep/.emacs.d/elpa/python-environment-20150310.853"
 "/home/davep/.emacs.d/elpa/deferred-20170901.1330"
 "/home/davep/.emacs.d/elpa/pyvenv-20191202.1039"
 "/home/davep/.emacs.d/elpa/quick-peek-20200130.2059"
 "/home/davep/.emacs.d/elpa/reformatter-20200426.818"
 "/home/davep/.emacs.d/elpa/request-20200517.1305"
 "/home/davep/.emacs.d/elpa/rpn-calc-20181121.1154"
 "/home/davep/.emacs.d/elpa/popup-20200610.317"
 "/home/davep/.emacs.d/elpa/stem-20131102.1109"
 "/home/davep/.emacs.d/elpa/stgit-20200606.1308"
 "/home/davep/.emacs.d/elpa/swiper-20200503.1102"
 "/home/davep/.emacs.d/elpa/ivy-20200608.1454"
 "/home/davep/.emacs.d/elpa/tablist-20200427.2205"
 "/home/davep/.emacs.d/elpa/thingopt-20160520.2318"
 "/home/davep/.emacs.d/elpa/treemacs-magit-20200421.1426"
 "/home/davep/.emacs.d/elpa/treemacs-20200601.1029"
 "/home/davep/.emacs.d/elpa/ht-20200217.2331"
 "/home/davep/.emacs.d/elpa/pfuture-20200425.1357"
 "/home/davep/.emacs.d/elpa/ace-window-20200606.1259"
 "/home/davep/.emacs.d/elpa/avy-20200522.510"
 "/home/davep/.emacs.d/elpa/f-20191110.1357"
 "/home/davep/.emacs.d/elpa/s-20180406.808"
 "/home/davep/.emacs.d/elpa/vdiff-magit-20190304.1707"
 "/home/davep/.emacs.d/elpa/magit-20200610.1111"
 "/home/davep/.emacs.d/elpa/git-commit-20200608.928"
 "/home/davep/.emacs.d/elpa/transient-20200601.1749"
 "/home/davep/.emacs.d/elpa/dash-20200524.1947"
 "/home/davep/.emacs.d/elpa/vdiff-20200214.1845"
 "/home/davep/.emacs.d/elpa/hydra-20200608.1528"
 "/home/davep/.emacs.d/elpa/lv-20200507.1518"
 "/home/davep/.emacs.d/elpa/w3m-20200325.2226"
 "/home/davep/.emacs.d/elpa/web-server-20200330.1407"
 "/home/davep/.emacs.d/elpa/websocket-20200419.2124"
 "/home/davep/.emacs.d/elpa/with-editor-20200609.903"
 "/home/davep/.emacs.d/elpa/async-20200113.1745"
 "/home/davep/.emacs.d/elpa/yahoo-weather-20181026.320"
 "/home/davep/.emacs.d/elpa/yapfify-20200406.830"
 "/home/davep/.emacs.d/elpa/yasnippet-20200524.2215"
 "/home/davep/.emacs.d/elpa/ztree-20191108.2234"
 "/home/davep/local/share/emacs/26.3.50/site-lisp"
 "/home/davep/local/share/emacs/site-lisp"
 "/home/davep/local/share/emacs/site-lisp/mu4e"
 "/home/davep/local/share/emacs/26.3.50/lisp"
 "/home/davep/local/share/emacs/26.3.50/lisp/vc"
 "/home/davep/local/share/emacs/26.3.50/lisp/url"
 "/home/davep/local/share/emacs/26.3.50/lisp/textmodes"
 "/home/davep/local/share/emacs/26.3.50/lisp/progmodes"
 "/home/davep/local/share/emacs/26.3.50/lisp/play"
 "/home/davep/local/share/emacs/26.3.50/lisp/org"
 "/home/davep/local/share/emacs/26.3.50/lisp/nxml"
 "/home/davep/local/share/emacs/26.3.50/lisp/net"
 "/home/davep/local/share/emacs/26.3.50/lisp/mh-e"
 "/home/davep/local/share/emacs/26.3.50/lisp/mail"
 "/home/davep/local/share/emacs/26.3.50/lisp/leim"
 "/home/davep/local/share/emacs/26.3.50/lisp/language"
 "/home/davep/local/share/emacs/26.3.50/lisp/international"
 "/home/davep/local/share/emacs/26.3.50/lisp/image"
 "/home/davep/local/share/emacs/26.3.50/lisp/gnus"
 "/home/davep/local/share/emacs/26.3.50/lisp/eshell"
 "/home/davep/local/share/emacs/26.3.50/lisp/erc"
 "/home/davep/local/share/emacs/26.3.50/lisp/emulation"
 "/home/davep/local/share/emacs/26.3.50/lisp/emacs-lisp"
 "/home/davep/local/share/emacs/26.3.50/lisp/cedet"
 "/home/davep/local/share/emacs/26.3.50/lisp/calendar"
 "/home/davep/local/share/emacs/26.3.50/lisp/calc"
 "/home/davep/local/share/emacs/26.3.50/lisp/obsolete")nil




========================
Wednesday June 17 2020
--
(let ((code (concat "import sys\n"
                    "print(sys.ps1)")))
  (with-temp-buffer  
    (let ((code-file (python-shell--save-temp-file code)))
      (call-process "jupyter-console" code-file '(t nil) nil "-i")
      (delete-file code-file))
    (buffer-string)))
"The Jupyter terminal-based Console.

This launches a Console application inside a terminal.

The Console supports various extra features beyond the traditional single-
process Terminal IPython shell, such as connecting to an existing ipython
session, via:

    jupyter console --existing

where the previous session could have been created by another ipython console,
an ipython qtconsole, or by opening an ipython notebook.

Options
-------

Arguments that take values are actually convenience aliases to full
Configurables, whose aliases are listed on the help line. For more information
on full configurables, see '--help-all'.

--debug
    set log level to logging.DEBUG (maximize logging output)
--generate-config
    generate default config file
-y
    Answer yes to any questions instead of prompting.
--existing
    Connect to an existing kernel. If no argument specified, guess most recent
--confirm-exit
    Set to display confirmation dialog on exit. You can always use 'exit' or
    'quit', to force a direct exit without any confirmation. This can also
    be set in the config file by setting
    `c.JupyterConsoleApp.confirm_exit`.
--no-confirm-exit
    Don't prompt the user when exiting. This will terminate the kernel
    if it is owned by the frontend, and leave it alive if it is external.
    This can also be set in the config file by setting
    `c.JupyterConsoleApp.confirm_exit`.
--simple-prompt
    Force simple minimal prompt using `raw_input`
--no-simple-prompt
    Use a rich interactive prompt with prompt_toolkit
--log-level=<Enum> (Application.log_level)
    Default: 30
    Choices: (0, 10, 20, 30, 40, 50, 'DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL')
    Set the log level by value or name.
--config=<Unicode> (JupyterApp.config_file)
    Default: ''
    Full path of a config file.
--ip=<Unicode> (JupyterConsoleApp.ip)
    Default: ''
    Set the kernel's IP address [default localhost]. If the IP address is
    something other than localhost, then Consoles on other machines will be able
    to connect to the Kernel, so be careful!
--transport=<CaselessStrEnum> (JupyterConsoleApp.transport)
    Default: 'tcp'
    Choices: ['tcp', 'ipc']
--hb=<Int> (JupyterConsoleApp.hb_port)
    Default: 0
    set the heartbeat port [default: random]
--shell=<Int> (JupyterConsoleApp.shell_port)
    Default: 0
    set the shell (ROUTER) port [default: random]
--iopub=<Int> (JupyterConsoleApp.iopub_port)
    Default: 0
    set the iopub (PUB) port [default: random]
--stdin=<Int> (JupyterConsoleApp.stdin_port)
    Default: 0
    set the stdin (ROUTER) port [default: random]
--existing=<CUnicode> (JupyterConsoleApp.existing)
    Default: ''
    Connect to an already running kernel
-f <Unicode> (JupyterConsoleApp.connection_file)
    Default: ''
    JSON file in which to store connection info [default: kernel-<pid>.json]
    This file will contain the IP, ports, and authentication key needed to
    connect clients to this kernel. By default, this file will be created in the
    security dir of the current profile, but can be specified by absolute path.
--kernel=<Unicode> (JupyterConsoleApp.kernel_name)
    Default: 'python'
    The name of the default kernel to start.
--ssh=<Unicode> (JupyterConsoleApp.sshserver)
    Default: ''
    The SSH server to use to connect to the kernel.

To see all available configurables, use `--help-all`

Examples
--------

    jupyter console # start the ZMQ-based console
    jupyter console --existing # connect to an existing ipython session

"

""


""



">>> 
"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq python-shell-interpreter "jupyter-console")

(defun* python-shell-prompt-detect (&optional
				    (python-shell-interpreter-interactive-arg
				     "--simple-prompt"))
  "Detect prompts for the current `python-shell-interpreter'.
When prompts can be retrieved successfully from the
`python-shell-interpreter' run with
`python-shell-interpreter-interactive-arg', returns a list of
three elements, where the first two are input prompts and the
last one is an output prompt.  When no prompts can be detected
and `python-shell-prompt-detect-failure-warning' is non-nil,
shows a warning with instructions to avoid hangs and returns nil.
When `python-shell-prompt-detect-enabled' is nil avoids any
detection and just returns nil."
  (when python-shell-prompt-detect-enabled
    (python-shell-with-environment
      (let* ((code (concat
                    "import sys\n"
                    "ps = [getattr(sys, 'ps%s' % i, '') for i in range(1,4)]\n"
                    ;; JSON is built manually for compatibility
                    "ps_json = '\\n[\"%s\", \"%s\", \"%s\"]\\n' % tuple(ps)\n"
                    "print (ps_json)\n"
                    "exit\n"))
;;;;;;;                    "sys.exit(0)\n"))
             (interpreter python-shell-interpreter)
             (interpreter-arg python-shell-interpreter-interactive-arg)
             (output
              (with-temp-buffer
                ;; TODO: improve error handling by using
                ;; `condition-case' and displaying the error message to
                ;; the user in the no-prompts warning.
                (ignore-errors
                  (let ((code-file
                         ;; Python 2.x on Windows does not handle
                         ;; carriage returns in unbuffered mode.
                         (let ((inhibit-eol-conversion (getenv "PYTHONUNBUFFERED")))
                           (python-shell--save-temp-file code))))
                    (unwind-protect
                        ;; Use `process-file' as it is remote-host friendly.
                        (process-file
                         interpreter
                         code-file
                         '(t nil)
                         nil
                         interpreter-arg)
                      ;; Try to cleanup
                      (delete-file code-file))))
                (buffer-string)))
	     (nnnaaadddaaa (dmessage "output>%s<" output))
             (prompts
              (catch 'prompts
                (dolist (line (split-string output "\n" t))
                  (let ((res
                         ;; Check if current line is a valid JSON array
                         (and (string= (substring line 0 2) "[\"")
                              (ignore-errors
                                ;; Return prompts as a list, not vector
                                (append (json-read-from-string line) nil)))))
                    ;; The list must contain 3 strings, where the first
                    ;; is the input prompt, the second is the block
                    ;; prompt and the last one is the output prompt.  The
                    ;; input prompt is the only one that can't be empty.
                    (when (and (= (length res) 3)
                               (cl-every #'stringp res)
                               (not (string= (car res) "")))
                      (throw 'prompts res))))
                nil)))
	(dmessage "prompts>%s<" prompts)
        (when (and (not prompts)
                   python-shell-prompt-detect-failure-warning)
          (lwarn
           '(python python-shell-prompt-regexp)
           :warning
           (concat
            "Python shell prompts cannot be detected.\n"
            "If your emacs session hangs when starting python shells\n"
            "recover with `keyboard-quit' and then try fixing the\n"
            "interactive flag for your interpreter by adjusting the\n"
            "`python-shell-interpreter-interactive-arg' or add regexps\n"
            "matching shell prompts in the directory-local friendly vars:\n"
            "  + `python-shell-prompt-regexp'\n"
            "  + `python-shell-prompt-block-regexp'\n"
            "  + `python-shell-prompt-output-regexp'\n"
            "Or alternatively in:\n"
            "  + `python-shell-prompt-input-regexps'\n"
            "  + `python-shell-prompt-output-regexps'")))
        prompts))))


(python-shell-prompt-detect)
("In : " "...: " "Out: ")

("In : " "...: " "Out: ")










(setq python-shell-interpreter "jupyter"
      python-shell-interpreter-args "console --simple-prompt"
      python-shell-prompt-detect-failure-warning nil)
(add-to-list 'python-shell-completion-native-disabled-interpreters
             "jupyter")
("jupyter" "pypy" "ipython")


python-shell-interpreter
"jupyter"

python-shell-interpreter-args
"console --simple-prompt"

python-shell-prompt-detect-failure-warning
nil

python-shell-completion-native-disabled-interpreters
("jupyter" "pypy" "ipython")



========================
Monday June 22 2020
--

(defun dp-lisp-indent-0 (a b)
  (dmessage "a: %s, b: %s" a b)
  0)
lisp-indent-0
(put 'dp-loading-require 'lisp-indent-function 'dp-lisp-indent-0)


(cl-pe '
(defmacro dp-unindented-body (docstring &rest body)
  "Sometimes it's nicer to be non-indented, since some actions get confuzed.
E.e. things in `dp-macros.el'."
  (unless (stringp docstring)
    (setq body (cons docstring body)
	  docstring ""))
  `(progn
     ,@body
     )
  )
)

(defalias 'dp-unindented-body
  (cons 'macro
	(function
	 (lambda (docstring &rest body)
	   "Sometimes it's nicer to be non-indented, since some actions get confuzed.
E.e. things in `dp-macros.el'."
	   (if (stringp docstring)
	       nil
	     (setq body (cons docstring body) docstring ""))
	   (cons 'progn body)))))
(put 'dp-unindented-body 'lisp-indent-function 'dp-lisp-indent-0)

(cl-pe '
(dp-unindented-body zz t
(a)
(b)
(c)
)
)

(dp-unindented-body zz t (a) (b) (c))nil



(dp-unindented-body zz t (a) (b) (c))nil



(dp-unindented-body zz t (a) (b) (c))nil



(dp-unindented-body (a) (b) (c))nil



(progn
  (a)
  (b)
  (c))nil





(cl-pe '
 (defmacro dp-loading-require (name enable-p &rest body)
   (let ((msg-prefix (dmessage "require: %s..." name)))
     (when enable-p
       `(progn
	  (dmessage ">%s<<" ,msg-prefix)
	  ,@body
	  (dmessage "%sdone." ,msg-prefix)
	  (provide ',name)
	  )))
   )
)


(defalias 'dp-loading-require
  (cons 'macro
	(function
	 (lambda (name enable-p &rest body)
	   (let ((msg-prefix (dmessage "require: %s..." name)))
	     (if enable-p
		 (progn
		   (cons 'progn
			 (cons (list 'dmessage ">%s<<" msg-prefix)
			       (append body
				       (list (list 'dmessage
						   "%sdone."
						   msg-prefix)
					     (list 'provide
						   (list 'quote name)))))))))))))nil


(cl-pe '
 (defmacro dp-loading-require (&rest body)
   (
(defalias 'dp-loading-require
  (cons 'macro (function (lambda (&rest body) (progn body)))))
dp-unindented-body
`,@body)
   )
 )



(get 'dp-loading-require 'lisp-indent-function)
nil

(lambda (&rest r) 2)

lisp-indent-0


(lambda nil 0)



(cl-pe '
 (dp-loading-require bubba t
		     (setq a 'b)
		     ))

(progn
  (dmessage "%s" "require: bubba...")
  (setq a 'b)
  (dmessage "%sdone." "require: bubba...")
  (provide 'bubba))nil



(progn
  (dmessage ">%s<<" "require: bubba...")
  t
  (setq a 'b)
  (dmessage "%sdone." "require: bubba...")
  (provide 'bubba))nil



(progn
  (dmessage ">%s<<" "require: bubba...")
  (setq a 'b)
  (dmessage "%sdone." "require: bubba...")
  (provide 'bubba))nil



(progn
  (dmessage ">%s<<" "require: bubba...")
  (setq a 'b)
  (dmessage "%sdone." "require: bubba...")
  (provide 'bubba))
bubba
()



(progn
  (dmessage "%s" "require: bubba...")
  (setq a 'b)
  (dmessage "%sdone." "require: bubba...")
  (provide 'bubba))nil



(progn
  (dmessage "%s" "require: bubba...")
  (setq a 'b)
  (dmessage "%sdone." "require: bubba...")
  (provide '"bubba"))nil




(progn
  (princf "%s" "require: bubba...")
  (setq a 'b)
  (princf "in body")
  (princf "%sdone." "require: bubba..."))
require: bubba...
in body
require: bubba...done.
nil

require: bubba...
require: bubba...done.
nil

"require: bubba...done."





(dmessage "%sdone." "require: bubba...")
"require: bubba...done."




(dmessage "%s" "require: bubba...")
 (setq a 'b)
 (dmessage "%sdone." "require: bubba...")
"require: bubba...done."

(cl-pe '
 (dp-loading-require
     bubba3
     (setq req-test-b 'b)
     (setq req-test-a 'a)
     (setq req-test-c 'c)
     (dmessage "did abc")
     (setq req-test-d 'd)
     (setq req-test-e 'e)
   (setq req-test-f 'f)
   (dmessage "did def")
   (setq req-test-g 'g)
   (dmessage "did g")
  )
)

(progn
  (dmessage ">%s<<" "require: bubba2...")
  (setq req-test-b 'b)
  (setq req-test-a 'a)
  (setq req-test-c 'c)
  (dmessage "did abc")
  (setq req-test-d 'd)
  (setq req-test-e 'e)
  (setq req-test-f 'f)
  (dmessage "did def")
  (setq req-test-g 'g)
  (dmessage "did g")
  (dmessage "%sdone." "require: bubba2...")
  (provide 'bubba2))nil


  (dmessage "%sdone." "require: bubba2...")

"require: bubba2...done."

(save-excursion
  aa
  aa
  aa
  aa
  )
(dp-loading-require bubba3
(setq req-test-b 'b)
(setq req-test-a 'a)
(setq req-test-c 'c)
(dmessage "did abc")
(setq req-test-d 'd)
(setq req-test-e 'e)
(setq req-test-f 'f)
(dmessage "did def")
(setq req-test-g 'g)
(dmessage "did g")
)

========================
Tuesday June 23 2020
--

(cl-pe '
 (defmacro dp-loading-require (name enable-p &rest body)
   (let ((msg-prefix (dmessage "require: %s..." name)))
     (when enable-p
       `(progn
	  (dmessage ">%s<<" ,msg-prefix)
	  ,@body
	  (dmessage "%sdone." ,msg-prefix)
	  (provide ',name)
	  ))))
 )

(cl-pe '
(dp-loading-require bubba3 nil
(setq req-test-b 'b)
(setq req-test-a 'a)
(setq req-test-c 'c)
(dmessage "did abc")
(setq req-test-d 'd)
(setq req-test-e 'e)
(setq req-test-f 'f)
(dmessage "did def")
(setq req-test-g 'g)
(dmessage "did g")
)
)

(progn
  (dmessage ">%s<<" "require: bubba3...")
  nil
  (setq req--test-b 'b)
  (setq req--test-a 'a)
  (setq req--test-c 'c)
  (dmessage "did abc")
  (setq req--test-d 'd)
  (setq req--test-e 'e)
  (setq req--test-f 'f)
  (dmessage "did def")
  (setq req--test-g 'g)
  (dmessage "did g")
  (dmessage "%sdone." "require: bubba3...")
  (provide 'bubba3))
bubba3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(cl-pe '
 (defmacro dp-loading-require (name enable-p &rest body)
   (let ((msg-prefix (dmessage "require: %s..." name))
	 (ok-enable-values '(t nil enable load require norequire)))
     (if (not (memq enable-p ok-enable-values))
	 (error "enable-p no a member of %s", ok-enable-values)
       (when enable-p
	 `(progn
	    (dmessage ">%s<<" ,msg-prefix)
	    ,@body
	    (dmessage "%sdone." ,msg-prefix)
	    (provide ',name)
	    )))))
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(cl-pe '
(dp-loading-require bubba3 'nil
  (setq req==test==b 'b)
  (setq req==test==a 'a)
  (setq req==test==c 'c)
  (princf "did abc")
  (setq req==test==d 'd)
  (setq req==test==e 'e)
  (setq req==test==f 'f)
  (princf "did def")
  (setq req==test==g 'g)
  (princf "did g")
)
)
name: bubba3, enable-p: (quote nil), docstring: (setq req==test==b (quote b))


(defun dp-lisp-indent-0 (a b)
  (dmessage "a: %s, b: %s" a b)
  0)
(put 'dp-loading-require 'lisp-indent-function 'dp-lisp-indent-0)

(defmacro dp-loading-require (name enable-p &rest body)
  (let ((msg-prefix (dmessage "require: %s..." name)))
    (when enable-p
      `(progn
	 (dmessage "%s" ,msg-prefix)
	 ,@body
	 (dmessage "%sdone." ,msg-prefix)
	 (provide ',name)
	 ))))


(defmacro dp-loading-require (name enable-p &rest body)
  (princf "enable-p:%s, ,enable-p:%s" enable-p `,enable-p)
  (let ((msg-prefix (dmessage "require: %s..." name))
	(ok-enable-values '(t enable enabled load require allow))
	(nok-enable-values '(nil no-enable no-enabled no-load no-require allow)))
    (if (not (memq `,enable-p (append ok-enable-values nok-enable-values)))
	(error "enable-p>%s< not a member of %s" enable-p ok-enable-values)
      (when (memq `,enable-p ok-enable-values)
	`(progn
	   (dmessage "%s" ,msg-prefix)
	   ,@body
	   (dmessage "%sdone." ,msg-prefix)
	   (provide ',name)
	   )))))

(cl-pe '
 (kb-warning "aaa" "hi")
 )

(function
 (lambda (&optional arg arg1 arg2 arg3 arg4 arg5)
   "aaa"
   (interactive "P")
   (error "kb-warning: %s" "hi")))

(cl-pe '
 (with-narrow-to-region 1 2
   (set a 1)
   (set b 1)
   )
 )

(progn
  (save-restriction (narrow-to-region 1 2) (set a 1) (set b 1)))nil


    

========================
Sunday June 28 2020
--
(defalias 'foofoo
  (defun foofoofun()
    (interactive)
    (message "I am foofoo(fun)?")))
foofoo

(password-read "PWD? ")
"lkdjfldkjfldkjf"

========================
2020-06-28T09:45:48
--
;;;; Works.
(modify-frame-parameters nil
	(list (cons 'cursor-type 'box)))
nil

;;; Hollow box.
(modify-frame-parameters nil
	(list (cons 'cursor-type 'block)))
nil

;;; Hollow box.
(modify-frame-parameters nil
	(list (cons 'cursor-type 'yaya)))
nil
Looks like bad cursor-type symbols give a hollow box.



nil

nil


========================
Monday June 29 2020
--

;obs (defvar-deflocal xemacs-like-eol-cursor-type 'box)
;obs (defun dp-xemacs-like-eol-cursor ()
;obs   (let ((old 'nc))
;obs     (if (eolp)
;obs 	(when (not (eq dp-xemacs-like-eol-cursor-type 'bar))
;obs 	  (setq old dp-xemacs-like-eol-cursor-type
;obs 		dp-xemacs-like-eol-cursor-type 'bar)
;obs 	  (modify-frame-parameters nil
;obs 				   (list (cons 'cursor-type
;obs 					       (cons
;obs 						dp-xemacs-like-eol-cursor-type
;obs 						;;    m|m|m|m
;obs 						6)))))
;obs       (when (not (eq dp-xemacs-like-eol-cursor-type 'box))
;obs 	(setq old dp-xemacs-like-eol-cursor-type
;obs 	      dp-xemacs-like-eol-cursor-type 'box)
;obs 	(modify-frame-parameters nil
;obs 				 (list (cons 'cursor-type
;obs 					     dp-xemacs-like-eol-cursor-type)))))
;obs     (cons old dp-xemacs-like-eol-cursor-type)))


(defvar-deflocal xemacs-like-eol-cursor-type 'box)
(defun dp-xemacs-like-eol-cursor ()
  (let ((old 'nc))
    (if (eolp)
	(when (not (eq dp-xemacs-like-eol-cursor-type 'bar))
	  (setq old dp-xemacs-like-eol-cursor-type
		dp-xemacs-like-eol-cursor-type 'bar
		cursor-type (cons
			     dp-xemacs-like-eol-cursor-type
			     6)))
      (when (not (eq dp-xemacs-like-eol-cursor-type 'box))
	(setq old dp-xemacs-like-eol-cursor-type
	      dp-xemacs-like-eol-cursor-type 'box
	      cursor-type dp-xemacs-like-eol-cursor-type)))
    (cons old dp-xemacs-like-eol-cursor-type)))


========================
Monday July 06 2020
--
(defmacro dp-loading-require (name enable-p docstring &rest body)
  (unless (stringp docstring)
    (error "dp-loading-require: docstring isn't."))
  (let ((msg-prefix (dmessage "require: %s..." name)))
    (when enable-p
      `(progn
	 (dmessage "%s" ,msg-prefix)
	 ,@body
	 (dmessage "%sdone." ,msg-prefix)
	 (provide ',name)
	 ))))
dp-loading-require

(defmacro dp-loading-require (name enable-p docstring &rest body)
  (princf "name: %s, enable-p: %s, docstring: %s" name enable-p docstring)
  (unless (stringp docstring)
    (error "dp-loading-require: docstring isn't."))
  (let ((msg-prefix (dmessage "require: %s..." name))
	(ok-enable-values '(t enable enabled load require allow))
	(nok-enable-values '(nil no-enable no-enabled no-load no-require allow)))
    (if (not (memq `,enable-p (append ok-enable-values nok-enable-values)))
	(error "enable-p>%s< not a member of %s" enable-p ok-enable-values)
      (when (memq `,enable-p ok-enable-values)
	`(progn
	   (dmessage "%s" ,msg-prefix)
	   (dmessage "%s" ,docstring)
	   ,@body
	   (dmessage "%sdone." ,msg-prefix)
	   (provide ',name)
	   )))))


(cl-pe '
 (dp-loading-require 'bubba3 t
"Test of loading messages."
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
)
)

(progn
  (message "%sbegin" "require: 'bubba3...")
  "Test of loading messages."
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (message "%sdone." "require: 'bubba3...")
  (provide 'bubba3))

  (message "a%sbegin" "require: 'bubba3...")
"arequire: 'bubba3...begin"

  (message "b%sdone." "require: 'bubba3...")
"brequire: 'bubba3...done."



(progn
  (message "begin: %s" "require: 'bubba3...")
  (message "end: %sdone." "require: 'bubba3...")
  )
"end: require: 'bubba3...done."

"require: 'bubba3...done."



(progn
  (message "%s" "require: 'bubba3...")
  "Test of loading messages."
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (message "%sdone." "require: 'bubba3...")
  (provide 'bubba3))nil



(progn
  (message "%s" "require: bubba3...")
  "Test of loading messages."
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (message "%sdone." "require: bubba3...")
  (provide "bubba3"))nil


name: bubba3, enable-p: t, docstring: Test of loading messages.

(progn
  (dmessage "%s" "require: bubba3...")
  (dmessage "%s" "Test of loading messages.")
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (dmessage "%sdone." "require: bubba3...")
  (provide '"bubba3"))nil


name: (quote bubba3), enable-p: t, docstring: Test of loading messages.

(progn
  (dmessage "%s" "require: 'bubba3...")
  (dmessage "%s" "Test of loading messages.")
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (dmessage "%sdone." "require: 'bubba3...")
  (provide '(quote bubba3)))nil


name: bubba3, enable-p: t, docstring: Test of loading messages.

(progn
  (dmessage "%s" "require: bubba3...")
  (dmessage "%s" "Test of loading messages.")
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (dmessage "%sdone." "require: bubba3...")
  (provide 'bubba3))nil


name: bubba3, enable-p: t, docstring: Test of loading messages.

(progn
  (dmessage "%s" "require: bubba3...")
  (dmessage "%s" docstring)
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (dmessage "%sdone." "require: bubba3...")
  (provide 'bubba3))nil


name: bubba3, enable-p: t, docstring: Test of loading messages.

(progn
  (dmessage "%s" "require: bubba3...")
  (princf "req==test==b")
  (princf "req==test==a")
  (princf "req==test==c")
  (princf "did abc")
  (princf "req==test==d")
  (princf "req==test==e")
  (princf "req==test==f")
  (princf "did def")
  (princf "req==test==g")
  (princf "did g")
  (dmessage "%sdone." "require: bubba3...")
  (provide 'bubba3))nil


name: bubba3, enable-p: nil, docstring: Test of loading messages.

nilnil


name: bubba3, enable-p: nil, docstring: Test of loading messages.

nilnil




(princf "%s" ''x)
(quote x)
nil

x
nil

========================
Tuesday July 07 2020
--

(dp-temp-*mode-buffer-alist 'lisp-interaction-mode)
nil
dp-temp-*mode-buffer-alist
nil

(dp-temp-*mode-buffer-alist 'lisp-interaction-mode)
nil

(cl-pe '
 (defmacro cl--check-test (item x)       ;all of the above.
  (declare (debug edebug-forms))
  `(cl--check-test-nokey ,item (cl--check-key ,x)))
 )

(prog1
    (defalias 'cl--check-test
      (cons 'macro
	    (function
	     (lambda (item x)
	       (list 'cl--check-test-nokey item (list 'cl--check-key x))))))
  (progn
    :autoload-end
    (put 'cl--check-test 'edebug-form-spec 'edebug-forms)))nil




(let ((a1 '((a . 1) (b . 2) (c . 4) (z . 26)))
      (a2 '((aa . 11) (d . 4) (c . 3)))
      (a9 '((aa . 99)))
      z z2)
  ;(remassoc 'a1 '(b 2))
  ;; (setq z (cl-delete 'b a1 :test #'equal
  ;; 	     :key #'car))
  (setq z2 (remassoc 'b a1))
  (princf "a1>%s<" a1)
  (princf "z>%s<" z)
  (princf "z2>%s<" z2)
  )
a1>((a . 1) (c . 4) (z . 26))<
z>nil<
z2>((a . 1) (c . 4) (z . 26))<
nil

a1>((a . 1) (c . 4) (z . 26))<
z>((a . 1) (c . 4) (z . 26))<
z2>nil<
nil

a1>((a . 1) (c . 4) (z . 26))<
z>((a . 1) (c . 4) (z . 26))<
nil

a1>((a . 1) (c . 4) (z . 26))<
z>((a . 1) (c . 4) (z . 26))<
nil

a1>((a . 1) (b . 2) (z . 26))<
z>((a . 1) (b . 2) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
z>((a . 1) (b . 2) (c . 4) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
z>((a . 1) (b . 2) (c . 4) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
z>((a . 1) (b . 2) (c . 4) (z . 26))<
nil


ssssss

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
z>((a . 1) (b . 2) (c . 4) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
z>((a . 1) (b . 2) (c . 4) (z . 26))<
nil

a1>((a . 1) (b . 2) (c . 4) (z . 26))<
nil



((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))






((a . 1) (b . 2) (c . 4) (z . 26))

(nthcdr 2 '((a . 1) (b . 2) (c . 4) (z . 26)))
((c . 4) (z . 26))


(nthcdr 3 '(1 2 3 4 5))
(4 5)



(nthcdr 3 '((a . 1) (b . 2) (c . 4) (z . 26)))
((z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))



((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))



((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))




((a . 1) (b . 2) (c . 4) (z . 26))



((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))

((a . 1) (b . 2) (c . 4) (z . 26))



(assoc 'c 
========================
2020-07-07T19:20:29
--
(let ((a1 '((a . 1) (b . 2) (c . 4) (z . 26)))
      (a2 '((aa . 11) (d . 4) (c . 3)))
      (a9 '((aa . 99)))
      z z2)
  (assoc 'c a1))

(list 'a 'a)
(a a)
(atom 'a)
t

(cdr 1)
(internal--listify 'a)
(a a)
(internal--listify 1)
(internal--listify nil)
(nil nil)

(internal--listify 'a)
(internal--listify '(((+ 1 1))))
(s ((+ 1 1)))

(cdr '(((+ 1 1))))
nil


(a a)

(s a)

(a b)

(a b c)

(a b c 1 2 3)

(s a)

(dp-listify-thing 'a)
(a)
(dp-listify-thing 1)
(1)
(dp-listify-thing "szzz")
("szzz")
(dp-listify-thing '(a))
(a)
(dp-listify-thing '(a b c))
(a b c)

(dp-listify-thing '(((+ 1 1))))
(((+ 1 1)))
========================
2020-07-07T21:23:48
--
(cl-pp dp-bubba-item)

(#("politics.2020" 0 13 (fontified t)))nil

(cdr dp-bubba-item)
nil
(listp (car dp-bubba-item))
nil
(listp dp-bubba-item)
t



#("politics.2020" 0 13 (fontified t))


========================
Thursday July 09 2020
--
========================
2020-07-09T11:25:46
--
(setq dp-dbg-a '((a "a") (qw "qw") (qw "qw2")
		 ))
((a "a") (qw "qw") (qw "qw2"))
(assoc 'qw dp-dbg-a)
(qw "qw")

(setq dp-dbg-a '((a "a") (qw ("qw" "qw2"))
		 ))
((a "a") (qw ("qw" "qw2")))
(assoc 'qw dp-dbg-a)
(qw ("qw" "qw2"))

(setq dp-dbg-a '((a . "a") (qw . ("qw" "qw2"))
		 ))
((a . "a") (qw "qw" "qw2"))

dp-dbg-a
((a . "a") (qw "qw" "qw2"))

(assoc 'z dp-dbg-a)
nil

(assoc 'qw dp-dbg-a)
(qw "qw" "qw2")

(remassoc 'qw '((a . "a") (qw . ("qw" "qw2"))
		 ))
((a . "a"))
(remassoc 'a
	  '(
	    (a . "a")
	    (qw . ("qw" "qw2"))
	    (a . "aa")
	    (qw . ("qwA" "QWb"))
	    )
	  )
((qw "qw" "qw2") (qw "qwA" "QWb"))


((qw "qw" "qw2"))

(let ((l '((a "a") (qw ("qw" "qw2")))))
  (car (assoc 'a l))
  )
a
(let ((l '((a "a") (qw ("qw" "qw2")))))
  (car (assoc 'qw l))
  )
qw
(let ((l '((a "a") (qw ("qw" "qw2")))))
  (car (cdr (assoc 'qw l)))
  )
("qw" "qw2")

(("qw" "qw2"))

(let ((l '((a "a") (qw ("qw" "qw2")))))
  (car (cdr (assoc 'a l)))
  )
"a"

("a")

(let ((l '((a "a") (qw ("qw" "qw2")))))
  (acons 'a "NEWa" l)
  )
((a . "NEWa") (a "a") (qw ("qw" "qw2")))


;; installed (defun* dp-add-or-update-alist (alist-var key val
;; installed 					  &key
;; installed 					  (canonicalizep nil)
;; installed 					  (keep-old-if-nil-p nil))
;; installed   "Add \(cons KEY VAL) to ALIST-VAR iff KEY isn't in ALIST-VAR.

;; installed If KEY exists, VAL will replace the existing val associated with
;; installed KEY.  UPDATE-P tells us how to update VAL: nil or not specified:
;; installed just add or replace.  'CANONICALIZEP: Nuke all with matching keys
;; installed w/ `remassoc'.  This puts the list into the canonical format: 0
;; installed or 1 instances of KEY.  In this case, 0 instances.  We don't use
;; installed `add-to-list' because we only want to key on KEY."
;; installed   (let (item orig-val)
;; installed     (when (and keep-old-if-nil-p
;; installed 	       (null val))
;; installed       ;; Preserve the original value if new one is nil and the caller wants
;; installed       ;; us to.  Be sure to save before canonicalization (d'uh).
;; installed       (setq item (assoc key (symbol-value alist-var))
;; installed 	    val (cdr-safe item)))
;; installed     (when canonicalizep
;; installed       ;; Nuke 'em all. We'll add a single entry for this key of val.
;; installed       (set alist-var (remassoc key (symbol-value alist-var))))
;; installed     ;; `item' (val part) may have changed due to the update. ?WHY/HOW?
;; installed     ;; get current item
;; installed     (if (setq item (assoc key (symbol-value alist-var)))
;; installed 	;; Update in place, either adding new entry if we canonicalized, else
;; installed 	;; cons the new val onto the current items' key.
;; installed 	(progn
;; installed 	  (setq val (cons val (dp-listify-thing (cdr item))))
;; installed 	  (setcdr item val))
;; installed       ;; Not in the alist, add it.
;; installed       (set alist-var (acons key val (symbol-value alist-var))))
;; installed     ;; Return current value.
;; installed     (symbol-value alist-var)))

(setq dp-dbg-a '((a "a") (qw ("qw" "qw2"))))
(let ()
  (dp-add-or-update-alist 'dp-add-or-update-alist 'a "a2")
  )
((a "a2" "a") (qw ("qw" "qw2")))

(setq dp-dbg-a '((a "a") (qw ("qw" "qw2")) (a "OTHER A")))
dp-dbg-a
((a "a") (qw ("qw" "qw2")))

((a ("JUSTME" "a") "JUSTME" "a") (qw ("qw" "qw2")) (a "OTHER A"))

((a "a") (qw ("qw" "qw2")) (a "OTHER A"))

((a . "WAHA") (qw ("qw" "qw2")))


(dp-add-or-update-alist 'dp-dbg-a 'a nil :canonicalizep t :keep-old-if-nil-p t)
((a "JUSTME" "a") (qw ("qw" "qw2")) (a "OTHER A"))


((a . "JUSTME") (qw ("qw" "qw2")))

((a "PUZUZU" "WAHA" "WAHA" "a") (qw ("qw" "qw2")) (a "OTHER A"))




((a . "a100") (qw ("qw" "qw2")))

((a . "a100") (qw ("qw" "qw2")))

((a . "a22") (qw ("qw" "qw2")))



((a "a22" "a22" "a22" "a1" "a") (qw ("qw" "qw2")) (a "OTHER A"))

((a "a22" "a1" "a") (qw ("qw" "qw2")) (a "OTHER A"))

((a "a1" "a") (qw ("qw" "qw2")) (a "OTHER A"))




(cl-pp dpj-topic-list)

((#("amd.work.umrsh" 0 14 (fontified t face dp-journal-topic-face)))
 (#("emacs.elisp" 0 11 (fontified t face dp-journal-topic-face)) (nil) nil)
 (#("games" 0 5 (fontified t)))
 (#("politics.2020" 0 13 (fontified t face dp-journal-topic-face)) ((((nil)
								      nil)
								     (nil)
								     nil)
								    ((nil)
								     nil)
								    (nil)
								    nil)
  (((nil)
    nil)
   (nil)
   nil)
  ((nil)
   nil)
  (nil)
  nil)
 (#("politics.2020.humor" 0 19 (fontified t face dp-journal-topic-face))))nil
 )

consp


(defun* dp-add-or-update-alist (alist-var key val
					  &key
					  (canonicalizep nil)
					  (cons-it nil)
					  (keep-old-if-nil-p nil))
  "Add \(cons KEY VAL) to ALIST-VAR iff KEY isn't in ALIST-VAR.

If KEY exists, VAL will replace the existing val associated with
KEY.  UPDATE-P tells us how to update VAL: nil or not specified:
just add or replace.  'CANONICALIZEP: Nuke all with matching keys
w/ `remassoc'.  This puts the list into the canonical format: 0
or 1 instances of KEY.  In this case, 0 instances.  We don't use
`add-to-list' because we only want to key on KEY."
  (let (item orig-val)
    (when (and keep-old-if-nil-p
	       (null val))
      ;; Preserve the original value if new one is nil and the caller wants
      ;; us to.  Be sure to save before canonicalization (d'uh).
      (setq item (assoc key (symbol-value alist-var))
	    val (cdr-safe item)))
    (when canonicalizep
      ;; Nuke 'em all. We'll add a single entry for this key of val.
      (set alist-var (remassoc key (symbol-value alist-var))))
    ;; `item' (val part) may have changed due to the update. ?WHY/HOW?
    ;; get current item
    (if (setq item (assoc key (symbol-value alist-var)))
	;; Update in place, either adding new entry if we canonicalized, else
	;; cons the new val onto the current items' key.
	(if cons-it
	    (setcdr item (cons val (dp-listify-thing (cdr item))))
	  (setcdr item val))
      ;; Not in the alist, add it.
      (set alist-var (acons key val (symbol-value alist-var))))
    ;; Return current value.
    (symbol-value alist-var)))

========================
Tuesday July 14 2020
--
(defun org-fontify-entities (limit)
  "Find an entity to fontify."
  (let (ee)
    (when org-pretty-entities
      (catch 'match
	;; "\_ "-family is left out on purpose.  Only the first one,
	;; i.e., "\_ ", could be fontified anyway, and it would be
	;; confusing when adding a second white space character.
	(while (re-search-forward
		"\\\\\\(there4\\|sup[123]\\|frac[13][24]\\|[a-zA-Z]+\\)\\($\\|{}\\|[^[:alpha:]\n]\\)"
		limit t)
	  (when (and (not (org-at-comment-p))
		     (setq ee (org-entity-get (match-string 1)))
		     (= (length (nth 6 ee)) 1))
	    (let* ((end (if (equal (match-string 2) "{}")
			    (match-end 2)
			  (match-end 1))))
	      (add-text-properties
	       (match-beginning 0) end
	       (list 'font-lock-fontified t))
	      (compose-region (match-beginning 0) end
			      (nth 6 ee) nil)
	      (backward-char 1)
	      (throw 'match t))))
	nil))))

(defun org-set-font-lock-defaults ()
  "Set font lock defaults for the current buffer."
  (let* ((em org-fontify-emphasized-text)
	 (lk org-highlight-links)
	 (org-font-lock-extra-keywords
	  (list
	   ;; Call the hook
	   '(org-font-lock-hook)
	   ;; Headlines
	   `(,(if org-fontify-whole-heading-line
		  "^\\(\\**\\)\\(\\* \\)\\(.*\n?\\)"
		"^\\(\\**\\)\\(\\* \\)\\(.*\\)")
	     (1 (org-get-level-face 1))
	     (2 (org-get-level-face 2))
	     (3 (org-get-level-face 3)))
	   ;; Table lines
	   '("^[ \t]*\\(\\(|\\|\\+-[-+]\\).*\\S-\\)"
	     (1 'org-table t))
	   ;; Table internals
	   '("^[ \t]*|\\(?:.*?|\\)? *\\(:?=[^|\n]*\\)" (1 'org-formula t))
	   '("^[ \t]*| *\\([#*]\\) *|" (1 'org-formula t))
	   '("^[ \t]*|\\( *\\([$!_^/]\\) *|.*\\)|" (1 'org-formula t))
	   '("| *\\(<[lrc]?[0-9]*>\\)" (1 'org-formula t))
	   ;; Properties
	   (list org-property-re
		 '(1 'org-special-keyword t)
		 '(3 'org-property-value t))
	   ;; Drawers
	   '(org-fontify-drawers)
	   ;; Link related fontification.
	   '(org-activate-links)
	   (when (memq 'tag lk) '(org-activate-tags (1 'org-tag prepend)))
	   (when (memq 'radio lk) '(org-activate-target-links (1 'org-link t)))
	   (when (memq 'date lk) '(org-activate-dates (0 'org-date t)))
	   (when (memq 'footnote lk) '(org-activate-footnote-links))
           ;; Targets.
           (list org-radio-target-regexp '(0 'org-target t))
	   (list org-target-regexp '(0 'org-target t))
	   ;; Diary sexps.
	   '("^&?%%(.*\\|<%%([^>\n]*?>" (0 'org-sexp-date t))
	   ;; Macro
	   '(org-fontify-macros)
	   ;; TODO keyword
	   (list (format org-heading-keyword-regexp-format
			 org-todo-regexp)
		 '(2 (org-get-todo-face 2) t))
	   ;; DONE
	   (if org-fontify-done-headline
	       (list (format org-heading-keyword-regexp-format
			     (concat
			      "\\(?:"
			      (mapconcat 'regexp-quote org-done-keywords "\\|")
			      "\\)"))
		     '(2 'org-headline-done t))
	     nil)
	   ;; Priorities
	   '(org-font-lock-add-priority-faces)
	   ;; Tags
	   '(org-font-lock-add-tag-faces)
	   ;; Tags groups
	   (when (and org-group-tags org-tag-groups-alist)
	     (list (concat org-outline-regexp-bol ".+\\(:"
			   (regexp-opt (mapcar 'car org-tag-groups-alist))
			   ":\\).*$")
		   '(1 'org-tag-group prepend)))
	   ;; Special keywords
	   (list (concat "\\<" org-deadline-string) '(0 'org-special-keyword t))
	   (list (concat "\\<" org-scheduled-string) '(0 'org-special-keyword t))
	   (list (concat "\\<" org-closed-string) '(0 'org-special-keyword t))
	   (list (concat "\\<" org-clock-string) '(0 'org-special-keyword t))
	   ;; Emphasis
	   (when em '(org-do-emphasis-faces))
	   ;; Checkboxes
	   '("^[ \t]*\\(?:[-+*]\\|[0-9]+[.)]\\)[ \t]+\\(?:\\[@\\(?:start:\\)?[0-9]+\\][ \t]*\\)?\\(\\[[- X]\\]\\)"
	     1 'org-checkbox prepend)
	   (when (cdr (assq 'checkbox org-list-automatic-rules))
	     '("\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]"
	       (0 (org-get-checkbox-statistics-face) t)))
	   ;; Description list items
	   '("^[ \t]*[-+*][ \t]+\\(.*?[ \t]+::\\)\\([ \t]+\\|$\\)"
	     1 'org-list-dt prepend)
	   ;; ARCHIVEd headings
	   (list (concat
		  org-outline-regexp-bol
		  "\\(.*:" org-archive-tag ":.*\\)")
		 '(1 'org-archived prepend))
	   ;; Specials
	   '(org-do-latex-and-related)
	   '(org-fontify-entities)
	   '(org-raise-scripts)
	   ;; Code
	   '(org-activate-code (1 'org-code t))
	   ;; COMMENT
	   (list (format
		  "^\\*+\\(?: +%s\\)?\\(?: +\\[#[A-Z0-9]\\]\\)? +\\(?9:%s\\)\\(?: \\|$\\)"
		  org-todo-regexp
		  org-comment-string)
		 '(9 'org-special-keyword t))
	   ;; Blocks and meta lines
	   '(org-fontify-meta-lines-and-blocks))))
    (setq org-font-lock-extra-keywords (delq nil org-font-lock-extra-keywords))
    (run-hooks 'org-font-lock-set-keywords-hook)
    ;; Now set the full font-lock-keywords
    (setq-local org-font-lock-keywords org-font-lock-extra-keywords)
    (setq-local font-lock-defaults
		'(org-font-lock-keywords t nil nil backward-paragraph))
    (setq-local font-lock-extend-after-change-region-function
		#'org-fontify-extend-region)
    (kill-local-variable 'font-lock-keywords)
    nil))
========================
2020-07-14T18:47:06
--
dp-journal-mode-font-lock-keywords is a variable defined in ‘dp-journal.el’.
Its value is shown below.

  Automatically becomes buffer-local when set.
  This variable may be risky if used as a file-local variable.

Documentation:
Journal mode font lock keywords

Value:
(("^[	 ]*!!!+\\( .*$\\|$\\)" quote dp-journal-high-problem-face)
 ("^[	 ]*!!\\( .*$\\|$\\)" quote dp-journal-medium-problem-face)
 ("^[	 ]*!\\( .*$\\|$\\)" quote dp-journal-low-problem-face)
 ("^[	 ]*D'OH!*\\( .*$\\|$\\)" quote dp-journal-high-problem-face)
 ("^[	 ]*d'oh!*\\( .*$\\|$\\)" quote dp-journal-medium-problem-face)
 ("^[	 ]*@@@+\\( .*$\\|$\\)" quote dp-journal-high-todo-face)
 ("^[	 ]*@@\\( .*$\\|$\\)" quote dp-journal-medium-todo-face)
 ("^[	 ]*@\\( .*$\\|$\\)" quote dp-journal-low-todo-face)
 ("^[	 ]*\\?\\?\\?+\\( .*$\\|$\\)" quote dp-journal-high-question-face)
 ("^[	 ]*\\?\\?\\( .*$\\|$\\)" quote dp-journal-medium-question-face)
 ("^[	 ]*\\?\\( .*$\\|$\\)" quote dp-journal-low-question-face)
 ("^[	 ]*\\$\\$\\$+\\( .*$\\|$\\)" quote dp-journal-high-info-face)
 ("^[	 ]*\\$\\$\\( .*$\\|$\\)" quote dp-journal-medium-info-face)
 ("^[	 ]*\\$\\( .*$\\|$\\)" quote dp-journal-low-info-face)
 ("^[	 ]*[Ff][Yy][Ii]:?\\( .*$\\|$\\)" quote dp-journal-high-info-face)
 ("^[	 ]*>>>>+\\( .*$\\|$\\)" quote dp-journal-extra-emphasis-face)
 ("^[	 ]*>>>\\( .*$\\|$\\)" quote dp-journal-high-info-face)
 ("^[	 ]*>>\\( .*$\\|$\\)" quote dp-journal-medium-info-face)
 ("^[	 ]*>\\( .*$\\|$\\)" quote dp-journal-low-info-face)
 ("^[	 ]*\\+\\+\\++\\( .*$\\|$\\)" quote dp-journal-high-attention-face)
 ("^[	 ]*\\+\\+\\( .*$\\|$\\)" quote dp-journal-medium-attention-face)
 ("^[	 ]*\\+\\( .*$\\|$\\)" quote dp-journal-low-attention-face)
 ("^[	 ]*\\*\\*\\*+\\( .*$\\|$\\)" quote dp-journal-high-attention-face)
 ("^[	 ]*\\*\\*\\( .*$\\|$\\)" quote dp-journal-medium-attention-face)
 ("^[	 ]*\\*\\( .*$\\|$\\)" quote dp-journal-low-attention-face)
 ("^[	 ]*[Ee]\\.?[Gg][.:]?\\(\\s-+\\|:\\).*$" quote dp-journal-high-example-face)
 ("^[	 ]*[nN]\\.?[Bb][.:]?\\( .*$\\|$\\)" quote dp-journal-extra-emphasis-face)
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
--
" quote dp-journal-timestamp-face)
 ("^========================
[SMTWF][a-z]+ [JFMASOND][a-z]+ [0-3][0-9] [0-9]\\{4\\}
--
" quote dp-journal-datestamp-face)
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
\\(.+?\\)
--
"
  (0 'dp-journal-topic-stamp-face)
  (1 'dp-journal-topic-face t))
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
\\(^todo: .*\\)
--
"
  (1 'dp-journal-todo-face t))
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
\\(^\\(<<done:\\|~~cancelled:\\).*\\)
--
"
  (0 'dp-journal-done-face t))
 ("\\((e.g[^)]*)\\)" 1 'dp-journal-high-example-face t)
 ("\\(ftp\\(?:\\.\\|://\\)\\|gopher://\\|http\\(?:s?://\\)\\|mailto:\\|telnet://\\|www\\.\\)[^
]*" quote dp-journal-medium-info-face)
 ("\\([	 ]\\|^\\)\\(\\*\\*.+?\\*\\*\\)" 2 'dp-journal-extra-emphasis-face 'prepend)
 ("\\([	 ]\\|^\\)\\(\\*.+?\\*\\)" 2 'dp-journal-emphasis-face 'prepend)
 ("\\([	 ]\\|^\\)\\(\\?[^?].*?\\?\\)" 2 'dp-journal-low-question-face 'prepend)
 ("\\([	 ]\\|^\\)\\(\\[\\?.+?\\?\\]\\)" 2 'dp-journal-emphasis-face 'prepend)
 ("\\(^[^=~].*?\\)\\(<<<<<*\\|\\?\\?\\?\\?\\?*\\|!!!!!*\\|WTF\\|\\^\\^\\^\\^\\^*\\)\\(.*\\)$"
  (1 'dp-journal-extra-emphasis-face nil)
  (2 'dp-journal-extra-emphasis-face t)
  (3 'dp-journal-extra-emphasis-face nil))
 ("`\\([^'`
]+\\)'" 1 'dp-journal-quote-face t)
 ("\\([a-zA-Z_]\\([0-9a-zA-Z_.-]\\|->\\|::\\)*\\)(\\(.*?\\))"
  (1 'dp-journal-function-face t)
  (3 'dp-journal-function-args-face t))
 ("=======[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}=======" quote dp-journal-topic-stamp-face)
 ("^[	 ]*~[?!@].*$" quote dp-journal-cancelled-action-item-face)
 ("^[	 ]*=[?!@].*$" quote dp-journal-completed-action-item-face)
 (":\\((.*)\\):" 0 'dp-journal-embedded-lisp-face t)
 ("\\(^.*?\\)\\(/////*\\)\\(.*\\)$"
  (1 'dp-journal-deemphasized-face t)
  (2 'dp-journal-deemphasized-face t)
  (3 'dp-journal-deemphasized-face nil))
 ("^[	 ]*--+\\( .*$\\|$\\)" quote dp-journal-deemphasized-face)
 (dpj-alt-0
  (0 'dp-journal-alt-0-face prepend))
 (dpj-alt-1
  (0 'dp-journal-alt-1-face prepend))
 ("\\(^.*?\\) \\(# .*\\)$" 2 'dp-journal-low-question-face t)
 ("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" 2 'dp-default-line-too-long-error-face prepend)
 ("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{9\\}.\\{6\\}\\(.+\\)$" 2 'dp-default-line-too-long-warning-face prepend))
Local in buffer daily-2020-07.jxt; global value is 
(("^[	 ]*!!!+\\( .*$\\|$\\)" quote dp-journal-high-problem-face)
 ("^[	 ]*!!\\( .*$\\|$\\)" quote dp-journal-medium-problem-face)
 ("^[	 ]*!\\( .*$\\|$\\)" quote dp-journal-low-problem-face)
 ("^[	 ]*D'OH!*\\( .*$\\|$\\)" quote dp-journal-high-problem-face)
 ("^[	 ]*d'oh!*\\( .*$\\|$\\)" quote dp-journal-medium-problem-face)
 ("^[	 ]*@@@+\\( .*$\\|$\\)" quote dp-journal-high-todo-face)
 ("^[	 ]*@@\\( .*$\\|$\\)" quote dp-journal-medium-todo-face)
 ("^[	 ]*@\\( .*$\\|$\\)" quote dp-journal-low-todo-face)
 ("^[	 ]*\\?\\?\\?+\\( .*$\\|$\\)" quote dp-journal-high-question-face)
 ("^[	 ]*\\?\\?\\( .*$\\|$\\)" quote dp-journal-medium-question-face)
 ("^[	 ]*\\?\\( .*$\\|$\\)" quote dp-journal-low-question-face)
 ("^[	 ]*\\$\\$\\$+\\( .*$\\|$\\)" quote dp-journal-high-info-face)
 ("^[	 ]*\\$\\$\\( .*$\\|$\\)" quote dp-journal-medium-info-face)
 ("^[	 ]*\\$\\( .*$\\|$\\)" quote dp-journal-low-info-face)
 ("^[	 ]*[Ff][Yy][Ii]:?\\( .*$\\|$\\)" quote dp-journal-high-info-face)
 ("^[	 ]*>>>>+\\( .*$\\|$\\)" quote dp-journal-extra-emphasis-face)
 ("^[	 ]*>>>\\( .*$\\|$\\)" quote dp-journal-high-info-face)
 ("^[	 ]*>>\\( .*$\\|$\\)" quote dp-journal-medium-info-face)
 ("^[	 ]*>\\( .*$\\|$\\)" quote dp-journal-low-info-face)
 ("^[	 ]*\\+\\+\\++\\( .*$\\|$\\)" quote dp-journal-high-attention-face)
 ("^[	 ]*\\+\\+\\( .*$\\|$\\)" quote dp-journal-medium-attention-face)
 ("^[	 ]*\\+\\( .*$\\|$\\)" quote dp-journal-low-attention-face)
 ("^[	 ]*\\*\\*\\*+\\( .*$\\|$\\)" quote dp-journal-high-attention-face)
 ("^[	 ]*\\*\\*\\( .*$\\|$\\)" quote dp-journal-medium-attention-face)
 ("^[	 ]*\\*\\( .*$\\|$\\)" quote dp-journal-low-attention-face)
 ("^[	 ]*[Ee]\\.?[Gg][.:]?\\(\\s-+\\|:\\).*$" quote dp-journal-high-example-face)
 ("^[	 ]*[nN]\\.?[Bb][.:]?\\( .*$\\|$\\)" quote dp-journal-extra-emphasis-face)
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
--
" quote dp-journal-timestamp-face)
 ("^========================
[SMTWF][a-z]+ [JFMASOND][a-z]+ [0-3][0-9] [0-9]\\{4\\}
--
" quote dp-journal-datestamp-face)
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
\\(.+?\\)
--
"
  (0
   (quote dp-journal-topic-stamp-face))
  (1
   (quote dp-journal-topic-face)
   t))
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
\\(^todo: .*\\)
--
"
  (1
   (quote dp-journal-todo-face)
   t))
 ("^\\(?:========================
\\|======================== \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}
\\(^\\(<<done:\\|~~cancelled:\\).*\\)
--
"
  (0
   (quote dp-journal-done-face)
   t))
 ("\\((e.g[^)]*)\\)" 1
  (quote dp-journal-high-example-face)
  t)
 ("\\(ftp\\(?:\\.\\|://\\)\\|gopher://\\|http\\(?:s?://\\)\\|mailto:\\|telnet://\\|www\\.\\)[^
]*" quote dp-journal-medium-info-face)
 ("\\([	 ]\\|^\\)\\(\\*\\*.+?\\*\\*\\)" 2
  (quote dp-journal-extra-emphasis-face)
  (quote prepend))
 ("\\([	 ]\\|^\\)\\(\\*.+?\\*\\)" 2
  (quote dp-journal-emphasis-face)
  (quote prepend))
 ("\\([	 ]\\|^\\)\\(\\?[^?].*?\\?\\)" 2
  (quote dp-journal-low-question-face)
  (quote prepend))
 ("\\([	 ]\\|^\\)\\(\\[\\?.+?\\?\\]\\)" 2
  (quote dp-journal-emphasis-face)
  (quote prepend))
 ("\\(^[^=~].*?\\)\\(<<<<<*\\|\\?\\?\\?\\?\\?*\\|!!!!!*\\|WTF\\|\\^\\^\\^\\^\\^*\\)\\(.*\\)$"
  (1
   (quote dp-journal-extra-emphasis-face)
   nil)
  (2
   (quote dp-journal-extra-emphasis-face)
   t)
  (3
   (quote dp-journal-extra-emphasis-face)
   nil))
 ("`\\([^'`
]+\\)'" 1
 (quote dp-journal-quote-face)
 t)
 ("\\([a-zA-Z_]\\([0-9a-zA-Z_.-]\\|->\\|::\\)*\\)(\\(.*?\\))"
  (1
   (quote dp-journal-function-face)
   t)
  (3
   (quote dp-journal-function-args-face)
   t))
 ("=======[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}=======" quote dp-journal-topic-stamp-face)
 ("^[	 ]*~[?!@].*$" quote dp-journal-cancelled-action-item-face)
 ("^[	 ]*=[?!@].*$" quote dp-journal-completed-action-item-face)
 (":\\((.*)\\):" 0
  (quote dp-journal-embedded-lisp-face)
  t)
 ("\\(^.*?\\)\\(/////*\\)\\(.*\\)$"
  (1
   (quote dp-journal-deemphasized-face)
   t)
  (2
   (quote dp-journal-deemphasized-face)
   t)
  (3
   (quote dp-journal-deemphasized-face)
   nil))
 ("^[	 ]*--+\\( .*$\\|$\\)" quote dp-journal-deemphasized-face)
 (dpj-alt-0
  (0
   (quote dp-journal-alt-0-face)
   prepend))
 (dpj-alt-1
  (0
   (quote dp-journal-alt-1-face)
   prepend))
 ("\\(^.*?\\) \\(# .*\\)$" 2
  (quote dp-journal-low-question-face)
  t))

========================
Monday July 20 2020
--
(
	 (format "%.1f seconds"
		 (float-time
		  (time-subtract first second)))))
)

	  
(defun* dp-floating-point-time-diff-sec(&optional (first (current-time))
						  (second before-init-time))
  (let ((tim (float-time
	      (time-subtract first second))))
    tim))

(defun dp-floating-point-time-diff-str(first second)
  (let ((str
	 (format "%.1f seconds"
		 (float-time
		  (time-subtract first second)))))
    (if (called-interactively-p 'interactive)
        (message "%s" str)
      str)))

(defun dp-uptime-sec ()
  (interactive)
  (message "up time: %s" (dp-floating-point-time-diff-sec
			  (current-time) before-init-time)))

(defun* dp-uptime-pretty (&optional (first (current-time))
				    (second before-init-time))
  (let* ((sec (dp-floating-point-time-diff-sec first second))
	 (fmt-sec (split-string (format-seconds "%y %d %h %m %s" sec)))
	 (unit-names '("year" "day" "hour" "min" "sec"))
	 (time-component "")
	 (pretty "")
	 (sep ""))
    (loop for time-component in fmt-sec do
	  (setq unit-name (car unit-names)
		unit-names (cdr unit-names)
		time-component (string-to-int time-component))
	  (unless (= time-component 0)
	    (setq pretty (concat pretty
				 (format "%s%s %s%s"
					 sep
					 time-component
					 unit-name
					 (dp-pluralize-num time-component)))
		  sep ", ")))
    pretty))

(dp-uptime-pretty)
"2 hours, 5 mins, 13 secs"

sec: 7480.90785982, fmt-sec>(0 0 2 4 40)<
"2 hours, 4 mins, 40 secs"

sec: 7479.86026353, fmt-sec>(0 0 2 4 39)<
"2 hours, 4 mins, 39 secs"

sec: 7476.472470877, fmt-sec>(0 0 2 4 36)<
"2 hours, 4 mins, 36 secs"

sec: 7474.087666438, fmt-sec>(0 0 2 4 34)<
"2 hours, 4 mins, 34 secs"

sec: 7462.859995834, fmt-sec>(0 0 2 4 22)<
"2 hours, 4 mins, 22 secs"




    
"0 0 1 24 40"





(dp-uptime-sec)
"up time: 4537.4 seconds"


========================
Monday July 27 2020
--

(cl-pe '
(defun dp-copy-to-eof ()
  (interactive)
  (let ((text (dp-get--as-string--region-or... :bounder 'rest-of-line-p)))
    (when (stringp text)
      (save-excursion
	(goto-char (point-max))
	(insert text)))))
dp-copy-to-eof

)

(defalias 'dp-copy-to-eof
  (function
   (lambda nil
     (interactive)
     (let ((text (dp-get--as-string--region-or\.\.\. :bounder 'line-p)))
       (if (stringp text)
	   (progn
	     (save-excursion (goto-char (point-max)) (insert text))))))))nil



(defalias 'dp-copy-to-eof
  (function
   (lambda nil
     (interactive)
     (let ((text (dp-get--as-string--region-or\.\.\.)))
       (save-excursion (goto-char (point-max)) (insert text))))))nil

(cl-pe '
 (save-excursion (goto-char (point-max)) (insert text)))

(save-excursion (goto-char (point-max)) (insert text))nil



(dp-shell-copy-to-command-line


 (let ((text "blah"))
   (save-excursion
     (goto-char (point-max))
     (insert text)))

 (let (alist)
   (acons 'bubba 'b1 alist)
   (acons 'bubba 'b2 alist)
   (acons 'bubba 'b2 alist)
   )
 (let (alist)
   (acons 'bubba 'b1 alist)
   (acons 'bubba 'b2 alist)
   (acons 'bubba 'b2 alist)
   )

 blahregion-or...

 ((()))
 (let (alist)
   (acons 'bubba 'b1 alist)
   (acons 'bubba 'b2 alist)
   (acons 'bubba 'b2 alist)
   )

;; (defalias 'elpy-shell-send-region-or-buffer #[256 "\300\301\302\211$\207" [elpy-shell--send-with-step-go elpy-shell-send-region-or-buffer-and-step nil] 6 (#$ . 46302) "P"])
;; #@123 Run `elpy-shell-send-region-or-buffer-and-step' but retain point position and switch to Python shell.


========================
Wednesday July 29 2020
--
(let (alist)
  (acons 'bubba 'b1 alist)
  (acons 'bubba 'b2 alist)
  (acons 'bubba 'b2 alist)
  )

(let (alist)
  (dp-add-or-update-alist 'alist 'bubba1 'b1-1 :cons-it t)
  (dp-add-or-update-alist 'alist 'bubba1 'b1-2 :cons-it t)
  (dp-add-or-update-alist 'alist 'bubba3 'b3-1 :cons-it t)
  )
((bubba3 . b3-1) (bubba1 b1-2 b1-1))

(let (alist)
  (dp-add-to-alist-if-new-key 'alist (cons 'bubba1 'b1-1))
  (dp-add-to-alist-if-new-key 'alist (cons 'bubba1 'b1-2))
  (dp-add-to-alist-if-new-key 'alist (cons 'bubba3 'b3-1))
  )
((bubba3 . b3-1) (bubba1 . b1-1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dirtrack-list
("^emacs \\([a-zA-Z]:.*\\)>" 1)

("^davep@vilya:\\([~/].*[^/]$\\)" 1)

"~/lisp (elpy-dev)"

(setq dp-ll-input "davep@vilya:~/lisp (elpy-dev)\n2786/0001> ")
"davep@vilya:~/lisp (elpy-dev)
2786/0001> "

(setq dp-ll-dirtrack-list '("^davep@vilya:\\([~/].*\\)\\( \\|([^)]*)\\)" 1))
("^davep@vilya:\\([~/].*\\)\\( \\|([^)]*)\\)" 1)


(let* (
       (dirtrack-list0 '("^davep@vilya:\\([~/].*[^/]$\\)" 1))
       (dirtrack-list dp-ll-dirtrack-list)
       (input "davep@vilya:~/lisp (elpy-dev)\n2786/0001> ")
       (i2 "davep@vilya:~\n2786/0001> ")
       (regexp (nth 0 dirtrack-list))
       (pp (string-match regexp input))
       (m0 (match-string 0 input))
       (dir (match-string (nth 1 dirtrack-list) input))
       )
  (princf "regexp>%s<" regexp)
  (princf "input>%s<" input)
  (princf "pp>%s<" pp)
  (princf "m0>%s<" m0)
  (princf "m1/dir>%s<" dir)
  )



(re-search-forward (nth 0 ))



regexp>^davep@vilya:\\([~/].*\\)\\( \\|([^)]*)\\)<117364

(re-search-forward "\\([~/].*\\)\\( \\|([^)]+)\\).*")


input>davep@vilya:~/lisp (elpy-dev)117410

2786/0001> <
pp>0<
m0>davep@vilya:~/lisp (elpy-dev)<
m1/dir>~/lisp <
nil




(dp-all-match-strings-string)
"381"






========================
Friday July 31 2020
--

e.g.
/home/davep/bin
davep@vilya:~/bin (elpy-dev)
2790/0001> 

"\([~/].*?\)\((\|$\|(.*)$\)"
"\\([~/].*?\\)\\((\\|$\\|(.*)$\\)"

"^davep@vilya:\\([~/].*?\\)\\( (\\|$\\|(.*)$\\)"

"^davep@vilya:\([~/].*?\)\([[:space:]](\|$\|(.*)$\)"


(let (
      (regexp "^davep@vilya:\\([~/].+?\\)\\([[:space:]](?\\|$\\|(.*)$\\)"
	      ))
  (save-excursion
    (search-forward-regexp regexp)
			   )
  (princf "ms1:>>>>>>>>>>%s<<<<<<<<\n"
	  (match-string-no-properties 1))
  )
ms1:>>>>>>>>>>~/tmp<<<<<<<<

nil

ms1:>>>>>>>>>>~/tmp<<<<<<<<

nil

Result: ("^davep@vilya:\\([~/].*?\\)\\([[:space:]](\\|$\\|(.*)$\\)" 1)
dp-dbg-re
"^davep@vilya:\\([~/].*?\\)\\([[:space:]](\\|$\\|(.*)$\\)"

"^davep@vilya:\\([~/].+?\\)\\([[:space:]](\\|$\\|(.*)$\\)"

re in shell buf:
"^davep@vilya:\\([~/].*?\\)\\([[:space:]](\\|$\\|(.*)$\\)"

dp-dirtrack-regexp
"^davep@vilya:\\([~/].+?\\)\\([[:space:]](\\|$\\|(.*)$\\)"

dp-dbg-input
davep@vilya:~/tmp
2792/0001> "

dp-dbg-re
"^davep@vilya:\\([~/].*?\\)\\([[:space:]](\\|$\\|(.*)$\\)"

(string-match dp-dbg-re dp-dbg-input)
0

(string-match dp-dbg-re dp-dbg-input)
0

dp-dbg-input
"davep@vilya:~/tmp
2792/0001> "
(cons 


davep@vilya:~)/bin (elpy-dev)
davep@vilya:~/bin
ms1:>>>>>>>>>>~/bin<<<<<<<<

nil


nil

"^davep@vilya:\([~/].*?\)\([[:space:]](\|$\|(.*)$\)"

davep@vilya:~/bin (elpy-dev)
;; "

works: ^davep@vilya:\([~/][[:graph:]]*\)\(.*\)$
       ^davep@vilya:\([~/][[:graph:]]*\)\(.*\)$
       ^davep@vilya:\([~/][[:graph:]]*\)\(.*\)$

(let (
      (regexp (dp-dirtrack-regexp)
       ;;"\\(^davep@vilya:[~/][[:graph:]]*?\\)\\([^[:graph:]]\\|$\\|.*$\\)"
       ;;"^davep@vilya:\\([~/][[:graph:]]*\\)\\(.*\\)$"
	      ))
  (princf "regexp>%s<" regexp)
  (if (not (string-match regexp dp-dbg-input))
      (princf "No match.")
    (princf "ms1:>>>>>>>>>>%s<<<<<<<<"
	    (match-string-no-properties 1 dp-dbg-input))
    (princf "ms2:>>>>>>>>>>%s<<<<<<<<"
	    (match-string-no-properties 2 dp-dbg-input))
    (princf "ms0:>>>>>>>>>>%s<<<<<<<<|"
	    (match-string-no-properties 0 dp-dbg-input)))
  )

dp-dbg-input
"davep@vilya:/yaya/ypyp (elpy-dev)
yadda/bladda"

davep@vilya:~/tmp
2792/0001> "






dp-bs
"^davep@vilya:\\([~/].*?\\)\\([[:space:]](\\|$\\|(.*)$\\)"
; "
())

(defun dp-setup-dirtrack ()
  (interactive)
  (setq-default dirtrack-list (list dp-dirtrack-regexp
				    1))
  (setq dirtrack-list (list dp-dirtrack-regexp
			    1))
  (dirtrack-mode))
dp-setup-dirtrack




abcdefg

12345
!@#$%^&*()-=_+[]{}\|:";',./<>?
::::::::::::::::::

:::::::::::: ::::::::: space
::::::::::::	: tab
;;::::::::::	

===============================================================
                                                     <



dp-dbg-input
davep@vilya:~/tmp
2792/0001> "

davep@vilya:~/lisp (elpy-dev)

========================
Saturday August 01 2020
--

;; :(dp-embedded-block-op 'dp-hide-region "ebo-block-end"):
"a block 
to test embedded block
operations."
;; ebo-block-end

(fmakunbound 'dp-shell-lookfor-dir-change)
(dp-shell-lookfor-dir-change)
(remove-hook 'comint-input-filter-functions 'dp-shell-lookfor-dir-change)
nil
(remove-hook 'comint-input-filter-functions 'dp-shell-lookfor-dir-change)
(remove-hook 'comint-output-filter-functions 'dp-shell-lookfor-dir-change)
(ansi-color-process-output comint-postoutput-scroll-to-bottom comint-watch-for-password-prompt)



()

========================
Monday August 03 2020
--
(defvar dp-py-class-or-def-regexp-format-str
  (concat
   "\\(^"                               ; <ms1
   "\\(\\s-*\\)"                        ;   <ms2></ms2>
   "%s\\s-+"                            ; Keywords we're interested in.
   "[a-zA-Z_][a-zA-Z_0-9]*\\)"          ; ms1> def or class name
   ;; look for what's after the def/class name.
   ;; We're interested in:
   ;; "(", "(text", "(text)", "()"
   "\\("                                ; <ms3
   "\\(?:\\s-*\\)"
   "\\(?:"                              ; | <shy
   "(\\(.*?\\))"                        ; | xxx()
   "\\)"                                ; | shy>
   "\\|"                                ; |
   "\\(?:"                              ; | <shy
;;   "(\\(\\S-*\\)"                       ; | xxx(
   "(\\(.*?\\)\\s-*\\($\\|\\(#.*$\\)?\\)"
   "\\)"                                ; | shy>
   "\\|"                                ; |
   "\\(?:"                              ; | <shy
   ")"                                  ; | xxx)  <== ignore
   "\\)"                                ; | shy>
   "\\|"                                ; |
   "\\(?:"                              ; | <shy
   "[^()].*?"                             ; | ;; Added .* Tuesday June 24 2008
   "\\)"                                ; | shy>
   "\\)?"                               ; ms3>
   "\\(\\s-*\\(#.*\\|$\\)\\)"           ; <ms4 <ms5>>

   )
  "Get to the parts of a Python def or class:
ms2: indentation (if in class, and block keyword is def --> method)
ms3: block keyword
ms4: existing parens
ms5 or ms6: params with parens (depends on current state of kw)
ms9: rest of line after program text -- includes ws and comment
ms10: comment char to end of line
"
========================
2020-08-03T11:53:29
--
(cl-pp dp-py-class-or-def-regexp)

"\\(^\\(\\s-*\\)\\(def\\|class\\)\\s-+[a-zA-Z_][a-zA-Z_0-9]*\\)\\(\\(?:\\s-*\\)\\(?:(\\(.*?\\))\\)\\|\\(?:(\\(.*?\\)\\s-*\\($\\|\\(#.*$\\)?\\)\\)\\|\\(?:)\\)\\|\\(?:[^()].*?\\)\\)?\\(\\s-*\\(#.*\\|$\\)\\)"nil






"\\(^					; >1 ws+{def|class}ws+[name]
  \\(\\s-*\\)				; 2  ws+
  \\(def\\|class\\)			; 3     {def|class}
  \\s-+[a-zA-Z_][a-zA-Z_0-9]*		;                  ws+[name]
\\)					; <1
\\(					; >4 '(' params ')'
\\(?:\\s-*\\)				; x
\\(?:					; >x1
  (  					; a  '(', real paren
  \\(.*?\\)				; 5      params
  )                                     ;               ')'
\\)                                     ; <x1
\\|
\\(?:					; x
  \\(.*?\\)				; 6
  \\s-*
  \\($\\|				; >7
    \\(#.*$\\)?				; 8
  \\)          				; <7
\\)
\\|
\\(?:					; x
\\)  					; real paren,  ')'
\\|\\(?:[^()].*?\\)			; x
\\)?                                    ; <4
\\(\\s-*				; >9
  \\(#.*\\|$\\)				; 10 '#' chars* | $
\\)                                     ; <9
"


========================
Wednesday August 05 2020
--
(defun comint-simple-send (proc string)
  "Default function for sending to PROC input STRING.
This just sends STRING plus a newline.  To override this,
set the hook `comint-input-sender'."
  (let ((send-string
         (if comint-input-sender-no-newline
             string
           ;; Sending as two separate strings does not work
           ;; on Windows, so concat the \n before sending.
           (concat string "\n"))))
    (comint-send-string proc send-string))
  (if (and comint-input-sender-no-newline
	   (not (string-equal string "")))
  ;;;;;    (dmessage "NO eof for you!")
      (process-send-eof)
    ))


========================
Thursday August 06 2020
--
(python-shell-interpreter "jupyter")
(python-shell-interpreter-args "console --simple-prompt")

(progn
  (setq python-shell-interpreter "ipython")
  (setq python-shell-interpreter-args "") ; "console --simple-prompt --debug")
  )


========================
Friday August 07 2020
--
(let ((new-position "c"))
  ;;  (string= "c" new-position))
  (when (string= "c" new-position)
    (avy-goto-char))

  (cond
    ((string= "c" new-position)
     (avy-goto-char))
    ((string= "l" new-position)
     (avy-goto-line))
    (t (princf "FOAD"))))






