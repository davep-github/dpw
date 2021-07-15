;;; contrast-color-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "contrast-color" "contrast-color.el" (23198
;;;;;;  64950 309367 391000))
;;; Generated autoloads from contrast-color.el

(autoload 'contrast-color "contrast-color" "\
Return most contrasted color against COLOR.
The return color picked from ‘contrast-color-candidates’.
The algorithm is used CIEDE2000. See also ‘color-cie-de2000’ function.

\(fn COLOR)" nil nil)

(autoload 'contrast-color-set "contrast-color" "\
Set list of COLORS to ‘contrast-color-candidates’.

\(fn COLORS)" nil nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; contrast-color-autoloads.el ends here
