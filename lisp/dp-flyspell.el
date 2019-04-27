;;;
;;; $Id: dp-flyspell.el,v 1.15 2004/04/07 08:20:03 davep Exp $
;;;
;;; flyspell setup
;;;

(setq flyspell-use-meta-tab nil)
(require 'flyspell)

(defcustom dp-flyspell-hooks
  '(text-mode-hook
    )
  "List of hooks to add `flyspell-mode' to."
  :group 'dp-vars
  :type '(repeat (symbol :tag "Major mode")))

(defcustom dp-flyspell-prog-hooks
  '(c-mode-common-hook
    python-mode-hook
    lisp-interaction-mode-hook
    emacs-lisp-mode-hook
    sh-mode-hook
    cperl-mode-hook
    ruby-mode-hook
    makefile-mode-hook
    asm-mode-hook
    )
  "List of hooks to add `flyspell-prog-mode' to.
Flyspell programming mode only checks spelling in strings and comments."
  :group 'dp-vars
  :type '(repeat (symbol :tag "Major mode")))

;;;###autoload
(defun dp-flyspell-setup0 (hook-list default-mode-func &optional force)
  (interactive)
  (dmessage "dp-flyspell-setup0: hook-list>%s<" hook-list)
  ;; start up the spelling process now.  And wait a bit.
  ;; This fixes a problem with 21.5.16
  ;; My theory is that when *scratch* is edited and goes into flyspell-prog
  ;; mode the process isn't initialized yet, and something looks into the
  ;; process buffer (? for a version ?) something gets an args out of range
  ;; error.  seems ok w/o sit-for...
  (flyspell-mode-on)
  ;;(sit-for 0.5)
  (flyspell-mode-off)

  (when (or force (dp-using-flyspell-p))
    (dmessage "force: %s" force)
    (dolist (hook-var hook-list)
      (dmessage "hook-var: %s" hook-var)
      (let (hook-val)
	(cond
	 ((functionp hook-var) (funcall hook-var))
	 ((consp hook-var) (setq hook-val (cdr hook-var)
				 hook-var (car hook-var)))
	 (t (setq hook-val `(lambda () (,default-mode-func 1)))))
	(when hook-val
	  (dmessage "var: %s, val: %s" hook-var hook-val)
	  (add-hook hook-var hook-val))))
    )
  )

;; !<@todo XXX flyspell mode allows us to put a mode-predicate on the
;; major-mode's symbol. It uses this to set `flyspell-generic-check-word-p'
;; Which is, in prog mode, `flyspell-generic-progmode-verify'
;; Using a hook allows us to do more processing to set things up.

(defun dp-flyspell-mode-hook ()
  (interactive)
  ;; Take it back!
  (define-key flyspell-mode-map [(control meta i)] 'overwrite-mode))

;;;###autoload
(defun dp-flyspell-setup (&optional force)
  (interactive "P")
  (add-hook 'flyspell-mode-hook 'dp-flyspell-mode-hook)
  (dp-flyspell-setup0 dp-flyspell-hooks 'flyspell-mode force))

;;;###autoload
(defun dp-flyspell-prog-setup ()
  (interactive)
  (dp-flyspell-setup0 dp-flyspell-prog-hooks 'dp-flyspell-prog-mode))

(defun dp-flyspell-local-persistent-highlight (on-p)
  (make-variable-buffer-local 'flyspell-persistent-highlight)
  (setq flyspell-persistent-highlight on-p))

; better to use flyspell's default bindings
;(defun dp-flyspell-auto-correct-word (&optional prev-p)
;  (interactive "P")
;  (if prev-p
;      (flyspell-auto-correct-previous-word (point))
;    (flyspell-auto-correct-word)))

;(define-key flyspell-mode-map flyspell-auto-correct-binding
;  'dp-flyspell-auto-correct-word)


(define-key flyspell-mouse-map [(control button3)] 'flyspell-correct-word)


;;;###autoload
(defun dp-flyspell-prog-mode (&optional persistent-highlight-p)
  "Put a buffer into `flyspell-prog-mode', with persistent-highlight OFF.
PERSISTENT-HIGHLIGHT-P says to turn on persistent-highlight."
  (interactive)
  (when (dp-using-flyspell-p)
    (flyspell-prog-mode)
    (if persistent-highlight-p
	(dp-flyspell-local-persistent-highlight t)
      (dp-flyspell-local-persistent-highlight nil))))

(defun dp-flyspell-prog-mode-persistent-highlight ()
  (dp-flyspell-prog-mode t))

;;;
;;;
;;;
(provide 'dp-flyspell)
