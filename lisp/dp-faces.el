(message "dp-faces loading...")

(defgroup dp-faces nil
  "My personal customizable faces."
  :group 'local)

(defface dp-cifdef-face0
  '(
    (((class color) (background light)) (:background "paleturquoise3"))
    (((class color) (background dark)) (:foreground "black" :background "paleturquoise3")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)

(defface dp-cifdef-face1
  '(
    (((class color) (background light)) (:background "plum"))
    (((class color) (background dark)) (:foreground "black" :background "plum")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)

(defface dp-cifdef-face2
  '(
    (((class color) (background light)) (:background "lightgreen"))
    (((class color) (background dark)) (:foreground "black" :background "lightgreen")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)

(defface dp-cifdef-face3
  '(
    (((class color) (background light)) (:background "mistyrose2"))
    (((class color) (background dark)) (:foreground "black" :background "mistyrose2")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)

(defface dp-cifdef-face4
  '(
    (((class color) (background light)) (:background "cornflowerblue"))
    (((class color) (background dark)) (:foreground "black" :background "cornflowerblue")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)

(defface dp-cifdef-face5
  '(
    (((class color) (background light)) (:background "rosybrown"))
    (((class color) (background dark)) (:foreground "black" :background "rosybrown")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)

(defface dp-cifdef-face6
  '(
    (((class color) (background light)) (:background "darkseagreen"))
    (((class color) (background dark)) (:foreground "black" :background "darkseagreen")))
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-faces)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defface dp-journal-selected-face
  '(
    (((class color) (background light)) (:background "paleturquoise1"))
    (((class color) (background dark)) (:foreground "black" :background "paleturquoise1")))
  "Face for selected topic in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-unselected-face
  '(
    (((class color) (background light)) (:foreground "thistle4"))
    (((class color) (background dark)) (:foreground "thistle4")))
  "Face for unselected topics in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-topic-face
  '(
    (((class color) (background light)) (:foreground "slateblue"))
    (((class color) (background dark))
     (:foreground "bookmark-menu-heading" :bold t)))
  "Face for topics in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-topic-stamp-face
  '(
    (((class color) (background light)) (:foreground "slateblue1"))
    (((class color) (background light)) (:foreground "slateblue1" :bold t)))
  "Face for topics in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-timestamp-face
  (custom-face-get-spec 'font-lock-keyword-face)
  "Face for timestamps (that are not topics) in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-datestamp-face
  (custom-face-get-spec 'font-lock-function-name-face)
  "Face for datestamps in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-todo-face
  (custom-face-get-spec 'font-lock-warning-face)
  "Face for todo text in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-done-face
  '(
    (((class color) (background light)) (:foreground "thistle4"))
    (((class color) (background dark)) (:foreground "thistle4")))
  "Face for completed or cancelled todos in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-low-problem-face
  '(
    (((class color) (background light)) (:foreground "darkred"))
    (((class color) (background dark)) (:foreground "darkred")))
  "Face for low priority problem lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-medium-problem-face
  '(
    (((class color) (background light)) (:foreground "red"))
    (((class color) (background dark)) (:foreground "red")))
  "Face for medium priority problem lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-high-problem-face
  '(
    (((class color) (background light)) (:foreground "red" :bold t))
    (((class color) (background dark)) (:foreground "red" :bold t)))
  "Face for high priority problem lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-low-question-face
  '(
    (((class color) (background light)) (:foreground "blue"))
    (((class color) (background dark)) (:foreground "blue")))
  "Face for low question lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-medium-question-face
  '(
    (((class color) (background light)) (:foreground "blue" :bold t))
    (((class color) (background dark)) (:foreground "blue" :bold t)))
  "Face for medium question lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-high-question-face
  '(
    (((class color) (background light)) (:foreground "red" :bold t))
    (((class color) (background dark)) (:foreground "red" :bold t)))
  "Face for high question lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-low-todo-face
  '(
    (((class color) (background light)) (:foreground "darkred"))
    (((class color) (background dark)) (:foreground "darkred")))
  "Face for low priority todo lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-medium-todo-face
  '(
    (((class color) (background light)) (:foreground "red"))
    (((class color) (background dark)) (:foreground "red")))
  "Face for medium priority todo lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-high-todo-face
  '(
    (((class color) (background light)) (:foreground "red" :bold t))
    (((class color) (background dark)) (:foreground "red" :bold t)))
  "Face for high priority todo lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-low-info-face
  '(
    (((class color) (background light)) (:foreground "forestgreen"))
    (((class color) (background dark)) (:foreground "forestgreen")))
  "Face for low priority info lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-medium-info-face
  '(
    (((class color) (background light)) (:foreground "darkgreen"))
    (((class color) (background dark)) (:foreground "darkgreen" :bold t)))
  "Face for medium priority info lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-high-info-face
  '(
    (((class color) (background light)) (:foreground "darkgreen" :bold t))
    (((class color) (background dark)) (:foreground "darkgreen" :bold t)))
  "Face for high priority info lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-low-attention-face
  '(
    (((class color) (background light)) (:foreground "black" :bold t))
    (((class color) (background dark)) (:foreground "black" :bold t)))
  "Face for low question lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-medium-attention-face
  '(
    (((class color) (background light)) (:foreground "blue" :bold t))
    (((class color) (background dark)) (:foreground "blue" :bold t)))
  "Face for medium question lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-high-attention-face
  '(
    (((class color) (background light)) (:foreground "green" :bold t))
    (((class color) (background dark)) (:foreground "green" :bold t)))
  "Face for high question lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-cancelled-action-item-face
  '(
    (((class color) (background light)) (:foreground "thistle4"))
    (((class color) (background dark)) (:foreground "thistle4")))
  "Face for cancelled action items in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-completed-action-item-face
  '(
    (((class color) (background light)) (:foreground "thistle4"))
    (((class color) (background dark)) (:foreground "thistle4")))
  "Face for cancelled action items in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-emphasis-face
  '(
    (((class color)) (:bold t))
    (((class color)) (:bold t)))
  "Face for emphasized items in 'dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-extra-emphasis-face
  '(
    (((class color) (background light)) (:foreground "darkviolet" :bold t))
    (((class color) (background dark)) (:foreground "darkviolet" :bold t)))
  "Face for extra emphasized items in 'dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-deemphasized-face
  '(
    (((class color) (background light)) (:foreground "thistle4"))
    (((class color) (background dark)) (:foreground "thistle4")))
  "Face for deemphasized items in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-quote-face
  (custom-face-get-spec font-lock-reference-face)
  "Face for functions in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-function-face
  '(
    (((class color) (background light)) (:bold t))
    (((class color) (background dark)) (:bold t)))
  "Face for functions in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-function-args-face
  '(
    (((class color) (background light)) (:foreground "blue"))
    (((class color) (background dark)) (:foreground "blue")))
  "Face for function args in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dpj-view-grep-hit-face
  '(
    (((class color) (background light)) (:background "palegreen"))
    (((class color) (background dark)) (:foreground "black" :background "palegreen")))
  "Face for grep hits in view grep hits buffer."
  :group 'faces
  :group 'dp-faces)

