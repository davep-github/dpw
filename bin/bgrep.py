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

DONE_STATE = "DONE, Just, DONE!"

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.setattr(namespace, "highlight_grep_matches_p", True)

##############################################################################
class HappyException(Exception):
    def __init__(self, *args, **kw_args):
        Exception.__init__(self, *args)
        self.d_args = args
        self.d_kw_args = kw_args

##############################################################################
def print_line(state, line):
    state.d_output_file.write(line)

##############################################################################
class State_data_t(object):
    def __init__(self, file_name, nth, open_regexp, close_regexp,
                 state_fun,
                 app_args,
                 fop = None,
                 line_handler=print_line,
                 end_state=DONE_STATE,
                 output_file=sys.stdout):
        self.d_file_name = file_name
        self.d_nth = nth
        self.d_open_regexp = dp_utils.re_compile_with_case_convention(open_regexp)
        if close_regexp is None:
            close_regexp = ".*"
        self.d_close_regexp = dp_utils.re_compile_with_case_convention(close_regexp)
        self.d_state_fun = state_fun
        self.d_app_args = app_args
        self.d_fop = fop
        self.d_line_handler = line_handler
        self.d_end_state = end_state
        self.d_output_file = output_file

        # <:non-argument-vars:>
        self.d_close_p = False
        self.d_error_code = 0
        self.d_error_msg = ""
        self.d_fun_change_list = []
        self.d_match_num = 0
        self.d_run_p = True
        self.d_most_recent_open_regexp_match_offset = None
        self.open_fop(close_and_reopen_p=True)

    ##############################################################################
    # Yarr, beware, ye be fer sure, or ye'll be brought down by thar collisions.
    def __getattr__(self, name):
        dp_io.cdebug(1, "__getattr__({})\n", name)
        return getattr(self.d_app_args, name)

    ##############################################################################
    def open_fop(self, close_and_reopen_p=False):
        dp_io.cdebug(1, "open_fop(), self.d_file_name>{}<\n", self.d_file_name)
        dp_io.cdebug(1, "open_fop(), self.d_fop>{}<\n", self.d_fop)
        fop = self.d_fop
        if fop and not fop.closed:
            if close_and_reopen_p:
                fop.close()
            else:
                raise RuntimeError("Attempting to open already opened file.")
        fop = open(self.d_file_name)
        self.d_fop = fop

    ##############################################################################
    def close_fop(state):
        if state.d_close_p:
            state.d_fop.close()
            state.d_close_p = False

    ##############################################################################
    def count_match(self):
        self.d_match_num += 1

    ##############################################################################
    def matches(self):
        return self.d_match_num

    ##############################################################################
    def fop_tell(self):
        return self.d_fop.tell()

    ##############################################################################
    def fop_seek(self, offset):
        return self.d_fop.seek(offset)

    ##############################################################################
    def fop_seek_match(self):
        off = self.d_most_recent_open_regexp_match_offset
        if off is None:
            state.die(exception=ValueError("No seek matches"))
        return self.fop_seek(self.d_most_recent_open_regexp_match_offset)

    ##############################################################################
    def fop_readline(self):
        return self.d_fop.readline()

    ##############################################################################
    def change_state_fun(self, new_fun):
        dp_io.cdebug(3, "Change state from: {} to {}\n",
                     self.d_state_fun, new_fun)
        self.d_state_fun = new_fun
        self.d_fun_change_list.append(self.d_state_fun)
#        dp_io.cdebug_exec(5, self.state_trace)

    ##############################################################################
    def state_trace(self):
        i = 0
        dp_io.printf("State trace:\n")
        for fun in self.d_fun_change_list:
            print "{}: {}".format(i, fun)
            i += 1

    ##############################################################################
    def __call__(self):
        return self.d_state_fun(self)

    ##############################################################################
    def die(self, message="", exception=None):
        if message:
            raise Exception(message)
        else:
            raise exception

    ##############################################################################
    def in_end_state(self):
        dp_io.cdebug(2, "end_state(): state_fun: %s\nend_state: %s\n",
                     self.d_state_fun, self.d_end_state)
        return self.d_state_fun == self.d_end_state

    ##############################################################################
    def run_p(self):
        return self.d_run_p and not self.in_end_state()

    ##############################################################################
    def stop(self):
        self.change_state_fun(DONE_STATE)
        self.d_run_p = False

    ##############################################################################
    def crank(self):
        while self.run_p():
            dp_io.cdebug(3, "crank(): about to run state fun: {}\n",
                         self.d_state_fun)
            self()

