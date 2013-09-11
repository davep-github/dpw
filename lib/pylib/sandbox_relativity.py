#!/usr/bin/env python

import sys, os, argparse, StringIO
import dp_io, find_up, go2env_lib, p4_lib
opath = os.path

# Create a config system.
# try ./some_config.py
# then pylib/some_config.py

Configuration = {
    "ROOT_INDICATOR_FILE": os.environ.get("DP_SANDBOX_RELATIVITY_ROOT_FILE",
                                          "DP_SB_ROOT"),
    "MAGICK_STRING_SEPARATOR": os.environ.get("DP_SANDBOX_RELATIVITY_MAGICK_STRING_SEPARATOR", ","),
    }

####################################################################
def magick_string_p(s, magick_string_separator=Configuration["MAGICK_STRING_SEPARATOR"]):
    return s.find(magick_string_separator) >= 0

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
                abbrev_suffix=None,
                magick_string_separator=Configuration["MAGICK_STRING_SEPARATOR"]):
#    print >>sys.stdout, "1: input_sandbox>{}<".format(input_sandbox)
#    print >>sys.stdout, "1: expand_dest_args>{}<".format(expand_dest_args)
    # Handle some legacy foolishness
    a = expand_dest_args.split(magick_string_separator)
    if len(a) > 1:
        abbrev = a[1]
        input_sandbox = a[2]
    else:
        abbrev = expand_dest_args

    # only expand the input sandbox it if it doesn't already look like a
    # path.
    if input_sandbox and input_sandbox.find("/") == -1:
        input_sandbox = go2env_lib.simple_lookup("^" + input_sandbox + "$")

    if abbrev.find("//") == 0:
        # p4 path location.
        return p4_lib.reroot(abbrev, input_sandbox).strip()

    if abbrev_suffix is None:
        abbrev_suffix = os.environ.get("DP_EXPAND_DEST_ABBREV_SUFFIX")
##     print "abbrev>%s<" % (abbrev,)
##     print "2: input_sandbox>%s<" % (input_sandbox,)
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

    new_abbrev = go2env_lib.simple_lookup("^" + abbrev + abbrev_suffix + "$")

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
    else:
        current_sandbox = None
    return current_sandbox

####################################################################
def get_expand_args(args, input_sandbox,
                    magick_string_separator=Configuration["MAGICK_STRING_SEPARATOR"]):
    # Handle some legacy foolishness
    a = args.split(magick_string_separator)
    if len(a) > 1:
        abbrev = a[1]
        sandbox = a[2]
    else:
        sandbox = input_sandbox or get_current_sandbox()
        abbrev = args

    if not sandbox:
        return None

    # only expand the input sandbox it if it doesn't already look like a
    # path.
    if sandbox and sandbox.find("/") == -1:
        sandbox = go2env_lib.simple_lookup("^" + sandbox + "$")
    
    return abbrev, sandbox

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
    oparser.add_argument("--abbrev-suffix",
                         dest="abbrev_suffix",
                         type=str, default="",
                         help="Suffix to add to abbrevs, e.g. __ME_src.")

    app_args = oparser.parse_args()

    expand_dest_args=app_args.expand_dest_args
    input_sandbox = app_args.input_sandbox
##     print "0: expand_dest_args>%s<" % (expand_dest_args,)
##     print "0: input_sandbox>%s<" % (input_sandbox,)
    a = get_expand_args(expand_dest_args, input_sandbox)
    if a:
        abbrev = a[0]
        current_sandbox = a[1]
    else:
        abbrev = expand_dest_args

    if not current_sandbox:
        dp_io.eprintf("cannot find root_indicator_file[%s]\n",
                      Configuration["ROOT_INDICATOR_FILE"])
        sys.exit(1)

##     print "A: input_sandbox>%s<" % (input_sandbox,)
    if  input_sandbox is None:
        input_sandbox = current_sandbox
##     print "A.1: current_sandbox>%s<" % (current_sandbox,)
##     print "B: input_sandbox>%s<" % (input_sandbox,)

    if expand_dest_args:
        s = expand_dest(current_sandbox=current_sandbox,
                        expand_dest_args=expand_dest_args,
                        input_sandbox=input_sandbox,
                        abbrev_suffix=app_args.abbrev_suffix)
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

