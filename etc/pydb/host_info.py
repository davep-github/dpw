#
# python database file.
# This file contains record definitions for a database that can be
# accessed by python programs.
# Databases can be keyed or not.  Keyed databases have a single key that
# can be used to find items very quickly using the key.
# Unkeyed dbs can be searched for any value of any key, but the search
# must look at all elements.
# This is actual python code for creating the elements in the database.
# If it is imported by things which use it, then it will be compiled
# and saved as a .pyc file which will speed up subsequent accesses.
#


#
# host is hostname
# shell is shell we run on that host
# ctl is flags indicating:
#  r - add this to .rhosts
#  x - this is a xhost host
# family is an indicator of the kind of host we are.  we can use it to
#  determine a common kind of .profile or .cshrc to run.
#
# Each host is a member of some family and refs a host-family entry.
# The family provides defaults for that class of machine.  Hosts can
# override anything they wish in their entry.  Host-families are
# things like crl-linux (linux machines at work), home-freebsd
# (freebsd machine at home). Each host family entry refs the default
# entry so that all necessary vars are present.

# import class defs for entries and databases
import dppydb
#db=dbt

import os
#
# create a default entry with some noticable values so we can know when
# we're getting this.
# Keep other entries usable so at least we can function until
# something is done.
#

HOME = os.environ["HOME"]
BREE = os.environ.get("BREE", os.path.join(HOME, "bree"))
BREE_BIN = os.path.join(BREE, "bin")
YOKEL = os.path.join(HOME, "yokel")
YOKEL_BIN = os.path.join(YOKEL, "bin")
HOME_LOCAL = os.path.join(HOME, "local")
HOME_LOCAL_BIN = os.path.join(HOME_LOCAL, "bin")

