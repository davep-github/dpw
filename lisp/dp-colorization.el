(message "loading dp-colorization...")

(defvar dp-colorization-background-extent-priority 0
  "Put background waaay back so it stomps on nothing.")

(defvar dp-colorization-extent-properties
  '(dp-extent-p t
    dp-colorized-p t)
  "These props should go on all of my colorization extents.")

(defun dp-color-to-face (color)
  "Convert a \"color\" \(string, face, etc\) to a face or NIL."
  (cond
   ((null color) nil)
   ((and color (facep color) color))
   ((dp-non-empty-string color)
    (list :background color))
   ((not (dp-non-empty-string color)) nil)
   (t nil)))

(defun dp-get-list-of-colorized-regions(&optional begin end)
  "Get the list of overlays (extents) at \(or point (point)."
  (setq-ifnil begin (point))
  (setq-ifnil end (point))
  (auto-overlays-in begin end
		    (list (lambda (prop pval)
			    (eq pval t))
			  'dp-colorized-region-p t)))

(defun dp-delete-regions (regions)
  (mapc (function
	 (lambda (region)
	   (delete-overlay region)))
	regions))

(defun dp-delete-colorized-regions (&optional begin end)
  (dp-delete-regions (dp-get-list-of-colorized-regions begin end)))

;; From XEmacs
;; (set-extent-property EXTENT PROPERTY VALUE)
(defun dp-overlay-put-prop (olay prop val)
  (overlay-put olay prop val))

(defun dp-overlay-get-prop (olay prop)
  (overlay-get olay prop))

(defun extent-properties (ext)
  (overlay-properties ext))

(defun extent-property (ext prop &optional default)
  (let ((props (extent-properties ext)))
    (if (plist-member props prop)
	(dp-overlay-get-prop ext prop)
      default)))

(defalias 'set-extent-property 'dp-overlay-put-property)

;; From XEmacs
;; (set-extent-properties EXTENT PLIST)
(defun set-extent-properties (olay prop-list)
  "Copped from XEmacs and implemented via Emacs' overlay system."
  (when prop-list
    (cl-loop for (key val) on prop-list by #'cddr
	     do
	     (dp-overlay-put-prop olay key val))))

;; (dp-make-extent FROM TO ID-PROP &rest PROPS)
(cl-defun dp-make-color-overlay (from to id-prop color buffer
				      &key prop-list
				      bounding-markers
				      front-advance rear-advance)
  "Make an overlay the way I like and the way I like to make it."
  (let ((begin (or from (point-min)))
	(end (or to (point-max)))
	;; These are required to make things work. prop-list will be
	;; appended.
	(required-plist (list id-prop t
			      'dp-extent-p t
			      'dp-source 'dp-make-color-overlay
			      'dp-extent-id id-prop
			      'dp-extent-type id-prop
			      'face color))
	olay)
    (when bounding-markers
      (cond
       ((memq bounding-markers '(begin both t))
	(setq begin (dp-mk-marker begin nil)))
       ((memq bounding-markers '(end both t))
	(setq end (dp-mk-marker end nil)))))
    (setq olay (make-overlay begin end
			     buffer
			     front-advance
	     		     rear-advance))
    (set-extent-properties olay (append required-plist prop-list))
    olay))

;; `make-extent' is a built-in function
;;   -- loaded from "/home/dpanarit/local/build/xemacs-21.5.34/src/extents.c"
;; (make-extent FROM TO &optional BUFFER-OR-STRING)

;; Documentation:
;; Make an extent for the range [FROM, TO) in BUFFER-OR-STRING.
;; BUFFER-OR-STRING defaults to the current buffer.  Insertions at point
;; TO will be outside of the extent; insertions at FROM will be inside the
;; extent, causing the extent to grow. (This is the same way that markers
;; behave.) You can change the behavior of insertions at the endpoints
;; using `set-extent-property'.  The extent is initially detached if both
;; FROM and TO are nil, and in this case BUFFER-OR-STRING defaults to nil,
;; meaning the extent is in no buffer and no string.

(defalias 'make-extent 'make-overlay)

(defvar dp-remote-file-colorization-info
  `(,dp-remote-file-regexp . dp-remote-buffer-face)
  "Remote file recognition regexp and default color")

(defvar dp-bmm-buffer-name-colorization-alist
  `(,dp-remote-file-colorization-info
;;    ("\\[" . dp-sudo-edit-bg-face)
    ("Man\\( apropos\\)?: " . font-lock-string-face)
    ("<dse>" . dp-sudo-edit-bg-face)
    ("\\*ssh-" . dp-remote-buffer-face)	; XEmacs
    (,(if (boundp 'dp-remote-file-regexp)
	 dp-remote-file-regexp
       "$^") . dp-remote-buffer-face)
    ("\\*Python\\*" . font-lock-variable-name-face))
  "Alist used to map buffer-name to display face.
A list of cons cells, where each cons cell is \(regexp . face\).
The regexp is matched against the buffer name.")

;;
;; XEmacs puts font lock info on the mode symbol. Kewl.
;; 
(defun dp-colorize-buffer-if (pred color &optional else-uncolorize-p
                              pred-args beg end)
  "Colourize the current buffer if PRED is non-nil."
  (interactive "P")
  (let* ((beg.end (dp-region-or... :beg beg :end end
                                   :bounder 'buffer-p))
         (beg (car beg.end))
         (end (cdr beg.end)))
    (if (dp-apply-or-value pred pred-args)
	(dp-buffer-bg-set-color (or color 'dp-default-read-only-face)
				(current-buffer)
				beg end)
      (when else-uncolorize-p
        (dp-uncolorize-region beg end t)))))

(defvar dp-remote-buffer-colorization-alist
  `(,dp-remote-file-colorization-info))

(defun dp-colorize-buffer-if-readonly (&optional color uncolorize-if-rw-p)
  (interactive "P")
  (dp-colorize-buffer-if buffer-read-only 
                         (or color 
                             'dp-default-read-only-face)
                         uncolorize-if-rw-p))

(defun dp-colorize-buffer-if-remote (&optional color buf)
  "Give buffers holding remote files a distinctive color."
  (interactive "P")
  (dp-colorize-buffer-if 'dp-remote-file-p 
                         (or color 
                             (dp-bmm-get-color-for-buf-name (current-buffer)))))

;; @todo experimenting with this.
;; similar functionality built in now.
;(require 'fdb)
;(setq debug-on-error t)

(dp-deflocal-permanent dp-colorize-region-default-color-index 0
  "Name says it all.")

(dp-deflocal-permanent dp-colorize-region-default-priority 100
  "Name says it all.")

(defvar dp-colorize-region-roll-colors t
  "Should `dp-colorize-region' increment the color after each invocation.")

(defvar dp-colorize-region-num-colors (length dp-colorize-region-faces))

(dp-deflocal dp-colorize-region-overwrite-existing-colors-p t
  "*What more can I say?")

(defun dp-invisible-color-p (color)
  "Return t if COLOR implies invisibility."
  (and color
       (eq color '-)))

(defun dp-colorize-roll-colors (&optional color)
  (interactive "P")
  (if (interactive-p)
      (setq dp-colorize-region-default-color-index
            (if color
                (prefix-numeric-value current-prefix-arg)
              0))
    (when (not (dp-invisible-color-p color))
      (when color
        (setq dp-colorize-region-default-color-index color))
      (setq dp-colorize-region-default-color-index
            (mod (1+ dp-colorize-region-default-color-index)
                 dp-colorize-region-num-colors)))))

(defun dp-invisible-face-p (face)
  (or (memq (car face) '(invisible invis))
      (memq (cdr face) '(invisible invis))))

(defun dp-get-color-and-face (color)
  "Convert COLOR index to colorization color and a face.
COLOR_INDEX can be <=0 or '- to indicate invisibility."
  (let* ((arg (cond
               ((and color (symbolp color)) nil)
               ((not color) dp-colorize-region-default-color-index)
               ((or (and (integerp color)
                         (<= color 0))
                    (eq color '-))
                'invis)
               (t (setq dp-colorize-region-default-color-index
                        (1- color)))))
         (face (cond
                ((and color (symbolp color)) color)
                ((integerp arg) (nth arg dp-colorize-region-faces))
                (t arg))))
    (cons arg face)))

(defun dp-region-is-colorized (from to)
  (dp-extent-with-property-exists 'dp-colorized-region-p from to nil))

(defun dp-colorize-pluck-color (&optional pos)
  "Grab color of colorized region at \(or pos \(point\)\)"
  (interactive "d")
  (let ((ext-list (dp-extents-at-with-prop 'dp-colorized-region-color-num))
        m)
    (if ext-list 
        (progn
          (setq dp-colorize-region-default-color-index
                (extent-property (car ext-list) 
                                 'dp-colorized-region-color-num))
          (setq m (format "Plucked color index %d." 
                          dp-colorize-region-default-color-index))
          ;; The face doesn't make it to the message area.
          (dp-make-extent0 m 0 (length m) 'dp-colorized-string 
                           'face (cdr (dp-get-color-and-face nil))
                           'duplicable t)
          (message m))
      (message "No colorized region at pos=%s" pos)
      (ding))))
  
(defun dp-colorize-region (color &optional beg end no-roll-colors-p 
                           overwrite-p
                           &rest props)
  "COLOR can be an integer index or a symbol representing a face.
This way a low priority background type object unless overridden in
PROPS."
  (interactive "P")
  (let* ((beg-end (dp-region-or... :bounder 'rest-or-all-of-line-p))
         (beg (or beg (car beg-end)))
         (end (or end (cdr beg-end)))
         (color-and-face (dp-get-color-and-face color))
         (arg (car color-and-face))
         extent
         (face (cdr color-and-face)))
    ;;(dmessage "beg: %s, end: %s" beg end)
    (setq overwrite-p (or overwrite-p 
                          dp-colorize-region-overwrite-existing-colors-p))
    (when (or overwrite-p 
              (not (dp-region-is-colorized beg end)))
      (unless (memq 'priority props)
        (setq props 
              (append props 
                      (list 'priority dp-colorize-region-default-priority))))
      (if (dp-invisible-face-p color-and-face)
          (setq face-sym 'invisible
                face-val 'y
                props (append props (list 'read-only t)))
        (setq face-sym 'face
              face-val face))
      ;; (setq extent (apply 'dp-make-extent beg end 'dp-colorized-region
      (setq extent
	    (dp-make-color-overlay
	     beg end 'dp-colorized-region-p face (current-buffer)
	     :prop-list
	     (append
	      (list 'dp-colorized-p t
		    'dp-colorized-region-p t  ; `region' is generic.
		    'dp-colorized-overlay-p t ; Specificity useful.
		    ;;'invisible 'dp-colorize-region
		    'dp-colorized-region-color-num arg
		    'dp-extent-search-key 'dp-colorized-region
		    'dp-extent-search-key2 (list 'dp-colorized-region-p arg))
	      props)))
      (when (and (not no-roll-colors-p)
		 arg ; ARG nil: called w/specific face, so we can't rotate.
		 (not (symbolp arg)) ; Don't roll when a color is passed in.
		 dp-colorize-region-roll-colors)
	(dp-colorize-roll-colors)))
    (dp-deactivate-mark)
    extent))

(defun dp-colorize-region-line-by-line (beg end color)
  (interactive "r\np")
  (let ((beginning-of-last-line (save-excursion 
                                  (goto-char end) 
                                  (line-end-position))))
  (goto-char beg)
  (while (<= (point) beginning-of-last-line)
    (dp-colorize-region color (line-beginning-position) (line-end-position)
                        nil nil nil
                        'dp-func 'dp-colorize-region-line-by-line
                        'dp-args (list beg end color))
    (setq color nil)                    ;So we actually roll colors.
    (next-line 1))))

(defun dp-set-colorized-extent-priority (arg &optional pos extents)
  (interactive "Npriority: \nXpos: ")
  (dp-set-extent-priority arg pos 'dp-colorized-region-p extents))

(defun* dp-unextent-region (region-id &optional beg end buf-or-string
				      (region-bounder 'buffer-p)
				      (verbose-p nil))
    (interactive "sregion-id(lisp expr): ")
  ;; Region first.
  (when verbose-p
    (message "dp-unextent-region: region-id: %s" region-id))
  (let* ((check-val-p (consp region-id))
         (prop (if check-val-p (car region-id) region-id))
         (prop-val (cdr-safe region-id))
         (num-deleted 0)
         (be (dp-region-or... :beg beg :end end :bounder region-bounder))
	 overlays olay)
    (when be
      (setq overlays (overlays-in (car be) (cdr be)))
      (while overlays
	(setq olay (car overlays))
	(when (or (not check-val-p)	; All overlays
		  (equal prop-val	; Overlays with matching props
			 (extent-property olay prop)))
	  (incf num-deleted)
	  (when verbose-p
	    (message "deleting extent>%s<" 
		     (dp-pretty-format-extent ext "; " nil)))
	  (delete-overlay olay))
	(setq overlays (cdr overlays))))))
      

(defun dp-uncolorize-region (&optional beg end preserve-current-color-index-p 
                             region-id)
  "Remove all of my colors in the region. 
The region is determined by `dp-region-or...'."
  (interactive)
  (dp-unextent-region (or region-id 'dp-colorized-region-p)
		      beg end nil 'line-p)
  (unless preserve-current-color-index-p
    (setq dp-colorize-region-default-color-index 0)))

;; C-u --> prompt for shrink-wrap and roll colors
;; current-prefix-arg < 0 --> color and prompt
(defun dpcml-get-args ()
  (let* ((pnv (prefix-numeric-value current-prefix-arg))
         (prompt-for-others (and current-prefix-arg
                                 (not (eq current-prefix-arg '-))
                                 (or (< pnv 0)
                                     (listp current-prefix-arg))))
         (regexp (read-from-minibuffer 
                  "regexp: "
                  nil nil nil 
                  dp-colorize-bracketing-regexps-history))
         (others (if prompt-for-others
                     (list
                      (progn
                        (dp-read-number "color index: " 'ints-only 1) ; color
                        (cond
                         ((not current-prefix-arg) nil)
                         ((eq current-prefix-arg '-) '-)
                         (t (abs pnv)))         ;color
                        nil                     ;end-regexp
                        (and prompt-for-others (y-or-n-p "Shrink-wrap? "))
                        (and prompt-for-others (y-or-n-p "Roll colors? "))))
                   '(:color nil))))
    ;; FUBAR'd. All `others' need &key keywords.
    (append (list regexp) others)))

(defvar dp-colorize-lines-shrink-wrap-p-default t
  "*Should we colorize just the matching text or the entire line?
We make this t by default because it's easy to force a full line match by
wrapping the match string in ^.* & .*$
We also make this a global default so I can change it when the mood strikes.")

(defun* dp-colorize-matching-lines (regexp &key
                                    color 
                                    end-regexp
                                    (shrink-wrap-p 
                                     dp-colorize-lines-shrink-wrap-p-default)
                                    roll-colors-p 
                                    non-matching-p
                                    quote-regexp-p
                                    (line-oriented-p t))
  "Colorize lines matching REGEXP.
SHRINK-WRAP-P says to only colorize the exact match. Add ^.* && .*$ to get
the entire line.
END-REGEXP - If given, colorize all lines from REGEXP to END-REGEXP.
See `dpcml-get-args' for details of the following:
COLOR - the color to use. 
ROLL-COLORS-P - make each match a different color.
NON-MATCHING-P - ??? Doesn't seem to be used."
  ;; We use `read-from-minibuffer' so we can use our own history list.
  (interactive (dpcml-get-args))
  (let ((starting-point (point))
        (num-matches 0)
        (pair-matches 0)
        first-match
        match-region
        match-begin
        match-end)
    (when quote-regexp-p
      (setq regexp (regexp-quote regexp)))
    (catch 'up
      (while (setq match-region 
                   (dp-match-contiguous-lines regexp shrink-wrap-p))
        (setq num-matches (1+ num-matches))
        (unless first-match
          (setq first-match (match-beginning 0)))
        (setq match-begin (car match-region)
              match-end (if (not end-regexp)
                            ;; Coloring newline has issues, so shrink
                            ;; wrapping may result in artifacts.
                            (cdr match-region) 
                          (end-of-line)
                          (if (dp-re-search-forward end-regexp nil t)
                              (progn
                                (setq pair-matches (1+ pair-matches))
                                (if shrink-wrap-p
                                    (match-end 0)
                                  (line-end-position)))
                            (throw 'up nil))))
        (dp-colorize-region color match-begin match-end (not roll-colors-p) 
                            nil 'dp-func 'dp-colorize-matching-lines
                            'dp-args (list regexp color end-regexp
                                           shrink-wrap-p roll-colors-p))
        ;; Clear color here, so `dp-colorize-region' won't reset its rolled
        ;; color back to our starting color
        (if roll-colors-p
            (setq color nil))
        ;; If we're shrink wrapping the matches, then don't move to the end
        ;; of the line.  This will allow us to highlight any other matches on
        ;; the current line.
        (when (or line-oriented-p (not shrink-wrap-p))
          (end-of-line))))
    (if (not first-match)               ; No matches.
        (progn
          (goto-char starting-point)
          (error (format "no matching lines for re: %s" regexp)))
      (dp-push-go-back "dp-colorize-region" starting-point)
      (goto-char first-match)
      (message "matched %s %s w/regexp: %s" 
               (if end-regexp pair-matches num-matches)
               (if end-regexp "pairs" "lines")
               regexp)
      (unless roll-colors-p
        (dp-colorize-roll-colors color)))))

(defun* dp-colorize-matching-line-sequence (regexps &rest pass-thru-args)
  (interactive)
  (loop for regexp in regexps
    do (save-excursion 
         (apply 'dp-colorize-matching-lines regexp pass-thru-args))))

(defun dp-colorize-matching-lines-from-isearch (&optional 
                                                colorize-each-match-p)
  "Use the last regexp from the last `isearch-\(for\|back\)ward\(-regexp\)?'."
  (interactive "P")
  ;;!<@todo Fix this so we can request shrink wrapping of the string.
  ;; The problem is that colors are specified with the prefix arg.
  ;;(call-interactively 'dp-colorize-matching-lines isearch-string)
  (dp-colorize-matching-lines isearch-string
                              :quote-regexp-p (not isearch-regexp)
                              :line-oriented-p (not colorize-each-match-p)))

(defvar dp-colorize-bracketing-regexps-history nil
  "History for `dp-colorize-bracketing-regexps'.")

(defun dp-colorize-bracketing-regexps(color regexp1 regexp2 roll-colors-p)
  "Colorized region [REGEXP1, REGEXP2] with COLOR."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (read-from-minibuffer 
                      "beginning regexp: "
                      nil nil nil dp-colorize-bracketing-regexps-history)
                     (read-from-minibuffer 
                      "ending regexp: "
                      nil nil nil dp-colorize-bracketing-regexps-history)
                     (y-or-n-p "roll-colors? ")))
  (dp-colorize-matching-lines regexp1 
                              :color color 
                              :end-regexp regexp2 
                              :shrink-wrap-p nil 
                              :roll-colors-p roll-colors-p))
(defalias 'dcbr 'dp-colorize-bracketing-regexps)

(defun dp-goto-next-colorized-region ()
  "Add ability to specify color. This would require us to use the secondary
  search key and the color number."
  (interactive)
  (dp-goto-next-matching-extent 'dp-extent-search-key 
                                '(unused . dp-colorized-region-p)))
(defun dp-set-colorized-extent-priority (arg &optional pos extents)
  (interactive "Npriority: \nXpos: ")
  (dp-set-extent-priority arg pos 'dp-colorized-region-p extents))

;; C-u --> prompt for shrink-wrap and roll colors
;; current-prefix-arg < 0 --> color and prompt
(defun dpcml-get-args ()
  (let* ((pnv (prefix-numeric-value current-prefix-arg))
         (prompt-for-others (and current-prefix-arg
                                 (not (eq current-prefix-arg '-))
                                 (or (< pnv 0)
                                     (listp current-prefix-arg))))
         (regexp (read-from-minibuffer 
                  "regexp: "
                  nil nil nil 
                  dp-colorize-bracketing-regexps-history))
         (others (if prompt-for-others
                     (list
                      (progn
                        (dp-read-number "color index: " 'ints-only 1) ; color
                        (cond
                         ((not current-prefix-arg) nil)
                         ((eq current-prefix-arg '-) '-)
                         (t (abs pnv)))         ;color
                        nil                     ;end-regexp
                        (and prompt-for-others (y-or-n-p "Shrink-wrap? "))
                        (and prompt-for-others (y-or-n-p "Roll colors? "))))
                   '(:color nil))))
    ;; FUBAR'd. All `others' need &key keywords.
    (append (list regexp) others)))

(defvar dp-colorize-lines-shrink-wrap-p-default t
  "*Should we colorize just the matching text or the entire line?
We make this t by default because it's easy to force a full line match by
wrapping the match string in ^.* & .*$
We also make this a global default so I can change it when the mood strikes.")

(defun* dp-colorize-matching-lines (regexp &key
                                    color 
                                    end-regexp
                                    (shrink-wrap-p 
                                     dp-colorize-lines-shrink-wrap-p-default)
                                    roll-colors-p 
                                    non-matching-p
                                    quote-regexp-p
                                    (line-oriented-p t))
  "Colorize lines matching REGEXP.
SHRINK-WRAP-P says to only colorize the exact match. Add ^.* && .*$ to get
the entire line.
END-REGEXP - If given, colorize all lines from REGEXP to END-REGEXP.
See `dpcml-get-args' for details of the following:
COLOR - the color to use. 
ROLL-COLORS-P - make each match a different color.
NON-MATCHING-P - ??? Doesn't seem to be used."
  ;; We use `read-from-minibuffer' so we can use our own history list.
  (interactive (dpcml-get-args))
  (let ((starting-point (point))
        (num-matches 0)
        (pair-matches 0)
        first-match
        match-region
        match-begin
        match-end)
    (when quote-regexp-p
      (setq regexp (regexp-quote regexp)))
    (catch 'up
      (while (setq match-region 
                   (dp-match-contiguous-lines regexp shrink-wrap-p))
        (setq num-matches (1+ num-matches))
        (unless first-match
          (setq first-match (match-beginning 0)))
        (setq match-begin (car match-region)
              match-end (if (not end-regexp)
                            ;; Coloring newline has issues, so shrink
                            ;; wrapping may result in artifacts.
                            (cdr match-region) 
                          (end-of-line)
                          (if (dp-re-search-forward end-regexp nil t)
                              (progn
                                (setq pair-matches (1+ pair-matches))
                                (if shrink-wrap-p
                                    (match-end 0)
                                  (line-end-position)))
                            (throw 'up nil))))
        (dp-colorize-region color match-begin match-end (not roll-colors-p) 
                            nil 'dp-func 'dp-colorize-matching-lines
                            'dp-args (list regexp color end-regexp
                                           shrink-wrap-p roll-colors-p))
        ;; Clear color here, so `dp-colorize-region' won't reset its rolled
        ;; color back to our starting color
        (if roll-colors-p
            (setq color nil))
        ;; If we're shrink wrapping the matches, then don't move to the end
        ;; of the line.  This will allow us to highlight any other matches on
        ;; the current line.
        (when (or line-oriented-p (not shrink-wrap-p))
          (end-of-line))))
    (if (not first-match)               ; No matches.
        (progn
          (goto-char starting-point)
          (error (format "no matching lines for re: %s" regexp)))
      (dp-push-go-back "dp-colorize-region" starting-point)
      (goto-char first-match)
      (message "matched %s %s w/regexp: %s" 
               (if end-regexp pair-matches num-matches)
               (if end-regexp "pairs" "lines")
               regexp)
      (unless roll-colors-p
        (dp-colorize-roll-colors color)))))

(defun* dp-colorize-matching-line-sequence (regexps &rest pass-thru-args)
  (interactive)
  (loop for regexp in regexps
    do (save-excursion 
         (apply 'dp-colorize-matching-lines regexp pass-thru-args))))

(defun dp-colorize-matching-lines-from-isearch (&optional 
                                                colorize-each-match-p)
  "Use the last regexp from the last `isearch-\(for\|back\)ward\(-regexp\)?'."
  (interactive "P")
  ;;!<@todo Fix this so we can request shrink wrapping of the string.
  ;; The problem is that colors are specified with the prefix arg.
  ;;(call-interactively 'dp-colorize-matching-lines isearch-string)
  (dp-colorize-matching-lines isearch-string
                              :quote-regexp-p (not isearch-regexp)
                              :line-oriented-p (not colorize-each-match-p)))

(defvar dp-colorize-bracketing-regexps-history nil
  "History for `dp-colorize-bracketing-regexps'.")

(defun dp-colorize-bracketing-regexps(color regexp1 regexp2 roll-colors-p)
  "Colorized region [REGEXP1, REGEXP2] with COLOR."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (read-from-minibuffer 
                      "beginning regexp: "
                      nil nil nil dp-colorize-bracketing-regexps-history)
                     (read-from-minibuffer 
                      "ending regexp: "
                      nil nil nil dp-colorize-bracketing-regexps-history)
                     (y-or-n-p "roll-colors? ")))
  (dp-colorize-matching-lines regexp1 
                              :color color 
                              :end-regexp regexp2 
                              :shrink-wrap-p nil 
                              :roll-colors-p roll-colors-p))
(defalias 'dcbr 'dp-colorize-bracketing-regexps)

(defun dp-goto-next-colorized-region ()
  "Add ability to specify color. This would require us to use the secondary
  search key and the color number."
  (interactive)
  (dp-goto-next-matching-extent 'dp-extent-search-key 
                                '(unused . dp-colorized-region-p)))

(defun dp-colorize-frame-bg (&optional color)
  "Set the frame's background color.
COLOR:
  prefix == C-u -- prompt for color.
  prefix == C-0 -- white.
  nil -- Use default color, if one.
  str -- Use as color name.
  face -- use as color face."
  (interactive "P")
  (let ((color
	 (cond
	  ((Cu-p)
	   (read-color "Frame background color: " nil t))
	  ((Cu0p)
	   "white")
	  ((eq color nil)
	   dp-default-background-color)
	  ((stringp color)
	   color)
	  ((facep color)
	   color)
	  (t "white"))))		; male conspiracy.
    (set-background-color color)))
(dp-defaliases 'cfb 'cfbg 'dp-colorize-frame-bg)

(provide 'dp-colorization)
(message "loading dp-colorization...done")
