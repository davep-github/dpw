(require 'tempo)

(setq dp-family-elements '("
# family item template inserted/edited by tempo.el
e(
    kef='family',
    dat={
    'family': '" (P "fam name: " fam-name nil) "',
    'family_zone': '"(P "fam zone: " fam-zone nil)"',
    'rinc_host': '"(P "mh inc host: " inc-host nil) "',
    # change or delete the rest by hand.
    'X': 'xf86',
    'shell': 'bash',
    'window_manager': 'sawfish',
    # 'xterm_bin': 'xterm',		# obtained from default, usually
    # try to pick unique color schemes per family
    # to allow visual differentiation of families.
    'xterm_bg': 'BlanchedAlmond',
    'xterm_fg': 'black',
    'xterm_font': '9x15',
    'xterm_opts': \"\"\"'-sb -sl 1024 -ls'\"\"\",
    },
    ref=default
)
"))

;tempo-define-template (name elements &optional tag documentation taglist

(tempo-define-template "dppydb-fam"
		        dp-family-elements )

(setq dp-host-elements '("
# host item template inserted/edited by tempo.el
e(
    kef='host',
    dat={
    'host': '" (P "host name: " host-name nil) "',
    'description': '" (P "descr: " host-descr nil) "',
    'nick': '" (P "nickname: " host-nick nil) "',
    
    # some likely  defaults
    'xem_bin': 'xemacs',
    'ctl': 'rx',               # r --> inc in .rhosts, x -> inc in xhosts

    # Some examples of host info
    # 'xem_font': '''-font -*-courier-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    # 'xem_opts': '''-geometry 80x60+456+0''',
    # 'tunnel-ip': '16.11.64.97',
    },
    ref=famDB['" (P "fam name: " fam-name nil) "'])"
))
(tempo-define-template "dppydb-host"
		        dp-host-elements )
