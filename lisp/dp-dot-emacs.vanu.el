(defvar dp-sudo-edit-password-required-p t
  "Well, is it?")


(dp-add-list-to-list 
 'dp-ssh-host-name-completion-list
 '(("vilya" . t) ("timberwolves" . t)))

(setq dp-mail-domain-work "vanu.com"
      dp-mail-fullname "David A. Panariti"
      dp-mail-user "davep"      
      dp-mail-domain dp-mail-domain
      dp-mail-user "davep"
      dp-mail-outgoing-host "smtp.vanu.com")

(defvar dp-vm-default-imap-folder
  "imap-ssl:imap.vanu.com:993:INBOX:login:davep:pwds-suck")

(defvar dp-vanu-gnus-sig  "~/.sig.vanu"
  "Vanu gnus sig file name.")

(defun dp-tame-sig-source ()
  (dp-tame-sig-source-internal `(file . ,dp-vanu-gnus-sig)))

(defun dp-tame-sig-string ()
  (dp-read-file-as-string dp-vanu-gnus-sig))

(defun dp-insert-tame-sig (&rest args)
  ;; Make a 1 time recursive call (since we're passing sig-source as a
  ;; string.)  But this means the "--" will be inserted twice.  Hence the
  ;; 'no--p.
  (dp-maybe-insert-sig (dp-tame-sig-string) nil 'no--p))

(setq dp-sig-source '(function . dp-insert-tame-sig))
;; Secondary, but will be invoked by `dis' (q.v.)
(setq dp-sig-source '(expr . (insert (dp-mk-baroque-fortune-sig))))

(setq semantic-ectag-program "exuberant-ctags")

(setq dp-main-project-root 
      "/home/davep/work/vanu/sandboxen/perf-anal/montserrat/code/")

(setq dp-main-project-includes
      '("/Agentpp/snmp++/include"
        "/Agentpp/agent++/include"
        "/Agentpp/agent++/examples/atm_mib/include"
        "/Agentpp/agent++/examples/cmd_exe_mib/include"
        "/Agentpp/agentX++/include"
        "/Agentpp/agentX++/examples/subagent/include"
        "/include"))

(defvar dp-EDE-main-project nil
  "The main project upon which we are working.")

(defun dp-EDE-setup-main-project (&rest r)
  "Setup EDE for the current/main project."
  (interactive)
  (setq dp-EDE-main-project
        (ede-cpp-root-project 
         "pamc"
         :name "Perf-anal Monserrat Code."
         :file (paths-construct-path '("a-top-level-src-file.cc") 
                                     dp-main-project-root)
         :include-path dp-main-project-includes
         :spp-table '(("EIFFEL_CHECK" (symbol "CHECK_ALL" 96 . 105))
                      ("HAVE_DLFCN_H" (number "1" 128 . 129))
                      ("HAVE_STRING_H" (number "1" 354 . 355))
                      ("PACKAGE_TARNAME" (string "" 665 . 667))
                      ("HAVE_LIBLOG4CPP" (number "1" 182 . 183))
                      ("HAVE_STL" (number "1" 330 . 331))
                      ("STDC_HEADERS" (number "1" 718 . 719))
                      ("HAVE_MEMORY_H" (number "1" 207 . 208))
                      ("HAVE_STDLIB_H" (number "1" 282 . 283))
                      ("PACKAGE_STRING" (string "" 637 . 639))
                      ("HAVE_STRINGS_H" (number "1" 380 . 381))
                      ("MONTSERRAT_VERSION" (string "1.7.0+svn" 516 . 527))
                      ("PACKAGE_BUGREPORT" (string "" 555 . 557))
                      ("HAVE_STD_NAMESPACE" . nil)
                      ("ANSI" (number "1" 27 . 28))
                      ("HAVE_STDINT_H" (number "1" 257 . 258))
                      ("HAVE_UNISTD_H" (number "1" 486 . 487))
                      ("PACKAGE_VERSION" (string "" 693 . 695))
                      ("VERSION" (string "1.7.0+svn" 737 . 748))
                      ("HAVE_NAMESPACES" . nil)
                      ("HAVE_SYS_TYPES_H" (number "1" 435 . 436))
                      ("PACKAGE" (string "Montserrat" 575 . 587))
                      ("HAVE_INTTYPES_H" (number "1" 155 . 156))
                      ("HAVE_SYS_STAT_H" (number "1" 407 . 408))
                      ("PACKAGE_NAME" (string "" 610 . 612))
                      ("BANNER_VERSION" (string "Development-version" 52 . 73))
                      ("HAVE_THROW_SPECS" . nil)
                      ("__const" . "const")
                      ("__restrict" . nil)
                      ("__THROW" . nil)))))

(defun dp-work-file-name-p-guts ()
  (if (dp-file-in-dirs-and (list dp-main-project-root)
                           nil
                           nil
                            'dp-c*-code-file-p)))
      (or (dmessage "is") t)
    (and (dmessage "is not") nil)))

;; WTFF? (if names are starting with /, this means, that path is specified
;; relative to project's root directory)
;;CO;    :include-path (mapcar (lambda (d)
;;CO;                            (paths-construct-path (list d)
;;CO;                                                  dp-main-project-root))
;;CO;                          dp-main-project-includes)))
