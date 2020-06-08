#!/usr/bin/env python
import sys, os, types
import dp_io

def quote_line(line, open_quote_char="'", close_quote_char="'"):
    """Separate open & close allow us to do things like '$(' ')'"""
    return open_quote_char + line + close_quote_char

def proc_file(file_obj, proc, ofile=sys.stdout, **kwargs):

    while True:
        # print("proc_file:file_obj>{}<".format(file_obj))
        line = file_obj.readline()
        # print("proc_file:line>{}<".format(line))
        if not line:
            return
        line = line[0:-1]
        oline = proc(line, **kwargs)
        ofile.write("%s\n" % (oline,))

def main(argv):
    import getopt
    proc_fun = quote_line
    kwargs = {}
    ofile = sys.stdout
    opt_string = "c:o:f:F:"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        if o == '-c':
            kwargs["close_quote_char"] = v
            continue
        if o == '-o':
            kwargs["open_quote_char"] = v
            continue
        if o == '-f':
            ofile = open(v, "w")
            continue
        if o == '-F':
            ofile = open(v, "a")
            continue

        print("sys.argv[0]: bad option:", o, file=sys.stderr)
        sys.exit(1)

    # print("ofile>{}<".format(ofile))
    kwargs["ofile"] = ofile
    if not args:
        # Filter
        args = [sys.stdin]

    for arg in args:
        # Handle arg
        close_p = False
        if type(arg) in (bytes, str):
            arg = open(arg, "r")
            close_p = True
        proc_file(arg, proc_fun, **kwargs)
        if close_p:
            arg.close()


if __name__ == "__main__":
    main(sys.argv)

