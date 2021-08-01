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







========================
Wednesday August 12 2020
--
M-C-y doesn't work.  No wrap, kb input, etc.
insert here>

      (setq buffer-read-only nil) <----- IMO, direct access to
      vars like this is a "Bad Thing(R)"

      -vs-

      (toggle-read-only 0) <-------------------- OBSOLETE.

      
      (let ((x 99)
	    (y 'i-am-yoot)
	    (nilz nil))
	(princf "x: is symbol: %s, %s" (symbolp x) x)
	(princf "y: is symbol: %s, %s" (symbolp y) y)
	(princf "n: is symbol: %s, %s" (symbolp nilz) nilz))
x: is symbol: nil, 99
y: is symbol: t, i-am-yoot
n: is symbol: t, nil
nil

(defun dp-toggle-val (arg val &optional verbose-p)
"Toggle value of VAL in the canonical manner as a function of ARG.
If ARG is nil, toggle value of VAL.
If ARG is > 0, or t then set value of VAL to t.
If ARG is <= 0, set value of VAL to nil.
If VERBOSE-P is non-nil, show new value of VAL."
  (interactive "P")
  (setq olde-val val
	val (if arg
		(or (eq arg t)		; t if, well, t.
		    (and (numberp arg)
			 (> arg 0)))	; t if >, nil if <=
	      ;; Just toggle.
	      (not val)))
  (when verbose-p
    (message "val was: %s, now %s." olde-val val))
  val)

(defun* dp-toggle-read-only (&optional toggle-flag (colorize-p t))
  "Toggle read only. Set color accordingly if COLORIZE-P is non-nil.
NB: for the original `toggle-read-only', t --> 1 --> set RO because
\(prefix-numeric-value t) is 1."
  (interactive "P")
  (let ((original-read-only buffer-read-only))
    (dp-toggle-var 'buffer-read-only)
    (when (and colorize-p buffer-read-only)
      (dp-colorize-found-file-buffer))))

					; arg val

(dp-toggle-val nil -1)
nil

nil

t

nil

nil




(princf "%s" 1)
1
nil

49
nil

========================
Thursday August 13 2020
--
(dp-toggle-val 'x t)
t

t
(setq dp-yadda t)
(dp-toggle-var 'dp-yadda -1)
nil

nil
dp-yadda
nil

nil

(progn
  (message "111;;;;;;;;;;;;")
  (message "B: mark_kboards (void)buffer-read-only: %s" buffer-read-only)
  (dp-toggle-read-only -1 nil)
  (message "A: buffer-read-only: %Some of the quotes quotes said the numbers would be much lower if he had
pushed universal mitigation: masks, social distancing, staying inside,
washing hands, in effect everything the CDC, etc, said.  trump never pushed
these.  Hell, he never wore a mask to influence people to disbelieve the
pandemic was as bad as was said, to pretend that he had fixed it.  What about
the states he encouraged to open?  The numbers are bigger than they were,
thanks to him.  Now it's red states and people in the WH.  Suddenly he begins
to wear a mask.  And he encourage people to participate in rallies (for his
ego, he's already going to be the red nominee), an environment that is almost
designed to spread covid.  Also, why did he insist on being the only one to
see the data from the hospitals, etc?  If his numbers are so good, they'd be
on every billboard as far as the eye can see.

s" buffer-read-only)
)

(progn
  (message "222;;;;;;;;;;;;")
  (message "B: dp-yadda: %s" dp-yadda)
  (dp-toggle-var 'dp-yadda -1 nil)
  (message "A: dp-yadda: %s" dp-yadda)
)

(progn
  (message "333;;;;;;;;;;;;")
  (message "B: buffer-read-only: %s" buffer-read-only)
  (dp-toggle-var 'buffer-read-only -1 nil)
  (message "A: buffer-read-only: %s" buffer-read-only)
)


========================
Monday August 17 2020
--
(defun dp-savehist-printable (value)
  "Return non-nil if VALUE is printable."
  (cond
   ;; Quick response for oft-encountered types known to be printable.
   ((numberp value))
   ((symbolp value))
   ;; String without properties
   ((and (stringp value)
	 (equal-including-properties value (substring-no-properties value))))
   (t
    ;; For others, check explicitly.
    (with-temp-buffer
      (condition-case nil
	  (let ((print-readably t) (print-level nil))
	  ;; Print the value into a buffer...
	  (prin1 value (current-buffer))
	  ;; ...and attempt to read it.
	  (read (point-min-marker))
	  ;; The attempt worked: the object is printable.
	  (message "Bad value{[(%s)]} " val)
	  t)
	;; The attempt failed: the object is not printable.
	(error nil))))))

(dolist (val kill-ring)
  (dp-savehist-printable val))



nil


nil

(dp-savehist-printable kill-ring)

finish me!!!
created bm `1' at Line=29, point=129157
Bad value:(format "%s" val)
Bad value:	;; The attempt failed: the object is not printable.
	((princf "bad val: %s" value)
	 (error nil))))))

Bad value:defun savehist-printable (value)
  "Return non-nil if VALUE is printable."
  (cond
   ;; Quick response for oft-encountered types known to be printable.
   ((numberp value))
   ((symbolp value))
   ;; String without properties
   ((and (stringp value)
	 (equal-including-properties value (substring-no-properties value))))
   (t
    ;; For others, check explicitly.
    (with-temp-buffer
      (condition-case nil
	  (let ((print-readably t) (print-level nil))
	  ;; Print the value into a buffer...
	  (prin1 value (current-buffer))
	  ;; ...and attempt to read it.
	  (read (point-min-marker))
	  ;; The attempt worked: the object is printable.
	  t)
	;; The attempt failed: the object is not printable.
	(error nil))))))
Bad value:savehist-additional-variables [2 times]
Bad value:`savehist-file'.
Bad value:(fboundp 'savehist-autosave)
Bad value:(set-cursor-color COLOR-NAME)
Bad value:Saved working directory and index state WIP on elpy-dev: d5ba02f4 Comment change.
Bad value:269bbd2f
Bad value:269bbd2f..246e78fa
Bad value:actually not toggling except in one case).
Bad value:56e7610d
Bad value:git show --pretty="format:" --name-only $FROM -- $WHAT | wc -l
Bad value:$(screen-lines 2/)
Bad value:git lonn $(screen-lines 2/)
Bad value:shell-prompt-pattern
Bad value:comint-use-prompt-regexp
Bad value:0 k 51 1* p
Bad value:0 k 51 *1 p
Bad value:"${prec} k $LINES $@ p"
Bad value:echo 0 k 51 4- * p
Bad value:51 0.5* 0k p
Bad value:BRANCH=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
Bad value:Fixed dp-sel2.

The problem was uncovered by 2 characters with read-only properties.  Which
revealed the use of an obsolete way of changing read-only-ness.  Yadda, etc.
Then, a change was made to my toggle var function signature.  I think this
file should be added to the previous commit because this combination of files
won't work if we check out this commit.

Bad value:# Your branch is ahead of 'dev' by 8 commits.

Bad value: on-off
Bad value:If ARG is nil or not specified, the state is toggled to non-nil
to nil and nil to t.

Bad value:If ARG is nil or not specified, the state is toggled to non-nil
to nil and nil to t.

Bad value: arg
Bad value: 'dp-primary-makefile-p
Bad value:list-processes
Bad value:@@ 

Bad value:(dp-toggle-read-only t nil)
Bad value:mark_kboards (void)
Bad value:  (message ";;;;;;;;;;;;")

Bad value:(progn
  (message ";;;;;;;;;;;;")
  (message "B: dp-yadda: %s" dp-yadda)
  (dp-toggle-var 'dp-yadda -1 nil)
  (message "A: dp-yadda: %s" dp-yadda)
)

Bad value:  (message "B: dp-yadda: %s" dp-yadda)

Bad value:(progn
  (message "B: buffer-read-only: %s" buffer-read-only)
  (dp-toggle-read-only -1 nil)
  (message "A: buffer-read-only: %s" buffer-read-only)
)

Bad value:  (princf "buffer-read-only: %s" buffer-read-only)

Bad value:(dp-toggle-read-only -1 nil)
Bad value:    )

Bad value:      ;; Make us read/write.  We may be reusing a pastie buffer that is read
      ;; only.  We could live in the (let ((inhibit-read-only t))...) but seems
      ;; more obvious.

Bad value:      (dp-erase-buffer)

Bad value:      (dp-toggle-read-only t nil)

Bad value:'buffer-read-only
Bad value:(dp-toggle-read-only 0 nil)
Bad value:(dp-last-command-char)
Bad value:(this-command-keys)
Bad value:(dp-last-command-char)
Bad value:dp-sel2:index
Bad value:(defun dp-sel2:digit-argument ()

Bad value:insert-buffer-substring-no-properties
Bad value:(defun* dp-toggle-read-only (&optional toggle-flag (colorize-p t))
  "Toggle read only. Set color accordingly if COLORIZE-P is non-nil.
NB: for the original `toggle-read-only', t --> 1 --> set RO because
\(prefix-numeric-value t) is 1."
  (interactive "P")
  (let ((original-read-only buffer-read-only))
    ;;(toggle-read-only toggle-flag)	;@todo XXX OBSOLETE
    (setq buffer-read-only (dp-toggle-val nil buffer-read-only))
    (when (and colorize-p buffer-read-only)
      (dp-colorize-found-file-buffer))))

Bad value: val
Bad value: arg
Bad value:enable-p 
Bad value:command-flag 
Bad value:(symbol-value var-sym)
Bad value:&optional 
Bad value: &optional
Bad value:(defun dp-toggle-val (arg val &optional verbose-p)
"Toggle value of VAL in the canonical manner as a function of ARG.
If ARG is nil, toggle value of VAL.
If ARG is > 0, or t then set value of VAL to t.
If ARG is <= 0, set value of VAL to nil.
If VERBOSE-P is non-nil, show new value of VAL."
  (interactive "P")
  (setq olde-val val
	val (if arg
		(or (eq arg t)		; t if, well, t.
		    (and (numberp arg)
			 (> arg 0)))	; t if >, nil if <=
	      ;; Just toggle.
	      (not val)))
  (when verbose-p
    (message "val was: %s, now %s." olde-val val))
  val)
