#!/usr/bin/env python
# $Id: ftreewalk.py,v 1.32 2005/06/19 08:20:11 davep Exp $

import os, sys, getopt, types, string, re
import dp_io, dp_sequences
dp_io.vprint_on()

DEF_EXCLUDED_FILES_FILE_OBJ = sys.stdout

FILE_TYPE_EXCL_CMD_SIZE = 2048

# rename to RC_\1
INCLUDE_SUBTREE_RC = 'tree'
INCLUDE_DIR_RC = 'dir'

# rename these include_dirs to include_dir_file
INCLUDE_DIRS_WITH_THIS_FILE = 'DP_DO_RCS_DIR'
INCLUDE_TREES_WITH_FILE = 'DP_DO_RCS_TREE'
EXCLUDE_DIRS_WITH_THIS_FILE = 'DP_NO_RCS_DIR'
EXCLUDE_TREES_WITH_THIS_FILE = 'DP_NO_RCS_TREE'
EXCLUDE_PER_DIR_FILE_NAME = "DP_RCS_EXCLUDE_FILES"

# RCS the control files so we don't lose them when we recreate the tree.
DEFAULT_EXCLUDE_FILE_REGEXPS = [
    #INCLUDE_DIRS_WITH_THIS_FILE, INCLUDE_TREES_WITH_FILE,
    #EXCLUDE_DIRS_WITH_THIS_FILE, EXCLUDE_TREES_WITH_THIS_FILE,
    '^CVS.adm$', '^Rcslog$', '^cvslog\..*$',
    '^etags$', '^ETAGS$',
    '^gtags$', '^GTAGS$',
    '^tags$', '^TAGS$',
    '.*~$', '^#.*', '^\.#.*', '^,.*',
    '.*\.bak$', '.*\.BAK$',
    '.*\.orig$', '.*\.ORIG$', '.*\.rej$',
    '.*\.a$', '.*\.o$', '.*\.so$',
    '.*\.elc$', '^core$',
    '.*\.pyc$', '.*\.pyo$',
    '.*\.dvi$',
    '^n?cscope.out$', '^n?cscope.files$',
    '^n?cscope.out.in$', '^n?cscope.po.out$',
    '^n?cscope.in.out$', '^n?cscope.po.out$',
    '^.xsession-errors$', '^.newsrc$',
    '.*tagtree\.excluded-files',
    # Auto(conf|make) stuff.
    "^aclocal\.m4$", "^config\.guess$", "^config\.sub$", "^configure\.ac$",
    "^logs", ".*\.te?mp$",
    ".*\.CR$",
    ]

EXCLUDE_FILES = DEFAULT_EXCLUDE_FILE_REGEXPS

# @todo Add path exclusions, regexps on full pathname
# @todo Add size exclusions
MAX_FILE_SIZE = -1                      # >0 ==> limit in bytes
# @todo Add switches for various {in|ex}clusions

DEFAULT_EXCLUDE_DIR_REGEXPS = [
    '^RCS$', '^SCCS$', '^CVS$', '^\.(svn|git|hg)$' ,
    # Auto(conf|make) stuff.
    "^autom4te.cache$",
    # Imagix stuff.
    "\.4D$",
    # My hidey holes
    "^(.*-HIDE|.*-IGNORE|HIDE|HIDE-.*IGNORE|IGNORE-.*|SKIP)$",
    # Junky stuff
    "^(.*-junk|junk|junk-.*|,.*|te?mp|te?mp-.*|TE?MP|TE?MP-.*)$",
    # Dev/learning/experimental. Often will be used to figure things out
    # and the the code will be copied into the real source.
    # I especially don't want to find stuff here while working on the main
    # code... "I thought I changed that! Oh, I did, but in the dev version."
    "^(exp|EXP|ddddev)$",               #duh-duh-duh-dev
    # Old, but of historical interest. But not for indexing.
    "^(deprecated|retired|RETIRED|olde?|OLDE?)$",
    ]

