(defun dp-in-to-tss-file (base-dir dir file ext)
  (interactive)
  ;;@todo  Return just new-name and let caller format???
  (format "%s%s/%s.%s"
          base-dir dir
          (progn
            (posix-string-match "\\(.*?\\)\\." (concat file "."))
            (match-string 1 file))
          ext))

(dp-add-to-list 'dp-file-infos '(tss in ("tss") (".")))
(dp-add-to-list 'dp-file-infos '(in tss ("in") (".") dp-in-to-tss-file))

(defvar ll-tc-le.ifaces 
  '(
    "fe80::207:e9ff:fe17:dbf6" "tc-le4/eth1"
    "fe80::207:e9ff:fe17:dbf7" "tc-le4/eth0"
    "fe80::207:e9ff:fe07:fb" "tc-le4/eth2"
    
    "fe80::207:e9ff:fe17:f660" "tc-le5/eth1"
    "fe80::207:e9ff:fe17:f661" "tc-le5/eth0"
    "fe80::207:e9ff:fe06:fafd" "tc-le5/eth2"
    
    "fe80::204:23ff:fec1:f1e0" "tc-le6/eth1"
    "fe80::204:23ff:fec1:f1e1" "tc-le6/eth0"
    "fe80::207:e9ff:fe07:19" "tc-le6/eth2")
  "Mapping from inet6 addr to machine/interface")

(defun ll-ip-info (ip &optional plist)
  "Get info about an IP address. PLIST defaults to ll-tc-le.ifaces."
  (interactive "sIP addr? ")
  (let ((r (lax-plist-get (or plist ll-tc-le.ifaces) ip)))
    (message "IP[%s] info: %s" ip r)
    r))

(defun ll-ips-to-names (&optional plist)
  "Replace raw ip addresses with names with a static mapping."
  (interactive)
  (let ((l (or plist ll-tc-le.ifaces)))
    (loop for (ip info) on l by 'cddr
      do (save-excursion
           (replace-string ip info nil)))))

(defvar tsat-bin "/home/davep/tsat-bin1/"
  "So we can change from running in tsat-bin for the IR and tsat-bin1 for the mainline.")

(defun mk-tsat-bin-name (&rest other-components)
  "Make a path name relative to the current value of `tsat-bin'."
  (expand-file-name (dp-string-join (cons tsat-bin other-components) "/")))

(defun ll-tmp-logs ()
  (interactive)
  (dired (mk-tsat-bin-name "tmp-arsvp-log-stream*") "-lt"))

(defun ll-teths ()
  (interactive)
  (dired (mk-tsat-bin-name "script-loop.tethereal*" "-lt")))