Bad value:(defun* dp-toggle-read-only (&optional toggle-flag (colorize-p t))
  "Toggle read only. Set color accordingly if COLORIZE-P is non-nil.
NB: for the original `toggle-read-only', t --> 1 --> set RO because
\(prefix-numeric-value t) is 1."
  (interactive "P")
  (let ((original-read-only buffer-read-only))
    (toggle-read-only toggle-flag)	;@todo XXX OBSOLETE
    (when (and colorize-p
               (not (equal original-read-only buffer-read-only)))
      (dp-colorize-found-file-buffer))))

Bad value:	(princf "y: is symbol: %s, %s" (symbolp y) y))

Bad value:(symbol-value var-sym)
Bad value:cmd is NOT SET}
Bad value:DP_NO_DP_INIT
Bad value:DP_NO_DP_LISP_INIT
Bad value:  (let ((inhibit-read-only t)

Bad value:	(toggle-read-only 0)

Bad value:      (setq buffer-read-only nil)

Bad value:

There are text properties here:
  fontified            t
  read-only            fence
 [2 times]
Bad value:ll researched answer with bated breath.␣…Especially the ones that support your claims precisely.
 76|Read *ALL* of the words in each article.␣…All disprove stump's 2M claim.␣…This will be the case for everything.␣…I'm just going down the list that google found given this search: "wh april press briefings trump save millions of lives" As is SOP for RWNJ, read something, find something that supports your biases and stop reading, even when the rest of the article disproves it.↵https://www.washingtonpost.com/politics/2020/07/21/mcenany-makes-new-indefensible-claim-trump-saved-3-4-million-lives/↵SOP↵https://www.c…
 77|Read *ALL* of the words in each article.␣…All disprove stump's 2M claim.␣…This will be the case for everything.␣…I'm just going down the list that google found given this search: "wh april press briefings trump save millions of lives" As is SOP for RWNJ, read something, find something that supports your biases and stop reading, even when the rest of the article disproves it.↵https://www.washingtonpost.com/politics/2020/07/21/mcenany-makes-new-indefensible-claim-trump-saved-3-4-million-lives/↵SOP↵https://www.c…
 78|Some of the quotes quotes said the numbers would be much lower if he had↵pushed universal mitigation: masks, social distancing, staying inside,↵washing hands, in effect everything the CDC, etc, said.␣…trump never pushed↵these.␣…Hell, he never wore a mask to influence people to disbelieve the↵pandemic was as bad as was said, to pretend that he had fixed it.␣…What about↵the states he encouraged to open?␣…The numbers are bigger than they were,↵thanks to him.␣…Now it's red states and people in the WH.␣…Suddenly he b…
 79|https://www.theguardian.com/us-news/2020/apr/04/trump-coronavirus-science-analysis
 80|rise
 81|https://www.whitehouse.gov/briefings-statements/remarks-president-trump-vice-president-pence-members-coronavirus-task-force-press-briefing-april-7-2020/
 82|As is SOP for RWNJ, read something, find something that supports your biases↵and stop reading, even when the rest of the article disproves it.↵
 83|Read *ALL* of it.␣…Disproves stump's 2M claim.␣…This will be the case for↵everything.␣…I'm just going down the list that google found given this↵search: "wh april press briefings trump save millions of lives"↵
 84|wh april press briefings trump save millions of lives
 85|Read *ALL* of it.␣…Disproves stump's 2M claim↵
 86|https://www.cnn.com/2020/05/11/politics/donald-trump-coronavirus-quarantine/index.html
 87|“In their estimates,” she said, “they had between 1.5 million and 2.2 million people in the United States succumbing to this virus without mitigation
 88|down to 100,000 to 200,000 deaths
 89|https://www.washingtonpost.com/politics/2020/07/21/mcenany-makes-new-indefensible-claim-trump-saved-3-4-million-lives/
 90|dp-orig-comint-input-sender
 91|SyntaxError[0m[0;31m:[0m unexpected EOF while parsing


In [2]: def a():
␣…File "<ipython-input-2-1e91c6a86c0c>", line 1
␣…def a():
␣…^
SyntaxError: unexpected EOF while parsing


In [3]: def a(aa):
␣…File "<ipython-input-3-6727f5e7ca83>", line 1
␣…def a(aa):
␣…^
SyntaxError: unexpected EOF while parsing


In [4]: def a(): \
␣…File "<ipython-input-4-d6a7ea8a5495>", line 1
␣…def a():
␣…^
SyntaxError: unexpected EOF while parsing


In [5]: print("Password:")
Password:

In [6]: -------------…
Bad value:      (dp-toggle-read-only 0 nil)

Bad value:      (dp-erase-buffer)

Bad value:#!/usr/bin/env bash
# should be sourced, but the shebang tells us and emacs what's up
#
#set -x
#
# pull in our generic functions
#

if [ "$USER" = "davep" ]
then
    # This is so I get my env in a sudo bash.
    DP_RC_DIR=~davep/.rc
else
    DP_RC_DIR=$HOME/.rc
fi

dp_source_rc ${DP_RC_DIR}/alias.b0rkd-kb ${DP_RC_DIR}/alias.root

alias ls_no_color="\ls -CF --color=never"
alias ls_with_color='\ls -CF --color=tty'
alias lca='\ls -CF --color=always'
alias lnc='ls_no_color'
alias lc='ls_with_color'        # @todo XXX deprecate this
alias lwc='ls_with_color'
#alias lf='ls_no_color'
#alias lm='ls_no_color'
alias ll='ls -l'
alias l1='ls -1'
alias l1t='ls -1t'
alias la='ls -a'
alias lla='ls -la'


if [ -n "$dp_no_color" ]
then
    alias ls='ls_no_color'
else
    alias ls='ls_with_color'
fi

alias hdps='echo $PS1 | hd'
alias lssmod='lsmod | less'
alias hless='history | less'
alias cls=clear
alias bq='beagle-query'
alias cx='chmod +x'
alias editprof='vi ~/.bash_profile'
alias eprof='vi ~/.bash_profile'
alias sprof='. ~/.bash_profile' # source profile
alias pro='. ~/.bash_profile' # source profile
#alias gb='g back'
alias gb='pushd'		# swaps top two elements, like g b
alias pd='popd'
alias h=page_of_history
alias archie='archie -h $ARCHIE_HOST'
alias vipath='typeset x=/tmp/vipath.$SECONDS; echo $PATH > $x && vi $x && PATH=`cat $x` && rm -f $x'
alias vicd='typeset x=/tmp/vicd.$SECONDS; echo $PWD > $x && vi $x && cd `cat $x` && rm -f $x'
alias alias_p="alias >/dev/null 2>&1"
alias_iff()
{
    local name="$1"
    shift
    alias_p "$name" || { eval alias "$name"="$@"; }
}
for i in bind env alias func rc bashrc
do
  # What in NGC714's name was I thinking of?
  #alias_iff "${i}rc" '"source_list $RC_DIR/$i \"\" \$locale_rcs"; true'
  eval alias ${i}rc='"source_list $RC_DIR/$i \"\" \$locale_rcs .work"; true'
done
case $shell_name in
    bash)
	alias r='fc -e -'
	alias print=echo
	;;
esac

[ -f $RC_DIR/alias.${HOSTNAME} ] && . $RC_DIR/alias.${HOSTNAME}
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias rlogin='rlogin -8'
alias setdisp='DISPLAY=`remote-disp`; export DISPLAY'
##alias dirc='__olddir=`pwd`; while popd; do :;done >/dev/null 2>&1 ; cd $__olddir'
alias dirc='dirs -c'
alias dirsv='dirs -p -l -v'
alias dirsl='dirs -p -l -v'
alias dirsplv='dirs -p -l -v'

#alias nh='export dp_NH=y; HISTFILE=; dp_NH_PS1_prefix=$PS1_prefix; PS1_prefix="(nh)$PS1_prefix"; PS1_title_prefix="-(NH)-"'
alias hh='export dp_HH=y; HISTFILE=${PWD}/.histfile.here; dp_HH_PS1_prefix=$PS1_prefix; PS1_prefix="(hh)$PS1_prefix"; PS1_title_prefix="-(HH)-"'
alias uh='unset dp_NH; HISTFILE=$DEF_HISTFILE; PS1_prefix=$dp_NH_PS1_prefix; PS1_title_prefix=""; PS1_prefix=""'
alias scat='\show -showproc cat'

alias ls1=lsl
# -i is no longer an option.
#alias uudecode='uudecode -i'

#echo "TERM>$TERM<"
#set -x

grep_opts=
: ${dp_grep_options:="--directories=skip"}

if inside_emacs_p
then
    # --with-filename puts:
    # 1) filename: in front of the match if it's in a file.
    # 2) (standard input) if it's, well, you guess.
    # They'll both take the same amount of parsing and the compile code to
    # find/goto the location works. `-' allows "" to not be replaced.  Only
    # unset vars are.
    #!<@todo make standard util to parse a ^.*?:\d+:.*$ out of grep matches.
    # ??? (\d+:)? and/or (^.*?:)?
    : ${dp_emacs_grep_options:="-n --color=never ${dp_grep_options}"}
    export dp_emacs_grep_options
    #echo "dp_emacs_grep_options>$dp_emacs_grep_options<"
    dp_emacs_dash_n_greps()
    {
#        source ${DP_RC_DIR}/grep-functions
	###echo 1>&2 "in dp_emacs_dash_n_greps()"; echo_id dp_emacs_grep_options
	local grep_options="${dp_emacs_grep_options}"
        alias zgrep="zgrep ${grep_options}"
        alias bzgrep="bzgrep ${grep_options}"
	alias lzgrep="lzgrep ${grep_options}"
	alias lzegrep="lzegrep ${grep_options}"
	alias lzfgrep="lzfgrep ${grep_options}"
	alias xzgrep="xzgrep ${grep_options}"
	alias xzegrep="xzegrep ${grep_options}"
	alias xzfgrep="xzfgrep ${grep_options}"
	alias pcregrep="pcregrep ${grep_options}"
	alias grep="grep $grep_options"
	alias egrep="grep --directories=skip -E $grep_options"
	alias fgrep="grep --directories=skip -F $grep_options"
    }
    export -f dp_emacs_dash_n_greps

    # How to make this dependent on my dp-shells lisp flags so the always match up?
    unalias ls
    alias ls='ls_no_color'

    #
    # give certain programs more emacs friendly/useful options
    #

    #
    # since I turn on compilation mode, having the greps
    # use line numbers is very useful
    # Line numbers are enables in emacs_shell_grepper.
    # Currently, baroque also implies a little broke.
    # e.g. grep ls get the expansion of ls rather than just 'ls'.
    dp_emacs_baroque_greps()
    {
        # We also use --file-name, but this causes problems when stdin is
        # used since we see a (stdin) as file name.  Change of heart: given
        # we have the name for other files, this is not a problem.  They'll
        # both take the same amount of parsing and the compile code to
        # find/goto the location works.
        alias grep="emacs_shell_grepper grep $grep_opts"
        alias egrep="emacs_shell_grepper egrep $grep_opts"
        alias fgrep="emacs_shell_grepper fgrep $grep_opts"
    }
    export -f dp_emacs_baroque_greps

    dp_emacs_dash_n_greps

    #alias less='cat'
    alias less="$LESSOPEN_PROG"
    alias more='cat'
    alias show='scat'           # nmh command
    alias man='emacs_man'
    #
    # turn off embedded colorization (-n) and other fiddle faddle.
    alias esearch='esearch -n'
    alias emerge='emerge --nospinner'
    alias pkg-grep='pkg-grep -n'
    alias eix='eix -n'
    alias equery='equery -C'
    alias lssz='ls -l --sort=size'
    # XEmacs seems OK with these in color. Why did I disable it? Perhaps
    # something intermittent or in certain cases? Or perhaps I fixed the
    # colorization issues?
#    alias lsl='kwa_LSL_COLOR="--color=never" lsl'
#    alias ls1='kwa_LSL_COLOR="--color=never" lsl'
#    alias lth='kwa_LSL_COLOR="--color=never" lth'
    
    alias ltl='ls -lt'          # xemacs makes a decent less.
    alias lrl='ls -ltr'         # xemacs makes a decent less.
    alias lsl='ls -1t'          # xemacs makes a decent less.
    alias lslr='ls -1tr'        # xemacs makes a decent less.
# ?? WTF??    alias lssz='kwa_LSL_COLOR="--color=never" lssz'

else
    #echo "dp_grep_options>$dp_grep_options<"
    alias grep="grep $dp_grep_options"
    alias egrep="grep -E $dp_grep_options"
    alias fgrep="grep -F $dp_grep_options"
fi

alias npg=port-grep
alias nmg=mgrep
###alias isascreen='isascreen "$IMASCREENINSTANCE" "$ignoreeof"'
alias imascreen=isascreen
alias evalgo2env="go2rc"
alias evalgo2="go2rc"
alias hl='history | $PAGER'
alias make_go='(cd ~; make go_aliases)'
alias dfh='df -h'
alias dfhd='dfh .'
alias dfh.=dfhd
alias dfhh=dfhd
alias xx-ncmpc='xx ncmpc'

alias fh='feh -sZF --next-button 2 --zoom-button 1'
#alias pix=eix
alias smv='sed-rename'
alias re-mv='sed-rename'
alias rpd='realpath .'
alias rp='realpath'
###alias mplayer='mplayer -vo x11 -framedrop'
#alias pquery=equery
#for i in 1 2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 18 19
#do
#  eval alias k$i="'dp_kill_job_id_n $i'"
#  eval alias k9$i="'dp_kill_job_id_n $i -9'"
#??? why did I do this?  eval alias k9$i=\'kill -9 %$i ; wait %$i \'
#done

alias sed-path=sed_path
alias bashhelp=help
alias mkpath='mkdir -p'
alias spv='sp -v'
# XEmacs command handler.  Originally ef meant `emacs file'.
alias xf=ef

alias lvlmessages=lmsgs
alias lvlm=lvlmessages
alias tail-msgs=tail_var_log_messages
alias tvlm=tail_var_log_messages
alias grep-msgs=grep_var_log_messages
alias gvlm=grep_var_log_messages
alias hgrep='hist_grep'
alias kkdm='kill-kdm'
alias lesspb='less $HOME/etc/pydb/phonebook.py'
alias subash='sudo -E bash'
alias tail-fall='tail -n+1 -f'
alias ascii='man ascii'
alias md-p='mkdir -p'

# Dirty rotten two-faced gits...
alias gitbr='git branch'
alias gcb='git-current-branch'
alias gitco='git checkout'
alias gitci='git commit'
alias gitcia='git cia'
alias gitstat='git status'
alias gits='git status -uno'
alias gitsu='git status'
alias gitss='git status -s'
alias gitsno='git status -uno'
alias gitsn='git status -unormal'
alias gitsy='git status -unormal'
alias gitadd='git add'
alias git+='git add'            # git+, git add.
# NTMs: there is a real git revert command that is very different.
alias gitrevert='git checkout --'  # Alternates use exact command.
alias gitrescue='git checkout --'
alias gitsub='git checkout --'  # Add. Subtract, get it? OppOsite of add.
alias git-='git checkout --'
alias gitdiff='git diff'        # Oooo 1 char... but gives us completion.
alias gittag='git tag'
alias gitconf='git config'
alias gitls='git ls-files'      # Most common/useful ls variant?
# Log will be more common than ls. Will completion be a PITA?
alias gitlog='git log'
alias gitl=gitlog               # Abbrevs use long form.
alias gitremote='git remote'
alias gitpush='git push'
alias gitpull='git pull'
alias githelp='gith'            # Remove ^H bolding/underlining
alias gdn='git diff --name-only' # Just the file names only.

# Quicksilver versioning service.
alias hgs='hg status'
alias hgh='hg help'
alias hgcia='hg commit --addremove'
alias hgci='hg commit'
alias hgbr='hg branch'
alias hgl='hg log'

alias goabbrev=g
alias cdrp='cd $(rpd)'
alias gorp='cd $(rpd)'
alias home_addr='eval echo "\$${DP_HOME_MACHINE}_ADDR"'
alias home_user='eval echo "\$${DP_HOME_MACHINE}_USER"'
alias dotfgrep='GLOBIGNORE=".:.."  fgrep'
alias dotegrep='GLOBIGNORE=".:.."  egrep'
alias dotjgrep='GLOBIGNORE=".:.."  grep' # just grep. Almost never used... egrep is preferred.
alias dotgrep=dotfgrep        # fgrep is far and away my most common grepper.

alias .fgrep=dotfgrep
alias .egrep=dotegrep
alias .jgrep=dotjgrep
alias .grep=dotgrep
alias fgrep.=dotfgrep
alias egrep.=dotegrep
alias jgrep.=dotjgrep
alias grep.=dotgrep

alias mex=me-expand-dest

alias dp4-meld='dp4-diff --meld'
# p4 diff with diff(1); just diff(1)
alias p4dd='p4diffdiff'
alias sandbox_root_dir="/${HOME}/lib/pylib/tree_root_relativity.py --find-root"
alias sbroot=sandbox_root_dir
alias treeroot=sandbox_root_dir
alias sb-root=sandbox_root_dir
alias tree-root=sandbox_root_dir

alias myvncs='ls -l ~/.vnc/*.pid'

alias gpg='dp-gpg-fe'

## grep: warning: GREP_OPTIONS is deprecated; please use an alias or script
## This sucks so much because I used a simple grep to eliminate the grep
## being used by dpgrep from the output.  Now it'll be more complex and
## I'll stay up nights worring when it will change again and screw me over. Again.
## Sigh.

alias sagi='sudo apt-get install'

alias nocolor='ul -t dumb'

alias hinfo='host-info.py'
alias dpmailer='send-mail-command-line.sh'
alias dpclm=dpmailer

# @todo XXX predicate this on gpg doing ssh.
alias sshauthsock='gpgconf --list-dirs agent-ssh-socket'
alias expauthsock='export SSH_AUTH_SOCK="$(sshauthsock)"'

alias jcons='jupyter-console'
true

Bad value:# Non-emacs shell buffer prompt.
PS1_template="%B%n@%m:%~%b
(zsh): %!%(0?||<%S%?%s)> "

PS1="%B%n@%m:%~%b
(zsh): %!%(0?||<%S%?%s)> "

Bad value:PS1="%B%n@%m:%~%b
(zsh): %!%(0?||?%S%?%s)> "

Bad value:# We don't want a leading or trailing : to be added.
# But we do want at least what I consider to be a vital path.
if [ -z "$PATH" ]
then
    PATH="$most_basic_path"
else
    PATH="$most_basic_path:$PATH"
fi

Bad value:: ${DP_ENV_ORIGINAL_PATH:=$PATH}
export DP_ENV_ORIGINAL_PATH
PATH="${DP_ENV_ORIGINAL_PATH}"

Bad value:SH_WORD_SPLIT [2 times]
Bad value:: ${DP_ENV_ORIGINAL_PATH:=$PATH}
export DP_ENV_ORIGINAL_PATH
PATH="${DP_ENV_ORIGINAL_PATH}"

Bad value:"%B%n@%m:%~%b
Bad value:#  1

Bad value:#  1
Bad value:PS1="%B%n@%m:%~%b
(zsh): %!%(0?||/%?)> "

Bad value:#a keeper PS1="%B%n@%m:%~%b
#a keeper (zsh)%!/%?> "

Bad value:PS1="%B%n@%m:%~%b
(zsh)%!/%?> "

Bad value:;; NB: q.v. rev f1ca57a1648b4a7542450f590e57ae87ecc914e0 if you're
;; interested.  Is this a better idea than leaving (especially large) chunks
;; of comment out code that changed for a reason that may be ephemeral.
;; Throwing it away without leaving a reference to it seems foolish.  This
;; depends heavily on the reason for the change, especially if it is not
;; impossible that undoing the change will be needed.  With no imformation
;; that a previous, *working*, piece of code exists and has been forgotten or
;; in the case of a new person on the task, that is ever existed, it will
;; need to be worked on again.  old Emacs incompatible for of tracking the
;; cwd to stuff into `default-directory' It used the same idea, though.
 [2 times]
Bad value:f1ca57a1648b4a7542450f590e57ae87ecc914e0
Bad value:davep@vilya:~
2893/0001> rcgrep dp_setup_prompt

Bad value:davep@vilya:~
2893/0001> rcgrep dp_setup_prompt

Bad value:2895/0001> echo ">$PS1_path_suffix<"
><
davep@vilya:~
2896/0001> echo ">$PS1_prefix<"
><
davep@vilya:~
2897/0001> echo ">$emph<"
><
davep@vilya:~
2898/0001> echo ">$PS1_1<"
><
davep@vilya:~
2899/0001> echo ">$PS1_path<"
>:\w<
davep@vilya:~
2900/0001> echo ">$PS1_path_suffix<"
><
davep@vilya:~
2901/0001> echo ">$PS1_bang_pre<"
><
davep@vilya:~
2902/0001> echo ">$PS1_bang_suff<"
>/0001<
davep@vilya:~
2903/0001> echo ">$PS1_terminator<"
>><
davep@vilya:~
2904/0001> echo ">$PS1_terminator<"
>><

Bad value:echo "$PS1_path_suffix"
Bad value:davep@vilya:~
2884/0001> echo "$PS1_prefix"

davep@vilya:~
2885/0001> echo "emph"
emph
davep@vilya:~
2886/0001> echo "$emph"

davep@vilya:~
2887/0001> echo "$PS1_1"

davep@vilya:~
2888/0001> echo "$PS1_path"
:\w
davep@vilya:~
2889/0001> echo "$PS1_path_suffix"

davep@vilya:~
2890/0001> echo "$PS1_bang_pre"

davep@vilya:~
2891/0001> echo "$PS1_bang_suff"
/0001
davep@vilya:~
2892/0001> echo "$PS1_terminator"
>
davep@vilya:~
2893/0001> rcgrep dp_setup_prompt

Bad value:davep@vilya:~/local/build/gitted/zsh (master)
2875/0001> 
Bad value:# The following lines were added by compinstall
zstyle :compinstall filename '/home/davep/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

Bad value:# The following lines were added by compinstall
zstyle :compinstall filename '/home/davep/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

Bad value:zshbuiltins.1.g
Bad value:IGNORE_EOF
Bad value:mw
Error in post-command-hook (isearch-post-command-hook): (wrong-number-of-arguments message 0)
Mark saved where search started


(setq dp-str (car kill-ring))
#("Mark saved where search started" 0 31 (fontified t face font-lock-string-face))
#"

(substring-no-properties dp-str 0 (length dp-str))
"Mark saved where search started"


"Mark saved where search starte"

""

"Mark saved where search starte"


========================
2020-08-17T19:00:19
--
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
				   (let ((s (substring-no-properties (car el))))
				     ;;(dmessage "el>%s<" el)
				     (if (string-match dpj-private-topic-re s)
					 nil
				       el))))
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
				   (setq el (substring (car el)
					     0
					     (length (car el))
					     ))
				   ;;(dmessage "el>%s<" el)
				   (if (string-match dpj-private-topic-re el)
				       nil
				     el)))
				dpj-topic-list)))))
========================
2020-08-17T20:41:52
--
(cl-pe dpj-topic-list)

((#("dpj.test-of-quotes-\"\"\")(i-don't-care-do-y" 0 41 (fontified t face dp-journal-topic-face)) last-update:
  "2020-08-17T19:04:17")
(#("dpj.test-of-quotes-\"\"\")(" 0 24 (fontified t face dp-journal-topic-face)))
(#("dpj.test-of-quotes-\"" 0 20 (fontified t face dp-journal-topic-face)))
(#("dpj.test-of-quotes-\"\"" 0 21 (fontified t face dp-journal-topic-face)))
(#("amd.work.umrsh" 0 14 (fontified t face dp-journal-topic-face)))
(#("politics.2020.humor" 0 19 (fontified t face dp-journal-topic-face)))
(#("emacs.elisp" 0 11 (fontified t face dp-journal-topic-face)))
(#("zsh" 0 3 (fontified t face dp-journal-topic-face)))
(#("python.completion" 0 17 (fontified t)))
(#("emacs.elisp.python-mode" 0 23 (fontified nil)))
(#("politics.2020.rwnj" 0 18 (fontified nil)))
(#("python.ipython" 0 14 (fontified nil)))
(#("elpy" 0 4 (fontified nil)))
(#("physics.light" 0 13 (fontified nil)))
#("dpj.test-of-quotes-\"\"\")(" 0 24 (face dp-journal-topic-face fontified t))
#("dpj.test-of-quotes-\"" 0 20 (face dp-journal-topic-face fontified t))
#("dpj.test-of-quotes-\"\"" 0 21 (face dp-journal-topic-face fontified t))
#("amd.work.umrsh" 0 14 (face dp-journal-topic-face fontified t))
#("politics.2020.humor" 0 19 (face dp-journal-topic-face fontified t))
#("emacs.elisp" 0 11 (face dp-journal-topic-face fontified t))
#("zsh" 0 3 (face dp-journal-topic-face fontified t))
#("python.completion" 0 17 (fontified t))
#("emacs.elisp.python-mode" 0 23 (fontified nil))
#("politics.2020.rwnj" 0 18 (fontified nil))
#("python.ipython" 0 14 (fontified nil))
#("elpy" 0 4 (fontified nil))
#("physics.light" 0 13 (fontified nil))
"emacs.elisp.journal"
"fsf.emacs.elisp"
"games"
"games.equipment.razer.trinity"
"humor"
"medical.back"
"politics.2020"
"python.elpy"
"tools"
"w")nil


========================
Tuesday August 18 2020
--
;;;;;;;;;;;;;;;;;
(setq bozo 'bozo)

(let ((el '(a))) ;; b)))
(princf "el>%s<" el)
(princf "(car el)>%s<" (car el))
(princf "(cdr el)>%s<" (cdr el))
(princf "(list (car el) (cdr el)>%s<" (list (car el) (cdr el)))
(princf "(cons (car el) (cdr el)>%s<" (cons (car el) (cdr el)))
)
el>(a)<
(car el)>a<
(cdr el)>nil<
(list (car el) (cdr el)>(a nil)<
(cons (car el) (cdr el)>(a)<
nil

el>(a b)<
(car el)>a<
(cdr el)>(b)<
(list (car el) (cdr el)>(a (b))<
(cons (car el) (cdr el)>(a b)<
nil



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


;installed (defun dpj-write-topic-file ()
;installed   "Save the topic-list into the topic file."
;installed   (save-excursion
;installed     ;;(dmessage "lwl>%s<" dpj-last-written-topic-list)
;installed     ;;(dmessage " tl>%s<" dpj-topic-list)
;installed     (dpj-visit-topic-file)
;installed     (setq dpj-topic-list (delq nil
;installed 			       (mapcar
;installed 				(function
;installed 				 (lambda (el)
;installed 				   (let ((s (substring-no-properties(car el))))
;installed 				     (dmessage "el>%s<" el)
;installed 				     (dmessage "s>%s<" s)
;installed 				     (if (not (listp el))
;installed 					 (progn
;installed 					   (dmessage "el>%s< not a list, %s" el
;installed 						     "discarding")
;installed 					   nil)
;installed 				       (if (string-match dpj-private-topic-re s)
;installed 					   nil
;installed 					 ;; Write the topic string sans props.
;installed 					 (cons s (cdr el)))))))
;installed 				dpj-topic-list)))
;installed ;;    (setq dpj-topic-list (delq nil dpj-topic-list))
;installed     (if dp-journal-sort-topics-p
;installed 	(setq dpj-topic-list (sort dpj-topic-list 'dpj-topic<)))

;installed     (when (or (not (equal dpj-last-written-topic-list dpj-topic-list))
;installed 	      dpj-abbrev-list-modified-p)
;installed       (dp-erase-buffer)
;installed       (insert ";; -*-emacs-lisp-*-\n")
;installed       (insert dpj-topic-file-id-magic "\n")
;installed       (let ((standard-output (current-buffer)))
;installed 	(pp `(setq dpj-topic-list (quote ,dpj-topic-list))))
;installed       (insert "\n; topic abbrevs\n")
;installed       (insert-abbrev-table-description 'dpj-topic-abbrev-table)
;installed       (set-buffer-modified-p t)
;installed       (write-region (point-min) (point) dpj-topic-file nil 1)
;installed       (set-buffer-auto-saved)
;installed       (set-buffer-modified-p nil)
;installed       (if (buffer-file-name)
;installed 	  (set-visited-file-modtime))

;installed       ;; this should be OK due to the way we add elements to the topic list.
;installed       (setq dpj-last-written-topic-list dpj-topic-list)
;installed       (setq dpj-abbrev-list-modified-p nil)
;installed       (setq dpj-topic-list-read-time (dpj-topic-file-mod-time)))))
========================
2020-08-18T10:31:48
--
(dp-timestamp-string)
"2020-08-18T10:33:06"

