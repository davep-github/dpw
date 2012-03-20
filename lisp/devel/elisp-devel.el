
========================
Monday March 05 2012
--

(cl-pe '(defun dp-list-subtract (l1 l2)
  "Return L1 with all elements of L2 removed."
  (loop for b in l1
    when (not (memq b l2))
    collect b)))

(defun dp-list-subtract (l1 l2)
  "Return L1 with all elements of L2 removed."
  (block nil
    (let* ((G117651 l1)
           (b nil)
           (G117652 nil))
      (while (consp G117651)
        (setq b (car G117651))
        (if (not (memq b l2)) (setq G117652 (cons b G117652)))
        (setq G117651 (cdr G117651)))
      (nreverse G117652))))nil

(dp-list-subtract '(w d c j f e j d s a) '(a c e))
(w d j f j d s)






(let* ((win-buffers
        (mapcar (lambda (win)
                  (window-buffer win))
                (window-list)))
       (buffers (delq nil (mapcar (lambda (buf)
                          (if (memq buf win-buffers)
                              nil
                            buf))
                        (buffer-list)))))
  (list win-buffers buffers))


(buffer-list)

(dp-all-window-buffers)
(#<buffer "elisp-devel.el"> #<buffer "*info*">)

(dp-non-window-buffers)

(dp-first-by-pred (lambda (e)
                    (eq e 'q))
                  '(a f 5 g q w g t))
(q w g t)




;;older; (defun* dp-layout-windows (op-list &optional other-win-arg 
;;older;                            (delete-other-windows-p t))
;;older;   "Layout windows trying to keep as many buffers visible as possible.
;;older; !<@todo XXX MAKE SURE THE CURSOR STAYS IN THE SAME PLACE."
;;older;   ;; Save the original list of buffers displayed in windows.
;;older;   (let ((original-window-buffers (dp-all-window-buffers)))
;;older;     (when delete-other-windows-p
;;older;       (delete-other-windows))
;;older;     ;; Set up the new window pattern.
;;older;     (let ((skip-these-windows (list (get-buffer-window (current-buffer))))
;;older;           (win-list (window-list))
;;older;           (buf-list (buffer-list)))
;;older;       (loop for op in op-list
;;older;         do (let (op-args)
;;older;              (if (listp op)
;;older;                  (eval op)
;;older;                (apply op op-args))))
;;older;       (when other-win-arg
;;older;         (other-window other-win-arg))
;;older;       (dp-distribute-buffers original-window-buffers
;;older;                              :skip-these-windows skip-these-windows))))

(listp 'other-window)
nil

(let ((op '(split-window)))
  (dp-aif op
    (eval op)))

(eval '(dmessage "blah"))
"blah"

;;(cl-pe

(let ((op (or dp-layout-compile-windows-func 'split-window-vertically)))
  (unless (listp op)
    (setq op (list op)))
  (dp-aif (op)
    (eval op)))

(dp-layout-compile-windows-func)
nil

nil

nil

nil

nil

nil

nil

#<window on "elisp-devel.el" 0x7fbeea31>

#<window on "elisp-devel.el" 0x7fb7c783>


#<window on "elisp-devel.el" 0x7fb43a7c>

#<window on "elisp-devel.el" 0x7f6ad716>


nil
(let ((op '(other-window 1)))
  (dp-aif (op)
    (eval op)))



'
(let ((op '(progn (princf "yee haw!"))))
  (dp-aif (op)
    (eval op)))
yee haw!
nil

yee haw!
nil

nil

#<window on "elisp-devel.el" 0x7f1e7294>


nil
nil
#<window on "elisp-devel.el" 0x7f136f0d>

(let ((op '(other-window 1)))
  (dp-aif (op)
    (eval op)))

(let ((op '(other-window 1)))
  (dp-aif (op)
    (eval op)))

aif-away!!!
nil

nil

(dp-aif split-window)



ll)
(let ((op (quote split-window))) (dp-aif op))




(apply 'progn '(princf "yadda"))



(functionp 'progn)
t



========================
Tuesday March 06 2012
--

nil

dp-c-mark-current-token


========================
Monday March 12 2012
--

(defun* dp-clr-shell0 (&key
                       (clear-fun 'erase-buffer)
                       (clear-args '())
                       dont-fake-cmd 
                       dont-preserve-input)
  "Clear shell window and remembered command positions."
  (interactive)
  (setq dp-shell-last-parse-start 0
	dp-shell-last-parse-end 0)
  (let* ((cur-input (buffer-substring (dp-current-pmark-pos) (point-max))))
    (kill-region (dp-current-pmark-pos) (point-max))
    (when (y-or-n-p "Save contents first? ")
      (dp-save-shell-buffer))
    (apply clear-fun clear-args)
    (unless dont-fake-cmd
      (funcall dp-shell-type-enter-func 
	       (dp-shell-buffer-type (buffer-name)))) ;; get us a prompt
    (dp-shell-init-last-cmds)
    (unless dont-preserve-input
      (dp-end-of-buffer)
      (insert cur-input))))

(defun dp-clr-shell (really-clear-p &optional dont-fake-cmd dont-preserve-input)
  (interactive "P")
  (if (or really-clear-p
          (eq last-command 'dp-clr-shell)
          ;; too many accidental real clears, when triggering a real clear by
          ;; 2 clear commands in a row.  so use only prefix arg to wipe
          ;; history
          nil)                          ;see if I like it.
      (dp-clr-shell0 :clear-fun 'erase-buffer
                     :dont-fake-cmd dont-fake-cmd 
                     :dont-preserve-input dont-preserve-input)
    (dp-clr-shell0 
     :dont-fake-cmd dont-fake-cmd 
     :dont-preserve-input  dont-preserve-input
     :clear-fun (lambda ()
                  (let (point
                        (old-point-max (point-max)))
                    ;; See if we're over the max.
                    (when (> (line-number (point-max)) 
                             dp-shell-buffer-max-lines)
                      (dp-end-of-buffer)
                      (forward-line (- dp-shell-buffer-max-lines))
                      ;; move back to previous command so that we have the
                      ;; entire command still in the history
                      (setq point (point))
                      (dp-shell-goto-prev-cmd-pos)
                      (if (> (point) point) ;did we wrap?
                          (goto-char point))
                      ;; Remove all of the command positions before the
                      ;; truncation point.  They're all markers so the
                      ;; remaining ones should adjust themselves.
                      (dp-shell-trim-command-positions (point))
                      (delete-region (point-min) (point))
                      ;; now, adjust all of the command positions They're
                      ;; markers now.
                      ;;(dp-shell-adjust-command-positions (- old-point-max
                      ;;(point-max)))
                      )
                    (dp-end-of-buffer)
                    (dp-point-to-top 1)
                    )))))
