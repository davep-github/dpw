
;; Never remove passwords from cache.
(setq password-cache-expiry nil)


(dp-add-list-to-list 
 'dp-auto-mode-alist-additions
 ;; (regexp . func-to-call-when-loaded)
 (list
  (cons "/etc/hosts"
        'dp-make-no-fill-stupidly-sh-mode)))