;; There aren't multiple levels of examples, but
;; having 3 faces defined makes it easier to switch
;; defaults as the whim strikes.
(defface dp-journal-low-example-face
  '((((class color) (background light))
     (:foreground "forestgreen")))
  "Face for low priority example lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-medium-example-face
  '(
    (((class color) (background light)) (:foreground "darkgreen"))
    (((class color) (background dark)) (:foreground "darkgreen")))
  "Face for medium priority example lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-high-example-face
  '(
    (((class color) (background light)) (:foreground "darkgreen" :bold t))
    (((class color) (background dark)) (:foreground "green" :bold t)))
    "Face for high priority example lines in `dp-journal-mode'."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-embedded-lisp-face
  '(
    (((class color) (background light)) (:foreground "royalblue"))
    (((class color) (background dark)) (:foreground "royalblue")))
  "Face for embedded lisp expressions."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-alt-0-face
  '(
    (((class color) (background light)) (:background "thistle"))
    (((class color) (background dark)) (:foreground "black" :background "thistle")))
  "Face for even alternation lines."
  :group 'faces
  :group 'dp-faces)

(defface dp-journal-alt-1-face
  '(
    (((class color) (background light)) (:background "lavender"))
    (((class color) (background dark)) (:foreground "black" :background "lavender")))
  "Face for odd alternation lines."
  :group 'faces
  :group 'dp-faces)

(defface dp-highlight-point-before-face
  '(
    (((class color) (background light)) (:background "plum"))
    (((class color) (background dark)) (:foreground "black" :background "plum")))
  "Face before point."
  :group 'faces
  :group 'dp-faces)

(defface dp-highlight-point-after-face
  '(
    (((class color) (background light)) (:background "plum"))
    (((class color) (background dark)) (:foreground "black" :background "plum")))
  "Face after point."
  :group 'faces
  :group 'dp-faces)

(defface dp-highlight-point-face
  '(
    (((class color) (background light)) (:background "green"))
    (((class color) (background dark)) (:foreground "black" :background "green")))
  "Face for point."
  :group 'faces
  :group 'dp-faces)