##############################################################################
def cat_from_offset(state):
    dp_io.cdebug(1, "enter cat_from_offset()\n")
    if dp_io.verbose_p(4):
        pre = "cat>"
        suf = "<cat\n"
    else:
        pre = ""
        suf = ""
    state.open_fop(state)
    state.fop_seek_match()
    if state.delimit_p:
        print_open_delimiter(state)
    while True:
        line = state.fop_readline()
        if not line:
            break
        if pre:
            line = line[:-1]
        state.d_line_handler(state, pre + line + suf)

    if state.delimit_p:
        print_close_delimiter(state)

    state.change_state_fun(DONE_STATE)

    return state

##############################################################################
def print_delimiter(state, prefix):
    state.d_line_handler(state, prefix + ("=" * 44) + '\n')

##############################################################################
def print_open_delimiter(state):
    print_delimiter(state, "+O: ")

##############################################################################
def print_close_delimiter(state):
    print_delimiter(state, "-C: ")

##############################################################################
def state_fun_nop(state):
    return state

##############################################################################
def state_fun_find_open(state):
    state.d_fop
    open_cre = state.d_open_regexp
    state.d_found_open_re_p = False
    read_from = 0
    #for line in state.d_fop:
    while True:
        offset = state.fop_tell()
        line = state.fop_readline()
        if not line:
            break
        dp_io.cdebug(4, "line@%s>%s<\n", state.fop_tell(), line[:-1])
        if open_cre.search(line):
            state.count_match()
            dp_io.cdebug(1, "state_fun_find_open(): match@offset: %d, line>%s<\n",
                         state.fop_tell(), line[:-1])
            ## @todo XXX Handle search for "LAST" open regexp match.
            if state.LAST_ONLY:
                dp_io.cdebug(2, "LAST_ONLY, skipping match.\n")
                state.d_most_recent_open_regexp_match_offset = offset
                continue

            if state.d_match_num >= state.d_nth:
                state.d_found_open_re_p = True
                state.d_most_recent_open_regexp_match_offset = state.fop_tell()
                break
        elif state.show_misses_p:
            dp_io.printf("open(): miss@offset: %d, line>%s<\n",
                         state.fop_tell(), line[:-1])
            
    if state.d_found_open_re_p and state.delimit_p:
        print_open_delimiter(state)
    if state.d_found_open_re_p:
        state.d_line_handler(state, line)

    if state.d_found_open_re_p:
        state.change_state_fun(state_fun_found_open_regexp)
    else:
        state.change_state_fun(state_fun_open_eof)
    state.d_nth = 1 # We want to process each open regexp after skipping the first <n>
    return state

##############################################################################
def state_fun_found_open_regexp(state):
    state.change_state_fun(state_fun_find_close)
    return state

##############################################################################
def raise_EOFError(state, message):
    state.d_error_msg = message
    raise EOFError(state.d_error_msg)

##############################################################################
def state_fun_open_eof(state):
    if state.matches():
        cat_from_offset(state)
        state.stop()
    else:
        raise_EOFError("Hit EOF without finding any opening regexps.")
    return state

##############################################################################
def state_fun_find_close(state):
    fop = state.d_fop
    close_cre = state.d_close_regexp
    found_close_re = False

    while True:
        line = state.fop_readline()
        if not line:
            break
        if not state.LAST_ONLY:
            state.d_line_handler(state, line)
            if close_cre.search(line):
                found_close_re = True
                break

        dp_io.cdebug(2, "state_fun_find_close(): offset: %d, line>%s<\n",
                     state.fop_tell(), line[:-1])

    if found_close_re:
        state.change_state_fun(state_fun_found_close)
        if state.delimit_p:
            print_close_delimiter(state)
    else:
        state.change_state_fun(state_fun_close_eof)
    return state