;; See doc for `dp-debug-like-patterns'
(add-to-list 'dp-local-debug-like-patterns (regexp-opt '("tmp_tx_rx_log")))

(defun ll-teth-back-section ()
  (interactive)
  (re-search-backward "^Frame")
  (dp-point-to-top nil))

(defun ll-teth-forward-section ()
  (interactive)
  (re-search-forward "^Frame")
  (dp-point-to-top nil))

;; Copy and exec this to do things
(when nil
  (progn
    (dp-define-buffer-local-keys '([(meta left)] ll-teth-back-section
                                   [(meta right)] ll-teth-forward-section))))

(setq compilation-search-path 
      '("/home/davep/work/ll/rsvp/RSVP2-testjig/src"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/api"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/api/generic"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients/generic"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients/unix"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/common"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/common/generic"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/common/unix"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/daemon"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/daemon/Linux"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/daemon/SunOS"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/daemon/generic"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/daemon/unix"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/extern"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/extern/generic"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/main"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/main/unix"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/ns2"
        "/home/davep/work/ll/rsvp/RSVP2-testjig/src/ns2/generic")

      dp-gdb-sudo-run-dir tsat-bin
      dp-gdb-sudo-cmd-name "./run-gdb"
      ;Yes, but with multiple branches, it's nice to see where I really am.
      find-file-use-truenames nil
)

(defvar  dp-gdb-cf-args
  (format "%s %s" (mk-tsat-bin-name "demos/dbra3c/c1/ir.in")
                                    "./cmd-factory")
  "Set envvar PROGRAM_ARGS to this before running gdb.
It will be used by the gdb set args command.")

(defvar dp-gdb-run-gdb-args "-c"
  "Args to the run-gdb program itself.")

(defvar dp-gdb-cf-history nil)

(defvar dp-gdb-cf-configs
  '(("qos3" . "tj/traces/qos3/ARSVP/qos3-agg1.in")
    ("d" . 
     "/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients/unix/demo-scripts/dbra/5.in")
    ("q4ir" . 
     "/home/davep/work/ll/rsvp/RSVP2-testjig/src/clients/unix/demo-scripts/qos3/qos3-ir-kim-KTRA.in")
    ("i" . "-i 56rc.in")
    ("c1" . "-i /home/davep/tsat-bin1/qos-c1-cfg.in")
    ("c2" . "-i /home/davep/tsat-bin1/qos-c2-cfg.in")
    ("q" . "-i qos-cfg.in")
    ("ir" . "-i ir-ir.in")
    ("nada" . "-i nada.in")
    ("iri" . "-i irrc.in"))
  "Some common configs.")

(defvar dp-gdb-cf-configs-completion-list
  (mapcar (function 
           (lambda (el)
             (list (format "=%s:%s" (car el) (cdr el)))))
          dp-gdb-cf-configs))

(defvar dp-gdb-default-func 'gdb-cf)

(defvar  dp-gdb-cf-Cu0-def-args (cdr-safe (assoc "c1" dp-gdb-cf-configs))
  "A convenient set of PROGRAM_ARGS for an interactive session.")

(defun gdb-cf (program &optional args)
  "Run PROGRAM \(\"cmd-factory\") using ${tsat-bin1}/simple-run-gdb.
This is a highly specific function, hence it inclusion is a fairly specific
rc file.
The purpose is to run a script \(simple-run-gdb) which sets up many useful
defaults for a gdb session and then runs sudo gdb on PROGRAM."
  (interactive (list
                (read-file-name (format "Run %s on file: " 
                                        dp-gdb-sudo-cmd-name)
                                tsat-bin
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
                                    dp-gdb-cf-history)))
                            (string-match "^\\(=[^:]+:\\)?\\(.*\\)$" s)
                            (match-string 2 s)))))
                 (t dp-gdb-cf-args))))
  (let ((gdb-command-name (mk-tsat-bin-name "run-gdb")))
    (setenv "PROGRAM_ARGS" args)
    (setenv "emacs_gdb" "t")
    ;;(setenv "out_of_date_ok" "y")
    (setq dp-gdb-buffer-name "*gdb-cmd-factory*")
    (gdb (or program (mk-tsat-bin-name "cmd-factory")))))

(defun gdb-dc (program &optional args)
  "Run PROGRAM \(\"demo-comm\") using ${tsat-bin}/simple-run-gdb.
This is a highly specific function, hence it inclusion is a fairly specific
rc file.
The purpose is to run a script \(simple-run-gdb) which sets up many useful
defaults for a gdb session and then runs sudo gdb on PROGRAM."
  (interactive (list
                (read-file-name (format "Run %s on file: " 
                                        dp-gdb-sudo-cmd-name)
                                tsat-bin
                                nil
                                'non-nil-and-non-t
                                "cmd-factory"
                                'dp-gdb-sudo-history)
                (cond
                 ((Cu0p) dp-gdb-cf-Cu0-def-args)
                 (current-prefix-arg 
                  (setq dp-gdb-cf-args 
                        (read-string "ARGS? " dp-gdb-cf-args 
                                     dp-gdb-cf-history)))
                 (t dp-gdb-cf-args))))
  (let ((gdb-command-name (mk-tsat-bin-name "simple-run-gdb")))
    (setenv "PROGRAM_ARGS" args)
    (and-boundp dp-gdb-run-gdb-args (setenv "RUN_GDB_ARGS" dp-gdb-run-gdb-args))
    (dp-gdb "/home/davep/tsat-bin/demo-comm")))

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

(defun dp-ll-spiral-default-makefile-name (&rest unused)
  "Return a more specific makefile."
  (when (posix-string-match "RSVP2-testjig" (default-directory))
    "/home/davep/work/ll/rsvp/RSVP2-testjig/makefile"))

(add-hook 'dp-default-makefile-name 'dp-ll-spiral-default-makefile-name)

(defun gwins ()
  "set up comvenient gdb windows."
  (interactive)
  (delete-other-windows)
  (split-window-horizontally)
  (other-window 1)
  (split-window-vertically))


;; A completion list for common host names as used with dp-ssh.
;; The elements must needs be conses; the . t is unused (at least for now.)
(dp-add-list-to-list 
 'dp-ssh-host-name-completion-list
 `(("tc-le3" . t) ("tc-le4" . t) ("tc-le5" . t) ("tc-le6" . t)
   ("dnstve0-ws1" . t) ("dnstve0-ws2" . t) ("dnstve1-man" . t)
   ("dnstve2-man" . t) ("dnstve0-mon" . t)
   ("z10" . t) ("z11" . t) ("z12" . t) ("z13" . t) ("z14" . t) ("z15" . t)
   ("z16" . t) ("z17" . t) ("z18" . t) ("z19" . t)
   ("mon0" . ,(dp-plist-put nil 'ip-addr "172.18.6.4"))
   ("g65svn" . t)
   ))

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

(add-hook 'text-mode-hook 'dp-ll-rsvp-text-mode-hook)
