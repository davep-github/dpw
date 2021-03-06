(;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with <open> and enter text in its buffer.

(require 'igrep)

(defvar dp-remote-file-colorization-info
  `(,dp-remote-file-regexp . dp-remote-buffer-face)
  "Remote file recognition regexp and default color")

(defvar dp-bmm-buffer-name-colorization-alist 
  `(,dp-remote-file-colorization-info
;;    ("\\[" . dp-sudo-edit-bg-face)
    ("Man\\( apropos\\)?: " . font-lock-string-face)
    ("<dse>" . dp-sudo-edit-bg-face)
    ("\\*ssh-" . dp-remote-buffer-face)
    ("\\*Python\\*" . font-lock-variable-name-face))
  "Alist used to map buffer-name to display face.
A list of cons cells, where each cons cell is \(regexp . face\).
The regexp is matched against the buffer name.")

;;
;; XEmacs puts font lock info on the mode symbol. Kewl.
;; 
(defun dp-colorize-buffer-if (pred color &optional else-uncolorize-p
                              pred-args beg end)
  "Colourize the current buffer if PRED is non-nil."
  (interactive "P")
  (let* ((beg.end (dp-region-or... :beg beg :end end
                                   :bounder 'buffer-p))
         (beg (car beg.end))
         (end (cdr beg.end)))
    (if (dp-apply-or-value pred pred-args)
        (dp-colorize-region (or color 'dp-default-read-only-color)
                            beg end
                            'no-roll-colors nil
                            'priority -11 ; This is a background.
                            ;; The property below says that the underlying
                            ;; extent is there showing some kind of file
                            ;; state, like read-only or remote.
                            'dp-file-state-colorization t)
      (when else-uncolorize-p
        (dp-uncolorize-region beg end t)))))

(defvar dp-remote-buffer-colorization-alist
  `(,dp-remote-file-colorization-info))

(defun dp-colorize-buffer-if-readonly (&optional color uncolorize-if-rw-p)
  (interactive "P")
  (dp-colorize-buffer-if buffer-read-only 
                         (or color 
                             'dp-default-read-only-color)
                         uncolorize-if-rw-p))

(defun dp-colorize-buffer-if-remote (&optional color buf)
  "Give buffers holding remote files a distinctive color."
  (interactive "P")
  (dp-colorize-buffer-if 'dp-remote-file-p 
                         (or color 
                             (dp-bmm-get-color-for-buf-name (current-buffer)))))

(defun lmessage (flags fmt &rest args)
  (display-message-or-buffer (apply 'format fmt args))))
