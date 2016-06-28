#!/usr/bin/env python

import sys, os, time, subprocess, re
import dp_sequences, dp_io, dp_utils

import ranking_global_gtags_lib
rgg = ranking_global_gtags_lib
log_file = rgg.setup_logging()
hdr_fmt = "==== {}: {} " + (47 * "=") + "\n"
rgg.log_file.write(hdr_fmt.format("begin", time.ctime()))

import find_up, p4_lib
opath = os.path

# Use [] so we fail messily if there is nothing defined.
WORK_INDEX_DB_LOCS = os.environ.get("WORK_INDEX_DB_LOCS", "")

# Everything will search up to the sandbox root. There is one other known
# place and that is TOT
# Abbrev or //p4/loc name.
Database_p4_locations = WORK_INDEX_DB_LOCS.split()
Database_locations = []
## Move this into ranking_global_gtags.py???

rgg_memo_file_name = "rgg_memo_file." + dp_utils.bq("dp4-get-root --basename")
rgg.log_file.write("rgg_memo_file_name>{}<\n".format(rgg_memo_file_name))
rgg_memo_file = dp_utils.make_db_file_name(rgg_memo_file_name)
rgg.log_file.write("rgg_memo_file>{}<\n".format(rgg_memo_file))
go_files, _ = dp_utils.process_gopath()
newest, _, _ = dp_utils.newest_file(go_files + [rgg_memo_file])

def create_db_locations(db_memo_file, dependencies, args):
    db_locations = []

    for dir in Database_p4_locations:
        rgg.log_file.write("Dir>{}<\n".format(dir))
        dir = p4_lib.p4_sb_location_to_absolute(dir)
        rgg.log_file.write("Dir>{}<\n".format(dir))
        if dir:
            dir = os.path.join(dir, "GTAGS")
            db_locations.append(dir)
    return db_locations

Database_locations = dp_utils.cheesy_memoized_file(
    rgg_memo_file,
    go_files,
    creator = create_db_locations,
    eval_p = True,
    write_new_p = True)

Out_of_tree_dbs = os.environ.get("WORK_INDEX_DB_LOCS", "")
Out_of_tree_dbs = Out_of_tree_dbs.split()

Database_locations.extend(Out_of_tree_dbs)

Database_locations = [ loc for loc in Database_locations
                       if opath.isfile(loc) ]

# Want to search upward from cwd for a db.
# Then want to search all other databases.

rgg.log_file.write("WORK_INDEX_DB_LOCS>{}<\n".format(WORK_INDEX_DB_LOCS))
pretty_db_string = dp_sequences.list_to_indented_string(Database_locations)
rgg.log_file.write("Database_locations>{}<\n".format(pretty_db_string))

def rank_init(
    top_ranking_regexp_strings,
    filter_out_regexp_strings):

    rgg.add_top_ranking_regexp_strings(top_ranking_regexp_strings)
    rgg.add_filter_out_regexp_strings(filter_out_regexp_strings)


# If we see *any* one of these options, punt to global(1)
## @todo XXX We want to handle at least --single-update so that we can update
## all ancestral data bases.
Passthrough_options = ["-u", "--single-update" ]
# (one_db_p-Value, all_matches_p-Value)
All_matches_map = { "-u":
                    (True, True),
                    "--single-update":
                    (True, True),
                    "-c":
                    (False, True)}
