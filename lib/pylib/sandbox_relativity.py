#!/usr/bin/env python

import sys, os, argparse, StringIO
import dp_io, find_up, go2env_lib, p4_lib
opath = os.path

# Create a config system.
# try ./some_config.py
# then pylib/some_config.py

Configuration = {
    "ROOT_INDICATOR_FILE": "DP_SB_ROOT"
    }

####################################################################
def emit_path(components, norm_p=True, real_p=True, ostream=sys.stdout,
              prefix="", suffix="\n"):
    #dp_io.printf("components>%s<\n", components)
    p = opath.join(*components)
    #dp_io.printf("p>%s<\n", p)
    if real_p:
        p = opath.realpath(p)
    if norm_p:
        p = opath.normpath(p)
    ostream.write("%s%s%s" % (prefix, p, suffix))

####################################################################
def expand_dest(current_sandbox, expand_dest_args, input_sandbox,
                abbrev_suffix=None):
    output = StringIO.StringIO()
    abbrev = expand_dest_args
    if abbrev_suffix is None:
        # The 0th iteration tends to be the model and often needs to be
        # assumed. But let's limit the amount the assumption fucks us up.
        abbrev_suffix = os.environ.get("DP_EXPAND_DEST_SUFFIX",
                                       "__ME_src")
    #
    # Some useful special cases
    #
    if abbrev == '~':
        abbrev = "ap"
    elif abbrev == ".":
##         print "abbrev>%s<" % (abbrev,)
##         print "current_sandbox>%s<" % (current_sandbox,)
        abbrev = relativize(current_sandbox,
                            opath.realpath(opath.normpath(opath.curdir)),
                            p4_location_p=False)
##         print "abbrev>%s<" % (abbrev,)
##         newd = opath.join(input_sandbox, abbrev)
##         print "newd>%s<" % (newd,)
##         return newd
    elif abbrev == "/":
        abbrev = current_sandbox

    output = StringIO.StringIO()
    go2env_lib.go2env(args=[], handlers_type="grep", selector="e",
                      handler_keyword_args={},
                      grep_regexps=("^" + abbrev + abbrev_suffix + "$",),
                      ostream=output)
    new_abbrev = output.getvalue().strip()
    if not new_abbrev:
        new_abbrev = abbrev
##     print "new_abbrev>%s<" % (new_abbrev,)
##     print "input_sandbox>%s<" % (input_sandbox,)
    output = StringIO.StringIO()
    emit_path((input_sandbox, new_abbrev), ostream=output)
    return output.getvalue().strip()


####################################################################
def relativize(current_sandbox, name_to_relativize, p4_location_p=False):
    name = opath.normpath(opath.realpath(name_to_relativize))
    p = name.find(current_sandbox)
    output = StringIO.StringIO()
    if p == 0:
        name = name[len(current_sandbox) + 1:]
        if p4_location_p:
            name = "//" + name
        emit_path((name,), norm_p=False, real_p=False, ostream=output)
    return output.getvalue()

####################################################################
def get_current_sandbox():
    current_sandbox = find_up.find_up(Configuration["ROOT_INDICATOR_FILE"])
    if current_sandbox:
        current_sandbox = opath.dirname(current_sandbox[0])
        current_sandbox = opath.normpath(opath.realpath(current_sandbox))
    return current_sandbox

####################################################################
def main(argv):
    oparser = argparse.ArgumentParser()
    oparser.add_argument("--find-root", "--sb-root",
                         dest="find_root_p",
                         action="store_true",
                         help="Find the sandbox root.")
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
    oparser.add_argument("-s", "--sandbox", "--sb",
                         dest="input_sandbox",
                         type=str, default=None,
                         help="A user specified sandbox. Defaults to current_sandbox.")

    app_args = oparser.parse_args()

    current_sandbox = get_current_sandbox()
    if not current_sandbox:
        dp_io.eprintf("cannot find root_indicator_file[%s]\n",
                      Configuration["ROOT_INDICATOR_FILE"])
    input_sandbox = app_args.input_sandbox
    if  input_sandbox is None:
        input_sandbox = current_sandbox
    else:
        output = StringIO.StringIO()
        go2env_lib.go2env(args=[], handlers_type="grep", selector="e",
                          handler_keyword_args={},
                          grep_regexps=["^" + input_sandbox + "$"],
                          ostream=output)
        input_sandbox = output.getvalue().strip()

    if app_args.expand_dest_args:
        s = expand_dest(current_sandbox, app_args.expand_dest_args, input_sandbox)
        print s
        sys.exit(0)


    if app_args.find_root_p:
        if current_sandbox:
            emit_path((current_sandbox,))
        else:
            dp_io.eprintf("Cannot find sandbox root, cwd>%s<\n",
                          opath.realpath(opath.curdir))

    if app_args.name_to_relativize:
        s = relativize(current_sandbox, app_args.name_to_relativize,
                       app_args.p4_location_p)
        print s
        sys.exit(0)

    name_to_make_absolute = app_args.name_to_make_absolute
    if name_to_make_absolute:
        relative_to = app_args.relative_to
        if relative_to == "//":
            relative_to = current_sandbox
        emit_path((relative_to, name_to_make_absolute))

    for arg in argv:
        # Handle arg
        pass

if __name__ == "__main__":
    main(sys.argv)

