
(defun* dp-unextent-region (region-id &optional beg end buf-or-string
				      (region-bounder 'buffer-p)
				      (verbose-p nil))
"REGION-ID: is a lisp expr: prop-name symbol or \(prop-name . prop-val).
The expr is `eval'd when read. Quoting (') may be required.
The property name prop-name is examined. If it exists (symbol) or exists and
has value \(cdr region-id), then that extent is matched."
  (interactive "sregion-id(lisp expr): ")
  ;; Region first.
  (when verbose-p
    (message "dp-unextent-region: region-id: %s" region-id))
  (let* ((check-val-p (consp region-id))
         (prop (if check-val-p (car region-id) region-id))
         (prop-val (cdr-safe region-id))
         (num-deleted 0)
         (be (dp-region-or... :beg beg :end end :bounder region-bounder)))
    (when be
      (mapcar-extents (lambda (ext)     ; Do this...
                        (incf num-deleted)
                        (when verbose-p
                          (message "deleting extent>%s<"
                                   (dp-pretty-format-extent ext "; " nil)))
                        (delete-extent ext))
                      (lambda (ext)           ; ...if this is non-nil
                        (or (not check-val-p)  ; Do all extents.
                            (equal prop-val  ; Or just these
                                   (extent-property ext prop))))
                      buf-or-string     ; Where the extents live.
                      (car be) (cdr be)
                      nil
                      prop))
    (message "%s %s deleted." num-deleted
             (dp-pluralize-num num-deleted nil nil "extent"))))

