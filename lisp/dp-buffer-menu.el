;;;
;;; $Id: dp-buffer-menu.el,v 1.17 2005/06/12 08:20:07 davep Exp $
;;;
;;; Extensions and modifications to buff-menu.el
;;;

(defvar buffers-menu-predicate 'buffers-menu-files-only-predicate-func
  "*Filtering predicate for `list-buffers-internal'.
Defaults to `buffers-menu-files-only-predicate-func'.
Passed to `list-buffers-internal' by `list-buffers-noselect'.")

(defvar buffers-menu-predicate-args nil
  "*Arguments passed to `buffers-menu-predicate'.
Passed to `list-buffers-internal' by `list-buffers-noselect' if non-nil.
If nil, `list-buffers-noselect' will use \(list files-only\)
as the predicate args passed to `list-buffers-internal'.")

(defcustom dp-bmm-visible-major-modes 
  '(dired-mode
    debugger-mode
    Manual-mode 
    w3m-mode
    comint-mode
    ssh-mode
    shell-mode)
  "*Normally invisible modes that I wish to see."
  :group 'dp-vars
  :type '(repeat (symbol :tag "Major mode")))

(defvar dp-buffer-menu-invocation-arg nil
  "Arg that dp-buffer-menu was invoked with.")

(defun dp-refresh-buffer-menu ()
  (interactive)
  (dp-buffer-menu dp-buffer-menu-invocation-arg))

(defun dp-list-buffers (&optional arg)
  (interactive "P")
  (dp-buffer-menu (not arg) 'list-buffers))

(defun* dp-buffer-menu (&optional arg (listing-function 'buffer-menu))
  "Invert the arg to buffer-menu so that ARG is required
to have buffer-menu show non-file buffers."
  (interactive "P")
  (setq dp-buffer-menu-invocation-arg arg)
  (funcall listing-function (not arg)))

(defun dp-bmm-visit (&optional one-window)
  (interactive "P")
  (if one-window
      (Buffer-menu-1-window)
    (let ((bmm-buf (current-buffer)))
      (Buffer-menu-this-window)
      (bury-buffer bmm-buf))))

(defun dp-bmm-save-immed ()
  (interactive)
  (let ((buf (Buffer-menu-buffer nil))
	(pt (point)))
    (with-current-buffer buf
      (save-buffer)
      ;; refresh the buffer
      (list-buffers t))
    (goto-char pt)))

(defun dp-buffer-menu-id-file ()
  (let ((file-name (dp-extent-with-property-exists 'help-echo 
						   (point) (point))))
    (message-nl "%s" (if file-name
                         (car file-name)
                       "No file."))))

(defun dp-buffer-menu-mode-hook ()
  "Sets up personal menu mode options."
  (local-set-key [?e] 'Buffer-menu-1-window)
  (local-set-key [?w] 'Buffer-menu-save)
  (local-set-key [?W] 'dp-bmm-save-immed)
  (local-set-key [?S] 'dp-bmm-save-immed)
  (local-set-key [(meta ?w)] 'dp-bmm-save-immed)
  (local-set-key [return] 'dp-bmm-visit)
  (local-set-key [(meta return)] 'Buffer-menu-1-window)
  (local-set-key [(control return)] 'Buffer-menu-1-window)
  ;; retain behavior that I like (inverted from standard): 
  ;; no prefix arg --> just files
  ;;    prefix arg --> all buffers
  (local-set-key [?g] (kb-lambda 
		       (dp-buffer-menu dp-buffer-menu-invocation-arg)))
  (local-set-key [?=] 'Buffer-menu-this-window)
  (local-set-key [?.] 'Buffer-menu-this-window)
  (local-set-key [?D] 'dp-buffer-menu-mark-for-kill-matching-buffers)
  (local-set-key [(meta ?D)] 'dp-buffer-menu-mark-for-kill-matching-buffers)
  (local-set-key [up] (kb-lambda 
			(call-interactively 'dp-up-with-wrap)
			(dp-buffer-menu-id-file)))
  (local-set-key [down] (kb-lambda 
			  (call-interactively 'dp-down-with-wrap)
			  (dp-buffer-menu-id-file)))
  ;;(dmessage "mmh: buf-name>%s<" (buffer-name))
)

(when (boundp 'buffers-menu-predicate)
  (defun dp-list-buffers-predicate (buffer &rest rest)
    (if (and buffer
	     (memq (symbol-value-in-buffer 'major-mode buffer)
		   dp-bmm-visible-major-modes))
	t
      (apply dp-old-buf-menu-pred (cons buffer rest))))
  (defvar dp-old-buf-menu-pred buffers-menu-predicate)
  (setq buffers-menu-predicate 'dp-list-buffers-predicate))

;;(setq-default list-buffers-identification
;;'default-list-buffers-identification)
(setq-default list-buffers-identification 'dp-list-buffers-identification)

(defface dp-remote-buffer-face
  '((((class color) (background light)) 
     (:background "lightblue"))) 
  "Face for file that is being edited remotely on another host."  
  :group 'faces 
  :group 'dp-vars)

(defface dp-server-buffer-face
  '((((class color) (background light)) 
     (:background "hotpink"))) 
  "Face for gnuserv buffers."
  :group 'faces
  :group 'dp-vars)

(setq list-buffers-header-line
      (concat " MR Buffer                     Size  Mode         File\n"
	      " -- ------                     ----  ----         ----\n"))
;(defvar dp-modeline-file-name-extent (make-extent nil nil)
;  "Extent covering the modeline file name string.")
;(set-extent-face modeline-modified-extent 'modeline-mousable)
;(set-extent-keymap modeline-modified-extent modeline-modified-map)
;(set-extent-property modeline-modified-extent 'help-echo
;		     "button2 toggles the buffer's read-only status")

(defun dp-bmm-get-color-for-buf-name (buf &optional colorization-alist)
  (let ((face (or (cdr-safe (dp-assoc-regexp 
                             (buffer-name buf)
                             (or colorization-alist
                                 dp-bmm-buffer-name-colorization-alist)))
                  ;; I don't know why I did this, but I must've come across a
                  ;; situation where the buffer name didn't work but the file
                  ;; name did. (duh)
                  (and (buffer-file-name buf)
                       (cdr-safe (dp-assoc-regexp 
                                  (buffer-file-name buf)
                                  dp-bmm-buffer-name-colorization-alist))))))
    (or face
        (and (symbol-value-in-buffer 'buffer-read-only buf)
             (buffer-file-name buf)
             ;; Give the name the same background as the read-only file.
             'dp-default-read-only-color))))

(defvar dp-bmm-get-buffer-name-face 'dp-bmm-get-color-for-buf-name
  "Function used to determine face of buffer name.
Gets the buffer as input.")

(defface dp-buffer-menu-comint-face
  '((((class color) (background light)) 
     (:foreground "forestgreen" :bold))) 
  "Face for mode: `comint-mode'."
  :group 'faces
  :group 'dp-vars)

(require 'dired)
(defvar dp-bmm-mode-name-colorization-alist 
  '(("^Dired$" . dired-face-directory)
    ("^Debugger$" . dp-journal-medium-problem-face)
    ("^Manual$" . font-lock-string-face)
    ("^\\(Comint\\|Shell\\|ssh\\)$" . dp-buffer-menu-comint-face)
    ("." . blue))			;helps mode column to stand out
  "Alist used to map buffer-name to display face.
A list of cons cell, where each cons cell is \(regexp . face\).
The regexp is matched against the buffer name.")

(defun dp-bmm-default-get-mode-face (buf)
  (cdr-safe (dp-assoc-regexp (with-current-buffer buf mode-name)
			     dp-bmm-mode-name-colorization-alist)))

(defvar dp-bmm-get-mode-face 'dp-bmm-default-get-mode-face
  "Function used to determine face of mode name.
Gets the buffer as input.")

(defvar dp-bmm-minor-mode-faces
  '((gnuserv-minor-mode . dp-server-buffer-face))
  "Faces to colorize mode field according active minor modes.")

(defun dp-bmm-add-minor-mode-faces (buffer begin end)
  (loop for (mode-var . face) in dp-bmm-minor-mode-faces
    do (when (buffer-local-value mode-var buffer)
         (dp-set-text-color 'buff-menu-mode-minor-mode 
                            face
                            begin end 'detachable t t))))

(defun dp-list-buffers-identification (output)
  (save-excursion
    (let ((cur-buf (current-buffer))
	  (file (or (buffer-file-name (current-buffer))
		    (and (boundp 'list-buffers-directory)
			 list-buffers-directory)))
	  (size (buffer-size))
	  (mode mode-name)
	  eob p s col p1 p2 p2-col face)
      ;;(dmessage "file>%s<, mode>%s<" file mode-name)
      (set-buffer output)
      (indent-to 29 1)
      (setq p1 (+ 4 (line-beginning-position))
	    p2 (+ p1 (length (buffer-name cur-buf))))
      
      (end-of-line)
      (setq eob (point))
      (prin1 size output)
      ;; make [@] a var
      (if (setq face (funcall dp-bmm-get-buffer-name-face cur-buf))
	  (dp-set-text-color 'buff-menu-mode-buffer-face 
			     face p1 p2 'detachable))
      (setq p (point))
      ;; right-justify the size
      (move-to-column 29 t)
      (setq col (point))
      (if (> eob col)
	  (goto-char eob))
      (setq s (- 6 (- p col)))
      ;;(dmessage "eob: %s, col: %s, s: %s" eob col s)
      (while (> s 0) ; speed/consing tradeoff...
	(insert ?. )
	(decf s))

      (end-of-line)
      (indent-to 37 1)
      (setq p1 (point))
      (insert mode)
      (if (not file)
	  (progn
	    (setq p2 (point)
		  p2-col 0))
	;; if the mode-name is really long, clip it for the filename
	(if (> 0 (setq s (- 49 (current-column))))
	    (delete-char (max s (- eob (point)))))
	(setq p2 (point))
	(setq p2-col (indent-to 50 1))
	(insert file)
	;;(dmessage "p2-col: %d" p2-col)
	)

      (when (<= p2-col 50)
        (when (setq face (funcall dp-bmm-get-mode-face cur-buf))
	  (dp-set-text-color 'buff-menu-mode face p1 p2 'detachable t t))
        (dp-bmm-add-minor-mode-faces cur-buf p1 p2))
      
      (dp-make-extent (line-beginning-position)
		      (line-end-position)
		      'dp-buff-menu-buffer-name
		      'help-echo 
		      (or file
			  "No file.")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Hack in here for now until I redo the patch.
;;

;; This needs to be dumped, so we'll just redefine it here.
(defun list-buffers-internal (output &optional predicate predicate-args)
  (let ((current (current-buffer))
        (buffers (buffer-list)))
    (save-excursion
      (set-buffer output)
      (setq buffer-read-only nil)
      (erase-buffer)
      (buffer-disable-undo output)
      (insert list-buffers-header-line)

      (while buffers
        (let* ((col1 19)
               (buffer (car buffers))
               (name (buffer-name buffer))
	       this-buffer-line-start)
          (setq buffers (cdr buffers))
          (cond ((null name))           ;deleted buffer
                ((and predicate
                      (not (if (stringp predicate)
                               (string-match predicate name)
			     (apply predicate (cons buffer predicate-args)))))
                 nil)
                (t
                 (set-buffer buffer)
                 (let ((ro buffer-read-only)
                       (id list-buffers-identification))
                   (set-buffer output)
		   (setq this-buffer-line-start (point))
                   (insert (if (eq buffer current)
                               (progn (setq current (point)) ?\.)
			     ?\ ))
                   (insert (if (buffer-modified-p buffer)
                               ?\*
			     ?\ ))
                   (insert (if ro
                               ?\%
			     ?\ ))
                   (if (string-match "[\n\"\\ \t]" name)
                       (let ((print-escape-newlines t))
                         (prin1 name output))
		     (insert ?\  name))
                   (indent-to col1 1)
                   (cond ((stringp id)
                          (insert id))
                         (id
                          (set-buffer buffer)
                          (condition-case e
                              (funcall id output)
                            (error
                             (princ "***" output) (prin1 e output)))
                          (set-buffer output)
                          (goto-char (point-max)))))
		 (put-nonduplicable-text-property this-buffer-line-start
						  (point)
						  'buffer-name name)
		 (put-nonduplicable-text-property this-buffer-line-start
						  (point)
						  'highlight t)
                 (insert ?\n)))))
      
      (Buffer-menu-mode)
      (if (not (bufferp current))
          (goto-char current)))))

(unless (fboundp 'buffers-menu-files-only-predicate-func)
  (defun buffers-menu-files-only-predicate-func (b files-only)
    "Default filtering predicate.
Default value of `buffers-menu-predicate'.
Predicate functions receive as parameters a buffer and
whatever PREDICATE-ARGS are passed to `list-buffers-internal'.
See also `buffers-menu-predicate-args'."
    (let ((n (buffer-name b)))
      (cond ((and (/= 0 (length n))
                  (= (aref n 0) ?\ ))
             ;;don't mention if starts with " "
             nil)
            (files-only
             (buffer-file-name b))
            (t
             t)))))

;;@todo XXX Override here. Rebuild patch.
(defun list-buffers-noselect (&optional files-only)
  "Create and return a buffer with a list of names of existing buffers.
The buffer is named `*Buffer List*'.
Note that buffers with names starting with spaces are omitted.
Non-nil optional arg FILES-ONLY means mention only file buffers.

The M column contains a * for buffers that are modified.
The R column contains a % for buffers that are read-only."
  (let ((buffer (get-buffer-create "*Buffer List*")))
    (list-buffers-internal buffer
			   (if (memq files-only '(t nil))
			       (progn
				 (setq pred-args
				       (or buffers-menu-predicate-args
					   (list files-only)))
				 buffers-menu-predicate)
			     files-only)
			   pred-args)

    buffer))


