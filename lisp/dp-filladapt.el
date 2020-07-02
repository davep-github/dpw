(dmessage "Loading dp-filladapt...")

;;; ********************
;;; "Filladapt is a paragraph filling package.  When it is enabled it
;;; makes filling (e.g. using M-q) much much smarter about paragraphs
;;; that are indented and/or are set off with semicolons, dashes, etc."
;;; (copped from sample.init.el)
;;;

;; It's now in elpa.
(require 'filladapt)

(setq-default filladapt-mode t)
(add-hook 'outline-mode-hook 'turn-off-filladapt-mode)
(setq filladapt-mode-line-string " Fa")

;;
;; Halfhearted attempt to fall back to auto-fill.
;;
(defun dp-turn-on-auto-fill ()
  (if (fboundp 'turn-on-filladapt-mode)
      (turn-on-filladapt-mode))
  (turn-on-auto-fill))

(defun dp-turn-off-auto-fill ()
  (if (fboundp 'turn-off-filladapt-mode)
      (turn-off-filladapt-mode))
  (auto-fill-mode 0))

(defvar dp-filladapt-state-stack nil
  "Stack of filladapt on/off statii")

(defun dp-push-filladapt-state (on-p)
  (setq dp-filladapt-state-stack
	(cons filladapt-mode dp-filladapt-state-stack))
  (if on-p
      (turn-on-filladapt-mode)
    (turn-off-filladapt-mode)))

(defun dp-pop-filladapt-state ()
  (let ((on-p (car dp-filladapt-state-stack)))
    (setq dp-filladapt-state-stack
	  (cdr dp-filladapt-state-stack))
    (if on-p
	(turn-on-filladapt-mode)
      (turn-off-filladapt-mode))))


(provide 'dp-filladapt)

(dmessage "Loading dp-filladapt...done")
