(message "loading fsf-early-init...")

;; (setq package-user-dir (locate-user-emacs-file
;; 			(dp-hostify-name "elpa.%s.d")))

;; load emacs 24's package system. Add MELPA repository.
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   ; many packages won't show if using stable
   ;;'("melpa" . "http://stable.melpa.org/packages/") 
   '("melpa" . "http://melpa.org/packages/")
t))

;; Keep here and there from trampling on each other.

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(when (bound-and-true-p dp-do-package-initialize-p)
  (package-initialize))

(defgroup dp-init-vars nil
  "My personal customizable variables; needs must be initialized early."
  :group 'local)

(defcustom dp-default-background-color "#1b182c"
  "Current fave, soon to be repulsive, background color"
  :group 'dp-init-vars
  :type 'string)

(defvar dp-initial-frame-width 180)
(defvar dp-initial-frame-height 66)

;; initial window settings
(setq initial-frame-alist
      `((width . ,dp-initial-frame-width)
	(height . ,dp-initial-frame-height)
	(vertical-scroll-bars . right)))

;; subsequent window settings
(setq default-frame-alist
      `((menu-bar-lines . 1)
        (tool-bar-lines . 0)
        (width . ,dp-initial-frame-width)
        (height . ,dp-initial-frame-height)
	(vertical-scroll-bars . right)
        (background-color . ,dp-default-background-color)))

(provide 'fsf-early-init)
(message "loading fsf-early-init...done")
