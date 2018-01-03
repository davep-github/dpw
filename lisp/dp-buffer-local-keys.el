;;;
;;; Manage buffer local keys.
;;; One way really, really sucks.

;;;
;;; This stuff is *way* better, but it requires my C code hack.

(message "dp-buffer-localkeys loading...")

(dp-deflocal dp-blm-buf-local-keymap nil)

(defun dp-blm-get-or-create-buf-local-keymap ()
  (or dp-blm-buf-local-keymap
      (setq dp-blm-buf-local-keymap
	    (or
	     (and (current-local-map)
		  (copy-keymap (current-local-map)))
	     (make-sparse-keymap (format "BLM: %s" 
                                         (buffer-file-name)))))))
	   

(defun dp-define-buffer-local-keys (keys &optional buffer protect-bindings-p)
  (interactive)
  (with-current-buffer (or buffer (current-buffer))
    (let ((keymap (dp-blm-get-or-create-buf-local-keymap)))
      (loop for (key def) on keys by 'cddr do
	    (define-key keymap key def))
      (use-local-map keymap))))

(provide 'dp-buffer-local-keys)
(message "dp-buffer-localkeys loading...done")
