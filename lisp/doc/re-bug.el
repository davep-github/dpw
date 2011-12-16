
(setq re1 "========================[
][0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}[
]\\(.*sp.*\\)[
]--[
]")

(setq re2 ".*sp.*")

(defun dp-find-topic4 (topic-re &optional count)
  (re-search-forward topic-re nil t count)
  (message "ams0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "bms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "cms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "dms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "dms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "ems0>%s<, mb0>%s<" (match-string 0) (match-beginning 0)))

(progn 
  (dp-find-topic4 re2)
  (message "Fms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "Gms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0)))


========================
2002-01-20T12:30:19
journal elisp devel
--
things are moving along.

========================
2002-01-20T12:34:50
a topic with spaces
--
this requires C-q<space> for spaces.

