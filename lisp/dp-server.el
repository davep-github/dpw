;; XXX @todo make poly-macse, since I tire of it now.

(defun dp-editing-server-ping ()
  t)

;; Called before process is killed.
(defun dp-gnuserv-shutdown-hook ()
  (dmessage "in `dp-gnuserv-shutdown-hook'")
  ;; This is also called if a server cannot be started, e.g. because another
  ;; server is running. Forcing finalize to remove the ipc file is almost
  ;; always wrong in this case.
  (dp-finalize-editing-server 'rm-ipc-if-ours)) 

(if (dp-xemacs-p)
    (add-hook 'gnuserv-shutdown-hook 'dp-gnuserv-shutdown-hook)
  ;; No equivalent in Emacs ?!?!?!?
  ;;(add-hook 'server-shutdown-hook 'dp-gnuserv-shutdown-hook))
  )

(defvar dp-editor-identification-data '()
  "Anything that might help us ID the correct editor running the server.")

(defsubst dp-add-editor-identification-data (key datum)
  (dp-add-or-update-alist 'dp-editor-identification-data key datum))

(defsubst dp-remove-editor-identification-data (key)
  (remove-alist 'dp-editor-identification-data key))

(defsubst dp-editor-identification-string ()
  (dp-string-join dp-editor-identification-data))

(defun dp-compare-ipc-file (&optional file-name)
  (setq-ifnil file-name (dp-editing-server-ipc-file))
  (let* ((file-id-info (dp-read-file-as-string file-name))
         (id-info (and file-id-info
                       (read-from-string file-id-info))))
    (and id-info
         (dp-simple-assoc-cmp (car id-info)
                              dp-editor-identification-data))))

(defun dp-editing-server-ipc-file ()
  "Editing server identification info. The environment variable is consistently stale."
  (or (getenv "DP_EDITING_SERVER_FILE")
      (format "%s/ipc/dp-editing-server" (getenv "HOME"))))

(defun dp-creat-editing-server-ipc-file (&optional host-name)
  "Unconditionally write the server ipc file."
  (dmessage "in dp-creat-editing-server-ipc-file")
  (setq-ifnil host-name (dp-short-hostname))
  (with-temp-file (dp-editing-server-ipc-file)
    (prin1 dp-editor-identification-data (current-buffer))
    (insert "\n")))

(defun* dp-update-editor-identification-data (&key host-name sandbox-name 
                                              pid update-our-data-p)
  "Update specified fields and optionally write the data.
Use '(nil) for field name to set it to nil."
  (let ((write-p (or (eq update-our-data-p 'force)
                     (and update-our-data-p
                          (dp-compare-ipc-file)))))
    (when host-name
      (dp-add-editor-identification-data 'host-name 
                                         (if (listp host-name)
                                             (car host-name)
                                           host-name)))
    (when sandbox-name
      (dp-add-editor-identification-data 'sandbox-name 
                                         (if (listp sandbox-name)
                                             (car sandbox-name)
                                           sandbox-name)))
    (when pid
      (dp-add-editor-identification-data 'pid 
                                         (if (listp pid)
                                             (car pid)
                                           pid)))
    (when write-p
      (dp-creat-editing-server-ipc-file))))
  
(defun dp-rm-editing-server-ipc-file (&optional force-p)
  "Remove the ipc file only iff it's ours."
  (when (or force-p
            (dp-compare-ipc-file))
    (shell-command-to-string
     (format "rm -f %s" 
             (dp-editing-server-ipc-file)))))

(defun dp-kill-editing-server (&optional server-fate)
  (interactive)
  (dp-low-level-server-start 'dont-start-a-new-one)
  (when (eq server-fate 'kill-all-p)
    ;; emacs w/existing server won't know its server is dead... not a real
    ;; problem?
    ;; Also, I can't find a way to kill the server.
    (when (dp-xemacs-p)
      (shell-command (format "dpkillprog -q %s" server-program))))
  (dmessage "dp-kill-editing-server")
  (dp-finalize-editing-server 'rm-ipc-if-ours))

(defalias 'dp-stop-editing-server 'dp-kill-editing-server)

;;
;; Try for more feature filled gnuserv and fall back
;; to the regular server if gnuserv is not available.
;; gnuserv is always available when I build my own XEmacs.
;;
(defun dp-start-server (&optional leave-or-make-dead-p)
  "Start up an editing server.  Try for gnuserv, then server.
This is a func so it can specified on the command line as something to run or
not."
  (condition-case appease-byte-compiler
      (progn
	(require 'gnuserv)
	(message "using gnuserv")
	(let ((frame (dp-current-frame)))
          (if (dp-low-level-server-start leave-or-make-dead-p)
              t                         ; Deeniiiiiiied!
            (setq server-frame frame)
            nil)))
    (error (unless (in-windwoes)
	     (message "using regular server")
	     (dp-low-level-server-start)))))

;;
;; Finalize the editing server. If one is running, remove the IPC file.  It
;; seems there can be timing problems where the new instance can have written
;; its ipc file before another gets and processes its signal. The signalee's
;; server is still running, but it shouldn't rm its file.
;;
(defun dp-finalize-editing-server (&optional rm-flag)
  (dmessage "dp-finalize-editing-server, rm-flag: %s" rm-flag)
  (dp-set-frame-title-format :force-no-server-p t)
  (when (or (memq rm-flag '(rm))
            (dp-server-running-p))
    ;; The title formatter uses `dp-server-running-p' so it can mistakenly
    ;; set the server indication in the title.
    (dp-rm-editing-server-ipc-file)))

(defun* dp-start-editing-server (&optional server-fate force-serving-p)
  "Start a server to edit files for remote clients.  Prefer `gnuserv'.
SERVER-FATE (prefix arg) says nuke any existing child server and 
start a new one."
  (interactive "P")
  (setq server-fate (cond
                     ;; No arg... choose default *my* way.
                     ((not server-fate) (if (or force-serving-p 
                                                (interactive-p))
                                            ;; By hand means to force this
                                            ;; emacs to be a server.
                                            'kill-all-p
                                          'kill-local-p))
                     ((Cu--p server-fate) 'just-kill-p)
                     (t server-fate)))
  (dmessage "server-fate: %s, force-serving-p: %s" server-fate force-serving-p)
  ;; Nuke any possible existing server and do not start a gnu one. Har!
  (dp-kill-editing-server server-fate)
  ;; Start gnu server! (har, har! It just never gets old).
  (unless (eq server-fate 'just-kill-p)
    (dp-start-server)
    ;; Allow time for the server to die if there is another one running.
    (sit-for 0.5) ;
    (let ((host-name (dp-short-hostname)))
      (when (and (dp-server-running-p)
                 (or (dmessage "server is running") t)
                 (string-match dp-edting-server-valid-host-regexp
                               host-name))
        ;; Set up newest server advertisement.
        (dp-update-editor-identification-data 
         :host-name host-name
         :sandbox-name (or "nil" (dp-current-sandbox-name) "nil")
         :pid (emacs-pid))
        (dp-set-frame-title-format)
        (dp-creat-editing-server-ipc-file)))))
  
(dp-defaliases 'gserv 'xserver 'eserver 'gnuserve 'dp-start-editing-server)

(if (dp-xemacs-p)
    (defun dp-server-running-p (&optional name)
      "Determine if the editing server process exists and is alive.
Standard function simply checks that the process is non-nil without checking
to see if it's alive as well, so we-uns are bettah."
      (when-and-boundp 'server-process
	(eq (process-status server-process) 'run)))
  (defun dp-server-running-p (&optional name)
    "Start the editing server.
I can't find where server.el is loaded, but it seems to be after
this code runs, so I need to check for its presence before running
`server-running-p' to avoid an error."
    (and (featurep 'server)
	 (server-running-p))))

(defun dp-sig-toggle-server ()
  (interactive)
  (message "Caught %S; toggling server active state."
	   last-input-event)
  (message "Current server state: %s." (if (dp-server-running-p)
					  "running"
					"stopped"))
  (if (dp-server-running-p)
      (dp-stop-editing-server)
    (dp-start-editing-server))

    (message "Current server state: %s." (if (dp-server-running-p)
					  "running"
					"stopped"))
)

(unless (dp-xemacs-p)
  (define-key special-event-map [sigusr1] 'dp-sig-toggle-server))

(provide 'dp-server)
