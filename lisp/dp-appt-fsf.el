;;;
;;; My hacks to the FSF appointment (appt.el) stuff.
;;;

(defvar dp-fsf-appt-frame nil
  "The frame in which the appointment reminder window/buffer is displayed.")

(defun dp-insinuate-appt-frame-code ()
  "Save off the original window/buffer functions and replace with ours."
  (interactive)
  (dp-save-orig-n-set-new 'appt-disp-window-function
			  (cons 'dp-fsf-appt-disp-frame 'literal))
  (dp-save-orig-n-set-new 'appt-delete-window-function
			(cons 'dp-fsf-appt-delete-frame 'literal)))


(defun dp-fsf-appt-frame-delete-hook (frame)
  "Clear `dp-fsf-appt-frame' when buffer frame is deleted.
NB: this hook is defecated. Look at new interface."
  (dmessage "dp-fsf-appt-frame-delete-hook: frame>%s<." frame)
  (when (eq frame dp-fsf-appt-frame)
    (dmessage "dp-fsf-appt-frame-delete-hook: clearing frame.")
    (setq dp-fsf-appt-frame nil)))

(defun dp-fsf-appt-disp-frame (&rest args) ;; min-to-app new-time appt-msg)
  "Wrap original window based appointment reminder in a frame.
Use &rest beacuse:
1) I'm lazy
2) Insulates us more from calling signature changes."
  (let ((frame (or (dp-frame-live-p dp-fsf-appt-frame)
		   (setq dp-fsf-appt-frame (make-frame)))))
    (add-hook 'delete-frame-hook 'dp-fsf-appt-frame-delete-hook)
    (select-frame frame)
    (apply (dp-get-orig-value 'appt-disp-window-function)
	   args)
    (appt-select-lowest-window)
;;    (goto-char (point-min))
;;    (insert "+++++++\n")
;;    (goto-char (point-max))
;;    (insert "-------\n")
    (delete-other-windows)
    (dp-shrink-wrap-frame)
    (raise-frame frame)))

(defun dp-fsf-appt-delete-frame (&rest r)
  "See `dp-fsf-appt-disp-frame'."
  (when dp-fsf-appt-frame
    (let (dest-frame)
      (apply (dp-get-orig-value 'appt-delete-window-function)
	     r)
      ;; Move to non-appt frame.
      (when (eq (selected-frame) dp-fsf-appt-frame)
	(other-frame 1))
      (setq dest-frame (selected-frame))
      (if (eq dp-fsf-appt-frame dest-frame)
	  (dmessage "dp-fsf-appt-delete-frame: No other frames")
	(if (eq (dp-primary-frame) dp-fsf-appt-frame)
	    (dmessage "dp-fsf-appt-delete-frame: refusing to delete primary frame.")
	  (delete-frame dp-fsf-appt-frame))
	(when dp-fsf-appt-frame
	  (dmessage "dp-fsf-appt-frame is non-nil."))
	))))

(defun dp-appt-setup ()
  (interactive)
  (dp-insinuate-appt-frame-code))

(provide 'dp-appt-fsf)
