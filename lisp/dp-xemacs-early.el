;;;
;;; $Id: dp-xemacs-early.el,v 1.9 2003/11/20 08:30:05 davep Exp $
;;;
;;; This file contains xemacs only stuff that can or must be loaded
;;; early in the startup process.
;;; This is loaded before dp-misc, so it cannot use anything provided
;;; there.
;;; 

(defun dp-timestamp-string (&optional time new-style-p)
  "Return a consistently formatted and sensibly sortable and succinct timestamp string."
  (interactive)
  (let ((fmt (format "%%Y-%%m%s-%%dT%%T"
                     (if (or new-style-p 
                             (and (interactive-p ) current-prefix-arg))
                         "%b"
                       ""))))
    (format-time-string fmt time)))

;;
(defun* dp-mk-dropping-dir (subdir &optional dont-change-subdir-name-p 
                            (create-p t))
  (unless dont-change-subdir-name-p
    (if (or (< (length subdir) 2)
            (not (string= (substring subdir -2) ".d")))
        (setq subdir (concat subdir ".d")))
    (if (or (< (length subdir) 1)
            (not (string= (substring subdir 0 1) "/")))
        (setq subdir (concat "/" subdir))))
  (setq subdir (concat dp-xemacs-droppings subdir))
  (when (and create-p
             (not (file-directory-p subdir)))
    (message "Creating editor dropping dir: $s..." subdir)
    (make-directory subdir)
    (message "Creating editor dropping dir: $s...done." subdir))
  ;; Warn if not there either way.
  (when (not (file-directory-p subdir))
    (warn "dropping dir >%s< isn't." subdir ))
  subdir)

(setq dp-editor-droppings (expand-file-name "~/droppings/editors")
      dp-xemacs-droppings (concat dp-editor-droppings "/xemacs")
      dp-backup-droppings (dp-mk-dropping-dir "xebacs")
      dp-auto-save-droppings (dp-mk-dropping-dir
                              "/session-auto-saves.d/"
                              'leave-it-alone))

;; Set autosave & backup variables more to my liking.
;;!<@todo how  does this work?  !<@todo also try setting prefix our way
;;and letting the rest go as usual.
;; If the prefix is nil, then using `auto-save-list-file-name' is
;; disabled, even if `auto-save-list-file-name' is not.  Obscure and
;; annoying.  But if the prefix is non-nil, the early start up code
;; constructs `auto-save-list-file-name'
(setq auto-save-list-file-prefix (concat dp-auto-save-droppings
                                         (format "%s-%s-aka-%s-"
                                                 (dp-timestamp-string)
                                                 (user-real-login-name)
                                                 (user-login-name)))
      ;; `auto-save-list-file-name' is overwritten if
      ;; `auto-save-list-file-prefix' is non-nil.
      ;;       auto-save-list-file-name (concat auto-save-list-file-prefix
      ;;                                        (format "%s-%s-%s-aka-%s@%s"
      ;;                                                (emacs-pid)
      ;;                                                (dp-timestamp-string)
      ;;                                                (user-real-login-name)
      ;;                                                (user-login-name)
      ;;                                                (system-name)))
      ;; ********************
      ;; Put all of your autosave files in one place, instead of scattering
      ;; them around the file system.  This has many advantages -- e.g. it
      ;; will eliminate slowdowns caused by editing files on a slow NFS
      ;; server.  (*Provided* that your home directory is local or on a
      ;; fast server!  If not, pick a value for `auto-save-directory' that
      ;; is fast fast fast!)
      ;;
      ;; Unfortunately, the code that implements this (auto-save.el) is
      ;; broken on Windows prior to 21.4.
      ;; (copped from sample.init.el)
      ;;
      auto-save-directory (dp-mk-dropping-dir "auto-saves.d")
      auto-save-directory-fallback (expand-file-name "~")
      auto-save-hash-p nil
      ;; now that we have auto-save-timeout, let's crank this up
      ;; for better interactive response.
      auto-save-interval 2000
      backup-directory-alist (list (cons "." dp-backup-droppings))
      backup-by-copying-when-linked t
      version-control t
      kept-new-versions 7)

(defvar dp-remote-file-regexp (concat 
                   "@.*:"               ; efs/ange-ftp syntax
                   "\\|"
                   "/\\[")              ; tramp syntax
  "Regular expression that, when matched against a file name, tells us if the
  file is remote or no.")

(defvar dp-remote-file-colorization-info
  `(,dp-remote-file-regexp . dp-remote-buffer-face)
  "Remote file recognition regexp and default color")

(defvar dp-bmm-buffer-name-colorization-alist 
  `(,dp-remote-file-colorization-info
;;    ("\\[" . dp-sudo-edit-bg-face)
    ("Man\\( apropos\\)?: " . font-lock-string-face)
    ("<dse>" . dp-sudo-edit-bg-face)
    ("\\*ssh-" . dp-remote-buffer-face)
    ("\\*Python\\*" . font-lock-variable-name-face))
  "Alist used to map buffer-name to display face.
A list of cons cells, where each cons cell is \(regexp . face\).
The regexp is matched against the buffer name.")

(setq gutter-buffers-tab-enabled nil)

(defconst dp-info-path-var 'Info-directory-list
  "Info dir list var we want to add our info dirs to.")

(defun dp-set-font-lock-defaults (mode-symbol defaults)
  (put mode-symbol 'font-lock-defaults defaults))

(defvar dp-default-read-only-color 'dp-journal-alt-1-face
  "*We colourize read only buffers so we can more easily recognize them.
!<@todo This needs reworking.  I need to rework my whole colour system.
Using numbers all over the place is BS.  Need names and a colour mapping if
dealing with indexed colours.")


(defun dp-colorize-buffer-if (pred color &optional uncolorize-if-not-p
                              pred-args beg end)
  "Colourize the current buffer if PRED is non-nil."
  (interactive "P")
  (destructuring-bind (beg . end) (dp-region-or... :beg beg :end end
                                                   :bounder 'buffer-p)
    (if (dp-apply-or-value pred pred-args)
        (dp-colorize-region (or color dp-default-read-only-color) 
                            beg end
                            'no-roll-colors nil 'priority 1
                            ;; The property below says that the underlying
                            ;; extent is there showing some kind of file
                            ;; state, like read-only or remote.
                            'dp-file-state-colorization t)
      (when uncolorize-if-not-p
        (dp-uncolorize-region beg end t)))))

(defvar dp-remote-buffer-colorization-alist
  `(,dp-remote-file-colorization-info))

(defun dp-colorize-buffer-if-readonly (&optional color uncolorize-if-rw-p)
  (interactive "P")
  (dp-colorize-buffer-if buffer-read-only 
                         (or color 
                             dp-default-read-only-color)
                         uncolorize-if-rw-p))

(defun dp-colorize-buffer-if-remote (&optional color buf)
  "Give buffers holding remote files a distinctive color."
  (interactive "P")
  (dp-colorize-buffer-if 'dp-remote-file-p 
                         (or color 
                             (dp-bmm-get-color-for-buf-name (current-buffer)))))
  
;; @todo experimenting with this.
;; similar functionality built in now.
;(require 'fdb)
;(setq debug-on-error t)

;;;
;;;
;;;
(provide 'dp-xemacs-early)