default = dppydb.Entry({
    'pydb_type:': 'host-info',

    # make colors ugly and noticable
    'xterm_bg': 'red',
    'xterm_fg': 'blue',

    # but some defaults are useful
    'X': 'xf86',
    'window_manager': 'kwin',
    'xrl_rsh_bin': 'ssh',               # used by xrl
    'xrl_xterm_bin': 'xterm',
    'xrl_xterm_bin_opts': """'-sb -sl 1024 -ls +si -sk'""",
    'xterm_bin': 'xterm',
    'xterm_opts': """'-sb -sl 1024 -ls +si -sk'""",
    'xterm_font': '9x15',
    'shell': 'bash',
    'family_zone': 'none-default',
    'family': 'none-default',
    'host': 'none-default',
    'nick': 'none-default',
    'ctl': 'rx',
    #
    'fsf_xem_bin': 'emacs',
    #'xem_bin': '/usr/local/bin/xemacs',
    'xem_bin': os.path.join(YOKEL_BIN, "xemacs"),
    'lem_bin': os.path.join(YOKEL_BIN, "xemacs"),
    'lem_opts': '-eval (dp-laptop-rc)',
    'main_macs_opts': '-eval (dp-main-rc)',
    #'xem_font': '''-font -*-courier-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    #'xem_font': '''-font -*-Fixed-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    #'lem_font': '''-font -*-courier-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    #'lem_font': '''-font -*-Fixed-medium-r-*-*-*-120-*-*-*-*-iso8859-*''',
    #'lem_font': '''-font -*-Courier-medium-r-*-*-*-120-*-*-*-*-iso8859-*''',
    #'xem_font': '''-*-Lucida Console-medium-r-*-*-*-100-*-*-*-*-*-*''',
    #'xem_font': '''-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*''',
    #'xem_font': '''Font -*-Proggycleansz-medium-r-*-*-*-100-*-*-*-*-*-*''',
    'xem_font': '''-*-fixed-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',

    # this looks better on XFree86 under cygwin.
    'lem_font': '''-*-Fixed-medium-r-*-*-*-120-*-*-*-*-iso8859-*''',

    'lem_xrdb_file': '''/home/davep/xf86/Xresources.lem_laptop''',
    'xem_bg_color': '',
    'lem_bg_color': '',
    'xxlem_pre_cmd': '''DISPLAY=`myhost`:0.0; export DISPLAY''',
    'x_html_browser': 'xkonq',
    'text_html_browser': 'w3m'
    })

#
# create the OS database.
# this provides defaults for individual OSes.
#
OSDB = dppydb.PythonDataBase()

# shorthand for constructor
e = OSDB.add

e(
    kef='osname',
    dat={
    'osname': 'freebsd',
    })

e(
    kef='osname',
    dat={
    'osname': 'linux',
    })

#
# create the family database.
# this provides defaults for related groups of machines (families)
# this DB is keyed by family name
#
famDB = dppydb.PythonDataBase()

# shorthand for constructor
e = famDB.add

# define color in one place so it is easier to change.
# if there are enough other constants, we can make a
# crl-default entry and reference that.
#CRL_BG_COLOR = 'BlanchedAlmond'
CRL_BG_COLOR = 'rgb:cb/d9/ee'       #cbd9ee # looks very nice w/golden colors
#HOME_BG_COLOR = '#ced3e2'               # light purplish
#HOME_BG_COLOR = '#cbd9ee'               # light bluish/purplish
# for bronze color scheme
# HOME_BG_COLOR = 'rgb:f3/eb/e1'          # F6EADE # light yellow
# for Ag/silver/mithril color scheme
HOME_BG_COLOR = 'rgb:Fc/Fc/Fe'
HOME_FG_COLOR = 'rgb:2f/06/5e'
REDNET_BG_COLOR = 'LavenderBlush1'      # reddish for rednet.
VANU_BG_COLOR = 'rgb:cb/d9/ee'       #cbd9ee # looks very nice w/golden colors
VANU_FG_COLOR = 'black'
#NVIDIA_BG_COLOR = 'gray40'
#NVIDIA_FG_COLOR = 'white'

#NVIDIA_BG_COLOR = 'honeydew'
#NVIDIA_BG_COLOR = 'azure'
#NVIDIA_BG_COLOR = 'AliceBlue'
NVIDIA_BG_COLOR = 'lavender'
NVIDIA_FG_COLOR = 'black'
NVIDIA_LSIM_FG_COLOR = 'black'
NVIDIA_LSIM_BG_COLOR = 'linen'


XEM_RUN_SERVER="""-eval (dp-start-server)"""
XEM_RUN_APPTS="""-eval (dp-activate-appts)"""
WORK_BG_COLOR = VANU_BG_COLOR
#
# define the families
# the host-family entries are keyed by the family name
#

#
# FAMILY entry for CRL-DUNIX
## e(
##     kef='family',
##     dat={
##     'family': 'crl-dunix',
##     'comment': 'digital unix boxen around the lab',
##     'X': 'CDE',
##     'family_zone': 'crl',
##     'xterm_bg': "'"+CRL_BG_COLOR+"'",   # family colors help distinguish
##     'xterm_fg': 'black',                # who's who when many windows are up
##     'rinc_host': 'goliath',             # from where do we inc mail?
##     'xem_bin': 'emacs',  # B.O.E
##     'xrl_rsh_bin': 'rsh',               # we're usually tunneled in
##     },
##     ref=default
## )

#
# FAMILY entry for CRL-LINUX
## e(
##     kef='family',
##     dat={
##     'family': 'crl-linux',
##     'family_zone': 'crl',
##     'comment': 'My linux boxen at CRL.',
##     'DTE': 'kde',
##     'xterm_bg': "'"+CRL_BG_COLOR+"'",
##     'xterm_fg': 'black',
##     'xem_bg_color': "'"+CRL_BG_COLOR+"'",
##     'rinc_host': 'goliath',    # since linux boxen can't mount the mail spool
##     'xterm_opts': """'-sb -sl 1024 -ls -sr +si -sk'""", # no fade support
##     'xem_opts': '-geometry 81x74+753+0',
##     'xns_dir': '/usr/lib/netscape',
##     'xns_bin': 'netscape-communicator',
##     'xrl_rsh_bin': 'rsh',               # we're usually tunneled in
##     },
##     # These are searched in the order given.
##     ref=[OSDB['linux'], default]
## )

#
# FAMILY entry for VANU-LINUX
## e(
##     kef='family',
##     dat={
##     'family': 'vanu-linux',
##     'family_zone': 'vanu',
##     'comment': 'My linux boxen at Vanu.',
##     'DTE': 'kde',
##     'xterm_bg': "'"+VANU_BG_COLOR+"'",
##     'xterm_fg': "'"+VANU_FG_COLOR+"'",
##     'xem_bg_color': "'"+VANU_BG_COLOR+"'",
##     'xem_opts': '-geometry 81x74+753+0',
##     'xns_dir': '/home/davep',
##     'xns_bin': 'ffox',
##     'work-zone': 'vanu',
##     },
##     # These are searched in the order given.
##     ref=[OSDB['linux'], default]
## )

#
# FAMILY entry for CRL-NETBSD
## e(
##     kef='family',
##     dat={
##     'family': 'crl-netbsd',
##     'comment': 'CRL netbsd boxes.',
##     'shell': 'tcsh'
##     },
##     ref=default
## )

#
# FAMILY entry for CRL-DOZE
## e(
##     kef='family',
##     dat={
##     'family': 'crl-doze',
##     'shell': 'cmd',
##     'family_zone': 'crl',
##     })

#
# FAMILY entry.  Common home (meduseld.net) stuff
namazu_base_dir = os.path.join(HOME, 'stuff/indices/')
home_family = e(
    kef='family',
    dat={
    'family': 'home',
    'comment': 'Common things for home unix like machines.',
    'network-name': 'meduseld',
    'ISP': 'verizon.net',
    'family_zone': 'home',
    'xterm_bg': HOME_BG_COLOR,
    'xterm_fg': HOME_FG_COLOR,
    'xterm_bin': "xterm",
    'xterm_opts': """'-sb -sl 1024 -ls +si -sk'""",
    #'xterm_font': "*NONE*",
    'cdrw-dev': '1001,1,0',             # dvd, etc. rw
    'cdrw-speed': '4',                  # 4x write speed, max for CDRWs
    'namazu-dir-base': namazu_base_dir, # look up before this e()
    'notes-index-dir': os.path.join(namazu_base_dir, 'notes'),
    'notes-index-enable': 'yes',
    'ports-index-dir': os.path.join(namazu_base_dir, 'ports'),
    'ports-index-enable': 'yes',
    'mail-index-dir': os.path.join(namazu_base_dir, 'mh'),
    'mail-index-enable': 'yes',
    # only colors scrollbar and menubar.
    # other colors in ~/xf86/Xresources.huan
    # except eit window bg, that is xterm_bg, above
    #'xem_bg_color': 'rgb:f1/df/d4',
    #'xem_bg_color': 'rgb:f1/f1/f1',
    # Too close to other terms' colors.
    #'xem_bg_color': 'rgb:f3/f3/f7',
    #'xem_bg_color': 'rgb:FF/FB/EC',
    'xem_bg_color': 'gray80',
    },
)

#
# FAMILY entry for HOME-FREEBSD
e(
    kef='family',
    dat={
    'family': 'home-freebsd',
    'comment': 'FreeBSD boxen at home.',
    'startx-opts': '-listen_tcp',
    'cd-writer-dev': '/dev/cdrw',
    'cd-writer-fs': '/cdrw',
    },
    ref=[home_family, OSDB['freebsd'], default]
)

#
# FAMILY entry for HOME-LINUX
e(
    kef='family',
    dat={
    'family': 'home-linux',
    'comment': 'Linux boxen at home.',
    'cd-writer-dev': '/dev/cdrom',
    'cd-writer-fs': '/cdrom',
    'work-ssh-host': "sentinels.vanu.com",
    },
    ref=[home_family, OSDB['linux'], default]
)

NV_GEOMETRY = '-geometry 81x72-0+0'
#
# FAMILY entry for NVIDIA-LINUX
nvidia_family = e(
    kef='family',
    dat={
    'family': 'nvidia-linux',
    'family_zone': 'nvidia',
    'comment': 'My linux boxen at nVIDIA.',
    'DTE': 'kde',
    'main_macs_opts': '-eval (dp-main-rc+2w)',
    'xem_opts': NV_GEOMETRY,
    # This is OK, but O0{}[]() : no slashed 0. O & 0 are distinguishable.
    #'xem_font': '''-*-Lucidatypewriter-medium-r-*-*-*-120-*-*-*-*-*-*''',
    # May be less legible in the long run, but 0 is slashed.
    'xem_font': '''-*-Fxd-medium-r-*-*-*-120-*-*-*-*-*-*''',
    #'xem_font': '''-*-fixed-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    "xem_font": "-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*",
    "xem_font": '''-*-Fixed-medium-r-*-*-*-120-*-*-*-*-*-*''',
    'work-zone': 'nvidia',
    'xterm_bg': NVIDIA_BG_COLOR,
    'xterm_fg': NVIDIA_FG_COLOR,
    'xem_bg_color': NVIDIA_BG_COLOR,

    },
    # These are searched in the order given.
    ref=[OSDB['linux'], default]
)


