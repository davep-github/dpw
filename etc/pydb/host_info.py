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

# N.B. See earlier commit(s) (like f80a23d0286b7c95917a3a4d127c0cac824eb715)
# For many, many retired entries.

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
    'xem_bin': os.path.join(HOME_LOCAL_BIN, "xemacs"),
    'lem_bin': os.path.join(HOME_LOCAL_BIN, "xemacs"),
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
    'text_html_browser': 'w3m',
    'command-line-mailer': 'mail',      # Must support mail(1) args.
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
# FAMILY entry for HOME-LINUX
e(
    kef='family',
    dat={
        'family': 'home-linux',
        'comment': 'Linux boxen at home.',
        'cd-writer-dev': '/dev/cdrom',
        'cd-writer-fs': '/cdrom',
        #'work-ssh-host': "sentinels.vanu.com",
    },
    ref=[home_family, OSDB['linux'], default]
)

AMD_XEM_GEOMETRY = '-geometry 81x70-0+0'
AMD_BG_COLOR = 'rgb:24/00/68'
AMD_FG_COLOR = 'white'
amd_family = e(
    kef='family',
    dat={
        'host-default-pattern': '.*',
        'family': 'amd-linux',
        'family_zone': 'amd',
        'project': 'brahma',
        'comment': 'My linux boxen at amd.',
        'DTE': 'kde',
        'main_macs_opts': '-eval (dp-main-rc+2w)',
        'xem_opts': '-eval (dp-2-v-or-h-windows) ' + AMD_XEM_GEOMETRY,
        #    "xem_font": "-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*",
        "xem_font": "",
        'lem_opts': '-eval (dp-laptop-rc) -geometry 80x72-1+0',
        'work-zone': 'amd',
        #    """xem-xft-font""": '''"Inconsolata-13"''',
        'xterm_bin': 'xterm',
        'xterm_bg': AMD_BG_COLOR,
        'xterm_fg': AMD_FG_COLOR,
        'xterm_opts': """'-sb -sl 1024 -ls +si -sk'""",
        'xem_bg_color': NVIDIA_BG_COLOR,
    },
    # These are searched in the order given.
    ref=[OSDB['linux'], default]
)

AMD_ATLR5N4_FG_COLOR = 'black'
##AMD_ATLR5N4_BG_COLOR = 'rgb:d2/d0/b0'
AMD_ATLR5N4_BG_COLOR = 'lavender'

e(
    kef='host',
    dat={
        'host-pattern': 'atlr5n4-[0-9]+$',
        'family': 'amd_family',
        'comment': 'A work machine.',
        'xem_opts': '-eval (dp-2-v-or-h-windows) ' + '-geometry 81x70-0+0',
        'xterm_bg': AMD_ATLR5N4_BG_COLOR,
        'xterm_fg': AMD_ATLR5N4_FG_COLOR,
        'xem_bg_color': AMD_ATLR5N4_BG_COLOR,
    },
    ref=[amd_family, OSDB['linux'], default]
)

PIGEONHAWKFG_COLOR = 'black'
# #BAC1D1
PIGEONHAWK_BG_COLOR = 'rgb:ba/c1/d1'
#PIGEONHAWK_BG_COLOR = 'rgb:57/a2/71'
#PIGEONHAWK_BG_COLOR = 'rgb:C7/E3/D2'

e(
    kef='host',
    dat={
        'host-pattern': 'p(igeon)?hawk',
        'family': 'amd_family',
        'comment': 'A work/dev machine.',
        'xem_opts': '-eval (dp-2-v-or-h-windows) ' + '-geometry 81x70-0+0',
        'xterm_bg': PIGEONHAWK_BG_COLOR,
        'xterm_fg': PIGEONHAWKFG_COLOR,
        'xem_bg_color': PIGEONHAWK_BG_COLOR,
    },
    ref=[amd_family, OSDB['linux'], default]
)


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

        # NB! using the version number can cause extreme weirdness with fonts!
        'tunnel-ip': '16.11.64.97',
        'SVN_ROOT': '''file:///usr/yokel/svn/my-world''',
        'SVNROOT': '''file:///usr/yokel/svn/my-world''',
        'firefox-profile': "KDE",
        'firefox-bin': "firefox",
    },
    ref=famDB['home-linux'])
