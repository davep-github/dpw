(require 'package)

;; load emacs 24's package system. Add MELPA repository.
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   ; many packages won't show if using stable
   ;;'("melpa" . "http://stable.melpa.org/packages/") 
   '("melpa" . "http://melpa.org/packages/")
t))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;;(require 'magit)

(provide 'fsf-init)
