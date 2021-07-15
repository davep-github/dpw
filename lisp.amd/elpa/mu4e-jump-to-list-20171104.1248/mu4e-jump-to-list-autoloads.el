;;; mu4e-jump-to-list-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "mu4e-jump-to-list" "mu4e-jump-to-list.el"
;;;;;;  (23229 13906 616451 773000))
;;; Generated autoloads from mu4e-jump-to-list.el

(defvar mu4e-jump-to-list-kill-regexp nil "\
Remove unwanted listid's from `mu4e-jump-to-list' using regular expressions.
Filter all matching listid's from the completion list using a regular
expression, or a list of regular expressions.")

(custom-autoload 'mu4e-jump-to-list-kill-regexp "mu4e-jump-to-list" t)

(defvar mu4e-jump-to-list-prefilter "date:1y.." "\
Query filter for listing available listid.
The string should be a valid mu4e query to select messages eligible for
`mu4e-jump-to-list'.")

(custom-autoload 'mu4e-jump-to-list-prefilter "mu4e-jump-to-list" t)

(defvar mu4e-jump-to-list-filter "NOT flag:trashed" "\
Query filter used when jumping to a given listid.")

(custom-autoload 'mu4e-jump-to-list-filter "mu4e-jump-to-list" t)

(defvar mu4e-jump-to-list-min-freq 3 "\
Minimal number of messages for a listid to be shown in `mu4e-jump-to-list'.")

(custom-autoload 'mu4e-jump-to-list-min-freq "mu4e-jump-to-list" t)

(autoload 'mu4e-jump-to-list "mu4e-jump-to-list" "\
Jump interactively to an existing LISTID.
Prompt interactively for a listid to be displayed according to existing
List-ID headers in your mu database. The IDs are displayed in
recency order if a suitable `mu4e-completing-read-function' is used.

Lists eligible for selection can be restricted first using
`mu4e-jump-to-list-prefilter' and `mu4e-jump-to-list-kill-regexp'. Only
lists containing at least `mu4e-jump-to-list-min-freq' messages are
displayed. `mu4e-jump-to-list-filter' is finally used to limit messages
when a List-ID has been selected.

\(fn LISTID)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; mu4e-jump-to-list-autoloads.el ends here