SKAION_XEM_GEOMETRY = '-geometry 81x70-0+0'
SKAION_BG_COLOR = 'lavender'
SKAION_FG_COLOR = 'black'
SKAION_LSIM_FG_COLOR = 'black'
SKAION_LSIM_BG_COLOR = 'linen'
skaion_family = e(
    kef='family',
    dat={
    'host-default-pattern': '.*',
    'family': 'skaion-linux',
    'family_zone': 'skaion',
    'comment': 'My linux boxen at skaion.',
    'DTE': 'lxde',                      # sigh.
    'main_macs_opts': '-eval (dp-main-rc+2w)',
    'xem_opts': SKAION_XEM_GEOMETRY,
    # This is OK, but O0{}[]() : no slashed 0. O & 0 are distinguishable.
    #'xem_font': '''-*-Lucidatypewriter-medium-r-*-*-*-120-*-*-*-*-*-*''',
    # May be less legible in the long run, but 0 is slashed.
    'xem_font': '''-*-Fxd-medium-r-*-*-*-120-*-*-*-*-*-*''',
    #'xem_font': '''-*-fixed-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    "xem_font": "-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*",
    "xem_font": '''-*-Fixed-medium-r-*-*-*-120-*-*-*-*-*-*''',
    'work-zone': 'skaion',
    'xterm_bg': SKAION_BG_COLOR,
    'xterm_fg': SKAION_FG_COLOR,
    'xem_bg_color': SKAION_BG_COLOR,

    },
    # These are searched in the order given.
    ref=[OSDB['linux'], default]
)