DEBUG_SHOW_ALL_DIRS =                   0x01
DEBUG_SHOW_ALL_FILES =                  0x02
DEBUG_SHOW_ALL_FILES_SORTED =           0x04
DEBUG_SHOW_FILTERED_FILES =             0x08
DEBUG_SHOW_ALL_EXCLUDES =               0x10
DEBUG_SHOW_FILE_TYPE_FILTERING =        0x20

# e.g., binary files, libs, etc.  HUGE bug fixed. We need to make sure that
# these things don't match part of the file name.
DEFAULT_FILE_TYPE_EXCLUSIONS = [
    "ELF.*(relocatable|executable|shared object),",
    #"executable", catches Bourne shell script text executable
    "^.+: .*x86 boot sector",
    "^.+: .*gzip",
    "^.+: .*archive",
    "^.+: .*JPEG",
    "^.+: .*RPM",
    "^.+: .*MS-DOS executable",
    "^.+: .*Debian binary package",
    "^.+: data",
    "^.+: .*Berkeley DB",
    "^.+: .*PDF document",
    "^.+: .*Netpbm",
    "^.+: .*pixmap",
    ]

FOLLOW_SYMLINKS = False

##########################################
def emit_excluded(fmt, *args, **kw_args):
    fobj = kw_args.get("fobj", DEF_EXCLUDED_FILES_FILE_OBJ)
    if not fobj:
        return
    if fobj == DEF_EXCLUDED_FILES_FILE_OBJ:
        dp_io.vcprintf(3, fmt, *args)
    else:
        dp_io.fprintf(fobj, fmt, *args)

##########################################
def list_collector(fname, walk_data):
    if walk_data:
        walk_data.files.append(fname)

##########################################
def file_emitter(fname, walk_data):
    dp_io.printf('%s\n', fname)

##########################################
def escape_single_quoted_filename(filename):
    return `filename`

##########################################
def regexp_join(regexps):
    return '(%s)' % string.join(regexps, ')|(')

##########################################
# general purpose data container
class PostProcessData:
    def __init__(self):
        pass

