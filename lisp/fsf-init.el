(require 'package)

(defconst save-place-file
  (format "~/.emacs.d/emacs-places.%s" (system-name))
  "When editing on multiple machines, it's nice to qualify them with the
 hostname on which certain resources are being used.  This tends to require
executable code, often a format with some function calls, often
`dp-short-hostname'.  Hooks to funcalls should be an option for
the value of some/many/most/all customizable variables.")
(message "After: save-place-file>%s<" save-place-file)

;complete this (let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
;complete this                     (not (gnutls-available-p))))
;complete this        (proto (if no-ssl "http" "https")))
;complete this   ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
;complete this   ;; (add-to-list 'package-archives
;complete this   ;; 	       (cons "melpa" (concat proto "://melpa.org/packages/")) t)
;complete this   (add-to-list 'package-archives
;complete this 	       (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
;complete this   (when (< emacs-major-version 24)
;complete this     ;; For important compatibility libraries like cl-lib
;complete this     (add-to-list 'package-archives
;complete this 		 '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(provide 'fsf-init)
