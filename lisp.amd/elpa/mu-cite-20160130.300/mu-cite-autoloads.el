;;; mu-cite-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "latex-math-symbol" "latex-math-symbol.el"
;;;;;;  (23229 13997 440006 363000))
;;; Generated autoloads from latex-math-symbol.el

(autoload 'latex-math-decode-region "latex-math-symbol" "\


\(fn BEG END)" t nil)

(autoload 'latex-math-decode-buffer "latex-math-symbol" "\


\(fn)" t nil)

;;;***

;;;### (autoloads nil "mu-cite" "mu-cite.el" (23229 13997 436006
;;;;;;  29000))
;;; Generated autoloads from mu-cite.el

(autoload 'mu-cite-original "mu-cite" "\
Citing filter function.
This is callable from the various mail and news readers' reply
function according to the agreed upon standard.

\(fn)" t nil)

(autoload 'fill-cited-region "mu-cite" "\
Fill each of the paragraphs in the region as a cited text.

\(fn BEG END)" t nil)

(autoload 'compress-cited-prefix "mu-cite" "\
Compress nested cited prefixes.

\(fn)" t nil)

;;;***

;;;### (autoloads nil "mu-register" "mu-register.el" (23229 13997
;;;;;;  444006 695000))
;;; Generated autoloads from mu-register.el

(autoload 'mu-cite-get-prefix-method "mu-register" "\


\(fn)" nil nil)

(autoload 'mu-cite-get-prefix-register-method "mu-register" "\


\(fn)" nil nil)

(autoload 'mu-cite-get-prefix-register-verbose-method "mu-register" "\


\(fn &optional NO-RETURN)" nil nil)

(autoload 'mu-cite-get-no-prefix-register-verbose-method "mu-register" "\


\(fn)" nil nil)

;;;***

;;;### (autoloads nil nil ("mu-cite-pkg.el") (23229 13997 448007
;;;;;;  28000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; mu-cite-autoloads.el ends here
