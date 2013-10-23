#!/usr/bin/env python

import sys, os, argparse, StringIO
import dp_io, find_up, p4_lib
import go2env_lib
#from go2env_lib import Alias_item_t
opath = os.path

ctracef = dp_io.ctracef

#############################################################################
#
# This was originally created to allow relative directory abbreviations to be
# used in multiple development sandboxes. E.g. `testgen' can be expanded to
# the absolute path of the directory relative to the current sandbox root.
# E.g. (er)
# in /scratch1/treeA/, testgen expands to /scratch1/treeA/some/dirs/testgen
# in /scratch1/treeQ/, testgen expands to /scratch1/treeQ/some/dirs/testgen
#
# However, there are no sandboxisms, so it can be generically applicable.
# @todo XXX It should be moved out of /home/dpanariti/bin.nvidia/ into
# /home/dpanariti/bin/.  Any nvidia-isms should be put into a front end which
# then uses this as a true lib.

# Create a config system.
# try ./some_config.py
# then pylib/some_config.py

Configuration = {
    "ROOT_INDICATOR_FILE": os.environ.get("DP_TREE_ROOT_RELATIVITY_ROOT_FILE",
                                          "DP_SB_ROOT"),
    "MAGICK_STRING_SEPARATOR": os.environ.get("DP_TREE_ROOT_RELATIVITY_MAGICK_STRING_SEPARATOR", ","),
    }

#############################################################################
def magick_string_p(s, magick_string_separator=Configuration["MAGICK_STRING_SEPARATOR"]):
    return s.find(magick_string_separator) >= 0

#############################################################################
def emit_path(components, norm_p=True, realpath_p=True, ostream=sys.stdout,
              prefix="", suffix="\n"):
    ctracef(2, "components>{}<\n", components)
    p = opath.join(*components)
    ctracef(2, "p>{}<\n", p)
    #
    # @todo XXX this probably isn't the best place to convert to realpath.
    if realpath_p:
        p = opath.realpath(p)
    if norm_p:
        p = opath.normpath(p)
    ctracef(2, "2: p>{}<\n", p)
    ostream.write("{}{}{}".format(prefix, p, suffix))


#############################################################################
def expand_dest(current_tree_root, expand_dest_args, input_tree_root,
                abbrev_suffix=None,
                magick_string_separator=Configuration["MAGICK_STRING_SEPARATOR"],
                realpath_p=True):
    ctracef(1, "1: current_tree_root>{}<\n", current_tree_root)
    ctracef(1, "1: input_tree_root>{}<\n", input_tree_root)
    ctracef(1, "1: expand_dest_args>{}<\n", expand_dest_args)
    # Handle some legacy foolishness
    a = expand_dest_args.split(magick_string_separator)
    if len(a) > 1:
        abbrev = a[1]
        input_tree_root = a[2]
    else:
        abbrev = expand_dest_args

    # only expand the input tree_root it if it doesn't already look like a
    # path.
    if input_tree_root and input_tree_root.find(opath.sep) == -1:
        input_tree_root = go2env_lib.simple_lookup(input_tree_root)

    if abbrev.find(p4_lib.LOCATION_ROOT) == 0:
        # p4 path location.
        ctracef(1, "found p4_lib.LOCATION_ROOT>{}<\n", p4_lib.LOCATION_ROOT)
        ret = p4_lib.reroot(abbrev, input_tree_root).strip()
        ctracef(1, "returning>{}<\n", ret)
        return ret

    if abbrev_suffix is None:
        abbrev_suffix = os.environ.get("DP_EXPAND_DEST_ABBREV_SUFFIX")
    ctracef(1, "abbrev>{}<\n", abbrev)
    ctracef(1, "2: input_tree_root>{}<\n", input_tree_root)
    #
    # Some useful special cases
    #
    if abbrev == '~':
        abbrev = "ap"
    elif abbrev == ".":
        ctracef(1, "2: abbrev>{}<\n", abbrev)
        ctracef(1, "2: current_tree_root>{}<\n", current_tree_root)
        abbrev = relativize(get_current_tree_root(),
                            opath.realpath(opath.normpath(opath.curdir)),
                            p4_location_p=False).strip()
        ctracef(1, "abbrev>{}<\n", abbrev)
        newd = opath.join(input_tree_root, abbrev)
        ctracef(1, "newd>{}<\n", newd)
        return newd
    elif abbrev == "/":
        abbrev = current_tree_root
    ctracef(1, "2: abbrev>{}<\n", abbrev)

    try_abbrev = abbrev + abbrev_suffix
    ctracef(1, "2: try_abbrev>{}<\n", try_abbrev)
    new_abbrev = go2env_lib.simple_lookup(try_abbrev)
    ctracef(1, "2: new_abbrev>{}<\n", new_abbrev)

    if not new_abbrev:
        new_abbrev = abbrev
