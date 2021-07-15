;;; make-color-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "make-color" "make-color.el" (23198 64945 817357
;;;;;;  360000))
;;; Generated autoloads from make-color.el

(autoload 'make-color-switch-to-buffer "make-color" "\
Switch to make-color buffer or create one if needed.
With prefix (if ARG is non-nil), make a new make-color buffer.

\(fn &optional ARG)" t nil)

(autoload 'make-color "make-color" "\
Begin to make a color by modifying a text sample.
If region is active, use it as the sample.

The name of the buffer is defined by `make-color-buffer-name'.
If `make-color-use-single-buffer' is non-nil, use an existing
make-color buffer (with ARG, create a new buffer), otherwise
create a new buffer (with ARG, use an existing one).

\(fn &optional ARG)" t nil)

(autoload 'make-color-foreground-color-to-kill-ring "make-color" "\
Add foreground color at point to the `kill-ring'.

\(fn)" t nil)

(autoload 'make-color-background-color-to-kill-ring "make-color" "\
Add background color at point to the `kill-ring'.

\(fn)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; make-color-autoloads.el ends here
