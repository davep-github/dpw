(defun display-message-or-buffer (message
				  &optional buffer-name not-this-window frame)
  "Display MESSAGE in the echo area if possible, otherwise in a pop-up buffer.
MESSAGE may be either a string or a buffer.

A buffer is displayed using `display-buffer' if MESSAGE is too long for
the maximum height of the echo area, as defined by `max-mini-window-height'
if `resize-mini-windows' is non-nil.

Returns either the string shown in the echo area, or when a pop-up
buffer is used, the window used to display it.

If MESSAGE is a string, then the optional argument BUFFER-NAME is the
name of the buffer used to display it in the case where a pop-up buffer
is used, defaulting to `*Message*'.  In the case where MESSAGE is a
string and it is displayed in the echo area, it is not specified whether
the contents are inserted into the buffer anyway.

Optional arguments NOT-THIS-WINDOW and FRAME are as for `display-buffer',
and only used if a buffer is displayed."
  (cond ((and (stringp message) (not (string-match "\n" message)))
	 ;; Trivial case where we can use the echo area
	 (message "%s" message))
	((and (stringp message)
	      (= (string-match "\n" message) (1- (length message))))
	 ;; Trivial case where we can just remove single trailing newline
	 (message "%s" (substring message 0 (1- (length message)))))
	(t
	 ;; General case
	 (with-current-buffer
	     (if (bufferp message)
		 message
	       (get-buffer-create (or buffer-name "*Message*")))

	   (unless (bufferp message)
	     (erase-buffer)
	     (insert message))

	   (let ((lines
		  (if (= (buffer-size) 0)
		      0
		    (count-screen-lines nil nil nil (minibuffer-window)))))
	     (cond ((= lines 0))
		   ((and (or (<= lines 1)
			     (<= lines
				 (if resize-minibuffer-frame
				     (cond ((integerp resize-minibuffer-window-max-height)
					    resize-minibuffer-window-max-height)
					   (t
					    1))
				   1)))
			 ;; Don't use the echo area if the output buffer is
			 ;; already dispayed in the selected frame.
			 (not (get-buffer-window (current-buffer))))
		    ;; Echo area
		    (goto-char (point-max))
		    (when (bolp)
		      (backward-char 1))
		    (message "%s" (buffer-substring (point-min) (point))))
		   (t
		    ;; Buffer
		    (goto-char (point-min))
		    (display-buffer (current-buffer)
				    not-this-window frame))))))))
