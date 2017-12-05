#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno, re
import argparse
import dp_io, dp_utils

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

BROKEN_PIPE_RC = 1
IOERROR_RC = 1

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.setattr(namespace, "highlight_grep_matches_p", True)

##############################################################################
def print_line(state, line):
    state.d_out_file.write(line)

########################################################################
class State_data_t(object):
    def __init__(self, file_name, nth, open_regexp, close_regexp,
                 state_fun,
                 app_args,
                 line_handler=print_line,
                 end_state="DONE",
                 out_file=sys.stderr):
        self.d_file_name = file_name
        self.d_nth = nth
        self.d_open_regexp = dp_utils.re_compile_with_case_convention(open_regexp)
        self.d_close_regexp = dp_utils.re_compile_with_case_convention(close_regexp)
        self.d_state_fun = state_fun
        self.d_app_args = app_args
        self.d_line_handler = line_handler
        self.d_end_state = end_state
        self.d_out_file = out_file

        self.d_close_p = False
        self.d_error_code = 0
        self.d_error_msg = ""
        self.d_fun_change_list = []
        self.d_match_num = 0
        if type(file_name) == type(""):
            self.d_fop = open(file_name)
            self.close_p = True
        else:
            self.d_fop = file_name
            self.close_p = False
        self.d_run_p = True

    ########################################################################
    # Yarr, beware, ye be fer sure, or ye'll be brought down by thar collisions.
    def __getattr__(self, name):
        return getattr(self.d_app_args, name)

    def count_match(self):
        self.d_match_num += 1

    def fop_tell(self):
        return self.d_fop.tell()

    def fop_seek(self, offset):
        return self.d_fop(offset)

    def fop_readline(self):
        return self.d_fop.readline()

    def change_state_fun(self, new_fun):
        dp_io.cdebug(3, "Change state to %s\n", new_fun)
        self.d_state_fun = new_fun
        self.d_fun_change_list.append(self.d_state_fun)
#        dp_io.cdebug_exec(5, self.state_trace)

    def state_trace(self):
        i = 0
        for fun in self.d_fun_change_list:
            print "{}: %s".format(i, fun)
            i += 1

    def __call__(self):
        return self.state_fun(self)

    def in_end_state(self):
        dp_io.cdebug(2, "end_state(): state_fun: %s\nend_state: %s\n",
                     self.d_state_fun, self.d_end_state)
        return self.d_state_fun == self.d_end_state

    def run_p(self):
        return self.d_run_p and not self.in_end_state()

    def crank(self):
        while self.run_p():
            self.d_state_fun(self)

########################################################################
def state_fun_nop(state):
    return state

########################################################################
def state_fun_find_open(state):
    state.d_fop
    open_cre = state.d_open_regexp
    state.d_found_open_re_p = False
    #for line in state.d_fop:
    while True:
        line = state.fop_readline()
        if not line:
            break
        dp_io.cdebug(2, "line@%s>%s<\n", state.fop_tell(), line[:-1])
        if open_cre.search(line):
            state.count_match()
            dp_io.cdebug(1, "open(): match@offset: %d, line>%s<\n",
                         state.fop_tell(), line[:-1])
            ## @todo XXX Handle "LAST"
            if state.d_match_num >= state.d_nth:
                state.d_found_open_re_p = True
                break
    print "+O: ========================================================================"
    if state.d_found_open_re_p:
        state.d_line_handler(state, line)

    state.d_nth = 1                      # We want to process each open regexp.
    if state.d_found_open_re_p:
        state.change_state_fun(state_fun_found_open_regexp)
    else:
        state.change_state_fun(state_fun_open_eof)
    return state

########################################################################
def state_fun_found_open_regexp(state):
    state.change_state_fun(state_fun_find_close)
    return state

####################################################################################
def raise_EOFError(state, message):
    state.d_error_msg = message
    raise EOFError(state.d_error_msg)

########################################################################
def state_fun_open_eof(state):
    raise_EOFError("Cannot find {}th opening regexp.".format(state.d_nth))

########################################################################
def state_fun_cat_from_offset(state):
    open_fop(state, fop_or_name)
    print >>sys.stderr, "!!!FINI ME!!!"
    return state

########################################################################
def state_fun_find_close(state):
    fop = state.d_fop
    close_cre = state.d_close_regexp
    state.d_found_close_re = False

    while True:
        line = state.fop_readline()
        if not line:
            break
        if not state.EOF_ONLY:
            state.d_line_handler(state, line)
            if close_cre.search(line):
                found_close_re = True
                break

        dp_io.cdebug(1, "close(): offset: %d, line>%s<\n", state.fop_tell(),
                     line[:-1])

    print "-C: ========================================================================"

    if found_close_re:
        if (state.EOF_ONLY and not state.EOF_FOR_CLOSE_OK):
            state.change_state_fun(state_fun_close_eof)
        else:
            state.change_state_fun(state_fun_found_close)
    elif state.EOF_FOR_CLOSE_OK:
        state.change_state_fun(state_fun_found_close)
    else:
        state.change_state_fun(state_fun_close_eof)
    return state