##########################################
class FileTreeWalker:
    def __init__(self, root, walk_type='include',
                 dir_control_file=None, tree_control_file=None,
                 excluded_files_file_obj=None):
        self.root = root
        self.dir_control_file = dir_control_file
        self.tree_control_file = tree_control_file
        self.excluded_files_file_obj = excluded_files_file_obj
        self.walk_type = walk_type
        self.walker = None
        self.prune_children = True      # @todo make settable.

        self.included_tree_dirs = {}

        self.dir_exclusion_list = []
        self.per_dir_file_exclusion_list = []
        self.global_file_exclusion_list = []
        self.file_type_exclusion_list = []

        # regexps are derived from lists
        self.global_file_exclusion_regexp = None
        self.dir_exclusion_regexp = None
        self.per_dir_file_exclusion_regexp = None

        self.control_info = {
            'exclude': ((INCLUDE_DIRS_WITH_THIS_FILE, INCLUDE_TREES_WITH_FILE),
                        self.walk_default_exclude),
            'include': ((EXCLUDE_DIRS_WITH_THIS_FILE,
                         EXCLUDE_TREES_WITH_THIS_FILE),
                        self.walk_default_include)}

        self.set_control_info(self.walk_type, self.dir_control_file,
                              self.tree_control_file)

    ##########################################
    # <:include:><:inc:>
    def walk_default_include(self, root=None,
                             post_proc=None, post_proc_data=None):
        dp_io.ldebug(1, "walk_default_include\n")
        root = root or self.root
        ret = []
        for cwd, dirs, files in os.walk(root, followlinks=FOLLOW_SYMLINKS):
            dp_io.vcprintf(0, 'd')
            cwd = os.path.normpath(cwd)

            dp_io.fdebug(DEBUG_SHOW_ALL_DIRS, 'nf: %3d, cwd>%s<\n',
                         len(files), cwd)
            if dp_io.debug_mask_exact_set(DEBUG_SHOW_ALL_FILES_SORTED):
                dp_io.eYOPPf('debug_mask: 0x%04x, AFS: 0x%04x\n',
                             dp_io.debug_mask, DEBUG_SHOW_ALL_FILES_SORTED)
                files.sort()
                for f in files:
                    dp_io.debug('file>%s<\n', f)

            ### if 'LINK-TO-.rc' in files:
            ###     dp_io.dprintf('LINK-TO-.rc is in files.\n')

            if os.path.basename(cwd) == 'LINK-TO-.rc':
                dp_io.dprintf('LINK-TO-.rc is cwd.\n')

            # we shuns the symlinks
            # and its chilluns unless we don't.
            if os.path.islink(cwd) and not FOLLOW_SYMLINKS:
                dp_io.ldebug(2,'shunning symlink cwd>%s<\n', cwd)
                del dirs[:]
                dp_io.vcprintf(0, 'S')
                continue

            # @todo - read a DP_RCS_IGNORE file of regexps for files
            # to ignore.
            # ??? Should these be handled differently than ignores passed as
            #  arguments?  Esp wrt a match on a dir causing the tree to be
            #  ignored.
            # While we're at it, should exclude arguments be handled this
            # way, too. I think they should be consistent whichever way is
            # chosen.

            # do first so that we don't recurse into a tree because another
            #  mechanism ignored this dir without handling the subtree
            #  properly.
            # ignoring trees has priority over ignoring dir and is a superset
            # also.
            if self.tree_control_file and (self.tree_control_file in files):
                emit_excluded('excluding tree under cwd>%s<\n', cwd,
                              fobj=self.excluded_files_file_obj)
                # don't rcs this tree by deleting all child dirs so that they
                # will not be visited.
                del dirs[:]
                dp_io.vcprintf(0, 'X')
                continue                # without processing any files.

            # prune here?
            if self.dir_is_excluded(os.path.basename(cwd)):
                emit_excluded('excluding cwd>%s<\n', cwd,
                              fobj=self.excluded_files_file_obj)
                if self.prune_children:
                    del dirs[:]
                    dp_io.vcprintf(0, 'p')
                continue

            if self.dir_control_file and (self.dir_control_file in files):
                emit_excluded('ignoring cwd>%s<\n', cwd,
                              fobj=self.excluded_files_file_obj)
                # don't rcs this dir
                # Child files won't be visited,
                # child dirs  will be.
                dp_io.vcprintf(0, 'e')
                continue

            if not files:
                dp_io.vcprintf(0, '0')
                continue

            if EXCLUDE_PER_DIR_FILE_NAME in files:
                files.delete(EXCLUDE_PER_DIR_FILE_NAME)
                per_dir_exclude_files = open(EXCLUDE_PER_DIR_FILE_NAME).read()
                per_dir_exclude_files = "per_dir_exclude_files = " + per_dir_exclude_files
                eval(per_dir_exclude_files)
            else:
                per_dir_exclude_files = []

            whither = os.getcwd()
            os.chdir(cwd)
            flist = []
            for f in files:
                dp_io.fdebug(DEBUG_SHOW_ALL_FILES, 'f>%s<\n', f)
                if os.path.islink(f):
                    if not FOLLOW_SYMLINKS:
                        dp_io.ldebug(2,'shunning link>%s<\n', f)
                        dp_io.vcprintf(0, 'S')
                        continue
                if not os.path.isfile(f):
                    dp_io.ldebug(2,'shunning non file>%s<\n', f)
                    dp_io.vcprintf(0, 'F')
                    continue
                if MAX_FILE_SIZE > 0 and dp_io.file_length(f) <= MAX_FILE_SIZE:
                    dp_io.vcprintf(0, 'B')
                    continue
                if (f in per_dir_exclude_files or #self.per_dir_file_is_excluded(f) or
                    self.global_filename_is_excluded(f)):
                    emit_excluded('excluding file>%s<\n', f,
                                  fobj=self.excluded_files_file_obj)
                    dp_io.vcprintf(0, 'x')
                    continue
                # Save 'em up for batch application of `file' command.
                # Some maladjusted, misguided, misanthropic, meshuggeneh
                # has misappropriated the name `-' and decided that it is a
                # good choice for a file name.  Well it isn't. Convention has
                # dictated for some time that `-' is used to indicate that
                # input is to come from stdin. Using `-' as a file name fucks
                # up, in this case, file(1).  Admittedly, file(1) is an
                # esoteric, seldom used program, but other slightly less
                # obscure programs -- cat leaps to mind -- use the same
                # convention. So, in order to deal with this asshole's use of
                # the file name `-', I must needs add a `./' in front. It
                # saddens me to think of the extra memory use and concomitant
                # energy waste and we glumly observe that this choice of file
                # name is hastening the demise of our planet through global
                # warning.
                flist.append('./%s' % f)

            if flist:
                flist = self.filter_global_file_types(flist)
                for f in flist:
                    p = os.path.normpath(os.path.join(cwd, f))
                    dp_io.vcprintf(0, 'f')
                    if post_proc:
                        post_proc(p, post_proc_data)

            self.per_dir_file_exclusion_list = []
            os.chdir(whither)

    ##########################################
    def add_included_dirs(self, cwd, dirs, files):
        for dir in dirs:
            if not self.dir_is_excluded(dir):
                p = os.path.normpath(os.path.join(cwd, dir))
                self.included_tree_dirs[p] = True


    ##########################################
    def dir_in_included_tree(self, dir):
        dp_io.dprintf('dir>%s<\nincluded_tree_dirs>[%s]<\n',
                    dir,
                    string.join(self.included_tree_dirs, ']\n['))

        return self.included_tree_dirs.get(dir)


    ##########################################
    def dir_is_included(self, dir, files):
        if ((self.tree_control_file in files)
            or
            (self.dir_in_included_tree(dir))):
            return INCLUDE_SUBTREE_RC

        if (self.dir_control_file in files):
            return INCLUDE_DIR_RC

        return None

    ##########################################
    def get_INCLUDE_DIR_regexp(self, cwd):
        inc_file = os.path.normpath(os.path.join(cwd,
                                                 INCLUDE_DIRS_WITH_THIS_FILE))
        try:
            f = open(inc_file)
        except IOError:
            return None
        patterns = []
        for line in f:
            patterns.append(string.strip(line))
        f.close()
        if not patterns:
            # no contents, the file just exists, include everything
            patterns = ['.*']
        regexp_str = regexp_join(patterns)
        dp_io.ldprintf(-40, 'regexp_str>%s<\n', regexp_str)
        return re.compile(regexp_str)


    ##########################################
    #
    # @todo: NO_TREE abort tree recursion
    def walk_default_exclude(self, root=None, **unused):
        root = root or self.root
        ret = []
        inc_regexp = None
        for cwd, dirs, files in os.walk(root, followlinks=FOLLOW_SYMLINKS):
            dp_io.vcprintf(0, 'd')
            cwd = os.path.normpath(cwd)
            # we shuns the symlinks
            # and its chilluns
            # but I never see ANY symlinked dirs in the walk
            if os.path.islink(cwd):
                dp_io.fdebug(DEBUG_SHOW_ALL_DIRS,
                             'shunning symlink cwd>%s<\n', cwd)
                dp_io.vcprintf(0, 'l')
                del dirs[:]
                continue
            status = self.dir_is_included(cwd, files)
            if status != None:
                if status == INCLUDE_SUBTREE_RC:
                    dp_io.vcprintf(0, 'S')
                    dp_io.dprintf('INCLUDE_SUBTREE_RC\n')
                    dp_io.dprintf('cwd>%s<, dirs>[%s]<\n',
                                cwd,
                                string.join(dirs, ']\n['))

                    # @todo: if NO_TREE in files, don't add anything.
                    # blah
                    self.add_included_dirs(cwd, dirs, files)

                    # If we're including the sub-tree then we include all of
                    # the files, too.
                    inc_regexp = re.compile('.*')

                # @todo: NO_DIR --> regexp == None
                # ??? @todo ? INCLUDE_SUBTREE overrides (good idea?)
                if inc_regexp == None:
                    inc_regexp = self.get_INCLUDE_DIR_regexp(cwd)
                if inc_regexp:
                    for f in files:
                        # we shuns the symlinks
                        p = os.path.normpath(os.path.join(cwd, f))
                        if os.path.islink(p):
                            dp_io.fdebug(DEBUG_SHOW_ALL_FILES,
                                         'shunning symlink file>%s<\n', f)
                            dp_io.vcprintf(0, 's')
                            continue
                        # we're excluding by default, so only include those
                        # in the include regexp
                        if (not inc_regexp.search(f)):
                            dp_io.vcprintf(0, 'x')
                            emit_excluded('excluding file>%s<\n', f,
                                          fobj=self.excluded_files_file_obj)
                            continue
                        dp_io.vcprintf(0, 'f')
                        ret.append(p)
            self.per_dir_file_exclusion_list = []
        dp_io.vcprintf(0, '\n')
        return ret


    ##########################################
    def set_control_info(self, walk_type='include', dir_control_file=None,
                         tree_control_file=None):
        dp_io.dprintf('walk_type>%s<\n', walk_type)
        control_files, self.walker = self.control_info[walk_type]

        dp_io.vcprintf(1, 'dir_control_file>%s<\n', dir_control_file)
        dp_io.vcprintf(1, 'tree_control_file>%s<\n', tree_control_file)

        self.dir_control_file = dir_control_file or control_files[0]
        self.tree_control_file = tree_control_file or control_files[1]

        dp_io.vcprintf(2, 'control_files>%s<\n', control_files)
        dp_io.vcprintf(2, 'dir_control_file>%s<\n', self.dir_control_file)
        dp_io.vcprintf(2, 'tree_control_file>%s<\n', self.tree_control_file)


    ##########################################
    def add_file_type_exclusion(self, exclusions):
        dp_sequences.extend_list(self.file_type_exclusion_list, exclusions)


    ##########################################
    def compile_file_type_exclusion_regexp(self):
        regexp_string = regexp_join(self.file_type_exclusion_list)
        self.file_type_exclusion_regexp = re.compile(regexp_string)
        dp_io.dprintf('file_type_exclusion_regexp_string\n  >%s<\n',
                      regexp_string)

    ##########################################
    def add_dir_exclude(self, exclusions):
        dp_sequences.extend_list(self.dir_exclusion_list, exclusions)

    ##########################################
    def compile_dir_exclusion_regexp(self):
        regexp_string = regexp_join(self.dir_exclusion_list)
        self.dir_exclusion_regexp = re.compile(regexp_string)
        dp_io.debug('dir_exclusion_regexp_string\n  >%s<\n', regexp_string)

    ##########################################
    def add_global_file_exclude(self, exclusions):
        dp_sequences.extend_list(self.global_file_exclusion_list, exclusions)

    ##########################################
    def compile_global_file_exclusion_regexp(self):
        regexp_string = regexp_join(self.global_file_exclusion_list)
        self.global_file_exclusion_regexp = re.compile(regexp_string)
        dp_io.dprintf('file_exclusion_regexp_string\n  >%s<\n', regexp_string)

    ##########################################
    def set_RCS_tree_params(self, exclude_files):
        dp_sequences.extend_list(self.global_file_exclusion_list,
                                 exclude_files)
        dp_sequences.extend_list(self.file_type_exclusion_list,
                                 DEFAULT_FILE_TYPE_EXCLUSIONS)
        self.add_dir_exclude(DEFAULT_EXCLUDE_DIR_REGEXPS)
        dp_io.ldebug(1, 'dir>%s<\ndir_exclusion_list>[%s]<\n',
                     dir,
                     string.join(self.dir_exclusion_list, ']\n['))

    ##########################################
    def dir_is_excluded(self, dir):
        dp_io.ldebug(1, 'dir>%s<\ndir_exclusion_list>[%s]<\n',
                     dir,
                     string.join(self.dir_exclusion_list, ']\n['))
        return (self.dir_exclusion_regexp and
                self.dir_exclusion_regexp.search(dir))

    ##########################################
    def per_dir_file_is_excluded(self, dir):
        dp_io.cdebug(4, 'dir>%s<\nper_dir_file_exclusion_list>[%s]<\n',
                      dir,
                      string.join(self.per_dir_file_exclusion_list, ']\n['))
        return ((self.per_dir_file_exclusion_regexp and
                 self.per_dir_file_exclusion_regexp.search(dir)))

    ##########################################
    def global_filename_is_excluded(self, filename):
        dp_io.cdebug(4, 'file>%s<\nglobal_file_exclusion_list>[%s]<\n',
                      filename,
                      string.join(self.global_file_exclusion_list, ']\n['))
        return ((self.global_file_exclusion_regexp and
                 self.global_file_exclusion_regexp.search(filename)))

    ##########################################
    def global_pathname_is_excluded(self, pathname):
        return self.global_filename_is_excluded(os.path.basename(pathname))

    ##########################################
    def filter_global_excludes(self, files):
        ret = []
        for f in files:
            dp_io.ldebug(2, 'filter_global_excludes, file>%s<\n', f)
            if not self.global_pathname_is_excluded(f):
                ret.append(f)
                dp_io.ldebug(2, 'filter_global_excludes, appended\n')
            else:
                dp_io.ldebug(2, 'filter_global_excludes, rej >%s<\n', f)

        return ret

    ##########################################
    def mk_next_arg_name(self, filename):
        ename = escape_single_quoted_filename(filename)
        return  ' ' + ename
        #return  ' ' + "'" + ename + "'"

    ##########################################
    def filter_global_file_types(self, files):
        ret = []
        regexp = self.file_type_exclusion_regexp
        if not regexp:
            return ret
        num_files = len(files)
        dp_io.ldebug(3, 'num_files: %d\n', num_files)
        dp_io.fdebug(DEBUG_SHOW_FILE_TYPE_FILTERING,
                     'num_files: %5d: ', num_files)

        file_i = 0
        i = file_i
        while file_i < num_files:
            file_cmd_str = 'file --'
            next_arg = self.mk_next_arg_name(files[i])
            while (i < num_files and
                   len(file_cmd_str + next_arg) < FILE_TYPE_EXCL_CMD_SIZE):
                file_cmd_str = file_cmd_str + next_arg
                i = i + 1
                if i < num_files:
                    next_arg = self.mk_next_arg_name(files[i])

            dp_io.ldebug(-1, 'file_cmd_str>%s<\n', file_cmd_str)
            rs = dp_io.bq_lines(file_cmd_str)
            dp_io.ldebug(-1, 'file command results>%s<\n', rs)
            dp_io.fdebug(DEBUG_SHOW_FILE_TYPE_FILTERING, 'f[%d]', len(rs))

            for r in rs:
                # sanity check
                if file_i >= num_files:
                    dp_io.eprintf('\nnum_files: %d, file_i: %d, rs>%s<\n',
                                  num_files, i, rs)
                    dp_io.eprintf('cmd>%s<\n', file_cmd_str)
                    raise 'sanity_check: file_i >= num_files'

                dp_io.ldebug(3, 'file_i: %5d, r>%s<\n', file_i, r)
                accepted = not regexp.search(r)
                dp_io.ldebug(2, 'filter_global_file_types>{}< {}\n',
                             files[file_i], accepted)
                dp_io.ldebug(3, '  file command said: %s\n', r)
                if accepted:
                    ret.append(files[file_i])
                    dp_io.vcprintf(0, 't')
                else:
                    dp_io.vcprintf(0, 'T')
                file_i = file_i + 1

            # sanity check
            if i != file_i:
                dp_io.eprintf('\ncmd>%s<\n', file_cmd_str)
                dp_io.eprintf('rs>%s<\n', rs)
                raise 'sanity_check: i (%d) != file_i (%d)' % (i, file_i)
        dp_io.fdebug(DEBUG_SHOW_FILE_TYPE_FILTERING, '\n')
        return ret

    ##########################################
    def filter_file_types_in_cwd(self, newdir, files):
        hither = os.getcwd()
        os.chdir(newdir)
        self.filter_global_file_types(files)
        os.chdir(newdir)


    ##########################################
    def walk(self, post_proc, post_proc_data):
        if not self.walker:
            dp_io.eprintf('walker function not defined.\n')
            sys.exit(1)

        self.compile_global_file_exclusion_regexp()
        self.compile_dir_exclusion_regexp()
        self.compile_file_type_exclusion_regexp()

        self.walker(post_proc=post_proc, post_proc_data=post_proc_data)

        # NB here we are filtering full pathnames.
        #files = self.filter_global_excludes(files)
        #dp_io.eprintf("begin file type filtering...\n")
        #files = self.filter_global_file_types(files)