e(
    kef='host',
    dat={
    'host-pattern': 'dplaptop|bld',
    'DTE': 'lxde',                      # or none
    'comment': 'Laptop running unadulterated ubuntu.',
    'nick': 'vet-build',
    'xterm_bin': 'xterm',
    'xterm_opts': """'-sb -sl 1024 -ls +si -sk'""",
    'lem_opts': '-eval (dp-laptop-rc) -geometry 80x72-1+0',
    'xem_opts': '-eval (dp-2-v-or-h-windows) -geometry  81x69-1+0',
    "xem_font": "-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*",
    """xem-xft-font""": '''"Inconsolata-12"''',
    'xterm_bg': 'linen',
    'xterm_fg': 'black',
    'xem_bg_color': 'linen',

    # NB! using the version number can cause extreme weirdness with fonts!
    },
    ref=famDB['skaion-linux'])

#
# FAMILY entry for o-xterm
e(
    kef='family',
    dat={
    'family': 'nv-o-xterm',
    'comment': 'General, interactive multiuser development machine. No CPU hogging',
    'host-pattern': '(sc|o)-xterm-[0-9]+',
    },
    ref=[nvidia_family, OSDB['linux'], default]
)

e(
    kef='family',
    dat={
    'family': 'nv-l-sim',
    'comment': 'Heavy load machines.',
    'host-pattern': 'l-sim-|sc-sim',
    'xem_opts': '-eval (dp-2-v-or-h-windows) ' + NV_GEOMETRY,
    'xterm_bg': NVIDIA_LSIM_BG_COLOR,
    'xterm_fg': NVIDIA_LSIM_FG_COLOR,
    'xem_bg_color': NVIDIA_LSIM_BG_COLOR,
    'main_macs_opts': '',
    'post_bashrc_command': 'eval ignoreeof=10',
    },
    ref=[nvidia_family, OSDB['linux'], default]
)

