;;;
;;; Manage buffer local keys.
;;; One way really, really sucks.

(message "dp-buffer-localkeys loading...")

(setq dp-bl-keymaps '())
(setq dp-bl-keymap-names '())

(dp-deflocal dp-blm-buf-local-keymap nil)

(defun dp-buffer-local-keymaps-p ()
  t)

(defun dp-buffer-local-keymap-p ()
  dp-blm-buf-local-keymap)

(defun dp-blm-get-or-create-buf-local-keymap (name)
  (message "in dp-blm-get-or-create-buf-local-keymap, name>%s<" name)
  (message "dp-blm-buf-local-keymap: %s" dp-blm-buf-local-keymap)
  (or dp-blm-buf-local-keymap
      (and (message "dp-blm-buf-local-keymap is nil") nil)
      (setq dp-blm-buf-local-keymap
	    (or
	     (and (current-local-map)
		  (or (message "current-local-map: %s" (current-local-map)) t)
		  (copy-keymap (current-local-map)))
	     (make-sparse-keymap (format "BLM: %s"
                                         (buffer-file-name)))))))

(defun dp-define-buffer-local-keys (keys &optional buffer protect-bindings-p name)
  "Create a keymap the is local to the current buffer.
Make copy of the current local map and override the keys in KEYS.
This allows us to make temporary changes that don't muck with the local map."
  (interactive)
  (message "in NEW dp-define-buffer-local-keys, name>%s<" name)
  (with-current-buffer (or buffer (current-buffer))
    (let ((keymap (dp-blm-get-or-create-buf-local-keymap name)))
      (message "keymap: %s" keymap)
      (when keymap
	(setq dp-bl-keymaps (cons (cons name keymap) dp-bl-keymaps))
	(message "Using map>%s<" name)
	(setq dp-bl-keymap-names (cons name dp-bl-keymap-names))
	(loop for (key def) on keys by 'cddr do
	      (define-key keymap key def))
	(use-local-map keymap)))))

(provide 'dp-buffer-local-keys)
(message "dp-buffer-localkeys loading...done")
