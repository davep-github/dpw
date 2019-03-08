(dmessage "dp-mingus loading...")

(defun dp-mingus-random-album ()
  (interactive)
  (dp-mpd-random-album)
  (mingus))

(defun dp-mingus-do-play ()
  (interactive)
  (save-excursion
    (mingus)
    ;; `mingus-play' doesn't work outside of the playlist buffer.
    (mingus-play))
  )

(defun dp-mingus-do-toggle ()
  (interactive)
  (pcase (getf (mpd-get-status mpd-inter-conn) 'state)
    ((or 'play 'pause) (mingus-toggle))
    ('stop (dp-mingus-do-play))
    (confusion (error "Unknown mpd state: %s" confusion))))

(defun dp-mingus-player-bind-keys ()
  "Set up the player specific bindings in my global `dp-music-player-map'."
  (interactive)
  (dp-define-key-list
   dp-music-player-map
   `(
     ;; Different names for the same key are becoming tiresome.
     [?p] dp-mingus-do-toggle
     [space] dp-mingus-do-toggle
     [? ] dp-mingus-do-toggle
     [?l] mingus
     [?m] mingus
     [(down)] mingus-next
     [(up)] mingus-prev
     [(kp-down)] mingus-next
     [(kp-up)] mingus-prev
     [?i] ,(kb-lambda (mingus-make-mode-line-help-echo))
     [?s] mingus-stop
     [?S] dp-mingus-do-play
     [(shift ?s)] mingus-play
     [?r] dp-mingus-random-album
     )))

(defalias 'dp-music-player-bind-keys 'dp-mingus-player-bind-keys)

(defun dp-mingus-playlist-mode-bind-keys ()
  (interactive)
  (dp-local-set-keys
   '(
     [?p] dp-mingus-do-toggle
     [(shift ?s)] mingus-play
     [?r] dp-mingus-random-album
     ;; See which one sticks.
     [(meta ?m)] mingus-browse		; [m]usic.
     [(meta ?b)] mingus-browse
     [(meta ?p)] mingus-browse
     [(meta ?u)] mingus-open-parent
     [(meta ?,)] mingus-open-parent
     )))

(defalias 'dp-music-playlist-mode-bind-keys 'dp-mingus-playlist-mode-bind-keys)

(defun dp-mingus-playlist-hook ()
  (dp-show-trailing-whitespace -1)
  (dp-mingus-playlist-mode-bind-keys))

(add-hook 'mingus-playlist-hooks 'dp-mingus-playlist-hook)

(defun dp-mingus-browse-mode-bind-keys ()
  (interactive)
  (dp-local-set-keys
   '(
     [(meta ?u)] mingus-open-parent
     [(meta ?,)] mingus-open-parent
     [?l] mingus-open-parent		; As in dired, Info, etc.
     [(meta ?l)] mingus-load-playlist
     )))

(defalias 'dp-music-browse-mode-bind-keys 'dp-mingus-browse-mode-bind-keys)

(defun dp-mingus-browse-mode-hook ()
  (dp-show-trailing-whitespace -1)
  (dp-mingus-browse-mode-bind-keys))

(add-hook 'mingus-browse-hook 'dp-mingus-browse-hook)

(global-set-key [(control meta ?m)] 'mingus)
(global-set-key [(control meta ?p)] 'dp-mingus-random-album)

(dmessage "...dp-mingus loaded.")
