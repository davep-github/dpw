;;; 
;;; context list format:
;;; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--------context-alist
;;;    vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--------context
;;; '(               vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--------proplist  
;;;    '(buf-name1 . '((keyword . val) (key2 . val)))
;;;    '(buf-name2 . '((keyword . val) (key2 . val)))

(defvar dp-sel-context-alist '())

(defun dp-sel-mk-buf-name (buf-prefix &optional buf-name)
  (format "%s for: %s" buf-prefix (or buf-name (buffer-name))))

(defun dp-sel-ctx-find0 (name &optional alist)
  (assoc name (or alist dp-sel-context-alist)))

(defun dp-sel-ctx-find (name &optional alist)
  (cdr-safe (dp-sel-ctx-find0 name alist)))

(defun dp-sel-cxt-create (buf-name)
  (let ((context (assoc buf-name dp-sel-context-alist))
	(new-context (cons buf-name '((key-is-buf-name . val-is-context)))))
    (if context
	context
    (setq dp-sel-context-alist (cons new-context dp-sel-context-alist))
    new-context)))

(defun dp-sel-ctx-get-proplist (ctx)
  (cdr-safe (ctx)))

(defun dp-sel-ctx-get (buf-context field)
  "Return field value from FIELD in BUF-CONTEXT"
  (cdr-safe (assoc field (dp-sel-ctx-get-proplist buf-context))))

(defun dp-sel-ctx-put (buf-context field val)
  "Put VAL in FIELD in BUF-CONTEXT"
  (let ((props (dp-sel-ctx-get-proplist buf-context))
	(new-field (cons field val)
  (cdr-safe (assoc field (dp-sel-ctx-get-proplist buf-context))))

(defun dp-sel-get-context (buf-name)
  (let ((ret (dp-sel-ctx-find buf-name)))
    (if ret
	ret
      (debug))))

(defun dp-sel-ctx-test ()
  (let ((prefix "test-prefix"))
  (pprint (dp-sel-ctx-create prefix))
  
  