##     new_abbrev = go2env_lib.simple_lookup(try_abbrev)
##     if not new_abbrev:
##         return None

    input_tree_root = opath.normpath(input_tree_root)
    ctracef(1, "3: new_abbrev>{}<\n", new_abbrev)
    ctracef(1, "3: input_tree_root>{}<\n", input_tree_root)
    output = StringIO.StringIO()
    emit_path((input_tree_root, new_abbrev), realpath_p=realpath_p,
              ostream=output)
    return_expansion = output.getvalue().strip()
    ctracef(1, "return_expansion>{}<\n", return_expansion)
    return return_expansion


#############################################################################
def relativize(current_tree_root, name_to_relativize, p4_location_p=False):
    if not current_tree_root:
        dp_io.eprintf("Current tree root is not set.\n")
        sys.exit(1)
    ctracef(1, "0, name_to_relativize>{}<\n", name_to_relativize)
    name = opath.normpath(opath.realpath(name_to_relativize))
    ctracef(1, "0, name>{}<\n", name)
    ctracef(1, "0, current_tree_root>{}<\n", current_tree_root)
    output = StringIO.StringIO()
    p = name.find(current_tree_root)
    ctracef(1, "0, p>{}<\n", p)

    if p == 0:
        name = name[len(current_tree_root) + 1:]
        ctracef(1, "1, name>{}<\n", name)
        if p4_location_p:
            name = "//" + name
        emit_path((name), norm_p=False, realpath_p=False, ostream=output)
    return output.getvalue()


#############################################################################
#
# This can be overridden in an environment specific front end program if
# there is some other way to find the relative root of the tree in question.
#
def get_current_tree_root():
    current_tree_root = find_up.find_up(Configuration["ROOT_INDICATOR_FILE"])
    if current_tree_root:
        current_tree_root = opath.dirname(current_tree_root[0])
        current_tree_root = opath.normpath(opath.realpath(current_tree_root))
    else:
        current_tree_root = None
    return current_tree_root

#############################################################################
def get_expand_args(args, input_tree_root,
                    magick_string_separator=Configuration["MAGICK_STRING_SEPARATOR"]):
    # Handle some legacy foolishness
    a = args.split(magick_string_separator)
    if len(a) > 1:
        abbrev = a[1]
        tree_root = a[2]
    else:
        ctracef(1, "get_expand_args(): input_tree_root>{}<\n", input_tree_root)
        tree_root = input_tree_root or get_current_tree_root()
        ctracef(1, "get_expand_args(): tree_root>{}<\n", tree_root)
        abbrev = args

    if not tree_root:
        return None

    # only expand the input tree_root it if it doesn't already look like a
    # path.
    if tree_root and tree_root.find("/") == -1:
        tree_root = go2env_lib.simple_lookup(tree_root)
    
    return abbrev, tree_root

