;;;
;;; Stolen from gnu emacs and hacked to support CEDET.
;;; To *only* support CEDET.
;;; Anything else isn't guaranteed.
;;; Most changes (and they aren't complete) involve changing the text prop
;;; stuff to extent stuff.  This should be done all over.  The xemacs guys
;;; have hacked some of the button functions to make `calendar' work.
;;; Should just make it into a fsf-button-compat file.
;;;
(defun push-button (&optional pos use-mouse-action)
  "Perform the action specified by a button at location POS.
POS may be either a buffer position or a mouse-event.  If
USE-MOUSE-ACTION is non-nil, invoke the button's mouse-action
instead of its normal action; if the button has no mouse-action,
the normal action is used instead.  The action may be either a
function to call or a marker to display.
POS defaults to point, except when `push-button' is invoked
interactively as the result of a mouse-event, in which case, the
mouse event is used.
If there's no button at POS, do nothing and return nil, otherwise
return t."
  (interactive
   (message "IN push-button!!!")
   (list (if (integerp last-command-event) (point) last-command-event)))
  (if (and (not (integerp pos)) (eventp pos))
      ;; POS is a mouse event; switch to the proper window/buffer
      (let ((posn (event-start pos)))
        (with-current-buffer (window-buffer (posn-window posn))
          (push-button (posn-point posn) t)))
    ;; POS is just normal position
    (let ((button (button-at (or pos (point)))))
      (if (not button)
          nil
        (button-activate button use-mouse-action)
        t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun button-at (pos)
  "Return the button at position POS in the current buffer, or nil."
  (let ((button (get-char-property pos 'button)))
    (if (or (overlayp button) (null button))
        button
      ;; Must be a text-property button; return a marker pointing to it.
      (copy-marker pos t))))

(defsubst button-activate (button &optional use-mouse-action)
  "Call BUTTON's action property.
If USE-MOUSE-ACTION is non-nil, invoke the button's mouse-action
instead of its normal action; if the button has no mouse-action,
the normal action is used instead."
  (let ((action (or (and use-mouse-action (button-get button 'mouse-action))
		    (button-get button 'action))))
    (if (markerp action)
	(save-selected-window
	  (select-window (display-buffer (marker-buffer action)))
	  (goto-char action)
	  (recenter 0))
      (funcall action button))))

(defun button-get (button prop)
  "Get the property of button BUTTON named PROP."
  (if (overlayp button)
      (overlay-get button prop)
    ;; Must be a text-property button.
    (extent-property (extent-at  button) prop)))

(defun button-start (button)
  "Return the position at which BUTTON starts."
  (if (overlayp button)
      (overlay-start button)
    ;; Must be a text-property button.
    (let ((ext (car (dp-extents-at-with-prop 'button nil button))))
      (if ext
          (extent-start-position ext)
        (point-max)))))

(defun button-end (button)
  "Return the position at which BUTTON ends."
  (if (overlayp button)
      (overlay-end button)
    ;; Must be a text-property button.
    (let ((ext (car (dp-extents-at-with-prop 'button nil button))))
      (if ext
          (extent-end-position ext)
        (point-max)))))

(defun button-put (button prop val)
  "Set BUTTON's PROP property to VAL."
  ;; Treat some properties specially.
  (cond ((memq prop '(type :type))
	 ;; We translate a `type' property a `category' property, since
	 ;; that's what's actually used by overlays/text-properties for
	 ;; inheriting properties.
	 (setq prop 'category)
	 (setq val (button-category-symbol val)))
	((eq prop 'category)
	 ;; Disallow updating the `category' property directly.
	 (error "Button `category' property may not be set directly")))
  ;; Add the property.
  (set-extent-property (car (dp-extents-at-with-prop prop nil button))
                       prop val))

(provide 'dp-fsf-button-compat)
