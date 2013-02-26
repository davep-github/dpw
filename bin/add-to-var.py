#!/usr/bin/env python

import sys, os

def main(argv):
    import getopt
    opt_string = "s:pe:i:"
    separator = ":"
    input_separator = None
    prepend_p = False
    empty_component_replacement = ""
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-s':
            separator = v
            continue
        if o == '-p':
            prepend_p = True
            continue
        if o == '-e':
            empty_component_replacement = v
            continue
        if o == '-i':
            input_separator = v
            continue
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        pass

    var = os.environ.get(args[0])
    if var:
        var_components = var.split(separator)
    else:
        var_components = []
    args = args[1:]
    if prepend_p:
        all_components = args + var_components
    else:
        all_components = var_components + args

    if empty_component_replacement:
        new_list = []
        for e in all_components:
            if e == "":
                e = empty_component_replacement
            new_list.append(e)
        all_components = new_list
    print separator.join(all_components)
                     
    for arg in args:
        # Handle arg
        pass

if __name__ == "__main__":
    main(sys.argv)

