;;; buffer-bg.el --- Changing background color of windows
;;
;; Author: Lennart Borgman (lennart O borgman A gmail O com)
;; Created: 2008-05-22T19:06:23+0200 Thu
;; Version: 0.5
;; Last-Updated: 2008-05-22T23:19:55+0200 Thu
;; URL: http://www.emacswiki.org/cgi-bin/wiki/buffer-bg.el
;; Keywords:
;; Compatibility:
;;
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; There is currently no way to change background colors of Emacs
;; windows. This library implements a workaround using overlays.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:
;;;
;;; Stolen by davep to allow me to make changes, and make it easier to
;;; tell which are my hacked version
;;;

(dp-deflocal-permanent dp-buffer-bg-overlay nil)

(defun* dp-buffer-bg-set-color-guts (bg-face buffer
					     &key
					     (widenp t)
					     begin end
					     intangiblep
					     props
					     (priority 0))
  (if (not bg-face)
      (when dp-buffer-bg-overlay
	(delete-overlay dp-buffer-bg-overlay)
	(setq dp-buffer-bg-overlay nil))
    (save-restriction
      (when widenp
	(widen))
      (setq dp-buffer-bg-overlay
	    (make-overlay
	     (dp-mk-marker (or begin (point-min)) nil t)
	     (dp-mk-marker (or end (point-max)) nil t)
	     buffer nil t))
      ;; Fix-me: Let the overlay have priority 0 which is the
      ;; lowest. Change this to below char properties if this is ever
      ;; allowed in Emacs.
      (dp-overlay-put-props dp-buffer-bg-overlay
			    'priority priority
			    'face bg-face))))
;;;###autoload
(defun* dp-buffer-bg-set-color (color
				&optional buffer
				&key begin end (widenp t)
				&allow-other-keys)
  "Add an overlay with background color COLOR to buffer BUFFER.
If COLOR is nil remove previously added overlay."
  (interactive
   (let* ((prompt (if dp-buffer-bg-overlay
		      "Background color (empty string to remove): "
		    "Background color: "))
          (color (read-color prompt nil t)))
     (list color))) ;;; buffer begin end widenp)))
  (setq color
	(cond
	 ((null color) nil)
	 ((and color (facep color) color))
	 ((dp-non-empty-string color)
	  (list :background color))
	 ((not (dp-non-empty-string color)) nil)
	 (t nil)))
  (dp-buffer-bg-set-color-guts color buffer :begin begin :end end :widenp t))

(provide 'dp-buffer-bg)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; buffer-bg.el ends here
