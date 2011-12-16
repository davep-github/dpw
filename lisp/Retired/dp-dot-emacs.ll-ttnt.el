(defvar dp-gdb-commands
  '("." ("dir /home/davep/work/ll/ttnt/pkt-gen/src"
         "dir /home/davep/work/ll/ttnt/pkt-gen/include"
         "dir /home/davep/work/ll/ttnt/pkt-gen/obj"
         "set history save on"
         "set history size 10240"
         "set logging on"
         "set listsize 32"
         "set args --davep"))
  "Feed these into gdb when it starts up with `dp-gdb'.
It's an alist keyed by things like node, project, whatever.  A default key,
\".\" may be present.")

;; See =.ll-spiral for some ideas.

(defvar dp-current-debug-bin-dir "/home/davep/work/ll/ttnt/pkt-gen/bin")

(defun mk-dp-current-debug-bin-name (&rest other-components)
  "Make a path name relative to the current value of `dp-current-debug-bin-dir'."
  (when other-components
    (paths-construct-path other-components dp-current-debug-bin-dir)))

;; See doc for `dp-debug-like-patterns'
(add-to-list 'dp-local-debug-like-patterns (regexp-opt '("tmp_tx_rx_log")))

;; Copy and exec this to do things
(when nil
  (progn
    (dp-define-buffer-local-keys '([(meta left)] ll-teth-back-section
                                   [(meta right)] ll-teth-forward-section))))

(setq compilation-search-path
      '("/home/davep/work/ll/ttnt/pkt-gen/src"
        "/davep/work/ll/ttnt/pkt-gen/include"
        "/davep/work/ll/ttnt/pkt-gen/obj")
      
      dp-gdb-sudo-run-dir dp-current-debug-bin-dir
      dp-gdb-sudo-cmd-name (paths-construct-path '("bin") (getenv "HOME"))
      ;;Yes, but with multiple branches, it's nice to see where I really am.
      find-file-use-truenames nil)

(defvar dp-gdb-run-gdb-args ""
  "Args to the run-gdb program itself.")

(defvar dp-gdb-current-history nil)

(defvar dp-gdb-cf-configs
  '(("pkg-gen" . ""))
  "Some common configs.  (cfg-name . program args)")

(defvar dp-gdb-cf-configs-completion-list
  (mapcar (function 
           (lambda (el)
             (list (format "=%s:%s" (car el) (cdr el)))))
          dp-gdb-cf-configs))

(defvar dp-gdb-default-func 'gdb-cf)

(defvar  dp-gdb-cf-Cu0-def-args (cdr-safe (assoc "c1" dp-gdb-cf-configs))
  "A convenient set of PROGRAM_ARGS for an interactive session.")

(defun gdb-cf (program &optional args)
  "Run PROGRAM \(\"cmd-factory\") using ${dp-current-debug-bin-dir1}/simple-run-gdb.
This is a highly specific function, hence it inclusion is a fairly specific
rc file.
The purpose is to run a script \(simple-run-gdb) which sets up many useful
defaults for a gdb session and then runs sudo gdb on PROGRAM."
  (interactive (list
                (read-file-name (format "Run %s on file: " 
                                        dp-gdb-sudo-cmd-name)
                                dp-current-debug-bin-dir
                                nil
                                'non-nil-and-non-t
                                "cmd-factory"
                                'dp-gdb-sudo-history)
                (cond
                 ((Cu0p) dp-gdb-cf-Cu0-def-args)
                 (current-prefix-arg 
                  (setq dp-gdb-cf-args 
                        (progn
                          (let ((s (completing-read 
                                    "ARGS? " 
                                    dp-gdb-cf-configs-completion-list nil nil 
                                    dp-gdb-cf-args 
                                    dp-gdb-current-history)))
                            (string-match "^\\(=[^:]+:\\)?\\(.*\\)$" s)
                            (match-string 2 s)))))
                 (t dp-gdb-cf-args))))
  (let ((gdb-command-name (mk-dp-current-debug-bin-name "run-gdb")))
    (setenv "PROGRAM_ARGS" args)
    (setenv "emacs_gdb" "t")
    ;;(setenv "out_of_date_ok" "y")
    (setq dp-gdb-buffer-name "*gdb-cmd-factory*")
    (gdb (or program (mk-dp-current-debug-bin-name "cmd-factory")))))

(defun gdb-dc (program &optional args)
  "Run PROGRAM \(\"demo-comm\") using ${dp-current-debug-bin-dir}/simple-run-gdb.
This is a highly specific function, hence it inclusion is a fairly specific
rc file.
The purpose is to run a script \(simple-run-gdb) which sets up many useful
defaults for a gdb session and then runs sudo gdb on PROGRAM."
  (interactive (list
                (read-file-name (format "Run %s on file: " 
                                        dp-gdb-sudo-cmd-name)
                                dp-current-debug-bin-dir
                                nil
                                'non-nil-and-non-t
                                "cmd-factory"
                                'dp-gdb-sudo-history)
                (cond
                 ((Cu0p) dp-gdb-cf-Cu0-def-args)
                 (current-prefix-arg 
                  (setq dp-gdb-cf-args 
                        (read-string "ARGS? " dp-gdb-cf-args 
                                     dp-gdb-current-history)))
                 (t dp-gdb-cf-args))))
  (let ((gdb-command-name (mk-dp-current-debug-bin-name "simple-run-gdb")))
    (setenv "PROGRAM_ARGS" args)
    (and-boundp dp-gdb-run-gdb-args (setenv "RUN_GDB_ARGS" dp-gdb-run-gdb-args))
    (dp-gdb "/home/davep/dp-current-debug-bin-dir/demo-comm")))

(defun dp-ll-spiral-make-ssh-host-name (shell-id)
  (when (numberp shell-id)
    (cond
     ((and (>= shell-id 1) (< shell-id 10))
      (format "tc-le%d" shell-id))
     ((and (>= shell-id 10) (< shell-id 20))
      (format "z%d" shell-id)))))

(setq dp-shells-ssh-host-name-fmt "tc-le%s"
      dp-shells-ssh-buf-name-fmt "*ssh-%s*"
      dp-shells-ssh-buf-name-regexp-fmt "\\*ssh-tc-le%s\\*\\(<%s>\\)?"
      dp-shells-make-ssh-host-name-fp 'dp-ll-spiral-make-ssh-host-name)

(defun dp-initial-window-config ()
  "Set up windows, sizes, etc.
This can be set per spec-macs. and the last to override it wins."
  (interactive)
  ;; I like a little bit of a margin.
  (sfw (or dp-2w-frame-width 
           (setq dp-2w-frame-width 168)))
  (dp-2-vertical-windows))

(defun dp-ll-spiral-default-makefile-name (&rest unused)
  "Return a more specific makefile."
  (when (posix-string-match "RSVP2-testjig" (default-directory))
    "/home/davep/work/ll/rsvp/RSVP2-testjig/makefile"))

(add-hook 'dp-default-makefile-name 'dp-ll-spiral-default-makefile-name)

(defun dp-sshes (&rest hosts)
  "Open ssh windows on our favourite hosts."
  (interactive)
  (loop for host in (or hosts '("tc-le3" "tc-le4" "tc-le5" "tc-le6")) do
       (dp-ssh host)))

(defun tsat ()
  "Insert marked tsat code."
  (interactive)
  (db nil "davep: for tsat" nil))


(defun dp-ll-rsvp-text-mode-hook()
  (interactive)
  ;; Handle some TSAT/ARSVP extensions differently
  (when (dp-match-buffer-name 
         "\\(^tmp-arsvp-log-stream\\..*$\\|\\.in\\(\\.kim\\)?\\)")
    (setq truncate-lines nil)
    (flyspell-mode-off)
    (auto-fill-mode -1)))

(defvar ttnt-debug-cfg1-register (dp-allocate-register)
  "Register to hold window config in `ttnt-debug-cfg1-register'.")

