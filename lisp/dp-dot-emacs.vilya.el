;;;
;;; $Id: dp-dot-emacs.sam.el,v 1.1 2004/11/28 09:20:03 davep Exp $
;;;
;;; local settings that vary from host to host
;;;

(setq dp-mail-fullname "David A. Panariti"
      dp-mail-user "davep"
      dp-mail-domain "meduseld.net"
      dp-mail-user "davep"
      dp-mail-outgoing-host "outgoing.verizon.net"
      mail-host-address "meduseld.net"
      mu4e-get-mail-command "mbsync.vilya"
      org-agenda-files (quote ("/home/davep/org/davep.org"))
      smtpmail-sendto-domain "meduseld.net"
      smtpmail-smtp-server "smtp.verizon.net"
      user-mail-address "davep@meduseld.net")

(defconst dp-vm-default-imap-folder
  "imap:vilya:143:INBOX:login:davep:bioshok"
  "My (dp) VM (vm) default (default) IMAP (imap) folder (folder).")

;; @info info path definitions
;; "/usr/local/lib/xemacs-21.4.15/info"
;; "/usr/local/lib/xemacs-21.5-b16/info"

(dp-add-list-to-list dp-info-path-var
                     (mapcar (lambda (dir-name)
                               (file-truename dir-name))
                             (dp-filter-dirs-by-file
                              (paths-directories-which-exist
                               (list "/usr/info"
                                     "/usr/local/info"
                                     "/usr/local/lib/xemacs-21.4.15/info"
                                     "/usr/local/lib/xemacs-21.5-b16/info"
                                     "/usr/local/lib/xemacs/xemacs-packages/info"
                                     "/usr/local/share/info"
                                     "/usr/share/info"
                                     "/usr/yokel/info"
                                     "/usr/yokel/sawmill-cvs/info"
                                     (dp-lisp-subdir "contrib/info")))
                              "dir")))
                     
;; fits the hp5l
(setq lpr-page-header-switches '("-F" "-l" "61"))

;;
;; see dp-mail.el
;; obsolete
(setq dp-fcc-alist '(
	  (("filko" "mel@digital\\.net" "thayer" "be_unique@" 
	    "gouge" "buchner" "woodruff" "dake")
	   ("to" "cc") "oldgang")
	  (nil ("to") "sent_mail")))

;;
;; Mew's gone to the dark side: FSF Emacs only.
;; mew's variables. see mew Info.
;; (setq dp-mew-case "home")

