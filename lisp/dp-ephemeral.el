;;
;; Hopefully temporary stuff
;;

(defvar dp-meds-initial-contents
  ":(replace-regexp \"'[0-9/]\" \"' \" nil):
               1 2 3 4 5 6 7 8 9 0
Namenda.....  ' ' ' ' ' ' ' ' '
Neurontin...  ' ' ' ' ' ' ' ' '
Tramadol....  ' ' ' ' ' ' ' ' '
MSER........  '1' ' ' ' ' ' ' '
MSIR........  ' ' ' ' ' ' ' ' '
Lamictal....  ' ' ' ' ' ' ' ' '
Wellbutrin..  '1' ' ' ' ' ' ' '"
  "Initial doses for the day.")

(defvar dp-meds-OTC-cocktail "4x ibuprofen
2x acetaminophen"
  "Over the counter pain meds.")

(defun meds ()
  (interactive)
  (cx :topic "meds"))

(defun meds0 ()
  (interactive)
  (meds)
  (insert dp-meds-initial-contents "\n"))

(defun meds-otc ()
  (interactive)
  (meds)
  (insert dp-meds-OTC-cocktail "\n"))

(defun meds-msir (&optional num)
  (interactive "p")
  (meds)
  (insert (format "%dx MSIR\n" num)))

(provide 'dp-ephemeral)
