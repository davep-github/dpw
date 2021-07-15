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

(provide 'dp-vc)
