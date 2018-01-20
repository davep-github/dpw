;;; metar-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "metar" "metar.el" (23134 33247 992277 201000))
;;; Generated autoloads from metar.el

(autoload 'metar "metar" "\
Display recent weather information.
If a prefix argument is given, prompt for country and station name.
If two prefix arguments are given, prompt for exact station code.
Otherwise, determine the best station via latitude/longitude.

\(fn &optional ARG)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; metar-autoloads.el ends here
