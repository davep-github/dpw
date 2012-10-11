;;;
;;; $Id: dp-sudo-edit3.el,v 1.30 2004/12/30 09:20:03 davep Exp $
;;;
;;; dp-sudo-edit.el - allow non-root-user to edit root writable files
;;; by use of sudo.
;;;

;;;
;;; "Sudo editing" Allow normally un-editable buffers to be edited by
;;; using sudo to access the files. The basic idea is that we add a
;;; entry to the `file-name-handler-alist' for the file we want to
;;; edit.  This implements methods to allow us to read/write and
;;; backup (via "sudo mv") files.
;;; `insert-file-contents' uses sudo cat to get the file contents.
;;; `write-region' uses `call-process-region' to send the region to
;;; "sudo tee" which copies stdin to the file(s) passed as args.
;;;

;;;###autoload
(defcustom dp-sudo-edit-load-hook nil
  "List of functions to be called after the we're loaded."
  :type 'hook
  :group 'dp-hooks)

;;;###autoload
(defface dp-sudo-edit-bg-face
  '((((class color) (background light)) 
     (:background "thistle2"))) 
  "Face for file being sudo edited."
  :group 'faces
  :group 'dp-vars)

(defcustom dp-sudo-edit-sudoer "sudo"
  "*A command which allows a user to execute a command as another user
  (e.g. root).  At this time there is no support for commands that require
  passwords.  Sudo, the prototypical command, has the ability to allow users
  to run commands w/o providing a password."
  :group 'dp-vars
  :type 'string)

(defconst dp-sudo-edit-suffix "<dse>"
  "Suffix appended to buffer names to indicate they are sudo edited files.")

(defvar dp-sudo-edit-sudo-password-args '("-S" "-p" "''")
  "How we make sudo read password from stdin.")

(defun dp-sudo-edit-sudo-it (&optional program infile buffer displayp 
                             &rest args-to-sudoer)
  "Front end so we can handle prompting for sudo password."
  ;; Get password if needed.
  ;; Uses, by default sudo -v (q.v.)
  (dp-sudo-authenticate)
  (apply 'call-process (or program dp-sudo-edit-sudoer)
         infile buffer displayp args-to-sudoer)
         (append dp-sudo-edit-sudo-password-args args-to-sudoer))
  
(defun dp-sudo-edit-mk-handler-alist-entry (file-name)
  "Create an entry for the `file-name-handler-alist'."
  (cons (regexp-quote file-name) 'dp-sudo-edit-handler-fn))

;;handler: op>rename-file<, rest>(/sudo-edit#/tmp/root-write-file /sudo-edit#/tmp/root-write-file~ t)<
;;(rename-file FILENAME NEWNAME &optional OK-IF-ALREADY-EXISTS)
(defun dp-sudo-edit-rename-file (op from to &rest rest)
  "Rename FROM to TO using 'sudo mv'."
  ;; can call dp_logging_mv to see what goes on.
  ;; @todo ??? also copy to xxx.ORIG if xxx.ORIG does not exist?
  ;;       this preserves an orig for diff and patch.
  (dp-sudo-edit-sudo-it dp-sudo-edit-sudoer nil nil nil "mv" from to))

;;handler: op>copy-file<, rest>(/etc/ppp/ppp.conf /etc/ppp/ppp.conf~ t t)<
(defun dp-sudo-edit-copy-file (op from to &rest rest)
  "Copy FROM to TO using 'sudo cp'."
  (dmessage "sudo-edit, cp >%s< >%s<" from to)
  (dp-sudo-edit-sudo-it dp-sudo-edit-sudoer nil nil nil "cp" from to))

;;+handler: op>write-region<, rest>(1 135 /sudo-edit#/tmp/root-write-file nil t /sudo-edit#/tmp/root-write-file #<coding_system iso-2022-8-unix>)<
;;(write-region START END FILENAME &optional APPEND VISIT LOCKNAME CODING-SYSTEM)

; (list start end dp-sudo-edit-sudoer 
; 			  nil "*dse-debug*" nil 
; 			  "tee" 
; 			  (buffer-file-name))
(defun dp-sudo-edit-write-region (op start end file-name &rest rest)
  "Write the requested region into the specified file.
We currently don't support all of the `write-region' options."
  (let (cp-command
        (num-to-write (- end start))
        write-len
	rc)
    (dmessage "wreg: s: %s, e: %s, fn>%s<, rest>%s<" start end file-name rest)
    ;; truncate the file before writing
    (dp-sudo-edit-copy-file 'cp "/dev/null" file-name)
    (save-restriction
      (widen)
      (while (> num-to-write 0)
        (setq write-len (min num-to-write 4096))
        (setq cp-command (list start (+ start write-len) 
                                dp-sudo-edit-sudoer 
                                nil "*dse-debug*" nil 
                                "tee" "-a" 
                                (buffer-file-name)))
        (dmessage "write-len: %d, cp-command>%s<" write-len cp-command)
        (setq rc (apply 'call-process-region cp-command))
        (dmessage "rc>%s<" rc)
        ;;(setq rc 0)
        (if (= rc 0)
            (set-visited-file-modtime)
          (error (format "cp cmd (%s) failed: %s" rc cp-command)))
        (setq start (+ start write-len))
        (setq num-to-write (- num-to-write write-len)))
    rc)))

(defun dp-sudo-edit-set-file-modes (op file-name mode-bits)
  "Set file modes using 'sudo chmod'."
  (dp-sudo-edit-sudo-it dp-sudo-edit-sudoer nil nil nil 
                        "chmod" 
                        (format "%o" mode-bits)
                        file-name))
    
(defun dp-sudo-edit-common-setup (handler-entry)
  (add-local-hook 'kill-buffer-hook 'dp-sudo-edit-temp-buffer-killed)
  (dp-set-text-color 'dp-sudo-edit-bg-extent 'dp-sudo-edit-bg-face)
  ;; not dp-sudo-edit-suffix$ since a buffer number <n> may follow
  (unless (string-match dp-sudo-edit-suffix (buffer-name))
    (rename-buffer (format "%s%s" (buffer-name) dp-sudo-edit-suffix) 'unique))
  (setq dp-sudo-edit-handler-entry handler-entry))


;; handler: op>insert-file-contents<, rest>(/sudo-edit#/tmp/root-write-file t nil nil nil)<
;; (insert-file-contents FILENAME &optional VISIT START END REPLACE)
;; NB: this is *not* called when reading a dir w/dired
(defun dp-sudo-edit-insert-file-contents (op file-name &rest rest)
  "Provide the `insert-file-contents' functionality.
Not all options are supported."
  (let ((opoint (point))
	handler-entry)
    (if (file-exists-p file-name)
	;;(call-process dp-sudo-edit-sudoer nil t nil "cat" file-name)
        (dp-sudo-edit-sudo-it dp-sudo-edit-sudoer nil t nil "cat" file-name)
        )
    ;; @todo fix use of visit, take from rest, (nth 0 rest)
    ;;(when visit
    ;; @todo remove when satisfied that this 
    ;;       2003-06-15T01:21:28
    (unless (eq visit (nth 0 rest))
      (ding)(ding)(ding)(ding)(ding)(ding)(ding)
      (error "You don't really unnerstand insert-file-contents!!!"))

    (when (nth 0 rest)
      (setq buffer-file-name file-name)
      (set-visited-file-modtime))

    (unless dp-sudo-edit-handler-entry
      (setq handler-entry (dp-sudo-edit-mk-handler-alist-entry file-name))
      (add-to-list 'file-name-handler-alist handler-entry)
      (dp-sudo-edit-common-setup handler-entry))

    (goto-char (point-min))
    (list file-name (- (point) opoint))
    ))

(defun dp-sudo-edit-return-t (&rest rest)
  "Hail yes!"
  t)

(defvar dp-sudo-edit-handler-alist
  '(
    (insert-file-contents    . dp-sudo-edit-insert-file-contents)
    (write-region            . dp-sudo-edit-write-region)
    (rename-file             . dp-sudo-edit-rename-file)
    (file-writable-p         . dp-sudo-edit-return-t)
    (set-file-modes          . dp-sudo-edit-set-file-modes)
    (copy-file               . dp-sudo-edit-copy-file)
    ))

(defvar dp-sudo-edit-handler-depth "")

(defun dp-sudo-edit-handler-fn (op &rest rest)
  "File-name-handler entry point."

  (setq dp-sudo-edit-handler-depth (concat dp-sudo-edit-handler-depth "+"))
  ;;(dmessage "%shandler: op>%s<, rest>%s<" dp-sudo-edit-handler-depth op rest)
  ;;(dmessage "handler: op>%s<, rest>%s<" op rest)

  (let ((handler (assoc op dp-sudo-edit-handler-alist))
	;; @todo should we cons ourself onto the existing handlers list?
	(inhibit-file-name-handlers (list 'dp-sudo-edit-handler-fn))
	(inhibit-file-name-operation op)
	ret)
    (setq ret
	  (if handler
	      (progn
		;;(dmessage "handling")
		(apply (cdr handler) op rest))
	    ;;(dmessage "default")
	    (apply op rest)))

    ;;(dmessage "%shandler: op>%s< ret>%s<" 
    ;;	      (replace-in-string dp-sudo-edit-handler-depth "\\+" "-") op ret)
    (setq dp-sudo-edit-handler-depth 
	  (substring dp-sudo-edit-handler-depth 0 -1))

    ret))

(dp-deflocal dp-sudo-edit-handler-entry nil
  "Handler entry for the file in this buffer.")

(defun dp-sudo-edit-remove-handler-entry (&optional entry)
  (unless entry (setq entry dp-sudo-edit-handler-entry))
  (if entry
      (setq file-name-handler-alist (delete dp-sudo-edit-handler-entry 
					    file-name-handler-alist))))
  
(defun dp-sudo-edit-temp-buffer-killed ()
  "Respond to a sudo-edit buffer being killed.  Delete this buffer's file-name-handler entry.
This is called as a `kill-buffer-hook', with the condemned buffer
current."
  (dp-sudo-edit-remove-handler-entry))

;;;###autoload
(defun dp-sudo-edit (orig-file-name)
  "Edit a file by using sudo to cat the file into a buffer and sudo to cp the edited file over the original."
  ;;(interactive "FSudo edit: ")
  (interactive (list (ffap-prompter)))
  (catch 'done
    (let* ((file-name (expand-file-name orig-file-name))
	   (visiting-buffer (find-buffer-visiting file-name))
	   (handler-entry (dp-sudo-edit-mk-handler-alist-entry file-name)))
      (add-to-list 'file-name-handler-alist handler-entry)
      (if visiting-buffer 
	  (let (point)
	    (switch-to-buffer visiting-buffer)
	    (when (buffer-modified-p)
	      (message "??! Buffer is modified !?? Save or revert first.")
	      (throw 'done nil))
	    (when dp-sudo-edit-handler-entry
	      (message "Already sudo editing this buffer")
	      (throw 'done nil))
	    (setq point (point))
            (dp-toggle-read-only nil)
	    (erase-buffer)
	    ;; revert will reread the file via our handlers.
	    (revert-buffer nil 'no-confirm)
	    (goto-char point))
	;; now find the file.  It will be opened with our handlers.
	;; insert-file-contents will set up a hook to discard this file's
	;; entry in the file-name-handler-alist.
	(find-file file-name)
	(goto-char (point-min)))
      ;; may want to do these in `insert-file-contents'
      ;; done there, *also*.
      ;; editing a file in a dse'd dired buf calls our handlers (esp to read)
      ;;  but not this fn.
      ;; using dse on a dir calls this fn, but not insert-file-contents
      ;; hence the need in both places.
      (unless dp-sudo-edit-handler-entry
	(dp-sudo-edit-common-setup handler-entry))
      ;; How could this have been missed for so long.
      ;; Each `dset?'d buffer ended up modified.
      ;; Something must've been lost.
      (set-buffer-modified-p nil)
      (throw 'done nil))))

;;;###autoload
(defalias 'dse 'dp-sudo-edit)

;;;###autoload
(defun dp-sudo-edit-this-file ()
  "Edit the current buffer w/sudo edit."
  (interactive)
  (let ((point (point)))
    (dp-sudo-edit (buffer-file-name))
    (goto-char point)))

;;;###autoload
(defalias 'dset 'dp-sudo-edit-this-file)
;;;###autoload
(defalias 'dse. 'dp-sudo-edit-this-file)

;;;###autoload
(defun dp-sudo-edit-devert ()
  "Stop sudo-editing this file.  Edit it normally."
  (interactive)
  (if (buffer-modified-p)
      (message "Buffer is modified. Save or revert first.")
    (let ((point (point)))
      (dp-sudo-edit-remove-handler-entry)
      (setq dp-sudo-edit-handler-entry nil)
      (dp-toggle-read-only nil)
      (dp-delete-extents (point-min) (point-max) 'dp-sudo-edit-bg-extent)
      (erase-buffer)
      ;; revert will reread the file via our handlers.
      (revert-buffer nil 'no-confirm)
      (string-match (format "\\(.*\\)%s" dp-sudo-edit-suffix) (buffer-name))
      (rename-buffer (match-string 1 (buffer-name)))
      (goto-char point))))

;;;###autoload
(defalias 'dsed 'dp-sudo-edit-devert)
(defalias 'devert 'dp-sudo-edit-devert)

;;;###autoload
(defun dp-dired-sudo-edit ()
  "In dired, sudo the file named on this line."
  (interactive)
  (let ((find-file-run-dired nil))
    (dp-sudo-edit (dired-get-filename))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Handle sudo when it needs a password.

(defvar dp-sudo-authentication-command dp-sudo-edit-sudoer
  "Call regular sudoer when (re)validating ourself.")

(defvar dp-sudo-authentication-args '("-v")
  "Arg to sudo (specifically) to (re)validate.  If `dp-sudo-edit-sudoer'
changes, this may need to change.")

(defvar dp-sudo-authentication-def-timeout '(30 0)
  "How long we wait for the sudoer to cough up a password prompt.
See `accept-process-output' for details of specifying a timeout.")

(defun dp-sudo-authentication-filter (proc string)
  (when (string-match comint-password-prompt-regexp string)
    (when (string-match "^[ \n\r\t\v\f\b\a]+" string)
      (setq string (replace-match "" t t string)))
    (process-send-string proc (concat (read-passwd string) "\n"))))
  
(defun dp-sudo-authentication-sentinel (proc status-msg)
  (unless (eq 'closed (process-status proc))
    (set-process-sentinel proc nil)
    (throw 'dp-sudo-authentication-done (process-exit-status proc))))

(defvar dp-sudo-authentication-function 'dp-sudo-authentication-sudo
  "Function what does sudo validation, login, etc.  That which allows us to use
sudoer.")
;;
;; unexp --> no program output, quick exit
;; exp --> program output, prompt user, send input, exit.
(defun dp-sudo-authentication-sudo (&rest args)
  "See man 8 sudo."
  (interactive)
  ;; start-process, add `comint-watch-for-password-prompt', wait for exit.
  ;; if `comint-watch-for-password-prompt' saw a password prompt, 
  ;; it should have handled it.
  (let ((sudo-proc (apply 'start-process 
                          "sudo authentication"
                          nil
                          dp-sudo-authentication-command  
                          dp-sudo-authentication-args))
        pstat)
    (set-process-sentinel sudo-proc 'dp-sudo-authentication-sentinel)
    (set-process-filter sudo-proc 'dp-sudo-authentication-filter)
    (setq pstat
          (catch 'dp-sudo-authentication-done
            (while t
              ;; Wait 30 sec for prompt to appear.
              (if (apply 'accept-process-output 
                         sudo-proc dp-sudo-authentication-def-timeout)
                  (dmessage "got some input.  Bad passwd?")
                ;; No output rx'd.  Since we're just waiting for the program to
                ;; give us a prompt, something must be wrong.  If we do get
                ;; output, we'll handle it in the sentinel and that will throw
                ;; back to us.
                ;; Kill the sob.
                (dmessage "Timed out waiting for %s to start up." 
                          dp-sudo-authentication-command)
                (process-send-signal 9 sudo-proc)
                (error 'process-error 
                       (format "Timed out waiting for %s to start up." 
                               dp-sudo-authentication-command))))))
    (if (equal pstat 0)
        ;; This'll get stomped immediately by the file name prompt.
        (message "Validation successful.")
      (error 'process-error (format "%s: Validation failed: %s" 
                                    dp-sudo-authentication-command pstat)))))

(defun dp-sudo-authenticate (&rest args)
  (interactive)
  (apply dp-sudo-authentication-function args))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Good thing for a dp-dot-emacs file.
;; (defvar dp-sudo-edit-password-required-p nil
;;   "Well, is it?")

;; (defvar dp-sudo-edit-password-key nil
;;   "If non-nil and `password-cache' is non-nil, cache password.
;; See `password-read'.")

;; (defvar dp-sudo-edit-password nil
;;   "Save password here if not caching.")

;; (defun dp-sudo-edit-read-password ()
;;   "Get password for sudoer.
;; Genericize and pass a struct with the parameters needed."
;;   (when dp-sudo-edit-password-required-p
;;     (let ((password (password-read (format "Sudo password%s: "
;;                                            (if dp-sudo-edit-password
;;                                                "resetting"
;;                                              ""))
;;                                            dp-sudo-edit-password-key)))
;;       (unless dp-sudo-edit-password-key
;;         (setq dp-sudo-edit-password password)))))
;; (add-hook 'dp-sudo-edit-load-hook 'dp-sudo-edit-read-password)

;; (run-hooks 'dp-sudo-edit-load-hook )

;;;
;;;
;;;
(provide 'dp-sudo-edit)
