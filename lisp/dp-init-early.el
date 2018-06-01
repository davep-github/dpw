(message "dp-init-early loading...")

(defvar dp-contrib-site-packages (dp-lisp-subdir "contrib/site-packages")
  "My local site packages root.")

(defun dp-mk-site-package-dir (&rest names)
  (expand-file-name (paths-construct-path 
                     (cons dp-contrib-site-packages names))))

(defvar dp-site-package-info (dp-mk-site-package-dir "info")
  "My local site packages info root.")
(message "dp-site-package-info>%s<" dp-site-package-info)

(defvar dp-site-package-lisp (dp-mk-site-package-dir "lisp")
  "My local site packages lisp root.")

(defun dp-mk-site-package-lisp-dir (&rest names)
  (expand-file-name (paths-construct-path (cons dp-site-package-lisp names))))

(defvar dp-contrib-package-root (dp-lisp-subdir "contrib"))

(defun dp-mk-contrib-subdir (&rest subdir-components)
  (expand-file-name (paths-construct-path
                     (cons dp-contrib-package-root subdir-components))))

(defun dp-add-contrib-subdir-to-load-path (&rest subdir-components)
  (add-to-list 'load-path 
               (apply 'dp-mk-contrib-subdir subdir-components)))

(defun dp-mk-contrib-pkg-child (&rest pkg-names)
  (expand-file-name (paths-construct-path  
                     (cons dp-contrib-site-packages pkg-names))))

(defun dp-mk-contrib-site-pkg-child (&rest pkg-names)
  (expand-file-name (paths-construct-path  
                     (cons dp-contrib-site-packages pkg-names))))

(dp-add-contrib-subdir-to-load-path "xemacs.el-for-fsf-compat")

(defun dp-timestamp-string (&optional time new-style-p)
  "Return a consistently formatted and sensibly sortable and succinct timestamp string."
  (interactive)
  (let ((fmt (format "%%Y-%%m%s-%%dT%%T"
                     (if (or new-style-p 
                             (and (interactive-p ) current-prefix-arg))
                         "%b"
                       ""))))
    (format-time-string fmt time)))

(defun* dp-mk-dropping-dir (subdir &optional dont-change-subdir-name-p 
                            (create-p t))
  "Make SUBDIR in `dp-emacs-droppings' to hold file droppings.
Things like backup files, auto-saves, etc.
Some are ephemeral and some are longer term."
  (unless dont-change-subdir-name-p
    (if (or (< (length subdir) 2)
            (not (string= (substring subdir -2) ".d")))
        (setq subdir (concat subdir ".d")))
    (if (or (< (length subdir) 1)
            (not (string= (substring subdir 0 1) "/")))
        (setq subdir (concat "/" subdir))))
  (setq subdir (concat dp-emacs-droppings subdir))
  (when (and create-p
             (not (file-directory-p subdir)))
    (message "Creating editor dropping dir: $s..." subdir)
    (make-directory subdir)
    (message "Creating editor dropping dir: $s...done." subdir))
  ;; Warn if not there either way.
  (when (not (file-directory-p subdir))
    (warn "dropping dir >%s< isn't." subdir ))
  subdir)

;; Nicked from GNU Emacs 25.3.2 (x86_64-pc-linux-gnu, X toolkit, Xaw
;; scroll bars) of 2018-01-02's
;; cc-defs.
(defmacro dp-last-command-char ()
  ;; The last character just typed.  Note that `last-command-event' exists in
  ;; both Emacs and XEmacs, but with confusingly different meanings.
  (if (featurep 'xemacs)
      'last-command-char
    'last-command-event))

;; pending-delete-mode causes typed text to replace a selection,
;; rather than append -- standard behavior under all window systems
;; nowadays. (copped from sample.init.el)
(when (fboundp 'pending-delete-mode)
  (pending-delete-mode 1)
  ;; kill the modeline display this mode
  (setq pending-delete-modeline-string " pD"))

;; The LOCAL arg to `add-hook' is interpreted differently in Emacs and
;; XEmacs.  In Emacs we don't need to call `make-local-hook' first.
;; It's harmless, though, so the main purpose of this alias is to shut
;; up the byte compiler.
;; Stolen from Emacs Gnus
(defalias 'dp-make-local-hook (if (featurep 'xemacs)
                               'make-local-hook
                               'ignore))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq dp-editor-droppings (expand-file-name "~/droppings/editors")
      dp-emacs-droppings (concat dp-editor-droppings "/emacs")
      dp-ebacs-droppings (dp-mk-dropping-dir "ebacs")
      dp-auto-save-droppings (dp-mk-dropping-dir
                              "/session-auto-saves.d/"
                              'leave-it-alone))

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
      backup-directory-alist (list (cons "." dp-ebacs-droppings))
      backup-by-copying-when-linked t
      backup-by-copying t
      delete-old-versions t
      version-control t
      kept-new-versions 7)

(defvar dp-remote-file-regexp
  (if (dp-xemacs-p)
      (concat
       "@.*:"				; efs/ange-ftp syntax
       "\\|"
       "/\\[")				; tramp syntax
    tramp-file-name-regexp-unified)
  "Regular expression that, when matched against a file name, tells us if the
  file is remote or no.")

(message "dp-init-early loading...done")
(provide 'dp-init-early)