if __name__ == "__main__":

    def add_file_excludes(file_name):
        #print "file_name: ", file_name
        f = open(file_name)
        if f:
            ls = f.readlines(f)
            f.close()
            EXCLUDE_FILES.extend(ls)
        else:
            dp_io.eprintf('Cannot open exclude file>%s<\n', file_name)
            sys.exit(1)

    walk_type = 'include'
    cfile = None
    dir_control_file = None
    tree_control_file = None
    verbosity = -1
    debug_level = -1
    debug_flags = 0
    list_out = 0
    relativize_p = False
    excluded_files_file_obj = DEF_EXCLUDED_FILES_FILE_OBJ

    options, args = getopt.getopt(sys.argv[1:], 'xi:d:t:e:E:vDF:mRlX:hc:')
    for o, v in options:
        if o == '-c':
            excluded_files_file_name = v
            excluded_files_file_obj = open(excluded_files_file_name, "w")
            EXCLUDE_FILES.append(v)
            continue
        if o == '-x':
            walk_type = 'exclude'
            continue
        if o == '-i':
            walk_type = 'include'
            continue
        if o == '-d':
            dir_control_file = v
            continue
        if o == '-t':
            tree_control_file = v
            continue
        if o == '-e':
            add_dir_exclude(v)
            continue
        if o == '-E':
            add_file_excludes(v)
            continue
        if o == '-v':
            verbosity = verbosity + 1
            continue
        if o == '-D':
            dp_io.debug_on()
            debug_level = debug_level + 1
            continue
        if o == '-F':
            dp_io.debug_on()
            debug_flags = debug_flags | eval(v)
            continue
        if o == '-R':
            # make output names relative.
            # replace arg with ./
            relativize_p = True
            continue
        if o == '-l':
            list_out = 1
            continue
        if o == '-X':
            EXCLUDE_TREES_WITH_THIS_FILE = v
            continue
        if o == '-h':
            FOLLOW_SYMLINKS = True
            continue

    dp_io.set_debug_level(debug_level)
    dp_io.v_vprint_files = [sys.stderr]
    dp_io.set_verbose_level(verbosity)
    dp_io.set_debug_mask(debug_flags)

    if args == []:
        args = ['.']

    for arg_dir in args:
        if relativize_p:
            directory = arg_dir
        else:
            directory = os.path.abspath(arg_dir)
        dp_io.vcprintf(1, 'Walking >%s<\n', directory)
        walker = FileTreeWalker(directory, walk_type,
                                dir_control_file, tree_control_file,
                                excluded_files_file_obj=excluded_files_file_obj)

        walker.set_RCS_tree_params(EXCLUDE_FILES)
        if list_out:
            walk_data = PostProcessData()
            walk_data.files = []
            walker.walk(list_collector, walk_data)
            files = walk_data.files
            for file in files:
                dp_io.printf('%s\n', file)
        else:
            walker.walk(file_emitter, None)

    sys.exit(0)
