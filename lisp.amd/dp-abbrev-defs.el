;;
;; see dp-common-abbrevs.el
;;
(defvar dp-abbrev-mode-alist
  '((c++-mode  
     ((("vb" "virtual bool")
       dp-manual)
      (("vv" "virtual void" "virtual")
       dp-manual)))

    (python-mode
     ((("f" "for") dp-manual)
      (("s" "self") dp-manual)
      (("w" "while") dp-manual)
      (("d" "def") dp-manual)
      (("p" "print") dp-manual)))
    
    )
)