#
# build the host records
# the host entries are keyed by the hostname
#

# create the db.
DB = dppydb.PythonDataBase()

# shorthand for constructor
e = DB.add

# create and add records

#
# put default record in this DB
#
e(
    kef='host',
    dat={
    'host': dppydb.default_to_node_name()
    },
    ref=default
    )

#
# Put family DB in the db
e(
    kef='host',
    dat={
        'host': dppydb.famDB_to_node_name(),
        'db': famDB,
    },
    ref=famDB
    )
#
# create entries for all of the families for the case where a node is
# not explicitly listed.
# We create a hostname based on the family name.  This is an
#  illegal hostname, so no collisions should happen.  If the hostname
#  of a search is not found, host-info.py looks for a name based
#  on the family name of the machine.
#
for fam in famDB:
    fhost = dppydb.family_to_node_name(fam['family'])
    e(
        kef='host',
        dat={
        'host': fhost,
        },
        ref=fam)

## e(
##     kef='host',
##     dat={
##     'host': 'baloo',
##     'DTE': 'kde',                       # or none
##     'comment': 'My main box at home.',
##     'nick': 'home',
##     #'xterm_bin': 'konsole',            # hangs, selection sucks.
##     #'xterm_opts': '--ls',              # konsole's opts

##     #'lem_bg_color': """#d3d3da""",
##     #'xem_bg_color': 'lavenderblush',
##     #'xem_opts': '-geometry 80x62-1+0',
##     # when using gnome & panel.
##     #'xem_opts': '-geometry 80x62+453+0 '+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS,
##     #'lem_opts': '-eval (dp-laptop-rc) -geometry 80x64+428+0',
##     # evo
##     'lem_opts': '-eval (dp-laptop-rc) -geometry 80x72-1+0',
##     # notebook
##     #'lem_opts': '-eval (dp-laptop-rc) -geometry 80x52-1+0',
##     # old: '+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS
##     # was part of xem_opts.
##     #'xem_opts': '-geometry 80x69-1+0', #digital 17in
##     #'xem_opts': '-geometry  80x74-30+0',
##     'xem_opts': '-geometry  80x69-77+0',
##     'xem_font': '-*-Terminus-medium-r-*-*-*-120-*-*-*-*-iso8859-*',
##     # with KDE setting colors of non-KDE apps, this only affects
##     #  menubar and scrollbar (?would toolbar be set, too?)
##     #'xem_bg_color': 'rgb:c5/ca/e6',     # consider: #F2F0FF
##     'xem_bg_color': 'rgb:f1/e8/d8',     # consider: #F2F0FF
##     'tunnel-ip': '16.11.64.97',
##     },
##     ref=famDB['home-freebsd'])

#    'xterm_bin': 'konsole',
e(
    kef='host',
    dat={
    'host': 'huan',
    'DTE': 'kde',                       # or none
    'comment': 'My main box at home.',
    'nick': 'home',
    'xterm_bin': 'aterm',            # hangs, selection sucks.
    #'xterm_opts': '--ls',              # konsole's opts

    #'lem_bg_color': """#d3d3da""",
    #'xem_bg_color': 'lavenderblush',
    #'xem_opts': '-geometry 80x62-1+0',
    # when using gnome & panel.
    #'xem_opts': '-geometry 80x62+453+0 '+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS,
    #'lem_opts': '-eval (dp-laptop-rc) -geometry 80x64+428+0',
    # evo
    'lem_opts': '-eval (dp-laptop-rc) -geometry 80x72-1+0',
    # notebook
    #'lem_opts': '-eval (dp-laptop-rc) -geometry 80x52-1+0',
    # old: '+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS
    # was part of xem_opts.
    #'xem_opts': '-geometry 80x69-1+0', #digital 17in
    #'xem_opts': '-geometry  80x74-30+0',
    'xem_opts': '-geometry  80x69-1+0',
    'xem_font': '-*-Terminus-medium-r-*-*-*-120-*-*-*-*-iso8859-*',
    # with KDE setting colors of non-KDE apps, this only affects
    #  menubar and scrollbar (?would toolbar be set, too?)
    # use home_family's
    #'xem_bg_color': 'rgb:c5/ca/e6',     # consider: #F2F0FF
    'tunnel-ip': '16.11.64.97',
    },
    ref=famDB['home-linux'])

