
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



;; I cannot believe I really need to write this. I must've missed it.
(defun dp-first-by-pred (pred list &rest pred-args)
  (while (not (apply pred (car list) pred-args))
    (setq list (cdr list)))
  list)


(defun dp-list-subtract (l1 l2)
  "Return L1 with all elements of L2 removed."
  (loop for b in l1
    when (not (memq b l2))
    collect b))

(defun dp-all-window-buffers (&optional win-list frame first-window)
  (mapcar (lambda (win)
            (window-buffer win))
          (window-list frame 'no-minibuffers first-window)))

(defun dp-non-window-buffers (&optional buf-list win-list)
  (setq-ifnil buf-list (buffer-list)
              win-list (dp-all-window-buffers))
  (dp-list-subtract buf-list win-list))


(defun dp-distribute-buffers (priority-buffers
                              &optional buf-list win-list frame first-window)
  "Distribute the buffers, 1 per window until no more buffers."
  (setq-ifnil buf-list (buffer-list)
              win-list (window-list frame 'no-minibuffers
                                    first-window))
  (let* ((buf-list (dp-list-subtract buf-list priority-buffers))
         (all-buffers (append priority-buffers buf-list)))
    (loop for w in win-list
      until (not all-buffers)
      do (let ((good-bufs (dp-first-by-pred
                           (lambda (b)
                             (and b
                                  (not (memq b (dp-all-window-buffers)))
                                  (not (dp-minibuffer-p b))))
                           all-buffers)))
           (when good-bufs
             (set-window-buffer w (car good-bufs)))
           (setq all-buffers (cdr good-bufs))))))


(setq dp-win-buffers (dp-all-window-buffers))
(#<buffer "elisp-devel.el"> #<buffer "*info*"> #<buffer "*shell*<0>">)
(dp-distribute-buffers dp-win-buffers)



(defun* dp-layout-windows (op-list &optional other-win-arg 
                           (delete-other-windows-p t))
  "Layout windows trying to keep as many buffers visible as possible.
!<@todo XXX MAKE SURE THE CURSOR STAYS IN THE SAME PLACE."
  ;; Save the original list of buffers displayed in windows.
  (let ((original-window-buffers (dp-all-window-buffers)))
    (when delete-other-windows-p
      (delete-other-windows))
    ;; Set up the new window pattern.
    (let ((win-list (window-list))
          (buf-list (buffer-list)))
      (loop for op in op-list
        do (let (op-args)
             (if (listp op)
                 (setq op-args (cdr op)
                       op (car op)))
             (apply op op-args)))
      (when other-win-arg
        (other-window other-win-arg)))
    (dp-distribute-buffers original-window-buffers)
    ))





