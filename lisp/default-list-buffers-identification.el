(defun default-list-buffers-identification (output)
  (save-excursion
    (let ((file (or (buffer-file-name (current-buffer))
		    (and (boundp 'list-buffers-directory)
			 list-buffers-directory)))
	  (size (buffer-size))
	  (mode mode-name)
	  eob p p1 p2 s col)
      (set-buffer output)
      (end-of-line)
      (setq eob (point))
      (prin1 size output)
      (setq p (point))
      ;; right-justify the size
      (move-to-column 19 t)
      (setq col (point))
      (if (> eob col)
	  (goto-char eob))
      (setq s (- 6 (- p col)))
      (while (> s 0) ; speed/consing tradeoff...
	(insert ? )
	(setq s (1- s)))
      (end-of-line)
      (indent-to 27 1)
      (setq p1 (point))
      (insert mode)
      (if (not file)
	  nil
	;; if the mode-name is really long, clip it for the filename
	(if (> 0 (setq s (- 39 (current-column))))
	    (delete-char (max s (- eob (point)))))

	(setq p2 (point))
	(indent-to 40 1)
	(insert file)
	(dp-set-text-color 'dp-buff-menu-bg-extent 'blue
			   p1 p2 'detachable)))))