e(
    kef='host',
    dat={
    'host': 'vilya',
    'DTE': 'kde',                       # or none
    'comment': 'My main box at home.',
    'nick': 'home',
    #'xterm_bin': 'aterm',            # hangs, selection sucks.
    '#xterm_bin': 'konsole',             # xx uses -T which konsole hates.
#    'xterm_bin': 'xterm',
#    'xterm_opts': """'-sb -sl 1024 -ls +si -sk'""",
    'lem_opts': '-eval (dp-laptop-rc) -geometry 80x72-1+0',
    'xem_opts': '-eval (dp-2-v-or-h-windows) -geometry  81x69-1+0',
    #'xem_font': '-*-Terminus-medium-r-*-*-*-120-*-*-*-*-iso8859-*',
    # magically changed from 120 being right to 160 being right.
    # update of terminus font?
    # Terminus is nice, but curlies and brackets are nigh indistinguishable.
    #'xem_font': '-*-Terminus-medium-r-*-*-*-160-*-*-*-*-iso8859-*',
    # Wish there were other sizes.
    #'xem_font': '-*-bitstream vera sans mono-*-r-*-*-*-120-*-*-*-*-*-*',
    #'xem_font': '-b&h-lucidatypewriter-medium-*-*-*-*-100-*-*-*-*-*-*',
    # Vera got very high marks in a legibility survey.
    "xem_font": "-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*",
    # I am playing with --with-xft. Font selection is "better" and really sucks.
    # Font menu is fucked, but this works:
    # (set-default-font "Inconsolata-12")
    """xem-xft-font""": '''"Inconsolata-12"''',
    'xem_bin': os.path.join(HOME_LOCAL_BIN, "xemacs"),

    # NB! using the version number can cause extreme weirdness with fonts!
    'tunnel-ip': '16.11.64.97',
    'SVN_ROOT': '''file:///usr/yokel/svn/my-world''',
    'SVNROOT': '''file:///usr/yokel/svn/my-world''',
    'firefox-profile': "KDE",
    'firefox-bin': "firefox",
    },
    ref=famDB['home-linux'])

e(
    kef='host',
    dat={
    'host': 'laptop',
    'DTE': 'none',                      # or none
    'comment': 'Laptop running debian.',
    'nick': 'laptop',
    'xterm_bin': 'aterm',
    #'lem_bg_color': """#d3d3da""",
    #'xem_bg_color': 'lavenderblush',
    #'xem_opts': '-geometry 80x62-1+0',
    # when using gnome & panel.
    #'xem_opts': '-geometry 80x62+453+0 '+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS,
    'xem_font': '''-*-Fixed-medium-r-*-*-*-120-*-*-*-*-iso8859-*''',
    'xem_opts': """-geometry 80x52-1+0 """+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS,
    'xem_bg_color': 'honeydew2',
    'startx-opts': '',
    },
    ref=famDB['home-linux'])


#
# FAMILY entry for CRL-REDNET-LINUX
## e(
##     kef='family',
##     dat={
##     'family': 'crl-rednet-linux',
##     'comment': 'CRL machines on the rednet',
##     'xem_bg_color': REDNET_BG_COLOR,
##     'xterm_bg': REDNET_BG_COLOR,
##     'xterm_bin': 'aterm',
##     'xterm_opts': """'-sb -sl 1024 -ls -sr +si -sk'""",
##     'xem_opts': '-geometry 80x74+553+0',
##     },
##     ref=famDB['crl-linux']
##     )

