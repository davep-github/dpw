;;
;; vc (not just vc.el) hacks, etc.
;;
(defun dp-diff-mode-goto-vc-dir ()
  (interactive)
  ;; Fix this since there can be >1 dirs.
  ;; ?Add switched-to-time as a BLV?
  (switch-to-buffer-other-window "*vc-dir*"))

(defadvice vc-diff (around dp-vc-advice activate)
  (dp-push-window-config)
  (dp-offer-to-start-editing-server)
  ad-do-it
  (local-set-key [(control ?c) (control ?c)] 
                 'dp-kill-buffer-and-pop-window-config))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; git
;;;

(defconst pcmpl-git-commands
  '("add"
    "bisect"
    "branch" "br"
    "checkout" "co"
    "clone"
    "commit" "ci"
    "diff"
    "fetch"
    "grep"
    "init"
    "log"
    "merge"
    "mv" "pull"
    "push"
    "rebase"
    "reset"
    "rm"
    "show"
    "status" "st"
    "tag" )
  "List of `git' commands")

(defvar pcmpl-git-ref-list-cmd "git for-each-ref refs/ --format='%(refname)'"
  "The `git' command to run to get a list of refs")

(defun pcmpl-git-get-refs (type)
  "Return a list of `git' refs filtered by TYPE"
  (with-temp-buffer
    (insert (shell-command-to-string pcmpl-git-ref-list-cmd))
    (goto-char (point-min))
    (let ((ref-list))
      (while (re-search-forward (concat "^refs/" type "/\\(.+\\)$") nil t)
        (add-to-list 'ref-list (match-string 1)))
      ref-list)))

(defun pcomplete/git ()
  "Completion for `git'"
  ;; Completion for the command argument.
  (pcomplete-here* pcmpl-git-commands)
  ;; complete files/dirs forever if the command is `add' or `rm'
  (cond
   ((pcomplete-match (regexp-opt '("add" "rm")) 1)
    (while (pcomplete-here (pcomplete-entries))))
   ;; provide branch completion for the command `checkout'.
   ((pcomplete-match (regexp-opt '("checkout" "co") 1))
    (pcomplete-here* (pcmpl-git-get-refs "heads")))))

(provide 'dp-vc)
