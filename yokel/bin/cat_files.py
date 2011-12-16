#!/usr/bin/env python

import sys, os, types

    
def cat(file_obj_in=sys.stdin, file_objs_out=(sys.stdout,)):
    for line in file_obj_in:
        for file_obj_out in file_objs_out:
            file_obj_out.write(line)

def cat_files(file_names_in=(sys.stdin,), file_names_out=(sys.stdout,)):
    file_objs_out = []
    open_files = []
    for file_obj_out in file_names_out:
        if type(name) != types.FileType:
            file_obj_out = file(file_name_out, file_mode_out)
            open_files.append(file_obj_out)
        file_objs_out.append(file_objs_out)
        
    for file_obj_in in file_names_in:
        if type(file_obj_in) != types.FileType:
            close_needed_p = True
            file_obj_in = file(file_obj_in, "r")
        else:
            close_needed_p = False
        cat(file_obj_in, file_objs_out)
        if close_needed_p:
            file_obj_in.close()
    for file_obj in open_files:
        file_obj.close()


def main(args):
    import getopt
    # Defer assignment so mode can be set anywhere in the command line.
    file_names_out = []
    file_mode_out = "a"
    opts, args = getopt.getopt(args[1:], "o:O:")
    for o, v in opts:
        if o == '-o':
            if v == '-':
                file_names_out.append(sys.stdout)
            else:
                file_names_out.append.append(v)
            continue
        if o == '-O':
            file_mode_out = v
            continue
    cat_files(args, file_names_out)
    sys.exit(0)
        

if __name__ == "__main__":
    main(sys.argv)


