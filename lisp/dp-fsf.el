(message "dp-fsf-early loading...")

(defun dp-ibuffer-do-and-update (op &rest op-args)
  "Do an ibuffer operation and then refresh the buffer."
  (apply op op-args))

(defun dp-ibuffer-do-save ()
  "Save and then refresh the buffer."
  (interactive)
  (dp-ibuffer-do-and-update 'ibuffer-do-save))

(message "dp-fsf-early loading...done.")
