


(defun dp-mk-prefix-match-regexp- (list-o-chars)
  "Create a regexp that matches all leading substrings of LIST-O-CHARS.
LIST-O-CHARS is a list of chars.
E.g.  given \"_cls\", match \"_\", \"_c\", \"_cl\" and \"_cls\".
This will make a regexp that matches the strings anywhere."
  (if list-o-chars
      (format "\\(%c%s\\)?" (car list-o-chars)
              (dp-mk-prefix-match-regexp- (cdr list-o-chars)))
    ""))

(defun dp-mk-prefix-match-regexp (str)
  "Call `dp-mk-prefix-match-regexp-' after convering STR to a list o' chars."
  (dp-mk-prefix-match-regexp- (string-to-list str)))

(defun dp-mk-bounded-prefix-match-regexp (str)
  "Make a regexp with `dp-mk-prefix-match-regexp' that only matches STR."
  (concat "^" (dp-mk-prefix-match-regexp str) "$"))

(defun dp-complete-prefix-remainder (prefix str)
  "Return string to make STR match the entire regexp PREFIX.
E.g. Given PREFIX == `dp-mk-prefix-match-regexp' \"_cls\", and STR == \"_c\",
return \"ls\".  So STR + new string = \"_cls\"."
  (when (string-match
         (dp-mk-bounded-prefix-match-regexp (string-to-list prefix))
         str)
    (let ((matched (match-string 1 str)))
      ;; 1234
      ;; 12..
      ;; 01   <<< offset
      ;; remainder len = len(str) - len(matched)
      (substring prefix (length matched)))))