########################################################################
def state_fun_close_eof(state):
    close_fop(state)
    if (not state.EOF_FOR_CLOSE_OK):
        raise_EOFError("Cannot find close regexp.")
    state.change_state_fun("DONE")
    return state

########################################################################
def state_fun_found_close(state):
    if state.EOF_ONLY:
        state.change_state_fun(state_fun_cat_from_offset)
    else:
        state.change_state_fun(state_fun_find_open)

########################################################################
def close_fop(state):
    if state.d_close_p:
        state.d_fop.close()
        state.d_close_p = False

########################################################################
def open_fop(state, fop_or_name):
    if type(fop_or_name) == type(""):
        close_p = True
        state.d_fop = open(file)
    else:
        state.d_close_p = False
        state.d_fop = file

########################################################################
def handle_file(file, app_args):
    nth = app_args.nth_open_bracket
    dp_io.cdebug(2, "open_regexp>%s<\n", app_args.open_regexp)
    open_regexp = app_args.open_regexp
    if type(open_regexp) == type(""):
        open_cre = re.compile(app_args.open_regexp)
    else:
        open_cre = open_regexp
    close_regexp = app_args.close_regexp
    if type(close_regexp) == type(""):
        close_cre = re.compile(app_args.close_regexp)
    else:
        close_cre = close_regexp
    found_nth = False

    state = State_data_t(file, nth, open_regexp, close_regexp, state_fun_find_open,
                         app_args)
    dp_io.cdebug(3, "state: %s\n", state)
    state.crank()
    state.state_trace()
    
########################################################################
def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug", "--dl",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
    oparser.add_argument("--verbose-level", "--vl",
                         dest="verbose_level",
                         type=int,
                         default=-1,
                         help="Set verbose/trace level. Use with, e.g. "
                         "dp_io.ctracef(<n>, fmt [, ...])")
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    oparser.add_argument("-t", "--trace-on-exit", "--toe",
                         dest="trace_on_exit_p",
                         default=False,
                         action="store_true",
                         help="Show trace all state functions before exiting.")
    oparser.add_argument("-T", "--no-trace-on-exit", "--no-toe",
                         dest="trace_on_exit_p",
                         default=False,
                         action="store_false",
                         help="Do not show trace all state functions before exiting.")
    oparser.add_argument("-E", "--eof-on-close-ok", "--eof-ok",
                         dest="EOF_ON_CLOSE_OK",
                         default=True,
                         action="store_true",
                         help="EOF counts as hitting the close regexp")
    oparser.add_argument("-C", "--no-eof-on-close-ok", "--no-eof-ok",
                         dest="EOF_ON_CLOSE_OK",
                         default=True,
                         action="store_false",
                         help="EOF is an error whilst searching for the close regexp")
    oparser.add_argument("--eo", "--EO", "--eof-only",
                         dest="EOF_ONLY",
                         default=False,
                         action="store_true",
                         help="EOF must be the end of the region.")
    oparser.add_argument("-neo", "--no-eof-only", "--no-eo",
                         dest="EOF_ONLY",
                         default=False,
                         action="store_false",
                         help="EOF need not be the end of the region.")
    oparser.add_argument("--nth-open-bracket", "--nth",
                         dest="nth_open_bracket",
                         type=int,
                         default=0,
                         help="Skip this many open regexps.")
    oparser.add_argument("-o", "-e", "--open", "--bre", "--ore", "--regexp",
                         dest="open_regexp",
                         type=str,
                         default=None,  # Cannot be none
                         help="Regexp of opening bracket.")

    oparser.add_argument("-c", "--cre", "--ere", "--eregexp",
                         dest="close_regexp",
                         type=str,
                         default=None,  # None --> close is open.
                         help="Regexp of closing bracket.")
    

##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args, first arg is name that goes into app_args.
    oparser.add_argument("fileses", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)
    dp_io.cdebug(3, "app_args>%s<\n", app_args)

    if app_args.open_regexp is None:
            raise ValueError("Opening regexp must be specified.")
    if app_args.close_regexp is None:
        if app_args.EOF_FOR_CLOSE_OK or app_args.EOF_ONLY:
            pass
        else:
            raise ValueError("Close regex required in this context. See EOF options.")
    elif app_args.EOF_ONLY:
        raise ValueError("Close regex not allowed in this context. See EOF options.")
            
    fileses = app_args.fileses
    if (fileses):
        for file in fileses:
            handle_file(file, app_args)
    else:
        handle_file(sys.stdio, app_args)
            

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError, e:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print >>sys.stderr, ":Broken PIPE:"
            sys.exit(BROKEN_PIPE_RC)
        print >>sys.stderr, "IOError>%s<" % (e,)
        sys.exit(IOERROR_RC)
#    except Exception, e:
#        print >>sys.stderr, "Exception: e: {}".format(e)
#        sys.exit(1)