========================
Saturday August 22 2020
--
(car (read-from-string INPUT-STRING))

(read-from-string '(eval "# "))


(eval "# ")
"# "


========================
Monday August 24 2020
--
(describe-minor-mode-completion-table-for-symbol)
("dictionary-tooltip-mode" "isearch-mode" "defining-kbd-macro" "compilation-in-progress" "folding-mode" "filladapt-mode" "2C-mode" "git-timemachine-mode" "dired-omit-mode" "minibuffer-electric-default-mode" "dp-blm-minor-mode-5" "dp-blm-minor-mode-4" ...)


(cl-pp minor-mode-list)

(dictionary-tooltip-mode isearch-mode
			 defining-kbd-macro
			 compilation-in-progress
			 folding-mode
			 filladapt-mode
			 2C-mode
			 git-timemachine-mode
			 dired-omit-mode
			 minibuffer-electric-default-mode
			 dp-blm-minor-mode-5
			 dp-blm-minor-mode-4
			 global-flycheck-mode
			 flycheck-mode
			 dimmer-mode
			 buffer-face-mode
			 text-scale-mode
			 ivy-mode
			 bug-reference-prog-mode
			 bug-reference-mode
			 magit-stgit-mode
			 markdown-live-preview-mode
			 outline-minor-mode
			 dired-isearch-filenames-mode
			 dp-blm-minor-mode-3
			 dp-blm-minor-mode-2
			 dirtrack-debug-mode
			 dirtrack-mode
			 ibuffer-auto-mode
			 sh-electric-here-document-mode
			 cursor-sensor-mode
			 cursor-intangible-mode
			 dp-blm-minor-mode-1
			 git-attr-linguist-vendored-mode
			 git-attr-linguist-generated-mode
			 dp-blm-minor-mode-0
			 electric-pair-mode
			 yas-global-mode
			 yas-minor-mode
			 highlight-indentation-current-column-mode
			 highlight-indentation-mode
			 flymake-mode
			 company-search-mode
			 global-company-mode
			 company-mode
			 elpy-mode
			 pyvenv-tracking-mode
			 pyvenv-mode
			 elpy-django
			 ido-everywhere
			 flyspell-mode
			 xref-etags-mode
			 savehist-mode
			 xgtags-mode
			 magit-popup-help-mode
			 magit-blame-read-only-mode
			 magit-blame-mode
			 magit-blob-mode
			 global-magit-file-mode
			 magit-file-mode
			 magit-wip-initial-backup-mode
			 magit-wip-before-change-mode
			 magit-wip-after-apply-mode
			 magit-wip-after-save-mode
			 magit-wip-after-save-local-mode
			 magit-wip-mode
			 smerge-mode
			 diff-minor-mode
			 diff-auto-refine-mode
			 git-commit-mode
			 global-git-commit-mode
			 transient-resume-mode
			 mml-mode
			 mail-abbrevs-mode
			 shell-command-with-editor-mode
			 with-editor-mode
			 async-bytecomp-package-mode
			 shell-dirtrack-mode
			 server-mode
			 edebug-x-mode
			 edebug-mode
			 which-function-mode
			 rectangle-mark-mode
			 compilation-minor-mode
			 compilation-shell-minor-mode
			 ispell-minor-mode
			 dired-hide-details-mode
			 delete-selection-mode
			 timeclock-mode-line-display
			 show-paren-mode
			 save-place-mode
			 magit-auto-revert-mode
			 global-auto-revert-mode
			 auto-revert-tail-mode
			 auto-revert-mode
			 icomplete-mode
			 global-hl-line-mode
			 hl-line-mode
			 global-cwarn-mode
			 cwarn-mode
			 display-time-mode
			 url-handler-mode
			 cl-old-struct-compat-mode
			 tooltip-mode
			 global-eldoc-mode
			 eldoc-mode
			 electric-quote-mode
			 electric-layout-mode
			 electric-indent-mode
			 mouse-wheel-mode
			 tool-bar-mode
			 paragraph-indent-minor-mode
			 global-prettify-symbols-mode
			 prettify-symbols-mode
			 use-hard-newlines
			 menu-bar-mode
			 file-name-shadow-mode
			 horizontal-scroll-bar-mode
			 jit-lock-debug-mode
			 global-font-lock-mode
			 font-lock-mode
			 blink-cursor-mode
			 window-divider-mode
			 auto-composition-mode
			 unify-8859-on-decoding-mode
			 unify-8859-on-encoding-mode
			 auto-encryption-mode
			 auto-compression-mode
			 temp-buffer-resize-mode
			 visible-mode
			 buffer-read-only
			 size-indication-mode
			 column-number-mode
			 line-number-mode
			 auto-fill-function
			 global-visual-line-mode
			 visual-line-mode
			 transient-mark-mode
			 next-error-follow-minor-mode
			 completion-in-region-mode
			 auto-save-visited-mode
			 auto-save-mode
			 auto-fill-mode
			 abbrev-mode
			 overwrite-mode
			 view-mode
			 hs-minor-mode)nil


(cl-pp
 (mapcar 'symbol-name minor-mode-list)
 )

("dictionary-tooltip-mode" "isearch-mode"
 "defining-kbd-macro"
 "compilation-in-progress"
 "folding-mode"
 "filladapt-mode"
 "2C-mode"
 "git-timemachine-mode"
 "dired-omit-mode"
 "minibuffer-electric-default-mode"
 "dp-blm-minor-mode-5"
 "dp-blm-minor-mode-4"
 "global-flycheck-mode"
 "flycheck-mode"
 "dimmer-mode"
 "buffer-face-mode"
 "text-scale-mode"
 "ivy-mode"
 "bug-reference-prog-mode"
 "bug-reference-mode"
 "magit-stgit-mode"
 "markdown-live-preview-mode"
 "outline-minor-mode"
 "dired-isearch-filenames-mode"
 "dp-blm-minor-mode-3"
 "dp-blm-minor-mode-2"
 "dirtrack-debug-mode"
 "dirtrack-mode"
 "ibuffer-auto-mode"
 "sh-electric-here-document-mode"
 "cursor-sensor-mode"
 "cursor-intangible-mode"
 "dp-blm-minor-mode-1"
 "git-attr-linguist-vendored-mode"
 "git-attr-linguist-generated-mode"
 "dp-blm-minor-mode-0"
 "electric-pair-mode"
 "yas-global-mode"
 "yas-minor-mode"
 "highlight-indentation-current-column-mode"
 "highlight-indentation-mode"
 "flymake-mode"
 "company-search-mode"
 "global-company-mode"
 "company-mode"
 "elpy-mode"
 "pyvenv-tracking-mode"
 "pyvenv-mode"
 "elpy-django"
 "ido-everywhere"
 "flyspell-mode"
 "xref-etags-mode"
 "savehist-mode"
 "xgtags-mode"
 "magit-popup-help-mode"
 "magit-blame-read-only-mode"
 "magit-blame-mode"
 "magit-blob-mode"
 "global-magit-file-mode"
 "magit-file-mode"
 "magit-wip-initial-backup-mode"
 "magit-wip-before-change-mode"
 "magit-wip-after-apply-mode"
 "magit-wip-after-save-mode"
 "magit-wip-after-save-local-mode"
 "magit-wip-mode"
 "smerge-mode"
 "diff-minor-mode"
 "diff-auto-refine-mode"
 "git-commit-mode"
 "global-git-commit-mode"
 "transient-resume-mode"
 "mml-mode"
 "mail-abbrevs-mode"
 "shell-command-with-editor-mode"
 "with-editor-mode"
 "async-bytecomp-package-mode"
 "shell-dirtrack-mode"
 "server-mode"
 "edebug-x-mode"
 "edebug-mode"
 "which-function-mode"
 "rectangle-mark-mode"
 "compilation-minor-mode"
 "compilation-shell-minor-mode"
 "ispell-minor-mode"
 "dired-hide-details-mode"
 "delete-selection-mode"
 "timeclock-mode-line-display"
 "show-paren-mode"
 "save-place-mode"
 "magit-auto-revert-mode"
 "global-auto-revert-mode"
 "auto-revert-tail-mode"
 "auto-revert-mode"
 "icomplete-mode"
 "global-hl-line-mode"
 "hl-line-mode"
 "global-cwarn-mode"
 "cwarn-mode"
 "display-time-mode"
 "url-handler-mode"
 "cl-old-struct-compat-mode"
 "tooltip-mode"
 "global-eldoc-mode"
 "eldoc-mode"
 "electric-quote-mode"
 "electric-layout-mode"
 "electric-indent-mode"
 "mouse-wheel-mode"
 "tool-bar-mode"
 "paragraph-indent-minor-mode"
 "global-prettify-symbols-mode"
 "prettify-symbols-mode"
 "use-hard-newlines"
 "menu-bar-mode"
 "file-name-shadow-mode"
 "horizontal-scroll-bar-mode"
 "jit-lock-debug-mode"
 "global-font-lock-mode"
 "font-lock-mode"
 "blink-cursor-mode"
 "window-divider-mode"
 "auto-composition-mode"
 "unify-8859-on-decoding-mode"
 "unify-8859-on-encoding-mode"
 "auto-encryption-mode"
 "auto-compression-mode"
 "temp-buffer-resize-mode"
 "visible-mode"
 "buffer-read-only"
 "size-indication-mode"
 "column-number-mode"
 "line-number-mode"
 "auto-fill-function"
 "global-visual-line-mode"
 "visual-line-mode"
 "transient-mark-mode"
 "next-error-follow-minor-mode"
 "completion-in-region-mode"
 "auto-save-visited-mode"
 "auto-save-mode"
 "auto-fill-mode"
 "abbrev-mode"
 "overwrite-mode"
 "view-mode"
 "hs-minor-mode")nil


("dictionary-tooltip-mode" "isearch-mode" "defining-kbd-macro" "compilation-in-progress" "folding-mode" "filladapt-mode" "2C-mode" "git-timemachine-mode" "dired-omit-mode" "minibuffer-electric-default-mode" "dp-blm-minor-mode-5" "dp-blm-minor-mode-4" ...)

@@ -1,26 +1,100 @@
-# The following lines were added by compinstall
-
-zstyle ':completion:*' auto-description 'specify: %d'
-zstyle ':completion:*' completer _complete _ignored
-zstyle ':completion:*' format 'Completing %d'
-zstyle ':completion:*' group-name ''
-zstyle ':completion:*' insert-unambiguous true
-zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
-zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
-zstyle ':completion:*' menu select=long-list select=0
-zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %l%s'
-zstyle ':completion:*' squeeze-slashes true
-zstyle ':completion:*' verbose true
-zstyle :compinstall filename '/home/davep/.zshrc'
-
-autoload -Uz compinit
-compinit
-# End of lines added by compinstall
-# Lines configured by zsh-newuser-install
-HISTFILE=~/.histfile.zsh.vilya
-HISTSIZE=1281
-SAVEHIST=9846
-setopt appendhistory extendedglob nomatch notify
-unsetopt autocd
-bindkey -e
-# End of lines configured by zsh-newuser-install

========================
Wednesday September 09 2020
--
entry>[zshenv, start=2020-09-09T23:02:40-04:00--<
Enter>zshenv<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:02:40-04:00--<
		      
entry>[zsh-path, start=2020-09-09T23:02:40-04:00--<
Enter>zsh-path<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:02:40-04:00--[zsh-path, start=2020-09-09T23:02:40-04:00--<
								  
entry>>end=2020-09-09T23:02:40-04:00]!!!zsh-path, start=2020-09-09T23:02:40-04:00--<
Exit>zsh-path<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:02:40-04:00--[zsh-path, start=2020-09-09T23:02:40-04:00-->end=2020-09-09T23:02:40-04:00]!!!zsh-path, start=2020-09-09T23:02:40-04:00--<
entry>>end=2020-09-09T23:02:40-04:00]!!!zshenv, start=2020-09-09T23:02:40-04:00--<
Exit>zshenv<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:02:40-04:00--[zsh-path, start=2020-09-09T23:02:40-04:00-->end=2020-09-09T23:02:40-04:00]!!!zsh-path, start=2020-09-09T23:02:40-04:00-->end=2020-09-09T23:02:40-04:00]!!!zshenv, start=2020-09-09T23:02:40-04:00--<


entry>[zshenv, start=2020-09-09T23:07:34-04:00..<
Enter>zshenv<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:07:34-04:00..<
entry>[zsh-path, start=2020-09-09T23:07:34-04:00..<
Enter>zsh-path<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:07:34-04:00..[zsh-path, start=2020-09-09T23:07:34-04:00..<
entry>:end=2020-09-09T23:07:34-04:00]!!!zsh-path, start=2020-09-09T23:07:34-04:00..<
Exit>zsh-path<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:07:34-04:00..[zsh-path, start=2020-09-09T23:07:34-04:00..:end=2020-09-09T23:07:34-04:00]!!!zsh-path, start=2020-09-09T23:07:34-04:00..<
entry>:end=2020-09-09T23:07:34-04:00]!!!zshenv, start=2020-09-09T23:07:34-04:00..<
Exit>zshenv<
DP_SHELL_RCS>[zshenv, start=2020-09-09T23:07:34-04:00..[zsh-path, start=2020-09-09T23:07:34-04:00..:end=2020-09-09T23:07:34-04:00]!!!zsh-path, start=2020-09-09T23:07:34-04:00..:end=2020-09-09T23:07:34-04:00]!!!zshenv, start=2020-09-09T23:07:34-04:00..<


[zshenv, start=2020-09-09T23:07:34-04:00..[zsh-path, start=2020-09-09T23:07:34-04:00..:end=2020-09-09T23:07:34-04:00]!!!zsh-path, start=2020-09-09T23:07:34-04:00..:end=2020-09-09T23:07:34-04:00]!!!zshenv, start=2020-09-09T23:07:34-04:00..

========================
Tuesday September 15 2020
--
(memq (with-current-buffer (current-buffer) major-mode)
                               '(magit-process-mode
                                 magit-revision-mode
                                 magit-diff-mode
                                 magit-stash-mode
                                 magit-status-mode))
nil


(current-buffer)
#<buffer elisp-devel.vilya.el>


(setq magit-display-buffer-function
      (lambda (buffer)
        (display-buffer
         buffer (if (and (derived-mode-p 'magit-mode)
                         (memq (with-current-buffer buffer major-mode)
                               '(magit-process-mode
                                 magit-revision-mode
                                 magit-diff-mode
                                 magit-stash-mode
                                 magit-status-mode)))
                    nil
                  '(display-buffer-same-window)))))
(lambda (buffer) (display-buffer buffer (if (and ... ...) nil (quote ...))))

========================
Thursday September 17 2020
--
(let ((x -1)
      (y 26)
      (frame nil))
  (set-frame-position frame x y))
t


;;(setq x (or x -1)) (setq y (or y 0)))

(run-with-idle-timer 2 nil #'dp-stuff-that-needs-to-done-after-init.el)
[nil 0 2 0 nil dp-stuff-that-needs-to-done-after-init\.el nil idle 0]

========================
Sunday September 27 2020
--

;; (defun dp-call-q (&optional key-I-wish)
;;   (interactive "p")
;;   (call-interactively (key-binding "q")))


(defun dp-q-exp()
;;  (interactive "d")
  (dmessage "in `dp-q-exp'")
  (let ((kb (key-binding "q")))
    (message "kb>%s<" kb)
    (call-interactively kb)))

;;(dmessage "leaving `dp-q-exp'"))

(defun dp-q-exp()
  (interactive "d")
  (dmessage "in `dp-q-exp'")
  (let ((kb (key-binding "q")))
    (message "kb>%s<" kb)
    (call-interactively kb)))


;; @todo XXX Complete/fix;
;; Breaks if I use the `save-window-excursion'. But works in the debugger.
;; D'UH.  It pays to keep track of stuff I've written:
;; `dp-op-other-window'
;; It doesn't use save-window-excursion, so it may break.
;; but it might be that which makes it work.

========================
Sunday October 04 2020
--
(defun dp-isearch-forward-list (search-list)
  (interactive)				;@todo XXX get interactive args.
  ()
  for str in search-list do
  (unless (re-search-forward str nil t)
    return nil

========================
Wednesday October 14 2020
--
;; zsh prompt (d'uh)
davep@vilya:~
(zsh) 1415> 

;; bash
davep@vilya:/tmp
(bash) 3150/0001> 
(concat "^\\(?:(.*)\\s-*\\)?"		; Misc annotation: shell name, etc.
	  "[0-9]+"			; History number
          "\\("
          "[/<]"                        ; hist num separator.
          "\\(?:[0-9]+\\|spayshul\\)"   ; shell "name"
          "\\)"
          "?\\([#>]\\|<[0-9]*>\\)")
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)"

^\(?:(.*)\s-*\)?[0-9]+\([/<]\(?:[0-9]+\|spayshul\)\)?\([#>]\|<[0-9]*>\)

"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)"

dp-sh-prompt-regexp
^[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)

^\(?:(.*)\s-*\)?[0-9]+\([/<]\(?:[0-9]+\|spayshul\)\)?\([#>]\|<[0-9]*>\)

(concat "^\\(?:(.*)\\s-*\\)?"		; (zsh) Misc annotation: shell name, etc.
	  "[0-9]+"			; xxxx History number
          "\\("
          "[/<]"                        ; hist num terminator/separator.
          "\\(?:[0-9]+\\|spayshul\\)"   ; shell "name/number"
          "\\)?"
	  ;;                V should this be [#>] ?
          "\\([#>]\\|<[0-9]*>\\)")
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)"
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)"



(concat "^\\(?:(.*)\\s-*\\)?"	    ; (zsh) Misc annotation: shell name, etc.
	  "[0-9]+"		    ; xxxx History number
          "\\("	      ; hist num terminator/separator, from shell number/name
          "[/<]"      ; terminator char.
          "\\(?:[0-9]+\\|spayshul\\)"   ; shell "name/number"
          "\\)"				; hist num end.
	  ;;                 V should this be [#>] ?
          "?\\([#>]\\|<[0-9]*>\\)")

(concat "^\\(?:(.*)\\s-*\\)?"	    ; (zsh) Misc annotation: shell name, etc.
	  "[0-9]+"		    ; xxxx History number
          "\\("	      ; hist num terminator/separator, from shell number/name
          "[/<]"      ; terminator char.
          "\\)"				; hist num end.
	  ;;                 V should this be [#>] ?
          "?\\([#>]\\|<[0-9]*>\\)")
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\)?\\([#>]\\|<[0-9]*>\\)"
^\(?:(.*)\s-*\)?[0-9]+\([/<]\)?\([#>]\|<[0-9]*>\)

dp-bash-prompt-regexp
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)"

dp-shells-prompt-font-lock-regexp-list
("^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)" "^(gdb) " "^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\)?\\([#>]\\|<[0-9]*>\\)")


(dp-concat-regexps-grouped (or nil
                                 dp-shells-prompt-font-lock-regexp-list))
"\\(^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<[0-9]*>\\)\\)\\|\\(^(gdb) \\)\\|\\(^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\)?\\([#>]\\|<[0-9]*>\\)\\)"


(cl-pp dp-shells-prompt-font-lock-regexp)

"^\\([0-9]+\\)
\\(/\\(?:[0-9]+\\|spayshul\\)\\)
\\([#>]\\|\\(<[0-9]*>\\)?\\)"


(concat
   "^\\([0-9]+\\)"			; history number
   "\\(/\\(?:[0-9]+\\|spayshul\\)\\)"	; shell buffer id
   "\\([#>]\\|\\(<[0-9]*>\\)?\\)"	; prompt [error] terminator
   )
"^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)"

========================
Friday October 16 2020
--
<a href="https://raw.githubusercontent.com/GoogleChrome/accessibility-developer-tools/master/dist/js/axs_testing.js">homepage</a>


(defun dp-re-search-forward-show-data (regexp &optional limit noerror count buffer)
  (interactive "sre: ")
  (dp-re-search-forward regexp limit noerror count buffer)
  (let ((match-data (match-data)))
    (dp-all-match-strings)
    (message "mb: %s, match-strings: %s" (match-string 0)
	     (dp-all-match-strings)))
  "=====================================")

dp-re-search-forward-show-data

PROMPT+=' $(git_prompt_
	    )'
zsh-o-prompt
"[?2004l
%                                                                                       "
dp-defwriteme

(cl-pe '
 (dp-defwriteme bubba (a b c)
   "a defwriteme"
   (princf "I am bubba!")
   )
 )

(defalias 'bubba
  (function
   (lambda (a b c)
     "WRITE THIS FUNCTION!
a defwriteme"
     (interactive)
     (let ((s (format "%s: WRITE ME!!!
signature %s %s" 'bubba 'bubba "(a b c)")))
       (message "%s" s)
       (princf "%s" s))
     (princf "I am bubba!"))))

bubba




(defalias 'bubba
  (function
   (lambda (a b c)
     "WRITE THIS FUNCTION!
a defwriteme"
     (interactive)
     (let ((s (format "%s: WRITE ME!!!: %s %s" 'bubba 'bubba "(a b c)")))
       (message "%s" s)
       (princf "%s" s))
     (princf "I am bubba!"))))
bubba




(defalias 'bubba
  (function
   (lambda (a b c)
     "WRITE THIS FUNCTION!
a defwriteme"
     (interactive)
     (let ((s (format "%s: WRITE ME!!!: %s %s" 'bubba 'bubba "(a b c)")))
       (message "%s" s)
       (princf "%s" s))
     (princf "I am bubba!"))))
bubba

bubba





(defalias 'bubba
  (function
   (lambda (a b c)
     "WRITE THIS FUNCTION!
a defwriteme"
     (interactive)
     (message "%s: WRITE ME!!!: %s %s" 'bubba 'bubba "(a b c)")
     (princf "I am bubba!"))))
bubba




(bubba 1 2 3)
bubba: WRITE ME!!!
signature bubba (a b c)
I am bubba!
nil

I am bubba!
nil

bubba: WRITE ME!!!: bubba (a b c)
I am bubba!
nil


========================
Saturday November 14 2020
--
;installed (defun dp-switch-to-minibuffer-window ()
;installed   "switch to minibuffer window (if active)"
;installed   (interactive)
;installed   (if (active-minibuffer-window)
;installed       (progn
;installed 	(select-frame-set-input-focus (window-frame (active-minibuffer-window)))
;installed 	(select-window (active-minibuffer-window)))
;installed     (ding)
;installed     (message "No active minibuffer.")))


;installed (global-set-key [(shift meta ?x)] 'dp-switch-to-minibuffer-window)

========================
Thursday November 19 2020
--
(cl-pp printable-chars)

#^nil
[nil nil nil 
#^^[3 0 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t nil] #^^[1 0 #^^[2 0 
#^^[3 0 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t nil] 
#^^[3 128 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t] t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t] t t t t t t t t t t t t t t t] t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t #^^[1 4128768 t t t t t t t t t t t t t t t #^^[2 4190208 t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t t nil]]]

(setq dp-prompt-string "davep@vilya:~/notes 
[36m(6:zsh) 3220<130>[39m 
")

"davep@vilya:~/notes 
[36m(6:zsh) 3220<130>[39m 
"

"davep@vilya:~/notes 
[36m(6:zsh) 3220<130>[39m 
"
"davep@vilya:~/notes 
[36m(6:zsh) 3220<130>[39m 
"
"davep@vilya:~/notes 
[36m(6:zsh) 3220<130>[39m 
"


"davep@vilya:~/notes 
[36m(6:zsh) 3220<130>[39m 
"

(setq comint-prompt-regexp "^\\(davep@vilya:.*\\|([0-9]+: zsh) [0-9]+> \\)$")

"^\\(davep@vilya:.*\\|([0-9]+: zsh) [0-9]+> "
^([0-9]+:zsh)

^\\(([0-9]+:zsh) [0-9]+>\\)


^\(davep@vilya:.*\|^([0-9]+:zsh)\)

"^\\(davep@vilya:.*\\|^([0-9]+:zsh)\\)"

(setq dp-pre "^\\(davep@vilya:.*\n([0-9]+:zsh) [0-9]+> \\)")
"^\\(davep@vilya:.*
([0-9]+:zsh) [0-9]+> \\)"



; works
(setq comint-prompt-regexp "^[^#$%>\n]*[#$%>]+ *")

; not
comint-prompt-regexp "^\\(davep@vilya:.*\n([0-9]+:zsh) [0-9]+> *\\)"
First up goes to a few chars from ^ and recalls something.
C-PgDn then up works.

========================
Monday June 07 2021
--
(defun* dp-nuke-fill-prefix (&optional
			     (set-to nil set-to-is-specified-p))
  "If `fill-prefix' gets set, how I know not, it fucks up a lots o' things.

E.g. the ability to fill docstrings and comments properly,
@todo XXX How does it get set, and stuck?  Fix the problem, not the symptoms."
  (interactive "P")
  (if set-to-is-specified-p
      (setq fill-prefix set-to)
    (kill-local-variable 'fill-prefix))
  fill-prefix)

========================================================================

 (defun dp-nuke-fill-prefix ()
  "If `fill-prefix' gets set somehow, it fucks up a lot.

E.g. the ability to fill docstrings and comments properly,
@todo XXX How does it get set, and stuck?  Fix the problem, not the symptoms."
  (interactive)
  (setq fill-prefix nil))


 (when t
   (defun dp-nuke-fill-prefix ()
     "If `fill-prefix' gets set somehow, it fucks up a lot.

E.g. the ability to fill docstrings and comments properly,
@todo XXX How does it get set, and stuck?  Fix the problem, not the symptoms."
     (interactive)
     (setq fill-prefix nil))
   )

========================
Tuesday June 08 2021
--
;; (defun dp-underscore-region-as-title (&optional char)
;;   (interactive "P")
;;   (when (Cu--p)
;;     (setq char
;; 	  (read-string "Underlining char? " "_" nil "_")))
;;   (dp-underscore-region 1 :char char :as-title-p 'as-title-p))

(defun* dp-underscore-region-as-title (&optional (char "_"))
  (interactive "P")
  (setq char
	(if (Cu-p)
	    (read-string "Underlining char? " "_" nil "_")
	  "_"))
  (dp-underscore-region 1 :char char :as-title-p 'as-title-p))



a b c d
;; WTF is going on!!??

_W_T_F_

||a b ||c

||a b c||

(progn
  (let ((a 100)
	(b 200))
    (setq
     gotta-be-a-better-way a
     a b
     b gotta-be-a-better-way)
    (cons a b)))
(200 . 100)

(200 . 100)

(defun dp-swap-a&b-to-cons  (a b)
  "Swap a and b and return cons of new values."
  (cons b a))
dp-swap-a&b-to-cons

(dp-swap-a&b-to-cons 'aye 'bee)
(bee . aye)

(defun dp-swap-cons-to-cons (c)
  (dp-swap-a&b-to-cons (car c) (cdr c)))
dp-swap-cons-to-cons

(dp-swap-cons-to-cons (cons 'first 'second))
(second . first)

(defun dp-region-boundaries-ordered (&optional beg? end? exchange-pt-and-mark-p
					       dont-force-to-markers-p)
  "Return the boundaries of the region ordered in a cons: \(low . hi\)"
  ;; I never knew about these functions.
  ;; (cons (region-beginning) (region-end)))
  ;; But here they're not very useful since beg? and end? may not be ordered.
  ;; Au contraire, they seem to always return beg as the lower, and end as
  ;; the higher, position-wise??? They???
  ;; Both must be provided.
  (let ((obcons
	 (if (and beg? end?)
	     (if (> end? beg?)
		 (cons beg? end?)
	       (cons end? beg?))
	   (when (and exchange-pt-and-mark-p
		      (< mark (point)))
	     (exchange-point-and-mark))
	   ;; @todo XXX These are already markers.  Fix this.
	   (cons (region-beginning)
		 (region-end)))))
    (if dont-force-to-markers-p
	obcons
      ;; The markerization isn't needed for region values.  It may not be
      ;; needed for beg? && end?, but 'tis easier to "Just Do It(tm)"
      ;; But we wanna markerize in one place.
      (cons (dp-mk-marker (car obcons))
	    (dp-mk-marker (cdr obcons))))))
dp-region-boundaries-ordered

(dp-region-boundaries-ordered 111 2)
(#<marker at 2 in elisp-devel.vilya.el> . #<marker at 111 in elisp-devel.vilya.el>)

(#<marker at 1 in elisp-devel.vilya.el> . #<marker at 2 in elisp-devel.vilya.el>)



_a_b_c_


_1_2_3_

_meh_

========================
Thursday June 10 2021
--
Sometimes in *Help* bufs, tab you to the end of a link, thus:

blah blah `blabbity' blah
<TAB>--------------^ 
Press enter --> "Debugger entered--Lisp error: (user-error "No cross-reference here")"
I can't recall when it happens.
But if it's common enough:
if looking at "'" see if [point +/- 1] has region/text
props/whatever indicating help. If so move <dir> and try again.


;;; --------------- Preserve everything above this line ----------------
;;; Anything in this file *before* the above line is preserved.
;;; --------------------- Begin generated section ----------------------
;;; Everything in this file from the beginning of the previous line to the
;;; end of file will be deleted.
;;; !!!!!!!!! I have no idea why I said that. !!!!!!!!!!
;;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;;
;;; File: /home/dapanarx/lisp/dp-common-abbrevs.el
;;; Last saved: 2012-08-22T18:02:02
;;;
;;; `manual' abbrevs are more common than global since they are only expanded
;;; upon request.  Automatic expansion in the wrong place is *very* amnoying!
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
;;; ABBREV-NAMES ::= "abbrev-name" | ("abbrev-name0"...)
;;; EXPANSIONS ::= "expansion0"...
;;; TABLE-INFO ::= TABLE-NAME | TABLE-INFO-PLIST
;;; TABLE-NAME ::= 'table-name-sym | "table-name"  ; it's `format'd w/%s
;;; TABLE-INFO-PLIST ::= (PROP/VAL PROP/VAL ...)
;;; PROP/VAL ::= 'table-name TABLE-NAME
;;;
;;; we define abbrevs: {ABBREV-NAMES} X {EXPANSIONS} X {TABLES}
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
;;; !<@todo Automatically generate "logical" case mixtures.
;;; Convenience binding in this file:
;;; C-c C-c (dp-save-and-redefine-abbrevs)
;;;
;;; This information is common between the abbrev file and dp-abbrev.el

(defconst dp-common-abbrevs
  '(((("dev" "development" "develop" "device")
      'circular)
     dp-manual)
    (("teh" "the" "duh" "D'OH!")
     dp-manual global)
    (("plisttest" "a test of the plist type table.")
     (table-name dp-manual tmp t)
     (table-name dp-plists))
    (("cs" "c_str()" "char* ")
     (table-name dp-c++-mode))
    (("nn" "non-nil")
     dp-manual)
    (("wrt" "WRT" "with respect to")
     dp-manual)
    ((("dtrt" "DTRT")
      "do the right thing" "DTRT" "dtrt")
     dp-manual)
    (("st" "such that ")
     dp-manual)
    ((("wether" "wheter")
      "whether")
     dp-manual global)
    ((("wether" "wheter")
      "whether")
     dp-manual global)
    (("thru" "through")
     dp-manual global)
    (("thot" "thought")
     dp-manual global)
    (("provate" "private")
     dp-manual global)
    (("tho" "though" "although")
     dp-manual global)
    ((("dap" "dp" "DAP" "DP" "davep")
      "David A. Panariti")
     dp-manual)
    (("stl" "STL")
     dp-manual)
    (("ds" "data structures")
     dp-manual)
    (("mobo" "motherboard")
     dp-manual)
    (("num" "number" "numbers")
     dp-manual)
    (("altho" "although")
     dp-manual global)
    (("provate" "private")
     dp-manual global)
    (("kb" "keyboard" "KB")
     dp-manual)
    (("eg" "e.g.")
     dp-manual)
    (("qv" "q.v.")
     dp-manual)
    (("ie" "i.e.")
     dp-manual)
    (("nb" "N.B.")
     dp-manual)
    (("plz" "please")
     dp-manual)
    (("sthg" "something")
     dp-manual global)
    ((("iir" "IIR" "Iir")
      "if I recall" "IIR")
     dp-manual)
    ((("appt" "appts")
      "appointments" "appointment")
     dp-manual)
    ((("p2p")
      "peer-to-peer" "point-to-point")
     dp-manual)
    ((("ptp")
      "point-to-point" "peer-to-peer")
     dp-manual)
    ((("concat" "cat")
      "concatenate")
     dp-manual)
    (("ok" "OK")
     dp-manual global)
    (("wtf" "WTF")
     dp-manual global)
    (("fo" "of")
     dp-manual global)
    ((("decl" "decls")
      "declaration" "declarations")
     dp-manual)
    (("pred" "predicate" "predicates")
     dp-manual)
    (("def" "definition" "define")
     dp-manual)
    (("defs" "definitions" "defines")
     dp-manual)
    (("prob" "problem" "problems")
     dp-manual)
    (("probs" "problems")
     dp-manual)
    (("gui" "GUI")
     dp-manual)
    (("bup" "backup" "backups")
     dp-manual)
    (("bups" "backups")
     dp-manual)
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
     dp-manual global)
    (("ms" "mS" global)
     dp-manual)
    (("linux" "Linux" "LINUX" "LiGNUx")
     dp-manual)
    (("thier" "their")
     dp-manual global)
    (("beleive" "believe")
     dp-manual global)
    ((("yop" "yopp")
      "YOPP!")
     dp-manual global)
    ((("repos" "repo")
      "repository")
     dp-manual)
    (("e2ei" "RSVP-E2E-IGNORE")
     dp-manual)
    ((("LARTC" "lartc")
      "Linux Advanced Routing & Traffic Control HOWTO")
     dp-manual)
    (("pkt" "packet")
     dp-manual)
    (("lenght" "length")
     dp-manual global)
    ((("recieve" "rx" "RX")
      "receive")
     dp-manual global)
    (("reciever" "receiver")
     dp-manual global)
    ((("rxer" "rxor" "rxr")
      "receiver")
     dp-manual)
    (("nic" "NIC" "network interface card")
     dp-manual)
    (("tcp/ip" "TCP/IP")
     dp-manual)
    (("udp" "UDP")
     dp-manual)
    (("q" "queue" "enqueue")
     dp-manual)
    ((("enq" "nq")
      "enqueue")
     dp-manual)
    ((("deq" "dq")
      "dequeue")
     dp-manual)
    ((("xlation" "xlat")
      "translation" "translate")
     dp-manual)
    ((("xmission" "xmit" "tx")
      "transmission" "transmit")
     dp-manual)
    ((("seq" "seqs")
      "sequences" "sequence")
     dp-manual)
    (("foriegn" "foreign")
     dp-manual global)
    (("yeild" "yield")
     global)
    (("peice" "piece")
     global)
    ((("govt" "gov")
      "government")
     dp-manual)
    (("wadr" "with all due respect")
     dp-manual)
    (("att" "at this time")
     dp-manual)
    (("atow" "at time of writing")
     dp-manual)
    ((("FHR" "fhr")
      "for historical reasons")
     dp-manual)
    (("provate" "private")
     dp-manual global)
    (("yko" "echo")
     dp-manual global)
    (("strenght" "strength")
     dp-manual global)
    (("gameplay" "game play")
     dp-manual global)
    (("WH" "White House")
     dp-manual)
    (("admin" "administration")
     dp-manual)
    (("christian" "xian")
     dp-manual)
    (("xian" "christian")
     dp-manual)
    ((("xemacs" "xem")
      "XEmacs")
     dp-manual)
    (("python" "Python")
     dp-manual)
    (("tcp" "TCP")
     dp-manual)
    (("ip" "IP")
     dp-manual)
    ((("filesystem" "fs" "FS")
      "file system" "file-system")
     dp-manual)
    (("Filesystem" "File system" "File-system")
     dp-manual)
    ((("filename" "fname")
      "file name" "File name")
     dp-manual)
    ((("fd" "fdesc")
      "file descriptor" "File descriptor")
     dp-manual)
    (("symlink" "symbolic link")
     dp-manual)
    (("Symlink" "Symbolic link")
     dp-manual)
    (("autosave" "auto save")
     dp-manual)
    (("Autosave" "Auto save")
     dp-manual)
    ((("keymap" "key maps")
      "key map" "key maps")
     dp-manual)
    (("beg" "begin")
     dp-manual)
    (("begin" "beg")
     dp-manual)
    (("ws" "white space")
     dp-manual)
    (("whitespace" "white space")
     dp-manual)
    (("qs" "questions")
     dp-manual)
    (("var" "variable")
     dp-manual)
    (("vars" "variables")
     dp-manual)
    (("env" "environment")
     dp-manual)
    ((("envv" "envvar" "evar" "envar" "ev")
      "environment variable" "environment variables")
     dp-manual)
    (("info" "information")
     dp-manual)
    ((("init" "ini")
      "initial" "initialize" "initializer" "initiator" "initialization")
     dp-manual)
    ((("nvidia" "NVIDIA")
      "nVIDIA")
     dp-manual)
    (("exe" "executable")
     dp-manual)
    ((("bin" "bina" "b2" "base2")
      "binary")
     dp-manual)
    (("ISTR" "I seem to recall")
     dp-manual)
     (("bi" "built-in" "builtin")
     dp-manual)
    (("subshell" "sub-shell")
     dp-manual)
    (("ding" "ba DooM!")
     dp-manual)
    ((("STFU" "stfu")
      "please be quiet" "hush" "hushup" "shhhh")
     dp-manual)
    (("goto" "go to")
     dp-manual)
    (("ww" "wall wart")
     dp-manual)
    (("flsit" "flist")
     dp-manual)
    (("dpdx" "DP_DASH_X=t")
     dp-manual)
    (("devs" "developers" "devices")
     dp-manual)
    (("devel" "development" "develop")
     dp-manual)
    (("memf" "member function" "member field")
     dp-manual)
    (("mfunc" "member function" "member field")
     dp-manual)
    ((("dir" "dirs")
      "directory" "directories")
     dp-manual)
    ((("subdir" "subdirs")
      "subdirectory" "subdirectories" "sub-directory" "sub-directories")
     dp-manual)
    ((("cwd" "current working directory" "working directory"
       "default directory" "pwd")
      'circular)
     dp-manual)
    ((("paren" "parens")
      "parenthesis" "parentheses" "parenthesize")
     dp-manual)
    (("orig" "original")
     dp-manual)
    ((("tmp" "temp")
      "temporary")
     dp-manual)
    ((("eof" "EOF")
      "EOF" "end of file")
     dp-manual)
    ((("hud" "Hud")
      "HUD" "head's up display")
     dp-manual global)
    ((("npc" "Npc")
      "NPC" "non-player character")
     dp-manual global)
    (("lang" "language")
     dp-manual global)
    (("vv" "virtual void " "virtual ")
     dp-manual global)
    (("vb" "virtual bool " "virtual ")
     dp-manual global)
    (("v" "virtual ")
     dp-manual global)
    (("src" "source" "sources")
     dp-manual)
    ((("dest" "dst")
      "destination" "destinations")
     dp-manual)
    ((("conf" "config" "cfg")
      "configuration" "configurations" "Configuration" "Configurations")
     dp-manual)
    ((("cap" "caps")
      "capability" "capabilities" "Capability" "Capabilities")
     dp-manual)
    ((("hie" "hier")
      "hierarchy")
     dp-manual)
    ((("bcbs" "BCBS")
      "Blue Cross Blue Shield")
     dp-manual)
    (("pvt" "priv" "private" "private:" "private")
     dp-manual)
    (("prot" "protected:" "protect" "protected")
     dp-manual)
    ((("dep" "deps")
      "dependency" "dependencies")
     dp-manual)
    (("foriegn" "foreign")
     dp-manual global)
    ((("lib" "libs")
      "library" "libraries"))
    ;; sc to be "current SCM specific?"
    ((("sc" "gc" "scmconf" "gitconf")	; scm conflict/git conflict
      "^<<<<<<< HEAD$" "^=======$" "^>>>>>>>\\.$"))
    ((("oaoo" "OaOO" "OAOO")
      "OaOO" "Once and Only Once" "Once and only once" "once and only once"))
    (("buncha" "bunch of")
     dp-manual)
    (("TMMW" "to make matters worse")
     dp-manual global)
    (("cla" "command line argument" "command line arguments")
     dp-manual global)
    (("envv" "environment variable" "environment variables")
     dp-manual global)
    (("med" "medication" "medications")
     dp-manual)
    ((("imo" "IMO")
      "in my opinion" "In my opinion" "im my humble opinion" "In my humble opinion"))
    ((("imho" "IMHO")
      "im my humble opinion" "In my humble opinion" "in my opinion" "In my opinion")
     dp-manual)
    (("PPT" "power of positive thinking")
     dp-manual)
    (("acet" "acetaminophen")
     dp-manual global)
    (("inv" "inventory")
     dp-manual)
    (("req" "request" "require" "requisition")
     dp-manual)
    (("ooi" "out of inventory")
     dp-manual)
    (("ooo" "out of order")
     dp-manual)
    (("compat" "compatible")
     dp-manual)
    (("lgtm" "looks good to me")
     dp-manual)
    (("combo" "combination")
     dp-manual)
    (("mks" "makeshift" "make-shift" "make shift")
     dp-manual)
    ((("cons" "constructable" "construct") 'circular) dp-manual)
    ((("fa" "forall")
      "\\-/")
     dp-manual)
    (("babs" "buildables")
     dp-manual)
    ((("sand" "land")
      "set and" "logical and" "intersection")
     dp-manual)
    ((("ch" "sf" "srcs" "chc")
      "*.[ch]" "*.[ch]*" "*.h" "*.cpp" "*.c" "*.h" "*.cpp")
     dp-manual)
    ((("obj" "objs" "doto")
      "*.ko *.o *.a" "*.o" "*.ko" "*.a")
     dp-manual)
    ((("ech" "esf" "esrcs" "echc")
      "\\.[ch]")
     dp-manual)
    ((("chre" "sfre" "srcre" "chcre")
      ".*\\.[ch]\\(pp\\)?$")
     dp-manual)

    ;; >> Wish I was smart
    ((("arg" "argument" "arguments")
      'circular)
     dp-manual)
    ((("args" "arguments" "arg" "argument")
      'circular)
     ;; << enough to handle plurals with elisp.
     dp-manual)

    ;; Homer's a roll modle.
    ((("smart" "S-M-R-T" "s-m-r-t" "SMRT" "smrt"
       "`I am so smart, S-M-R-T'")
      'circular)
     dp-manual)

     ;; Homer's a roll modle.
     ((("we" "whatever" "what ever" "WE")
	"`I am so smart, S-M-R-T'")
       'circular)
     dp-manual)
        
    ((("P" "Python" "py")
      'circular)
     dp-manual)
    (("te" "TE" "there exists" "-]")
     dp-manual)
    ((("te" "TE" "t.e." "T.E." "there exists") 'circular) dp-manual)
    (("hp" "hit points")
     dp-manual)
    ((("ntms" "note to myself" "fmi" "for my info" "for my information")
      'circular)
     dp-manual)
    (("pita" "pain in the ass")
     dp-manual)
    (("vp" "virtual Property_t")
     dp-manual)
    (("vaddr" "virtual address")
     dp-manual)
    (("paddr" "physical address")
     dp-manual)
    (("mem" "memory")
     dp-manual)
    (("sb" "*scratch*")
     dp-manual)
    (("shmem" "shared memory")
     dp-manual)
    (("proc" "process" "processor")
     dp-manual)
    (("FCFS" "first come first served")
     dp-manual)
    (("con" "concierge" "concierges" "Concierge" "Concierges")
     dp-manual)
    (("metadata" "meta-data" "meta data")
     dp-manual)
    (("md" "metadata" "meta-data" "meta data")
     dp-manual)
    (("ccs" "const char* " "const std::string& ")
     dp-manual)
    (("cus" "const unsigned char* ")
     dp-manual)
    ((("08x" "x80" "x8" "8x") "0x%08x")
     dp-manual)
    (("vccs" "virtual const char* " "virtual const std::string & ")
     dp-manual)
    (("css" "const std::string& " "std::string& " "const char* "
      "const std::string " "std::string ")
     dp-manual)
    (("less" "std::less")
     dp-manual)
    ((("osr" "os")
      "std::ostream& os" "std::ostream& " "ostream& ")
     dp-manual)
    ((("fgrep" "egrep" "grep") 'circular) dp-manual)
    (("vvs" "const void* ")
     dp-manual)
    (("bg" "background")
     dp-manual)
    (("cha" "challenge")
     dp-manual)
    (("ascii" "ASCII")
     dp-manual)
    (("phr" "Prop_handler_ret_t")
     dp-manual)
    ((("xargsr0" "xargs") "xargs -r0 ")
     dp-manual)
    ((("pxargs" "xargsp") "| xargs -r0 ")
     dp-manual)
    ;; We ignore grep in favor of egrep.
    (("faf" "find . -type f -print0 | xargs -r0 "
      "find . -type f -print0 | xargs -r0 egrep ")
     dp-manual)
    (("faff" "find . -type f -print0 | xargs -r0 fgrep -ni "
      ;;Usually it's fgrep or egrep.
      ;;"find . -type f -print0 | xargs -r0 grep "
      "find . -type f -print0 | xargs -r0 egrep -n ")
     dp-manual)
    (("faff" "find . -type f -print0 | xargs -r0 fgrep -ni "
      ;;Usually it's fgrep or egrep.
      ;;"find . -type f -print0 | xargs -r0 grep "
      "find . -type f -print0 | xargs -r0 egrep -n ")
     dp-manual)
    (("fafe" "find . -type f -print0 | xargs -r0 egrep -ni "
      ;;Usually it's fgrep or egrep.
      ;;"find . -type f -print0 | xargs -r0 grep "
      "find . -type f -print0 | xargs -r0 fgrep -ni ")
     dp-manual)
    (("fasf" "find . -type f \\( -name '*.cpp' -o -name '*.h' \\)  -print0 | xargs -r0 fgrep -ni "
      ;;Usually it's fgrep or egrep.
      ;;"find . -type f -print0 | xargs -r0 grep "
      "find . -type f -print0 | xargs -r0 egrep -ni ")
     dp-manual)
    ((("tr" "tra" "tramp" "remfile" "remf" "rf") "/ssh:dpanarit@")
     dp-manual)
    (("cz" "cz-fp4-bdc")
     dp-manual)
    (("xer" "xerxes")
     dp-manual)
    ;; Make "/ssh:dpanarit@" a vary-able.
    ((("rcz" "rz") "/ssh:dpanarit@cz-fp4-bdc:")
     dp-manual)
    (("rxer" "/ssh:dpanarit@xerxes:")
     dp-manual)
    (("cttoi" "come to think of it")
     dp-manual)
    (("br" "bug report")
     dp-manual)
    (("fasb" "for sb in sb1 sb2 sb3 sb4 sb5; do echo_id sb; cd $sb; ")
     dp-manual)
    (("style" "/home/dpanariti/work/doc/code-style.txt")
     dp-manual)
    (("psse" "print >>sys.stderr, ")
     dp-manual)
    (("hc" "hard coded" "hard-coded")
     dp-manual)
    (("janine" "someone with your qualifications would have no trouble finding a top-flight job in either the food service or housekeeping industries.")
     dp-manual)
    ;; Extra quote is really used.
    ((("ctor" "constructor" "construct")
      'circular)
     dp-manual)
    ((("alt" "alternative" "alternate")
      'circular)
     dp-manual)
    ((("emacs" "xemacs" "XEmacs" "Emacs")
      'circular)
     dp-manual)
    ((("acc" "accurate" "accuracy")
      'circular)
     dp-manual)
    ((("res" "resource")
      'circular)
     dp-manual)
    ((("sch" "schematics" "schematic" "scheme" "schedule" )
      'circular)
     dp-manual)
    ((("ftci" "FTCI" "ftca" "FTCA")
      'circular)
     dp-manual)
    ((("dos" "DOS" "DoS" "denial of service")
      'circular)
     dp-manual)
    ((("ob1" "obo" "OBO" "OB1" "off-by-one" "off by one")
      'circular)
     dp-manual)
    ((("re" "regexp" "regex" "regular expression")
      'circular)
     dp-manual)
     ((("fe" "front end" "Front end")
       'circular)
      dp-manual)
     ((("sagi" "sudo apt install " "sudo apt-get install ")
       'circular)
      dp-manual)
     ((("sagi" "sudo apt install " "sudo apt-get install ")
       'circular)
      dp-manual)
     ((("endis" "(en|dis)able " "enable/disable " "enable or disable")
       'circular)
      dp-manual)
     ((("got" "git") 'circular) dp-manual)
     ((("get" "git") 'circular) dp-manual)
     ((("fh" "FETCH_HEAD") 'circular) dp-manual)
     ;; Plurals seem to make sense as they are.
     ((("iter" "iteration" "iterations" "iters" "iterations")
       'circular) dp-manual)
     ((("dup" "dupe" "duplicate") 'circular) dp-manual)
     ((("dups" "dupes" "duplicates") 'circular) dp-manual)
     ((("stderr" "/proc/self/fd/2" "1>&2") 'circular) dp-manual)
     ((("stdout" "/proc/self/fd/1") 'circular) dp-manual)
     ((("stdin" "/proc/self/fd/0") 'circular) dp-manual)

     ;; Some mu4e mailbox names.
     ;; Expansion no work.
     ;; Need to hack the function mu4e uses to read MB names
     (("amba" "/Amd/Archive") dp-manual)
     (("ambC" "/Amd/Calendar") dp-manual)
     (("ambk" "/Amd/Clutter") dp-manual)
     (("ambc" "/Amd/Contacts") dp-manual)
     (("ambch" "/Amd/Conversation History") dp-manual)
     (("ambdi" "/Amd/Deleted Items") dp-manual)
     (("ambd" "/Amd/Drafts") dp-manual)
     (("ambi" "/Amd/Inbox") dp-manual)
     (("ambj" "/Amd/Journal") dp-manual)
     (("ambJ" "/Amd/Junk Email") dp-manual)
     (("ambn" "/Amd/Notes") dp-manual)
     (("ambo" "/Amd/Outbox") dp-manual)
     (("ambr" "/Amd/RSS Subscriptions") dp-manual)
     (("ambs" "/Amd/Sent") dp-manual)
     (("ambsi" "/Amd/Sent Items") dp-manual)
     (("ambS" "/Amd/Sync Issues") dp-manual)
     (("ambt" "/Amd/Tasks") dp-manual)
     (("amb" "/Amd/") dp-manual)
    ))
;; We could just use the non-void-ness of dp-common-abbrevs, but I
;; like suspenders with my belt.
(put 'dp-common-abbrevs 'dp-I-am-a-dp-style-abbrev-file t)


========================
Saturday June 26 2021
--

(format "%%s")
"%s"
(format "\%s")
[ at this time 2021-06-26T09:27:17 ]
2021-06-26T09:27:22 
[ at this time 2021-06-26T09:28:19 ]

========================
2021-06-26T11:06:27
--

<207709>color-me<207725>
(defun dp-set-colorized-extent-priority (arg &optional pos extents)
  (interactive "Npriority: \nXpos: ")
  (dp-set-extent-priority arg pos 'dp-colorized-region-p extents))

(defun* dp-colorized-region-boundaries (&key
					(pos (point))
					(prop 'dp-colorized-region-p))
  (interactive)
  (dp-extents-at-with-prop prop nil (or pos (point))))
dp-colorized-region-boundaries


(let ((pos 207709))
  (dp-extents-at-with-prop 'dp-colorized-region nil (or pos (point))))
nil



========================
Tuesday June 29 2021
--
(cl-pp
    (list
     ;; Prompts:
     ;; user
     ;;;;;???(cons 'dp-shells-prompt-font-locker 'shell-prompt-face)
     (cons dp-shells-prompt-font-lock-regexp
           (list (list 1 'shell-prompt-face)
                 (list 2 'dp-journal-medium-attention-face)
                 (list 3 'dp-journal-medium-attention-face)
                 (list 4 'dp-journal-high-problem-face t t)))
)
(("^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" (1 shell-prompt-face) (2 dp-journal-medium-attention-face) (3 dp-journal-medium-attention-face) (4 dp-journal-high-problem-face t t)))

(cl-pp dp-shell-mode-font-lock-keywords)

(("^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" (1 shell-prompt-face)
(2 dp-journal-medium-attention-face)
(3 dp-journal-medium-attention-face)
(4 dp-journal-high-problem-face t t))
("^[0-9]+## " . dp-shell-root-prompt-face)
("^\\(^davep@vilya:\\)\\(.*$\\)$" (1 dp-shells-prompt-id-face)
(2 dp-shells-prompt-path-face))
("^[^
]*~:[0-9]+:.*$" . shell-uninteresting-face)
("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" .
font-lock-keyword-face)
("^[-_.\"A-Za-z0-9/+]+\\(: *\\|, line \\)[0-9]+:.*$" .
font-lock-function-name-face)
("\\(^[-_.\"A-Za-z0-9/+]+\\)\\(: *\\|, line \\)[0-9]+" 1
shell-output-2-face
t)
("^[-_.\"A-Za-z0-9/+]+\\(: *[0-9]+\\|, line [0-9]+\\)" 1 bold t)
("^[^
]+.*$" . shell-output-face))nil

(cl-pp
    (list
     ;; Prompts:
     ;; user
     ;;;;;???(cons 'dp-shells-prompt-font-locker 'shell-prompt-face)
     (cons dp-shells-prompt-font-lock-regexp
           (list (list 1 'shell-prompt-face)
                 (list 2 'dp-journal-medium-attention-face)
                 (list 3 'dp-journal-medium-attention-face)
                 (list 4 'dp-journal-high-problem-face t t)))
)
(("^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" (1 shell-prompt-face) (2 dp-journal-medium-attention-face) (3 dp-journal-medium-attention-face) (4 dp-journal-high-problem-face t t)))

(cl-pp dp-shell-mode-font-lock-keywords)

(("^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)" (1 shell-prompt-face)
(2 dp-journal-medium-attention-face)
(3 dp-journal-medium-attention-face)
(4 dp-journal-high-problem-face t t))
("^[0-9]+## " . dp-shell-root-prompt-face)
("^\\(^davep@vilya:\\)\\(.*$\\)$" (1 dp-shells-prompt-id-face)
(2 dp-shells-prompt-path-face))
("^[^
]*~:[0-9]+:.*$" . shell-uninteresting-face)
("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" .
font-lock-keyword-face)
("^[-_.\"A-Za-z0-9/+]+\\(: *\\|, line \\)[0-9]+:.*$" .
font-lock-function-name-face)
("\\(^[-_.\"A-Za-z0-9/+]+\\)\\(: *\\|, line \\)[0-9]+" 1
shell-output-2-face
t)
("^[-_.\"A-Za-z0-9/+]+\\(: *[0-9]+\\|, line [0-9]+\\)" 1 bold t)
("^[^
]+.*$" . shell-output-face))nil

 
========================
Wednesday June 30 2021
--
(format-kbd-macro 'encircle)

;; Simple way to make these:
;; 1) Record kbd macro
;; 2) M-x name-last-kbd-macro
;; 3) (format-kbd-macro 'name) on name from step 2 in temp buffer.
;; 4) Add a `defalias' like below using the string from step 3.
;;template (defalias '<name>
;;template   (read-kbd-macro
;;template    (concat "keys..."
;;template            " more keys.")))

(message "wtf")
"wtf"


(format-kbd-macro 'encircle)




C-s			;; isearch-forward
)			;; self-insert-command
RET			;; newline
DEL			;; backward-delete-char-untabify
SPC			;; self-insert-command
M-j			;; join-line
C-e			;; dp-brief-end
RET			;; newline
'cu			;; self-insert-command * 3
DEL			;; backward-delete-char-untabify
ircular)		;; self-insert-command * 8
2*<down>		;; dp-next-line

(kmacro-display 'dfdf)
"Macro: C-s ) RET DEL SPC M-j C-e RET 'circular) 2*<down>"

"Macro: C-s ) RET DEL SPC M-j C-e RET 'circular) 2*<down>"

(format-kbd-macro 'bubba)
"C-s ) RET DEL SPC M-j C-e RET 'circular) 2*<down>"

(format-kbd-macro 'bubba)
"C-s ) RET DEL SPC M-j C-e RET 'circular) 2*<down>"
(format-kbd-macro 'encirclex)
"C-s ) RET DEL SPC M-j C-e RET 'circular) 2*<down>"
(format-kbd-macro 'encircle)

(kmacro-display 'encircle)


!!!! @@@@@ !!!! @@@@@ !!!! @@@@@ !!!! @@@@@ !!!! @@@@@ !!!! @@@@@
??????????? why does
dpj-topic-list is a variable defined in ‘dp-journal.el’.
Its value is shown below.

Documentation:
Global topic list.

Value:
(("emacs.elisp" last-update: "2021-06-30T07:59:11")
 ("todo.tools" last-update: "2021-06-30T06:49:48")
 ("screeds.english.internet" last-update: "2021-06-28T12:47:01")
 ("emacs.elisp.dpj")
 ("utils")
 ("todo")
 ("toys.bluetooth.mifa-x17.review")
 ("politics")
 ("nordvpn")
 ("games")
 ("work")
 ("emacs.elisp.dp-sel2")
 ("utils.bugs.index-code")
 ("work.amd.tom")
 ("tmux")
 ("medical.pain")
 ("todo.openbox")
 ("medical.psychiatric")
 ("not-work")
 ("games.health")
 ("games.falcon-age.ui")
 ("doggo.speak")
 ("physics.simulation-hypothesis")
 ("zsh")
 ("security.passwords")
 ("mvsik.solos")
 ("ui.suckage.stackexchange.level:")
 ("ui.suckage.stackexchange.level:heavenly")
 ("stackexchange.e.g.suckassexchange.emacs")
 ("humor.emacs.You-know-you're-an-Emacs-geek-when")
 ("net.usb.usb.tethering")
 ("net.usb.tethering")
 ("security.passwords.google-drive")
 ("politics.yt")
 ("python.mode")
 ("bash.utils")
 ("todo.zsh")
 ("todo.vilya")
 ("avast-scams" last-update: "2021-06-15T00:46:50")
 ("cx")
 ("games.console")
 ("insults")
 ("games.controls")
 ("faux-clevernesses")
 ("yt.misc")
 ("yt.chris-squre")
 ("mvsik")
 ("security")
 ("python")
 ("games.crafting")
 ("posting.yt")
 ("mvisk.yt")
 ("mvisk.prog")
 ("screeds.programming.OAOO")
 ("mvisk")
 ("games.ui")
 ("politics.money")
 ("amd.management" last-update: "2020-10-21T10:43:47")
 ("amd.vpn" last-update: "2021-05-20T14:26:36")
 ("amd.work.python")
 ("amd.work.umrsh" last-update: "2020-09-24T20:20:00")
 ("amd.work.umrsh.zsh" last-update: "2020-11-04T10:39:00")
 ("assholiness" last-update: "2020-11-22T14:22:59")
 ("avast" last-update: "2021-06-13T07:40:10")
 ("bash" last-update: "2020-09-17T08:43:46")
 ("bash.completion" last-update: "2020-10-01T15:55:46")
 \.\.\.)

Get formatted and written as:
(setq dpj-topic-list
      '(("amd.management" last-update: "2020-10-21T10:43:47")
	("amd.vpn" last-update: "2021-05-20T14:26:36")
	("amd.work.python")
	("amd.work.umrsh" last-update: "2020-09-24T20:20:00")
	("amd.work.umrsh.zsh" last-update: "2020-11-04T10:39:00")
	("assholiness" last-update: "2020-11-22T14:22:59")
	("avast" last-update: "2021-06-13T07:40:10")
	("avast-scams" last-update: "2021-06-15T00:46:50")
	("bash" last-update: "2020-09-17T08:43:46")
	("bash.completion" last-update: "2020-10-01T15:55:46")
	...))
??????????????????????????????????????????????????????


========================
2021-06-30T22:57:21
--
PROMPT=$'%{$purple%}%n%{$reset_color%} in %{$limegreen%}%~%{$reset_color%}$(ruby_prompt_info " with%{$fg[red]%} " v g "%{$reset_color%}")$vcs_info_msg_0_%{$orange%} λ%{$reset_color%} '


PROMPT=$'$(ruby_prompt_info " with%{$fg[red]%} " v g "%{$reset_color%}")

PROMPT+='$(dp_decode_cmd_status --zsh '"%?"')>%f '




========================
Thursday July 01 2021
--
(cl-pp dpj-topic-list)

(("emacs.elisp" last-update: "2021-06-30T22:05:20")
("yt.mvsik" last-update: "2021-06-30T11:52:00")
(#("todo.tools" 0 10 (fontified t face dp-journal-topic-face)) last-update:
"2021-06-30T11:19:05")
(#("emacs.elisp.journal-mode" 0 24 (fontified t face dp-journal-topic-face)) last-update:
"2021-06-30T08:45:15")
(#("tmux" 0 4 (fontified t face dp-journal-topic-face)) last-update:
"2021-06-30T08:20:07")
(#("ponderables" 0 11 (fontified t)))
(#("screeds.english.internet" 0 24 (fontified nil)) last-update:
"2021-06-28T12:47:01")
(#("emacs.elisp.dpj" 0 15 (fontified nil)))
(#("utils" 0 5 (fontified nil)))
(#("todo" 0 4 (fontified nil)))
(#("toys.bluetooth.mifa-x17.review" 0 30 (fontified nil)))
(#("politics" 0 8 (fontified nil)))
(#("nordvpn" 0 7 (fontified nil)))
(#("games" 0 5 (fontified nil)))
(#("work" 0 4 (fontified nil)))
(#("emacs.elisp.dp-sel2" 0 19 (fontified nil)))
(#("utils.bugs.index-code" 0 21 (fontified nil)))
(#("work.amd.tom" 0 12 (fontified nil)))
(#("medical.pain" 0 12 (fontified nil)))
(#("todo.openbox" 0 12 (fontified nil)))
(#("medical.psychiatric" 0 19 (fontified nil)))
(#("not-work" 0 8 (fontified nil)))
(#("games.health" 0 12 (fontified nil)))
(#("games.falcon-age.ui" 0 19 (fontified nil)))
(#("doggo.speak" 0 11 (fontified nil)))
(#("physics.simulation-hypothesis" 0 29 (fontified nil)))
(#("zsh" 0 3 (fontified nil)))
(#("security.passwords" 0 18 (fontified nil)))
(#("mvsik.solos" 0 11 (fontified nil)))
(#("ui.suckage.stackexchange.level:" 0 31 (fontified nil)))
(#("ui.suckage.stackexchange.level:heavenly" 0 39 (fontified nil)))
(#("stackexchange.e.g.suckassexchange.emacs" 0 39 (fontified nil)))
(#("humor.emacs.You-know-you're-an-Emacs-geek-when" 0 46 (fontified nil)))
(#("net.usb.usb.tethering" 0 21 (fontified nil)))
(#("net.usb.tethering" 0 17 (fontified nil)))
(#("security.passwords.google-drive" 0 31 (fontified nil)))
(#("politics.yt" 0 11 (fontified nil)))
(#("python.mode" 0 11 (fontified nil)))
(#("bash.utils" 0 10 (fontified nil)))
(#("todo.zsh" 0 8 (fontified nil)))
(#("todo.vilya" 0 10 (fontified nil)))
(#("avast-scams" 0 11 (fontified nil)) last-update: "2021-06-15T00:46:50")
(#("cx" 0 2 (fontified nil)))
(#("games.console" 0 13 (fontified nil)))
(#("insults" 0 7 (fontified nil)))
(#("games.controls" 0 14 (fontified nil)))
(#("faux-clevernesses" 0 17 (fontified nil)))
(#("yt.misc" 0 7 (fontified nil)))
(#("yt.chris-squre" 0 14 (fontified nil)))
(#("mvsik" 0 5 (fontified nil)))
(#("security" 0 8 (fontified nil)))
(#("python" 0 6 (fontified nil)))
(#("games.crafting" 0 14 (fontified nil)))
(#("posting.yt" 0 10 (fontified nil)))
(#("mvisk.yt" 0 8 (fontified nil)))
(#("mvisk.prog" 0 10 (fontified nil)))
(#("screeds.programming.OAOO" 0 24 (fontified nil)))
(#("mvisk" 0 5 (fontified nil)))
(#("games.ui" 0 8 (fontified nil)))
(#("politics.money" 0 14 (fontified t face dp-journal-topic-face)))
("amd.management" last-update: "2020-10-21T10:43:47")
("amd.vpn" last-update: "2021-05-20T14:26:36")
("amd.work.python")
("amd.work.umrsh" last-update: "2020-09-24T20:20:00")
("amd.work.umrsh.zsh" last-update: "2020-11-04T10:39:00")
("assholiness" last-update: "2020-11-22T14:22:59")
("avast" last-update: "2021-06-13T07:40:10")
("bash" last-update: "2020-09-17T08:43:46")
("bash.completion" last-update: "2020-10-01T15:55:46")
\.\.\.)nil


(setq dpj-topic-list
      '(("emacs.elisp" last-update: "2021-06-30T22:05:20")
	("yt.mvsik" last-update: "2021-06-30T11:52:00")
	(#("todo.tools" 0 10 (fontified t face dp-journal-topic-face)) last-update:
	 "2021-06-30T11:19:05")
	(#("emacs.elisp.journal-mode" 0 24 (fontified t face dp-journal-topic-face)) last-update:
	 "2021-06-30T08:45:15")
	(#("tmux" 0 4 (fontified t face dp-journal-topic-face)) last-update:
	 "2021-06-30T08:20:07")
	(#("ponderables" 0 11 (fontified t)))
	(#("screeds.english.internet" 0 24 (fontified nil)) last-update:
	 "2021-06-28T12:47:01")
	(#("emacs.elisp.dpj" 0 15 (fontified nil)))
	(#("utils" 0 5 (fontified nil)))
	(#("todo" 0 4 (fontified nil)))
	(#("toys.bluetooth.mifa-x17.review" 0 30 (fontified nil)))
	(#("politics" 0 8 (fontified nil)))
	(#("nordvpn" 0 7 (fontified nil)))
	(#("games" 0 5 (fontified nil)))
	(#("work" 0 4 (fontified nil)))
	(#("emacs.elisp.dp-sel2" 0 19 (fontified nil)))
	(#("utils.bugs.index-code" 0 21 (fontified nil)))
	(#("work.amd.tom" 0 12 (fontified nil)))
	(#("medical.pain" 0 12 (fontified nil)))
	(#("todo.openbox" 0 12 (fontified nil)))
	(#("medical.psychiatric" 0 19 (fontified nil)))
	(#("not-work" 0 8 (fontified nil)))
	(#("games.health" 0 12 (fontified nil)))
	(#("games.falcon-age.ui" 0 19 (fontified nil)))
	(#("doggo.speak" 0 11 (fontified nil)))
	(#("physics.simulation-hypothesis" 0 29 (fontified nil)))
	(#("zsh" 0 3 (fontified nil)))
	(#("security.passwords" 0 18 (fontified nil)))
	(#("mvsik.solos" 0 11 (fontified nil)))
	(#("ui.suckage.stackexchange.level:" 0 31 (fontified nil)))
	(#("ui.suckage.stackexchange.level:heavenly" 0 39 (fontified nil)))
	(#("stackexchange.e.g.suckassexchange.emacs" 0 39 (fontified nil)))
	(#("humor.emacs.You-know-you're-an-Emacs-geek-when" 0 46 (fontified nil)))
	(#("net.usb.usb.tethering" 0 21 (fontified nil)))
	(#("net.usb.tethering" 0 17 (fontified nil)))
	(#("security.passwords.google-drive" 0 31 (fontified nil)))
	(#("politics.yt" 0 11 (fontified nil)))
	(#("python.mode" 0 11 (fontified nil)))
	(#("bash.utils" 0 10 (fontified nil)))
	(#("todo.zsh" 0 8 (fontified nil)))
	(#("todo.vilya" 0 10 (fontified nil)))
	(#("avast-scams" 0 11 (fontified nil)) last-update: "2021-06-15T00:46:50")
	(#("cx" 0 2 (fontified nil)))
	(#("games.console" 0 13 (fontified nil)))
	(#("insults" 0 7 (fontified nil)))
	(#("games.controls" 0 14 (fontified nil)))
	(#("faux-clevernesses" 0 17 (fontified nil)))
	(#("yt.misc" 0 7 (fontified nil)))
	(#("yt.chris-squre" 0 14 (fontified nil)))
	(#("mvsik" 0 5 (fontified nil)))
	(#("security" 0 8 (fontified nil)))
	(#("python" 0 6 (fontified nil)))
	(#("games.crafting" 0 14 (fontified nil)))
	(#("posting.yt" 0 10 (fontified nil)))
	(#("mvisk.yt" 0 8 (fontified nil)))
	(#("mvisk.prog" 0 10 (fontified nil)))
	(#("screeds.programming.OAOO" 0 24 (fontified nil)))
	(#("mvisk" 0 5 (fontified nil)))
	(#("games.ui" 0 8 (fontified nil)))
	(#("politics.money" 0 14 (fontified t face dp-journal-topic-face)))
	("amd.management" last-update: "2020-10-21T10:43:47")
	("amd.vpn" last-update: "2021-05-20T14:26:36")
	("amd.work.python")
	("amd.work.umrsh" last-update: "2020-09-24T20:20:00")
	("amd.work.umrsh.zsh" last-update: "2020-11-04T10:39:00")
	("assholiness" last-update: "2020-11-22T14:22:59")
	("avast" last-update: "2021-06-13T07:40:10")
	("bash" last-update: "2020-09-17T08:43:46")
	("bash.completion" last-update: "2020-10-01T15:55:46"))

      (cl-pp dpj-topic-list)

(("emacs.elisp" last-update: "2021-06-30T22:05:20")
 ("yt.mvsik" last-update: "2021-06-30T11:52:00")
 (#("todo.tools" 0 10 (fontified t face dp-journal-topic-face)) last-update:
  "2021-06-30T11:19:05")
 (#("emacs.elisp.journal-mode" 0 24 (fontified t face dp-journal-topic-face)) last-update:
  "2021-06-30T08:45:15")
 (#("tmux" 0 4 (fontified t face dp-journal-topic-face)) last-update:
  "2021-06-30T08:20:07")
 (#("ponderables" 0 11 (fontified t)))
 (#("screeds.english.internet" 0 24 (fontified nil)) last-update:
  "2021-06-28T12:47:01")
 (#("emacs.elisp.dpj" 0 15 (fontified nil)))
 (#("utils" 0 5 (fontified nil)))
 (#("todo" 0 4 (fontified nil)))
 (#("toys.bluetooth.mifa-x17.review" 0 30 (fontified nil)))
 (#("politics" 0 8 (fontified nil)))
 (#("nordvpn" 0 7 (fontified nil)))
 (#("games" 0 5 (fontified nil)))
 (#("work" 0 4 (fontified nil)))
 (#("emacs.elisp.dp-sel2" 0 19 (fontified nil)))
 (#("utils.bugs.index-code" 0 21 (fontified nil)))
 (#("work.amd.tom" 0 12 (fontified nil)))
 (#("medical.pain" 0 12 (fontified nil)))
 (#("todo.openbox" 0 12 (fontified nil)))
 (#("medical.psychiatric" 0 19 (fontified nil)))
 (#("not-work" 0 8 (fontified nil)))
 (#("games.health" 0 12 (fontified nil)))
 (#("games.falcon-age.ui" 0 19 (fontified nil)))
 (#("doggo.speak" 0 11 (fontified nil)))
 (#("physics.simulation-hypothesis" 0 29 (fontified nil)))
 (#("zsh" 0 3 (fontified nil)))
 (#("security.passwords" 0 18 (fontified nil)))
 (#("mvsik.solos" 0 11 (fontified nil)))
 (#("ui.suckage.stackexchange.level:" 0 31 (fontified nil)))
 (#("ui.suckage.stackexchange.level:heavenly" 0 39 (fontified nil)))
 (#("stackexchange.e.g.suckassexchange.emacs" 0 39 (fontified nil)))
 (#("humor.emacs.You-know-you're-an-Emacs-geek-when" 0 46 (fontified nil)))
 (#("net.usb.usb.tethering" 0 21 (fontified nil)))
 (#("net.usb.tethering" 0 17 (fontified nil)))
 (#("security.passwords.google-drive" 0 31 (fontified nil)))
 (#("politics.yt" 0 11 (fontified nil)))
 (#("python.mode" 0 11 (fontified nil)))
 (#("bash.utils" 0 10 (fontified nil)))
 (#("todo.zsh" 0 8 (fontified nil)))
 (#("todo.vilya" 0 10 (fontified nil)))
 (#("avast-scams" 0 11 (fontified nil)) last-update: "2021-06-15T00:46:50")
 (#("cx" 0 2 (fontified nil)))
 (#("games.console" 0 13 (fontified nil)))
 (#("insults" 0 7 (fontified nil)))
 (#("games.controls" 0 14 (fontified nil)))
 (#("faux-clevernesses" 0 17 (fontified nil)))
 (#("yt.misc" 0 7 (fontified nil)))
 (#("yt.chris-squre" 0 14 (fontified nil)))
 (#("mvsik" 0 5 (fontified nil)))
 (#("security" 0 8 (fontified nil)))
 (#("python" 0 6 (fontified nil)))
 (#("games.crafting" 0 14 (fontified nil)))
 (#("posting.yt" 0 10 (fontified nil)))
 (#("mvisk.yt" 0 8 (fontified nil)))
 (#("mvisk.prog" 0 10 (fontified nil)))
 (#("screeds.programming.OAOO" 0 24 (fontified nil)))
 (#("mvisk" 0 5 (fontified nil)))
 (#("games.ui" 0 8 (fontified nil)))
 (#("politics.money" 0 14 (fontified t face dp-journal-topic-face)))
 ("amd.management" last-update: "2020-10-21T10:43:47")
 ("amd.vpn" last-update: "2021-05-20T14:26:36")
 ("amd.work.python")
 ("amd.work.umrsh" last-update: "2020-09-24T20:20:00")
 ("amd.work.umrsh.zsh" last-update: "2020-11-04T10:39:00")
 ("assholiness" last-update: "2020-11-22T14:22:59")
 ("avast" last-update: "2021-06-13T07:40:10")
 ("bash" last-update: "2020-09-17T08:43:46")
 ("bash.completion" last-update: "2020-10-01T15:55:46")
 \.\.\.)nil



 (setq dpj-topic-list
      '(("emacs.elisp" last-update: "2021-06-30T22:05:20")
	("yt.mvsik" last-update: "2021-06-30T11:52:00")
	(#("todo.tools" 0 10 (fontified t face dp-journal-topic-face)) last-update:
	 "2021-06-30T11:19:05")
	(#("emacs.elisp.journal-mode" 0 24 (fontified t face dp-journal-topic-face)) last-update:
	 "2021-06-30T08:45:15")
	(#("tmux" 0 4 (fontified t face dp-journal-topic-face)) last-update:
	 "2021-06-30T08:20:07")
	(#("ponderables" 0 11 (fontified t)))
	(#("screeds.english.internet" 0 24 (fontified nil)) last-update:
	 "2021-06-28T12:47:01")
	(#("emacs.elisp.dpj" 0 15 (fontified nil)))
	(#("utils" 0 5 (fontified nil)))
	(#("todo" 0 4 (fontified nil)))
	(#("toys.bluetooth.mifa-x17.review" 0 30 (fontified nil)))
	(#("politics" 0 8 (fontified nil)))
	(#("nordvpn" 0 7 (fontified nil)))
	(#("games" 0 5 (fontified nil)))
	(#("work" 0 4 (fontified nil)))
	(#("emacs.elisp.dp-sel2" 0 19 (fontified nil)))
	(#("utils.bugs.index-code" 0 21 (fontified nil)))
	(#("work.amd.tom" 0 12 (fontified nil)))
	(#("medical.pain" 0 12 (fontified nil)))
	(#("todo.openbox" 0 12 (fontified nil)))
	(#("medical.psychiatric" 0 19 (fontified nil)))
	(#("not-work" 0 8 (fontified nil)))
	(#("games.health" 0 12 (fontified nil)))
	(#("games.falcon-age.ui" 0 19 (fontified nil)))
	(#("doggo.speak" 0 11 (fontified nil)))
	(#("physics.simulation-hypothesis" 0 29 (fontified nil)))
	(#("zsh" 0 3 (fontified nil)))
	(#("security.passwords" 0 18 (fontified nil)))
	(#("mvsik.solos" 0 11 (fontified nil))))
	(#("ui.suckage.stackexchange.level:" 0 31 (fontified nil)))
	(#("ui.suckage.stackexchange.level:heavenly" 0 39 (fontified nil)))
	(#("stackexchange.e.g.suckassexchange.emacs" 0 39 (fontified nil)))
	(#("humor.emacs.You-know-you're-an-Emacs-geek-when" 0 46 (fontified nil)))
	(#("net.usb.usb.tethering" 0 21 (fontified nil)))
	(#("net.usb.tethering" 0 17 (fontified nil)))
	(#("security.passwords.google-drive" 0 31 (fontified nil)))
	(#("politics.yt" 0 11 (fontified nil)))
	(#("python.mode" 0 11 (fontified nil)))
	(#("bash.utils" 0 10 (fontified nil)))
	(#("todo.zsh" 0 8 (fontified nil)))
	(#("todo.vilya" 0 10 (fontified nil)))
	(#("avast-scams" 0 11 (fontified nil)) last-update: "2021-06-15T00:46:50")
	(#("cx" 0 2 (fontified nil)))
	(#("games.console" 0 13 (fontified nil)))
	(#("insults" 0 7 (fontified nil)))
	(#("games.controls" 0 14 (fontified nil)))
	(#("faux-clevernesses" 0 17 (fontified nil)))
	(#("yt.misc" 0 7 (fontified nil)))
	(#("yt.chris-squre" 0 14 (fontified nil)))
	(#("mvsik" 0 5 (fontified nil)))
	(#("security" 0 8 (fontified nil)))
	(#("python" 0 6 (fontified nil)))
	(#("games.crafting" 0 14 (fontified nil)))
	(#("posting.yt" 0 10 (fontified nil)))
	(#("mvisk.yt" 0 8 (fontified nil)))
	(#("mvisk.prog" 0 10 (fontified nil)))
	(#("screeds.programming.OAOO" 0 24 (fontified nil)))
	(#("mvisk" 0 5 (fontified nil)))
	(#("games.ui" 0 8 (fontified nil)))
	(#("politics.money" 0 14 (fontified t face dp-journal-topic-face)))
	("amd.management" last-update: "2020-10-21T10:43:47")
	("amd.vpn" last-update: "2021-05-20T14:26:36")
	("amd.work.python")
	("amd.work.umrsh" last-update: "2020-09-24T20:20:00")
	("amd.work.umrsh.zsh" last-update: "2020-11-04T10:39:00")
	("assholiness" last-update: "2020-11-22T14:22:59")
	("avast" last-update: "2021-06-13T07:40:10")
	("bash" last-update: "2020-09-17T08:43:46")
	("bash.completion" last-update: "2020-10-01T15:55:46"))


      (cl-pp dpj-topic-list)

========================
2021-07-01T09:13:32
--

========================
Saturday July 03 2021
--
(symbol-plist 'mingus)

(autoload ("mingus-stays-home" nil t nil)
custom-group ((mingus-faces custom-group) (mingus-timer-interval
custom-variable) (mingus-use-caching
custom-variable) (mingus-mpd-config-file
custom-variable) (mingus-mpd-playlist-dir
custom-variable) (mingus-fold-case
custom-variable) (mingus-mode-line
custom-group) (mingus-mode-line-separator
custom-variable) (mingus-use-ido-mode-p
custom-variable) (mingus-use-mouse-p
custom-variable) (mingus-mpd-env-set-p
custom-variable) (mingus-mpd-host
custom-variable) (mingus-mpd-port
custom-variable) (mingus-mpd-root
custom-variable) (mingus-playlist-directory
custom-variable) (mingus-seek-amount
custom-variable) (mingus-format-song-function
custom-variable) (mingus-stream-alist
custom-variable) (mingus-podcast-alist
custom-variable) (mingus-wait-for-update-interval
custom-variable) (mingus-dired-add-keys
custom-variable) (mingus-bookmarks
custom-variable) (mingus-stays-home custom-group) (mingus-burns
custom-group)) group-documentation "Group customization for
mingus mpd interface" event-symbol-element-mask (mingus 0)
event-symbol-elements (mingus) modifier-cache ((0 . mingus))
defalias-fset-function #[128 "\300\301\302#\207" [apply
advice--defalias-fset #[128 "\300\301\302#\207" [apply
ad--defalias-fset nil nil] 5 nil] nil] 5 nil]
ad-advice-info ((active . t) (advicefunname
. ad-Advice-mingus) (after (mingus-dnd-injection nil t (advice
lambda nil (mingus-inject-dnd-action 'mingus-add-url)))) (cache
#[(ad--addoit-function &optional set-variables) "\303
!\304\305!\210)\207" [ad-return-value ad--addoit-function
set-variables nil mingus-inject-dnd-action mingus-add-url] 2] nil
nil (mingus-dnd-injection) fun2 (&optional set-variables) nil))
function-documentation (advice--make-docstring 'mingus))


(global-unset-key [(control meta ?m)])
nil

(global-unset-key [(control meta ?p)])
nil

(global-set-key [(control meta ?m)] 'mingus)
(global-set-key [(control meta ?p)] 'dp-mingus-random-album)

========================
2021-07-03T12:57:20
--

Global Bindings Starting With C-x v:
key             binding
---             -------

C-x v +		vc-update
C-x v =		vc-diff
C-x v D		vc-root-diff
C-x v G		vc-ignore
C-x v I		vc-log-incoming
C-x v L		vc-print-root-log
C-x v M		Prefix Command
C-x v O		vc-log-outgoing
C-x v P		vc-push
C-x v a		vc-update-change-log
C-x v b		vc-switch-backend
C-x v d		vc-dir
C-x v g		vc-annotate
C-x v h		vc-region-history
C-x v i		vc-register
C-x v l		vc-print-log
C-x v m		vc-merge
C-x v r		vc-retrieve-tag
C-x v s		vc-create-tag
C-x v u		vc-revert
C-x v v		vc-next-action
C-x v x		vc-delete-file
C-x v ~		vc-revision-other-window

C-x v M D	vc-diff-mergebase
C-x v M L	vc-log-mergebase

[back]

========================
Tuesday July 06 2021
--

(dp-setup-bookmarks)

(dp-nuke-newline
 (shell-command-to-string
  "mk-persistent-dropping-name.sh --use-project-as-suffix emacs.bmk"))
"EExec_parse: enter$@>--use-project-as-suffix emacs.bmk<
EExec_parse:$1>--use-project-as-suffix<
EExec_parse: exit$@>--use-project-as-suffix emacs.bmk<
/home/davep/droppings/persist/emacs.bmk/vilya.-"

"/home/davep/droppings/persist/emacs.bmk/vilya.-"




========================
Tuesday July 13 2021
--
(defvar zuzz 'i-am-zuzz2)
zuzz
i-am-zuzz2

i-am-zuzz2

i-am-zuzz2

(makunbound 'zuzz)
zuzz
zuzz
new-zuzz

variable-history

("variable-history" "zuzz")

(makunbound 'variable-history)
variable-history



(defun zuzzf (&optional zuzz-val)
  (interactive "Ssym? ")
  (defvar zuzz zuzz-val))



========================
Tuesday July 20 2021
--
========================
2021-07-20T16:10:58
--
(require 'ggtags)
ggtags

(require 'xgtags)
xgtags




(defun dp-force-fucking-umr-c-mode()
  (interactive)
  (let* ((proj (getenv "PROJECT"))
	 (umrp (and proj (string= proj "umr"))))
    (when umrp
      (setq dp-default-c-style-name "dp-umr-c-style")
      (setq dp-default-c-style dp-umr-c-style)
      ))
  )

(dp-force-fucking-umr-c-mode)
((dp-c-using-kernel-style-p . t) (dp-c-indent-for-comment-prefix . "") (dp-use-stupid-kernel-struct-indentation-p) (dp-c-like-mode-default-indent-tabs-mode-p . t) (dp-c-fill-statement-minimal-indentation-p) (dp-lang-use-c-new-file-template-p) (dp-c-style-tab-width . 4) (dp-trailing-whitespace-use-trailing-ws-font-p) (dp-use-space-before-tab-font-lock-p . t) (dp-use-too-many-spaces-font-p . t) (dp-use-ugly-ass-pointer-style-p . t) (c-insert-tab-function . dp-phys-tab) ...)

(cl-pp dp-default-c-style)

((dp-c-using-kernel-style-p . t)
 (dp-c-indent-for-comment-prefix . "")
 (dp-use-stupid-kernel-struct-indentation-p)
 (dp-c-like-mode-default-indent-tabs-mode-p . t)
 (dp-c-fill-statement-minimal-indentation-p)
 (dp-lang-use-c-new-file-template-p)
 (dp-c-style-tab-width . 4)
 (dp-trailing-whitespace-use-trailing-ws-font-p)
 (dp-use-space-before-tab-font-lock-p . t)
 (dp-use-too-many-spaces-font-p . t)
 (dp-use-ugly-ass-pointer-style-p . t)
 (c-insert-tab-function . dp-phys-tab)
 (c-tab-always-indent . t)
 (c-basic-offset . 4)
 (c-comment-only-line-offset . 0)
 (c-cleanup-list scope-operator
		 empty-defun-braces
		 defun-close-semi
		 list-close-comma
		 brace-else-brace
		 brace-elseif-brace
		 knr-open-brace)
 (c-offsets-alist (arglist-intro . +)
		  (substatement-open . 0)
		  (inline-open . 0)
		  (cpp-macro-cont . +)
		  (access-label . /)
		  (inclass . +)
		  (statement-block-intro . +)
		  (knr-argdecl-intro . 0)
		  (substatement-label . 0)
		  (label . 0)
		  (statement-cont . +)
		  (case-label . 0))
 (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
 (c-echo-syntactic-information-p)
 (c-indent-comments-syntactically-p . t)
 (c-hanging-braces-alist (brace-list-open . ignore)
			 (brace-list-close . ignore)
			 (brace-list-intro . ignore)
			 (substatement-open after)
			 (brace-entry-open . ignore))
 (c-hanging-colons-alist (member-init-intro before)))nil





========================
Wednesday July 21 2021
--
(defvar dp-input-bup dp-input)
dp-input-bup

dp-input
"[?2004l
[1m[7m%[m[1m[m                                                                                        "


dp-input1
"ccd .[?2004l
[1m[7m%[m[1m[m                                                                                        "

dp-input2
"ccd .[?2004l
[1m[7m%[m[1m[m                                                                                        "

(string= dp-input1 dp-input2)
t

in shell zsh prompt and dirtrack issue:
current:
(setq dp-dirtrack-regexp
      (format
       ;; Switching to zsh caused this to fail.  It looked like it was just
       ;; sending garbage with no prompt/dir.  However, there was a
       ;; prompt/dir, it was just not at the beginning of the reply string.
       ;; So, after [too] much wailing and gnashing of teeth, all it too was
       ;; the removal of the ^ before <usr>@<host>.  `concat' makes it easier
       ;; (for me) to see and doc the components.
       (concat "%s@%s:"
	       "\\([~/][[:graph:]]*\\)" ; potential funky prompt graphical chars.
	       "\\(.*\\)$"		;possible terminators
	       )
       (user-login-name) (dp-short-hostname)))

(setq dp-dirtrack-regexp
      (format
       ;; Switching to zsh caused this to fail.  It looked like it was just
       ;; sending garbage with no prompt/dir.  However, there was a
       ;; prompt/dir, it was just not at the beginning of the reply string.
       ;; So, after [too] much wailing and gnashing of teeth, all it too was
       ;; the removal of the ^ before <usr>@<host>.  `concat' makes it easier
       ;; (for me) to see and doc the components.
       (concat "%s@%s:"
	       "\\([~/][[:graph:]]*\\)" ; potential funky prompt graphical chars.
	       "\\(.*\\)$"		;possible terminators
	       )
       (user-login-name) (dp-short-hostname)))
n

dp-input

dpx-dirtrack-list-using-regexp
"davep@vilya
:\\([~/][[:graph:]]*\\)\\(.*\\)$"

dpx-dirtrack-list
("davep@vilya
:\\([~/][[:graph:]]*\\)\\(.*\\)$" 1)

dpx-input-echo
"[A[m[m[m[J[1mdavep@vilya:~/tmp[m 
[36m(3:zsh) 3000>[39m "

(nth 0 dpx-dirtrack-list)
"davep@vilya
:\\([~/][[:graph:]]*\\)\\(.*\\)$"


(string-match "davep@vilya\\([~/][[:graph:]]*\\)\\(.*\\)$" dpx-input-echo)
21

nil

nil

nil

(or (getenv "HOSTNAME")
       (shell-command-to-string "hostname")
       (or default "***LOCALHOST***"))
"vilya
"

(shell-command-to-string "hostname")
"vilya
"
(or (getenv "HOST")
      (car (split-string
	    (dp-hostname)
	    ?.)))
(dp-hostname)
"vilya
"
(getenv "HOST")
nil
(getenv "HOSTNAME")
nil
(dp-short-hostname)

"vilya
"
(split-string (dp-hostname) "\\.")
("vilya
")
(dp-hostname)
"vilya
"

(split-string (dp-hostname) "\\(\\.\\|\\|$\\)")
("vilya" "
" "")

("vilya
")

(car
 (split-string "vilya
 " "\\(\\.\\|\\|\n\\)"))
"vilya"

 ("vilya" " ")

("vilya
 ")


("vilya
")
(split-string (dp-hostname) "\\(\\.\\|\\|
\\)")
("vilya" "")

(shell-command-to-string "hostname")
"vilya
"

(dp-hostname)




;installed (defun dp-short-hostname ()
;installed    (or (getenv "HOST")
;installed        (car (split-string
;installed 	     (dp-hostname)
;installed 	     "\\(\\."\\|\\|\\)"))
;installed "
;installed (defun dp-hostname (&optional default)
;installed   "Get a hostname, whatever the system gives us."
;installed   (let ((hostname
;installed 	 (or (getenv "HOSTNAME")
;installed 	     (shell-command-to-string "hostname")
;installed 	     (or default "***LOCALHOST***"))))
;installed     (car
;installed      (split-string hostname "\\(\\.\\|\\|\n\\)"))))
;installed dp-hostname

;installed (dp-hostname)
;installed "vilya"

;installed (defun dp-short-hostname ()
;installed    (or (getenv "HOST")
;installed        (car (split-string
;installed 	     "a.b.c.d
;installed "
;installed 	     "\\."))))
;installed dp-short-hostname

(dp-hostname)
"vilya"

"vilya"

(dp-short-hostname)
"vilya"

"vilya"

"vilya"

"a"

"vilya"



========================
Tuesday July 27 2021
--
(append '(1 2 3) '(a b c) nil)
(1 2 3 a b c)

(cons 'a '(1 2 3))
(a 1 2 3)


(1 2 3 a b c)

(append '(1 2 3) nil '(a b c) nil)
(1 2 3 a b c)


(setq full-plist (append
		  '(re quired)
		  '(prop list)
		  (when (= 0 0)
		    '(invisible))))
(re quired prop list invisible)

(defun dp-invisible-color-p (color)
  "Return t if COLOR implies invisibility."
  (and color
       (or (and (integerp color)
		(<= color 0))
	   (eq color 'invisible)
	   (eq color '-))
       'invisible))

(dp-invisible-color-p 'invisible)
invisible
(dp-invisible-color-p '-)
invisible
(dp-invisible-color-p 0)
invisible
(dp-invisible-color-p -1)
invisible
(dp-invisible-color-p 1)
nil

(dp-invisible-color-p '-)
invisible


(setq full-plist (append
		  '(re quired)
		  '(prop list)
		  (dp-invisible-color-p '-)))
(re quired prop list . invisible)

		  (when (= 0 0)
		    '(invisible))))
(setq buffer-invisibility-spec t)

(add-to-invisibility-spec '(dp-invis t))
HEREvvvv
(setq full-plist (append
		  '(re quired)
		  '(prop list)
		  (when (= 0 0)
		    '(invisible))))
(re quired prop list invisible)
^^^^^HERE

(re quired prop list invisible)

(setq full-plist (append
		  '(re quired)
		  '(prop list)
		  '(nil)))
(re quired prop list nil)

		  (dp-invisible-color-p '-)))

(append '(a 1 2) '(nil))
(a 1 2 nil)

(a 1 2 a)

(a 1 2)

(a 1 2 . t)

(a 1 2)

buffer-invisibility-spec
t

;installed (cl-pe '
;installed (defmacro dp-with-current-buffer (buffer &rest forms)
;installed   "Exec FORMS in `dp-get-buffer'.  A *functional* language? Sigh."
;installed   `(with-current-buffer (dp-get-buffer ,buffer)
;installed      ,@forms))
;installed )

;installed   (put 'dp-with-current-buffer 'lisp-indent-function
;installed        (get 'with-current-buffer 'lisp-indent-function))

;installed (defmacro dp-with-current-buffer (buffer &rest forms)
;installed   "Exec FORMS in `dp-get-buffer'.  A *functional* language? Sigh."
;installed   `(with-current-buffer (dp-get-buffer ,buffer)
;installed      ,@forms))
;installed dp-with-current-buffer


;installed (defalias 'dp-with-current-buffer
;installed   (cons 'macro
;installed 	(function
;installed 	 (lambda (buffer &rest forms)
;installed 	   "Exec FORMS in `dp-get-buffer'.  A *functional* language? Sigh."
;installed 	   (cons 'with-current-buffer
;installed 		 (cons (list 'dp-get-buffer buffer) forms))))))nil



;installed (defalias 'dp-with-current-buffer
;installed   (cons 'macro
;installed 	(function
;installed 	 (lambda (buffer &rest forms)
;installed 	   "Exec FORMS in `dp-get-buffer'.  A *functional* language? Sigh."
;installed 	   (cons 'with-current-buffer
;installed 		 (cons (list 'dp-get-buffer buffer) forms))))))nil

;installed (cl-pe '
;installed  (dp-with-current-buffer nil
;installed      (save-excursion
;installed        (goto-char (point-max))
;installed        (insert "FTW!")))

;installed  )

;installed (save-current-buffer (set-buffer (dp-get-buffer nil))
;installed 		     (save-excursion (goto-char (point-max)) (insert "FTW!")))nil



;installed (save-current-buffer (set-buffer (dp-get-buffer nil))
;installed 		     (save-excursion (goto-char (point-max)) (insert "FTW!")))
;installed nil




;installed (save-current-buffer (set-buffer (dp-get-buffer buffer))
;installed 		     (save-excursion
;installed 		       (goto-char
;installed 			(point-max))
;installed 		       (insert "FTW!")))

 (dp-with-current-buffer "*scratch*"
     (save-excursion
       (goto-char (point-max))
       (insert "\n!FTW!\n")))
nil



 (dp-with-current-buffer nil
     (save-excursion
       (goto-char (point-max))
       (insert "\n!FTW!\n")))
 
nil

!FTW!

========================
Sunday August 01 2021
--
dp-zsh-prompt-regexp
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\)?\\([#>]\\|<.*>\\)"

dp-bash-prompt-regexp
"^\\(?:(.*)\\s-*\\)?[0-9]+\\([/<]\\(?:[0-9]+\\|spayshul\\)\\)?\\([#>]\\|<.*>\\)"
(regexp-quote "(gdb) ")
"(gdb) "

(getenv "PROMPT")
nil
(getenv "PS1")
nil
(getenv "PATH")
"/home/davep/bin/override:/home/davep/bin:/home/davep/local/bin:/home/davep/yokel/sbin:/home/davep/yokel/bin:/home/davep/.cargo/bin:/home/davep/lib/pylib:/home/davep/bin.primitive:/etc/alternatives:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin:/home/davep/perl5/bin:/home/davep/.oh-my-zsh:/home/davep/.rc/zsh:/usr/games:/usr/local/games:/snap/bin:/usr/bin/X11:/opt/p4v-2021.2.2138880/bin:/opt/p4v/bin:/home/davep/bin/last-resort"

nil

${PS1_prefix}\u@\h${PS1_1}:\w${PS1_path_suffix}\n${PS1_bang_pre}\!${PS1_bang_suff}${PS1_terminator}

(getenv "PS1_prefix")
nil
