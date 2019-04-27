;;;
;;;
;;;

;; Mew `requires' faces, but faces doesn't do a provide and we fail.
;; So we fake the results of a require.
(load-library "faces")
(provide 'faces)
(autoload 'mew "mew" nil t)
(autoload 'mew-send "mew" nil t)

;; Optional setup (Read Mail menu for Emacs 21):
(if (boundp 'read-mail-command)
    (setq read-mail-command 'mew))

;; Optional setup (e.g. C-xm for sending a message):
(autoload 'mew-user-agent-compose "mew" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-message
      'mew-draft-kill
      'mew-send-hook))

(setq mew-proto "%")
(setq mew-imap-user "davep") ;; (user-login-name)
(setq mew-imap-server "imap.vanu.com") ;; if not localhost

(setq mew-config-alist
      '((vanu
          (proto          "%")
          (imap-server    "imap.vanu.com"))))

(setq mew-smtp-server "smtp.vanu.com")



(provide 'dp-new-mew)