;; see dp-mail.el
;; (setq dp-sig-source '(dp-insert-file-sig "~/.signature"))
;;(setq dp-sig-source '(dp-insert-shell-cmd-sig "fortune" "-s"))
(setq dp-sig-source '(insert (dp-mk-baroque-fortune-sig)))

;; set appt countdown times
(setq appt-msg-countdown-list '(15 1))
(message "spec-macs (%s) done." (or (and (boundp 'spec-macs)
                                         spec-macs)
                                    (buffer-file-name)))

(setq dp-sfh-height 67
      dp-2w-frame-width 170)

(dp-add-list-to-list 
 'dp-ssh-host-name-completion-list
 '(("vilya" . t) ("tw" . "sentinels.vanu.com")
   ("owls" . "sentinels.vanu.com") ("sentinels" . "sentinels.vanu.com")))
 

;; this can be different on a per-host basis.  There's now a guesser that
;; checks for aspell, then ispell.  And we need to set dp-ispell-program-name
;; so we can tell if we set it vs it being a default set elsewhere.
;;(setq ispell-program-name "aspell")

(setq semantic-ectag-program "/usr/bin/exuberant-ctags")

(defvar dp-g++-include-dir-base "/usr/lib/gcc/i686-pc-linux-gnu/4.3.3/")
(defvar dp-g++-include-dirs
  (cons "/usr/include/"
        (dp-map-prefix 
         dp-g++-include-dir-base
         '(
;;""
;;           "finclude/"
;;           "include/"
;;           "include-fixed/"
;;           "include-fixed/schily/"
           "include/g++-v4/"
;;           "include/g++-v4/backward/"
;;           "include/g++-v4/bits/"
;;           "include/g++-v4/debug/"
;;           "include/g++-v4/ext/"
;;           "include/g++-v4/ext/pb_ds/"
;;           "include/g++-v4/ext/pb_ds/detail/"
;;           "include/g++-v4/ext/pb_ds/detail/basic_tree_policy/"
;;           "include/g++-v4/ext/pb_ds/detail/bin_search_tree_/"
;;           "include/g++-v4/ext/pb_ds/detail/binary_heap_/"
;;           "include/g++-v4/ext/pb_ds/detail/binomial_heap_/"
;;           "include/g++-v4/ext/pb_ds/detail/binomial_heap_base_/"
;;           "include/g++-v4/ext/pb_ds/detail/cc_hash_table_map_/"
;;           "include/g++-v4/ext/pb_ds/detail/eq_fn/"
;;           "include/g++-v4/ext/pb_ds/detail/gp_hash_table_map_/"
;;           "include/g++-v4/ext/pb_ds/detail/hash_fn/"
;;           "include/g++-v4/ext/pb_ds/detail/left_child_next_sibling_heap_/"
;;           "include/g++-v4/ext/pb_ds/detail/list_update_map_/"
;;           "include/g++-v4/ext/pb_ds/detail/list_update_policy/"
;;           "include/g++-v4/ext/pb_ds/detail/ov_tree_map_/"
;;           "include/g++-v4/ext/pb_ds/detail/pairing_heap_/"
;;           "include/g++-v4/ext/pb_ds/detail/pat_trie_/"
;;           "include/g++-v4/ext/pb_ds/detail/rb_tree_map_/"
;;           "include/g++-v4/ext/pb_ds/detail/rc_binomial_heap_/"
;;           "include/g++-v4/ext/pb_ds/detail/resize_policy/"
;;           "include/g++-v4/ext/pb_ds/detail/splay_tree_/"
;;           "include/g++-v4/ext/pb_ds/detail/thin_heap_/"
;;           "include/g++-v4/ext/pb_ds/detail/tree_policy/"
;;           "include/g++-v4/ext/pb_ds/detail/trie_policy/"
;;           "include/g++-v4/ext/pb_ds/detail/unordered_iterator/"
;;           "include/g++-v4/i686-pc-linux-gnu/"
;;           "include/g++-v4/i686-pc-linux-gnu/bits/"
;;           "include/g++-v4/parallel/"
;;           "include/g++-v4/tr1/"
;;           "include/g++-v4/tr1_impl/"
;;           "include/objc/"
))))
  
  (defun dp-ede-open-talismon-project ()
    "Just for testing/playing with CEDET..."
  (interactive)
  (ede-cpp-root-project "talisman" 
                        :file "/mnt/stuff/davep/work/talisman/talisman/README"
                        :system-include-path dp-g++-include-dirs
                        :include-path 
                        (dp-map-prefix 
                         "/Talisman/"
                         '("pod-zed-sa/lib0/include"
                           "pod-zed-sa/include"
                           "host/elfdump/include"
                           "ecos/patches/v1.2.10/hal/arm/arch/v1_2_10/include"
                           "ecos/patches/v1.2.10/hal/arm/edb7xxx/v1_2_10/include"
                           "include"
                           "pod-zed-ecos/talismon/include"
                           "pod-zed-ecos/talislib/include"
                           "include/extrinsic/cyg"
                           "include/extrinsic/cyg/hal"))))

(defvar dp-ts2-project-root
  "/mnt/stuff/davep/work/ts2/tstreams/")

(defun dp-ede-open-ts2-project ()
  "Just for testing/playing with CEDET.  
It's a little more challenging than talisman, C++ utilization wize."
  (interactive)
  (ede-cpp-root-project "ts2" 
                        :file (concat dp-ts2-project-root 
                                      "why-cant-ede-just-use-a-dir-name.cxx")
                        :system-include-path dp-g++-include-dirs
                        :include-path 
                        '("/util_lib/include"
                          "/av2/include")))

(defvar dp-wip-project-root
  "/home/davep/work-is-play/")

(defvar dp-ede-wip-project-opened-p nil
  "Has the wip project already been opened?")

(defun dp-ede-open-wip-project (&optional force-p)
  "Work is play... when work is right.
My dream job: let us play!"
  (interactive "P")
  (if (or force-p
          (not dp-ede-wip-project-opened-p))
      (let* ((root-dir dp-wip-project-root)
             (hat-hook-file-name (expand-file-name "ede-hat-hook.cc" root-dir))
             (hat-hook-buffer (dp-ede-make-hat-hook hat-hook-file-name)))
        (kill-buffer hat-hook-buffer)
        (add-to-list 'dp-semantic-enabled-file-name-p-pred-list root-dir)
        (ede-cpp-root-project "wip"
                              :file hat-hook-file-name
                              :system-include-path dp-g++-include-dirs
                              :include-path '("/include"))
        (find-file hat-hook-file-name)
        (dired-other-window root-dir))
    (message "wip project is already open."))
  (setq dp-ede-wip-project-opened-p t))

(defalias 'wip 'dp-ede-open-wip-project)