## e(
##     kef='host',
##     dat={
##     'host': 'sybil',
##     'comment': 'My main box at CRL.',
##     'xem_opts': '-geometry 80x74+753+0 '+XEM_RUN_SERVER+' '+ XEM_RUN_APPTS,
##     'distribution': 'Mandrake',
##     },
##     ref=famDB['crl-linux'])

## e(
##     kef='host',
##     dat={
##     'host': 'walrus',
##     'comment': '2nd linux box @ work.',
##     'distribution': 'Mandrake',
##     'xterm_bg': 'linen',
##     'xterm_fg': 'black',
##     },
##     ref=famDB['crl-linux'])

## e(
##     kef='host',
##     dat={
##     'host': 'highwind',
##     },
##     ref=famDB['crl-linux'])

## e(
##     kef='host',
##     dat={
##     'host': 'thorin',
##     'xterm_bg': REDNET_BG_COLOR,
##     'xrl_rsh_bin': 'ssh',               # used by xrl
##     },
##     ref=famDB['crl-linux'])

## e(
##     kef='host',
##     dat={
##     'host': 'foehammer',                # glamdring from the outside
##     'xterm_bg': REDNET_BG_COLOR,
##     'xrl_rsh_bin': 'ssh',               # used by xrl
##     },
##     ref=famDB['crl-linux'])

## #
## # my alpha test cluster
## PP_BG_COLOR='cornsilk'
## for h in ('ping', 'pong'):              # test hosts, linux 2-way alphas
##     e(
##         kef='host',
##         dat={
##         'host': h,
##         'xterm_bg': PP_BG_COLOR,
##         'xem_bg_color': PP_BG_COLOR,
##         },
##         ref=famDB['crl-linux'])


#
# misc digital unix hosts around the lab
## e(
##     kef='host',
##     dat={
##     'host': 'mammoth',
##     'comment': 'a BIG alpha server',
##     'xterm_opts': """'-sb -sl 1024 -ls -sr +si -sk'""",
##     'xem_bin': 'emacs',
##     'xem_opts': '-geometry 80x76+440+0',
##     'xem_bg_color': 'white',
##     'xrl_rsh_bin': 'rsh',               # used by xrl
##     },
##     ref=famDB['crl-dunix'])

## for h in ('wishbone', 'rowdy', 'gil', 'scout', # rawhide cluster
##           'mustang', 'goliath'):        # useful servers
##     e(
##         kef='host',
##         dat={
##         'host': h,
##         },
##         ref=famDB['crl-dunix'])

## e(
##     kef='host',
##     dat={
##     'host': 'well',                     # terminal server
##     'xterm_bg': 'aquamarine',           # it is a well, after all
##     },
##     ref=famDB['crl-dunix'])


#
# some net-bsd boxen
## for h in ('marvin', 'c3po',
##           'sand', 'dogfish'
##           ):
##     e(
##         kef='host',
##         dat={
##         'host': h,
##         'shell': 'tcsh',
##         },
##         ref=famDB['crl-netbsd'])

#
# add the rednet nodes
## for x in xrange(1, 8):
##     e(
##         kef='host',
##         dat={
##         'host': 'alpha%d' % x,
##         },
##         ref=famDB['crl-rednet-linux'])

#
# Vanu, Inc. hosts.
## e(
##     kef='host',
##     dat={
##     'host': 'timberwolves',
##     'distribution': 'debian etch',
##     'xterm_bg': 'linen',
##     'xterm_fg': 'black',
##     'firefox-profile': "",
##     'firefox-bin': "iceweasel",
##     },
##     ref=famDB['vanu-linux'])  ## !!! Make Vanu vamily.

## e(
##     kef='host',
##     dat={
##     'host': 'sentinels',
##     "comment": "Immediately ssh's over to timberwolves, but I need it defined here so I get the correct setup.",
##     'distribution': 'debian etch',
##     'xterm_bg': 'moccasin',
##     'xterm_fg': 'black',
##     'firefox-profile': "",
##     },
##     ref=famDB['vanu-linux'])  ## !!! Make Vanu vamily.


############################ nVIDIA Hosts Begin #############################
#
# There are many, all identical save name:
# o-xterm-[0-9][0-9]+ (don't know full range.)
# They can be handled by a single family entry.
#
