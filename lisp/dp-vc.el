;;
;; vc (not just vc.el) hacks, etc.
;;
(defun dp-diff-mode-goto-vc-dir ()
  (interactive)
  ;; Fix this since there can be >1 dirs.
  ;; ?Add switched-to-time as a BLV?
  (switch-to-buffer-other-window "*vc-dir*"))
