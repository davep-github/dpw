#!/usr/bin/env python

import sys, os
import dp_sequences

def main(argv):
    import getopt
    opt_string = "s:pe:i:v:"
    separator = ":"
    input_separator = None
    prepend_p = False
    empty_component_replacement = None
    var = None
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        print("o>{}<, v>{}<".format(o, v))
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
        if o == '-v':
            var = v
            continue
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        pass

    # print("var>{}<".format(var), file=sys.stderr)
    if var:
        var = os.environ.get(var)
        # print("var_val>{}<".format(var), file=sys.stderr)
    if var:
        var_components = var.split(separator)
    else:
        var_components = []
    # print >>sys.stderr, "args[0]>%s<" % (args[0],)
    # print >>sys.stderr, "var_components>%s<" % (var_components,)
    if prepend_p:
        all_components = args + var_components
    else:
        all_components = var_components + args
    #print >>sys.stderr, "all_components>%s<" % (all_components,)

    if empty_component_replacement is not False:
        new_list = []
        for e in all_components:
            if e == "":
                e = empty_component_replacement
            if e is not None:
                new_list.append(e)
        all_components = new_list
    #print >>sys.stderr, "all_components>%s<" % (all_components,)
    uniq_components = dp_sequences.uniqify_list_ordered(all_components)
    print(separator.join(uniq_components))

    for arg in args:
        # Handle arg
        pass

if __name__ == "__main__":
    main(sys.argv)