(defun ttnt-debug-cfg1 ()
  (interactive)
  (dp-ssh "tc-le5")
  (dp-ssh "tc-le6")
  (dp-shell)                            ; tc-le4's local shell.
  (dp-1+2-wins)                         ; | |-|
  ;; we're in top right
  (dp-shell 0)
  (other-window 1)
  ;; bottom right
  (dp-shell 6)
  (other-window 1)
  ;; left
  (dp-shell 5)
  (window-configuration-to-register ?1))

(defun ttnt-debug-cfg2 ()
  (interactive)
  (dp-ssh "tc-le5")
  (dp-ssh "tc-le6")
  (dp-shell)                            ; tc-le4's local shell.
  (dp-1+2-wins)                         ; | |-|
  ;; we're in top right
  (dp-shell 5)
  (other-window 1)
  ;; bottom right
  (dp-shell 6)
  (other-window 1)
  ;; left
  (dp-shell 0)
  (window-configuration-to-register ?2))

(defun ttnt-debug-cfg-src-multi-sink ()
  (interactive)
  (dp-ssh "tc-le5")                     ; src
  (dp-shell)                            ; multi-sink
  (2w)
  ;; in left window
  (dp-shell 5)
  (other-window 1)
  (dp-shell 0)
  (window-configuration-to-register ?3)
  (window-configuration-to-register ?m))

;; Current favorite.
(defalias 'ttnt-debug-cfg 'ttnt-debug-cfg-src-multi-sink)

(add-hook 'text-mode-hook 'dp-ll-rsvp-text-mode-hook)

(setq gdb-command-name "irserv-gdb")

(require 'hideif)
;; From pg/Makefile
;; PKT_GEN_DEFS = -DPG_TIMING -DDEBUG -UTESTING_SINK_PKT_LOSS -DADD_INTERPACKET_DELAY
;;!<@todo Make a function to extract these, or add python code to
;;mk-build-info.py to stick it in the info file in an ifdef in a form
;;suitable for `dp-eval-lisp@point'.
(setq hide-ifdef-env  '(("PG_TIMING" . 1)
                        ("DEBUG" . 1)
;;                        ("TESTING_SINK_PKT_LOSS" . nil)
                        ("ADD_INTERPACKET_DELAY" 1)))

(dp-add-list-to-list 'hide-ifdef-define-alist
                     '((dbg DEBUG)
                       (timing PG_TIMING)
                       (cur DEBUG PG_TIMING)))
                       
(hide-ifdef-use-define-alist 'cur)


(setq dp-gdb-commands 
      (acons "tc-le4" 
             '("set args --send-remote-options='--version --exit-after-version'")
             dp-gdb-commands))

(setq dp-gdb-commands 
      (acons "tc-le5" 
             '("set args --remote-controller=tc-le4 --remote-options")
             dp-gdb-commands))
  