def rank_main1(argv):
    rgg.log_file.write("rank_main({})\n".format(argv))
    all_matches_p = False
    one_db_p = False

    ## Check args to determine default way to handle all_matches_p.  The
    ## value can always be set using explicit args.
    for arg in argv:
        try:
            one_db_p, all_matches_p = All_matches_map[arg]
            print >>sys.stderr, "one_db_p:", one_db_p, ", all_matches_p:", all_matches_p
            break
        except KeyError:
            continue

    if all_matches_p is None:
        all_matches_p = False

    rgg.log_file.write("all_matches_p: {}, one_db_p: {}\n".format(all_matches_p,
                                                                  one_db_p))
    filter_p = os.environ.get("BEA_FILTER")
    uniqify_p = True

    rgg_argv = os.environ.get("RGG_ARGV")
    if (rgg_argv):
        rgg.parse_args(rgg_argv)

    if argv[1] == '-d':
        for d in Database_locations:
            print "{}".format(opath.dirname(d))
        sys.exit(0)

    # we need to pass everything to global, verbatim. WHY?
    rgg.log_file.write("PWD>%s<\n" % (os.environ.get("PWD", "//NO PWD//"),))
    rgg.log_file.write("argv: %s\n" % \
                       dp_sequences.list_to_indented_string(argv))
    if argv[1] == '-pr' or argv[1] == '-rp':
        arg = '-p'
        # args = [arg] + argv[2:]
        args = argv[1:]
        # print "[arg] + argv[2:]>%s<" % (args,)
        # sys.exit(99)
        glob = subprocess.Popen(["global"] + args,
                                stdout=subprocess.PIPE)
        for line in glob.stdout:
            if line[-1] == '\n':
                line = line[:-1]
            if line:
                print line
        sys.exit(0)

    opt_cre = re.compile("--rgg-(.*)$")
    # So we don't remove elements from the iteration list
    argv_copy = argv[0:]
    for arg in argv_copy[1:]:
        # This make not passing in args easier.  E.g.
        # (or dp-gtags-auto-update-flags "")
        # since `call-process' wants strings
        # and this is easy to do.
        if arg in ('', '--nop', '--noop'):
            argv.remove(arg)
        opt = opt_cre.search(arg)
        #print >>sys.stderr, "arg>{}<, opt>{}<".format(arg, opt)

        if not opt:
            break
        opt_name = opt.group(1)
        #print >>sys.stderr, "opt>{}<, opt_name>{}<".format(opt, opt_name)
        if opt_name == "no-uniq":
            uniqify_p = False
            argv.remove(arg)
            continue
        if opt_name == "one-db":
            one_db_p = True
            argv.remove(arg)
            continue
        # This means all matches from first DB that has matches
        if opt_name in ("stop-after-first",
                        "first-match",
                        "first-db",
                        "first-db-match",
                        "first-db-matches",
                        "one-p",
                        "not-all-matches-p"):
             all_matches_p = False
             argv.remove(arg)
             continue
        if opt_name in ("all-matches",
                        "all-match",
                        "all-db",
                        "all-dbs",
                        "all-p",
                        "all-db-match",
                        "all-db-matches",
                        "all-matches-p"):
            all_matches_p = True
            one_db_p = False
            argv.remove(arg)
            continue

    print >>sys.stderr, "argv>%s<" % (argv,)
    #@todo XXX We should do this in every db searched.
    #@todo XXX Why was it commented out?
    #@todo XXX Pass an update flag to run_globals_over_path()?  This way we
    #@todo XXX hit only those dbs we search.
    #@todo XXX Or do we always want to do them all?
#    if argv[1] in ('-u' '--update'):
#        sys.exit(subprocess.call(["global"] + argv[1:]))

    # Find this dir's parental db(s).
    path = find_up.find_up("GTAGS", all_p = not one_db_p)
    rgg.log_file.write("find_up(): path: %s\n" % \
                       dp_sequences.list_to_indented_string(path))
    # Add all other known db locations.
    # We should only add new elements.
    path.extend(Database_locations)
    dp_io.ctracef(1, "before uniq: path>{}<\n", "\n ".join(path))
    rgg.log_file.write("before uniq: path>{}<\n".format("\n ".join(path)))
    path = dp_sequences.uniqify_list_ordered(path)
    dp_io.ctracef(1, "after uniq: path>{}<\n", "\n ".join(path))
    rgg.log_file.write("after uniq: path>{}<\n".format("\n ".join(path)))

    rgg.log_file.write("extended path: %s\n" % \
                       dp_sequences.list_to_indented_string(path))

    rc = 0
    if filter_p:
        lines = get_lines(sys.stdin)
    else:
        #lines = run_globals_path(argv, path)
        lines = rgg.run_globals(argv, path,
                                start_dir=opath.realpath(opath.curdir),
                                all_matches_p=all_matches_p)

    if lines:
        if uniqify_p:
            lines = rgg.uniqify_matches(lines)
            
        rgg.log_file.write("lines: %s\n" % \
                           dp_sequences.list_to_indented_string(lines))
        lines = rgg.rank_lines(lines)
        rgg.log_file.write("ranked lines: %s\n" % \
                           dp_sequences.list_to_indented_string(lines))
        rgg.log_file.write("output >>>>>>>>>>>>>>\n")
        for line in lines:
            print line
            rgg.log_file.write("line>" + line + "<" + "\n")
        rgg.log_file.write("<<<<<<<<<<<<<< output\n")
        rc = 0
    else:
        rgg.log_file.write("No matching lines.\n")
        #rc = 1
        ## emacs' gtags doesn't like non-0 return code.
        rc = 0
    rgg.log_file.write(hdr_fmt.format("finish", time.ctime()))

    return rc

def rank_main(argv):
    try:
        rc = rank_main1(argv)
        rgg.log_file.write("All good.\n")

    except Exception, e:
        rgg.log_file.write("Error.\n")
        rgg.log_file.write("Failed, exception: {}\n".format(e))
        rgg.log_file.write("sys.exc_type: {}\n".format(sys.exc_type))
        rgg.log_file.write("sys.exc_value: {}\n".format(sys.exc_value))
        rgg.log_file.write("Error.\n")
        rc = 1
    rgg.log_file.close()
    return rc
