#!/usr/bin/env python
import sys, os
import dp_utils, dp_sequences

def main(argv):
    import getopt
    opt_string = "crp"
    concat_components_p = False
    path_ops = []

    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        if o == '-r':
            path_ops.append(os.path.realpath)
        elif o == '-p':
            path_ops.append(dp_utils.normpath_plus)
        elif o == '-c':
            concat_components_p = True
        else:
            print("WTF? option>{}< is unsupported".format(o), file=sys.stderr)
            sys.exit(1)

    if concat_components_p:
        path = os.path.join(*args)
        args = [path]

    if not path_ops:
        path_ops=[os.path.normpath]

    if len(args) == 0:
        # read lines and discard newlines.
        path_args = dp_sequences.Chomped_file(sys.stdin)
    else:
        path_args = args
    for p in path_args:
        for op in path_ops:
            # print "op>{}<".format(op)
            p = op(p)
            # print "p>{}<".format(p)
        print(p)

if __name__ == "__main__":
    main(sys.argv)
