(defvar dp-portage-root "/usr/portage")
(defvar dp-local-portage-root (paths-construct-path (list
                                                     dp-portage-root
                                                     "local")))

(defun dp-dired-portage-category (category-name &optional local-p)
  (interactive "fPortage category name: \nP")
  
  
  )

(provide 'dp-portage)