(defface dp-highlight-point-other-window-before-face
  '(
    (((class color) (background light)) (:background "DarkSeaGreen2" :bold t))
    (((class color) (background dark)) (:foreground "black" :background "DarkSeaGreen2" :bold t)))
  "Face before point."
  :group 'faces
  :group 'dp-faces)

(defface dp-highlight-point-other-window-at-face
  '(
    (((class color) (background light)) (:background "SeaGreen1" :bold t))
    (((class color) (background dark)) (:foreground "black" :background "SeaGreen1" :bold t)))
  "Face for point."
  :group 'faces
  :group 'dp-faces)

(defface dp-highlight-point-other-window-after-face
  '(
    (((class color) (background light)) (:background "SeaGreen1" :bold t))
    (((class color) (background dark)) (:foreground "black" :background "SeaGreen1" :bold t)))
  "Face after point."
  :group 'faces
  :group 'dp-faces)

(defface dp-next-error-other-window-before-face
  (custom-face-get-spec 'dp-cifdef-face3)
  "Face before point."
  :group 'faces
  :group 'dp-faces)

(defface dp-next-error-other-window-at-face
  (custom-face-get-spec 'dp-cifdef-face3)
  "Face for point."
  :group 'faces
  :group 'dp-faces)

(defface dp-next-error-other-window-after-face
  (custom-face-get-spec 'dp-cifdef-face3)
  "Face after point."
  :group 'faces
  :group 'dp-faces)

(defface dp-debug-like-face
  '(
    (((class color)
      (background dark))
     (:foreground "VioletRed"))
    (((class color) (background light))
     (:foreground "blue")))
  "Face for debug like lines, e.g. @todo, XXX, ..."
  :group 'faces
  :group 'dp-faces)

(defface dp-remote-buffer-face
  '(
    (((class color)
      (background dark))
     (:background "#1B2D61"))
    (((class color) (background light))
     (:background "lightblue")))
  "Face for file that is being edited remotely on another host."
  :group 'faces
  :group 'dp-faces)

(defface dp-server-buffer-face
  '(
    (((class color)
      (background dark))
     (:background "DarkCyan"))
    (((class color) (background light))
     (:background "HotPink")))
  "Face for gnuserv buffers."
  :group 'faces
  :group 'dp-faces)


(defface dp-default-read-only-color
  '(
    (((class color)
      (background dark))
     (:background "#270000"))
    (((class color) (background light))
     (:background "mistyrose")))
  "*We colourize read only buffers so we can more easily recognize them.
!<@todo This needs reworking.  I need to rework my whole colour system.
Using numbers all over the place is BS.  Need names and a colour mapping if
dealing with indexed colours."
  :group 'faces
  :group 'dp-faces)

(defstruct dp-highlight-point-faces
  before                    ; Face for text before point on the current line.
  at                        ; Face for text at point on the current line.
  after                     ; Face for text after point on the current line.
  )

(defvar dp-highlight-point-default-faces
  (make-dp-highlight-point-faces
   :before 'dp-highlight-point-before-face
   :at 'dp-highlight-point-face
   :after'dp-highlight-point-after-face)
  "Default face list for dp-highlight-point.")

(defvar dp-highlight-point-other-window-faces
  (make-dp-highlight-point-faces
   :before 'dp-highlight-point-other-window-before-face
   :at 'dp-highlight-point-other-window-at-face
   :after'dp-highlight-point-other-window-after-face)
  "Default face list for dp-highlight-point for current line in `other-window'
when changing windows.")

(defvar dp-next-error-other-buffer-faces
  (make-dp-highlight-point-faces
   :before 'dp-next-error-other-window-before-face
   :at 'dp-next-error-other-window-at-face
   :after'dp-next-error-other-window-after-face)
  "Default face list for dp-highlight-point for current line in `other-window'
when finding next error.")

;;;###autoload
(defun dp-all-dp*-faces ()
  (delq nil (mapcar (function
                     (lambda (face-sym)
                       (and (string-match "^dp[j]?-" (format "%s" face-sym))
                            face-sym)))
                    (face-list))))

;;;###autoload
(defun dp-edit-faces ()
  "Alter face characteristics by editing a list of defined faces.
Pops up a buffer containing a list of defined faces.

WARNING: the changes you may perform with this function are no longer
saved. The prefered way to modify faces is now to use `customize-face'. If you
want to specify particular X font names for faces, please do so in your
.XDefaults file.

Editing commands:

\\{edit-faces-mode-map}"
  (interactive)
  (let ((faces (dp-all-dp*-faces)))
    (flet ((face-list (&rest rest)
             faces)
           (edit-faces-mode ()))
      (edit-faces)
      (set-buffer-modified-p nil)
      (toggle-read-only 1))))

(provide 'dp-faces)
(message "dp-faces loaded...")
