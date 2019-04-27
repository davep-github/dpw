;;;
;;; $Id: dp-xemacs-early.el,v 1.9 2003/11/20 08:30:05 davep Exp $
;;;
;;; This file contains xemacs only stuff that can or must be loaded
;;; early in the startup process.
;;; This is loaded before dp-misc, so it cannot use anything provided
;;; there.
;;;
(message "Loading dp-xemacs-early...")

(setq gutter-buffers-tab-enabled nil)
(defconst dp-info-path-var 'Info-directory-list
  "Info dir list var we want to add our info dirs to.")

(defun dp-set-font-lock-defaults (mode-symbol defaults)
  (put mode-symbol 'font-lock-defaults defaults))

;;rem-after-fsf (defun dp-timestamp-string (&optional time new-style-p)
;;rem-after-fsf   "Return a consistently formatted and sensibly sortable and succinct timestamp string."
;;rem-after-fsf   (interactive)
;;rem-after-fsf   (let ((fmt (format "%%Y-%%m%s-%%dT%%T"
;;rem-after-fsf                      (if (or new-style-p
;;rem-after-fsf                              (and (interactive-p ) current-prefix-arg))
;;rem-after-fsf                          "%b"
;;rem-after-fsf                        ""))))
;;rem-after-fsf     (format-time-string fmt time)))

;;
;;rem-after-fsf (defun* dp-mk-dropping-dir (subdir &optional dont-change-subdir-name-p
;;rem-after-fsf                             (create-p t))
;;rem-after-fsf   "Make SUBDIR in `dp-emacs-droppings' to hold file droppings.
;;rem-after-fsf Things like backup files, auto-saves, etc.
;;rem-after-fsf Some are ephemeral and some are longer term."
;;rem-after-fsf   (unless dont-change-subdir-name-p
;;rem-after-fsf     (if (or (< (length subdir) 2)
;;rem-after-fsf             (not (string= (substring subdir -2) ".d")))
;;rem-after-fsf         (setq subdir (concat subdir ".d")))
;;rem-after-fsf     (if (or (< (length subdir) 1)
;;rem-after-fsf             (not (string= (substring subdir 0 1) "/")))
;;rem-after-fsf         (setq subdir (concat "/" subdir))))
;;rem-after-fsf   (setq subdir (concat dp-emacs-droppings subdir))
;;rem-after-fsf   (when (and create-p
;;rem-after-fsf              (not (file-directory-p subdir)))
;;rem-after-fsf     (message "Creating editor dropping dir: $s..." subdir)
;;rem-after-fsf     (make-directory subdir)
;;rem-after-fsf     (message "Creating editor dropping dir: $s...done." subdir))
;;rem-after-fsf   ;; Warn if not there either way.
;;rem-after-fsf   (when (not (file-directory-p subdir))
;;rem-after-fsf     (warn "dropping dir >%s< isn't." subdir ))
;;rem-after-fsf   subdir)

;;rem-after-fsf (setq dp-editor-droppings (expand-file-name "~/droppings/editors")
;;rem-after-fsf       dp-emacs-droppings (concat dp-editor-droppings "/emacs")
;;rem-after-fsf       dp-backup-droppings (dp-mk-dropping-dir "ebacs")
;;rem-after-fsf       dp-auto-save-droppings (dp-mk-dropping-dir
;;rem-after-fsf                               "/session-auto-saves.d/"
;;rem-after-fsf                               'leave-it-alone))

;; Set autosave & backup variables more to my liking.
;;!<@todo how  does this work?  !<@todo also try setting prefix our way
;;and letting the rest go as usual.
;; If the prefix is nil, then using `auto-save-list-file-name' is
;; disabled, even if `auto-save-list-file-name' is not.  Obscure and
;; annoying.  But if the prefix is non-nil, the early start up code
;; constructs `auto-save-list-file-name'
;;rem-after-fsf (setq auto-save-list-file-prefix (concat dp-auto-save-droppings
;;rem-after-fsf                                          (format "%s-%s-aka-%s-"
;;rem-after-fsf                                                  (dp-timestamp-string)
;;rem-after-fsf                                                  (user-real-login-name)
;;rem-after-fsf                                                  (user-login-name)))
;;rem-after-fsf       ;; `auto-save-list-file-name' is overwritten if
;;rem-after-fsf       ;; `auto-save-list-file-prefix' is non-nil.
;;rem-after-fsf       ;;       auto-save-list-file-name (concat auto-save-list-file-prefix
;;rem-after-fsf       ;;                                        (format "%s-%s-%s-aka-%s@%s"
;;rem-after-fsf       ;;                                                (emacs-pid)
;;rem-after-fsf       ;;                                                (dp-timestamp-string)
;;rem-after-fsf       ;;                                                (user-real-login-name)
;;rem-after-fsf       ;;                                                (user-login-name)
;;rem-after-fsf       ;;                                                (system-name)))
;;rem-after-fsf       ;; ********************
;;rem-after-fsf       ;; Put all of your autosave files in one place, instead of scattering
;;rem-after-fsf       ;; them around the file system.  This has many advantages -- e.g. it
;;rem-after-fsf       ;; will eliminate slowdowns caused by editing files on a slow NFS
;;rem-after-fsf       ;; server.  (*Provided* that your home directory is local or on a
;;rem-after-fsf       ;; fast server!  If not, pick a value for `auto-save-directory' that
;;rem-after-fsf       ;; is fast fast fast!)
;;rem-after-fsf       ;;
;;rem-after-fsf       ;; Unfortunately, the code that implements this (auto-save.el) is
;;rem-after-fsf       ;; broken on Windows prior to 21.4.
;;rem-after-fsf       ;; (copped from sample.init.el)
;;rem-after-fsf       ;;
;;rem-after-fsf       auto-save-directory (dp-mk-dropping-dir "auto-saves.d")
;;rem-after-fsf       auto-save-directory-fallback (expand-file-name "~")
;;rem-after-fsf       auto-save-hash-p nil
;;rem-after-fsf       ;; now that we have auto-save-timeout, let's crank this up
;;rem-after-fsf       ;; for better interactive response.
;;rem-after-fsf       auto-save-interval 2000
;;rem-after-fsf       backup-directory-alist (list (cons "." dp-ebacs-droppings))
;;rem-after-fsf       backup-by-copying-when-linked t
;;rem-after-fsf       version-control t
;;rem-after-fsf       kept-new-versions 7)


;;;
;;;
;;;
(provide 'dp-xemacs-early)
