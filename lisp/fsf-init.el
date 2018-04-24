(message "loading fsf-init...")
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

(defgroup dp-init-vars nil
  "My personal customizable variables; needs must be initialized early."
  :group 'local)

(defcustom dp-default-background-color "azure3"
  "Current fave, soon to be repulsive, background color"
  :group 'dp-init-vars
  :type 'string)

;; initial window settings
(setq initial-frame-alist
      `((width . 92)
	(height . 59)
	(vertical-scroll-bars . right)
	(background-color . ,dp-default-background-color)))

;; subsequent window settings
(setq default-frame-alist
      `((menu-bar-lines . 1)
        (tool-bar-lines . 0)
        (width . 92)
        (height . 59)
	(vertical-scroll-bars . right)
        (background-color . ,dp-default-background-color)))

(require 'dp-magit)

(provide 'fsf-init)
(message "loading fsf-init...done")