##############################################################################
def state_fun_close_eof(state):
    if not state.EOF_FOR_CLOSE_OK:
        raise_EOFError("Hit EOF scanning for close regexp.\n")
    state.change_state_fun(state_fun_eof)
    return state

##############################################################################
def state_fun_found_close(state):
    state.change_state_fun(state_fun_find_open)
    return state

###############################################################################
def state_fun_eof(state):
    state.close_fop()
    state.stop()
    return state

###############################################################################
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

    if type(file) is not type(""):
        fop = file
        file = fop.name
    else:
        fop = None

    state = State_data_t(file, nth, open_regexp, close_regexp, state_fun_find_open,
                         app_args, fop=fop, output_file=app_args.output_file)
    dp_io.cdebug(3, "state: %s\n", state)
    state.crank()
    if app_args.trace_on_exit_p:
        state.state_trace()

###############################################################################
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
                         dest="EOF_FOR_CLOSE_OK",
                         default=True,
                         action="store_true",
                         help="EOF counts as hitting the close regexp")
    oparser.add_argument("-C", "--no-eof-on-close-ok", "--no-eof-ok",
                         dest="EOF_FOR_CLOSE_OK",
                         default=True,
                         action="store_false",
                         help="EOF is an error whilst searching for the close regexp")
    oparser.add_argument("--eo", "--EO", "--eof-only", "--last",
                         dest="LAST_ONLY",
                         default=False,
                         action="store_true",
                         help="EOF must be the end of the region.")
    oparser.add_argument("-neo", "--no-eof-only", "--no-eo",
                         dest="LAST_ONLY",
                         default=False,
                         action="store_false",
                         help="Turn off LAST_ONLY.")
    oparser.add_argument("--delimit", "--wrap",
                         dest="delimit_p",
                         default=False,
                         action="store_true",
                         help="Wrap regions in delimiters.")
    oparser.add_argument("--no-delimit", "--no-wrap",
                         dest="delimit_p",
                         default=False,
                         action="store_false",
                         help="Wrap regions in delimiters.")
    oparser.add_argument("--show-misses", "--sm",
                         dest="show_misses_p",
                         default=False,
                         action="store_true",
                         help="Show mismatching line when looking for open regexp.")
    oparser.add_argument("--no-show-misses", "--no-sm", "--nsm",
                         dest="show_misses_p",
                         default=False,
                         action="store_false",
                         help="Show mismatching line when looking for open regexp.")
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
    oparser.add_argument("--out", "--ofile", "--output-file",
                         dest="output_file",
                         type=str,
                         default=sys.stdout,
                         help="Where do we show output?.")
    oparser.add_argument("-s", "--seq-out", "--seq-ofile", "--seq-output-file",
                         "--serialize-out", "--serialize-ofile",
                         "--serialize-output-file",
                         dest="seq_output_file_p",
                         default=False,
                         action="store_true",
                         help="Create serialized output file names if output-file is a filename.")

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
        if app_args.EOF_FOR_CLOSE_OK or app_args.LAST_ONLY:
            pass
        else:
            raise ValueError("Close regex required in this context. See EOF options.")
    elif app_args.LAST_ONLY:
        raise ValueError("Close regex not allowed in this context. See EOF options.")
    output_file = app_args.output_file
    if type(output_file) == type(""):
        if app_args.seq_output_file_p:
            output_file = dp_io.serialize_file_name(output_file)
    dp_io.cdebug(1, "output_file>{}<\n", output_file)
    if type(output_file) == type(""):
        output_file = open(output_file)

    with output_file as ofile:
        app_args.output_file = ofile
        fileses = app_args.fileses
        if (fileses):
            for file in fileses:
                with open(file) as fop:
                    handle_file(fop, app_args)
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
    except EOFError:
        sys.exit(0)
#    except Exception, e:
#        print >>sys.stderr, "Exception: e: {}".format(e)
#        sys.exit(1)

