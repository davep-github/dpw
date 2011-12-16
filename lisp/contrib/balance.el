;;;; balance.el --- editing balance sheets
;;;; Jim Blandy <jimb@cyclic.com> --- March 1996
;;;; Copyright (C) 1996 Jim Blandy

(defvar balance-mode-map (make-sparse-keymap))
(define-key balance-mode-map "\C-c\C-c" 'bal-update)

(defconst bal-regexp "\\(-?[0-9]*\\.[0-9][0-9]\\)\\([+-=]\\)\\(\\S-+\\)")
(defconst bal-bankrupt-face 'bal-red)
(copy-face 'default 'bal-red)
(set-face-foreground 'bal-red "red")

(defun bal-match (n)
  (buffer-substring (match-beginning n) (match-end n)))

(defun bal-replace (value start end)
  ;; We need to replace the right number of columns each time.  The
  ;; `8' in there is a crock; there should be a variable specifying
  ;; the format to use for totals, and this function should compute
  ;; its width.
  (goto-char end)
  (let ((end-col (current-column)))
    (skip-chars-backward "-0-9. \t")
    (delete-region (point) end)
    (indent-to-column (- end-col 8))
    (insert (if (numberp value)
		(let ((text (format "%8.2f" value)))
		  (if (< value 0) (put-text-property 0 (length text)
						     'face bal-bankrupt-face
						     text))
		  text)
	      "  <err>"))))

(defun bal-make-table ()
  (list 'bal-table))

(defun bal-accumulate (table name amount)
  (let* ((sym (intern name))
	 (pair (assq sym (cdr table))))
    (or pair
	(setcdr table (cons (setq pair (cons sym 0))
			    (cdr table))))
    (setcdr pair (+ (cdr pair) amount))
    (cdr pair)))

(defun bal-value (table name)
  (let* ((sym (intern name))
	 (pair (assq sym (cdr table))))
    (cdr pair)))

(defun bal-update ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((accounts (bal-make-table)))
      (while (re-search-forward bal-regexp nil t)
	(let ((amount (string-to-number (bal-match 1)))
	      (op (char-after (match-beginning 2)))
	      (account (bal-match 3)))
	  (cond
	   ((eq op ?+) (bal-accumulate accounts account amount))
	   ((eq op ?-) (bal-accumulate accounts account (- amount)))
	   ((eq op ?=) (bal-replace (bal-value accounts account)
				    (match-beginning 1)
				    (match-end 1)))))))))


(defun balance-mode ()
  "Mode for editing balance sheets.
The buffer can contain arbitrary text, marked up with tags that denote
credits, debits, and where to show the current total.
\\<balance-mode-map>
In the following explanation,
N denotes a monetary amount --- any number of digits followed by a
	decimal point, and then exactly two digits.
A denotes an account name --- any string of non-whitespace characters.

Credits have the form ``N+A'', meaning \"add N to A.\"
Debits have the form ``N-A'', meaning \"subtract N from A.\"
Reports have the form ``N=A'', meaning that \\[bal-update] should
   replace N with the current balance of account A, according to the
   credits and debits that appear above it in the buffer's text."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'balance-mode)
  (setq mode-name "Balance")
  (use-local-map balance-mode-map))
