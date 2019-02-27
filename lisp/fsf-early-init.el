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

;; Use `dp-set-to-max-vert-frame-height' and check that width is <= max width
;; using a similar mechanism.
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

(defconst dp-original-isearch-string-out-of-window-function
  (symbol-function 'isearch-string-out-of-window)
  "Save this so we can still use it in our hack.")

(defun dp-unfuck-isearch-scrolling ()
  "Stop Emacs from preventing search string from scrolling off the screen.
I *really* *really* *really* hate this.  So I just say, nope,
we're not off screen.  However, this fucks up and seems to
activate the mark and mark from the iseatch string to the cursor
position."
  (unless (bound-and-true-p
	   dp-dont-fix-stupid-emacs-refusal-to-scroll-search-string-off-screen-p)
    (defun isearch-string-out-of-window (isearch-point)
      ;; @todo XXX As a less terrible hack, when we move out of the window,
      ;; exit `isearch-mode'.
      ;; Causing an error here (and in the `post-command-hook') seems to make
      ;; things less fucked up.
      (message))))
  ;FIXME     (when (funcall dp-original-isearch-string-out-of-window-function
  ;FIXME 		     isearch-point)
  ;FIXME 	;; We left the window.
  ;FIXME 	;; exit isearch mode.
  ;FIXME 	;; Works much better, but the cursor goes to the beginning of the
  ;FIXME 	;; line.  However, unexpectedly and quite happily, the searched for
  ;FIXME 	;; string remains highlighted.  I have no idea why, since the
  ;FIXME 	;; `isearch-exit' should, well, exit the search.
  ;FIXME 	(isearch-exit)
  ;FIXME 	)
  ;FIXME     )
  ;FIXME   )
  ;FIXME )

(add-hook 'dp-post-dpmacs-hook 'dp-unfuck-isearch-scrolling)

(provide 'fsf-early-init)
(message "loading fsf-early-init...done")