#############################################################################
def main(argv):
    oparser = argparse.ArgumentParser()
    oparser.add_argument("--find-root", "--sb-root",
                         dest="find_root_p",
                         action="store_true",
                         help="Find the tree_root root.")
    oparser.add_argument("--name-to-relativize", "--relativize",
                         dest="name_to_relativize", default="",
                         type=str,
                         help="Print name relative to sb_root")
    oparser.add_argument("-a", "--make-absolute-relative-to",
                          dest="name_to_make_absolute", default="",
                         type=str,
                         help="Make name this name absolute under relative_to")
    oparser.add_argument("-r", "--relative-to",
                          dest="relative_to", default="//",
                         type=str,
                         help="Print name relative to sb_root")
    oparser.add_argument("--expand-dest",
                         dest="expand_dest_args", default="",
                         type=str,
                         help="Like expand_dest command but --expand_dest abbrev[,sb]")
    oparser.add_argument("--p4",
                         dest="p4_location_p",
                         action="store_true",
                         help="Give relative dirs a p4 root: //")
    oparser.add_argument("-t", "--tree-root",
                         dest="input_tree_root",
                         type=str, default=None,
                         help="A user specified tree_root. Defaults to current_tree_root.")
    oparser.add_argument("--abbrev-suffix",
                         dest="abbrev_suffix",
                         type=str, default="",
                         help="Suffix to add to abbrevs, e.g. __ME_src.")
    oparser.add_argument("--realpath", "--real-path", "--rp",
                         dest="realpath_p", default=None,
                         action="store_true",
                         help="Emit realpath of resulting expansion.")
    oparser.add_argument("--no-realpath", "--no-real-path", "--no-rp",
                         dest="realpath_p", default=None,
                         action="store_false",
                         help="Emit realpath of resulting expansion.")
    oparser.add_argument("-p", "-print-non-existent", "--pne",
                         dest="print_non_existent_p", default=False,
                         action="store_true",
                         help="Print an expansion even if it doesn't exist. Still returns error.")
    oparser.add_argument("--trace",
                         dest="trace_level", type=int, default=0,
                         help="Set trace level 0 == off.")

    app_args = oparser.parse_args()
    if app_args.trace_level:
        dp_io.set_verbose_level(app_args.trace_level)
    else:
        dp_io.vprint_off()
    expand_dest_args=app_args.expand_dest_args
    input_tree_root = app_args.input_tree_root
    current_tree_root = None
    ctracef(1, "0: expand_dest_args>{}<\n", expand_dest_args)
    ctracef(1, "0: input_tree_root>{}<\n", input_tree_root)
    a = get_expand_args(expand_dest_args, input_tree_root)
    if a:
        abbrev = a[0]
        current_tree_root = a[1]
    else:
        abbrev = expand_dest_args

    if not current_tree_root:
        dp_io.eprintf("Cannot find root_indicator_file>{}<\n",
                      Configuration["ROOT_INDICATOR_FILE"])
        if input_tree_root:
            dp_io.eprintf("  Looking in user specified tree_root>{}<\n",
                          input_tree_root)
        else:
            dp_io.eprintf("  Looking in current dir>{}<\n",
                          opath.realpath(opath.curdir))
        sys.exit(2)

    ctracef(1, "A: input_tree_root>{}<\n", input_tree_root)
    if  input_tree_root is None:
        input_tree_root = current_tree_root
    ctracef(1, "A.1: current_tree_root>{}<\n", current_tree_root)
    ctracef(1, "B: input_tree_root>{}<\n", input_tree_root)

    # None vs False allows us to know if the user has set the value one way
    # or the other.
    realpath_p = app_args.realpath_p
    if realpath_p is None:
        realpath_p = True
    if expand_dest_args:
        s = expand_dest(current_tree_root=current_tree_root,
                        expand_dest_args=expand_dest_args,
                        input_tree_root=input_tree_root,
                        abbrev_suffix=app_args.abbrev_suffix,
                        realpath_p=realpath_p)

        ctracef(1, "s>{}<\n", s)
        if not s:
            sys.exit(3)
        if opath.exists(s):
            print s
            sys.exit(0)
        elif app_args.print_non_existent_p:
            print s

        ctracef(1, "NO GO ON s>{}<\n", s)
        sys.exit(13)


    if app_args.find_root_p:
        if current_tree_root:
            emit_path((current_tree_root,))
        else:
            dp_io.eprintf("Cannot find tree_root root, cwd>{}<\n",
                          opath.realpath(opath.curdir))

    if app_args.name_to_relativize:
        s = relativize(current_tree_root, app_args.name_to_relativize,
                       app_args.p4_location_p)
        print s
        sys.exit(0)

    name_to_make_absolute = app_args.name_to_make_absolute
    if name_to_make_absolute:
        relative_to = app_args.relative_to
        if relative_to == "//":
            relative_to = current_tree_root
        emit_path((relative_to, name_to_make_absolute))

    for arg in argv:
        # Handle arg
        pass

if __name__ == "__main__":
    main(sys.argv)

