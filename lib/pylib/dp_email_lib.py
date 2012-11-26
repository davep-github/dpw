#!/usr/bin/env python
#############################################################################
## @package
##
import sys, os, string, re, types
import email
import dp_io, dp_sequences
from dp_io import sprintf, eprintf, printf, fprintf, vcprintf, vprintf

DP_EL_None = """None object for dp_email_lib.py so we can distinguish an
"empty" return from a legitimate return of the value `None'."""
DELIVERED_TO_HEADER_NAME = "Delivered-To"
RECEIVED_HEADER_NAME = "Received"
SUBJECT_HEADER_NAME = "Subject"
X_ANNOTATION_Header = "X-dp-email-lib-annotation"
X_INFO_Header = "X-dp-info"
# This was originally written to work with the getmail mta, so these names make
# sense if you read its filters doc.
QUIET_FOR_GETMAIL_p = "QUIET_FOR_GETMAIL_p"
GETMAIL_RUNTIME_KW_ARGS = {QUIET_FOR_GETMAIL_p: True,
                           "anomaly_ostream": None}

DP_EL_FLAG_FALL_OFF_END_OK = "Fall off end ok"
GETMAIL_SENSITIVE_OSTREAMS = set([sys.stdout, sys.stderr])
GODADDY_CL_FLAG = "-g"

NO_FLAGS = []

def getmail_sensitive_ostream_p(os):
    return GETMAIL_SENSITIVE_OSTREAMS.intersection(dp_sequences.listify(os))

def GODADDY_FIX_p(args):
    return GODADDY_CL_FLAG in args

def annotate_imperfections(msg, header, fmt, *fmt_args):
    msg.add_header(header, fmt % fmt_args)

def email_lib_none_p(v):
    return v is None or v == DP_EL_None

def SET_FLAG(current_flags, *new_flags):
    if not current_flags:
        return new_flags
    for f in new_flags:
        if f not in current_flags:
            current_flags.append(f)
    return current_flags

def CLEAR_FLAGS(current_flags, flag):
    ret = []
    # Use [a] built in functions(s)
    for f in current_flags:
        if f != flag:
            ret.append(f)
    return ret

def FLAG_SET_P(current_flags, flag):
    if not current_flags:
        return False
    return flag in current_flags

def FLAGS_ALL_SET_P(current_flags, flags):
    for f in flags:
        if not FLAGS_ALL_SET_P(current_flags, f):
            return False
    return True

def FLAGS_ANY_SET_P(current_flags, flags):
    for f in flags:
        if flag in current_flags:
            return True
    return False

def FLAGS_NONE_SET_P(current_flags, flags):
    return not FLAGS_ANY_SET_P(current_flags, flags)

def fall_off_end_ok_p(flags):
    return FLAG_SET_P(flags, DP_EL_FLAG_FALL_OFF_END_OK)

def KW_VERBOSE_p(kw_args, level):
    if kw_args.get(QUIET_FOR_GETMAIL_p):
        return False
    if level in (None, True, False):
        # Force the return to be a member of {True, False}
        return not not level
    # If there's a verbose level in kw_args, use that, else use the current
    # global verbose level from dp_io
    try:
        return kw_args["verbose"] > level
    except KeyError:
        return dp_io.verbose_p(level)
    raise RuntimeError("You should not be here.")

def KW_VERBOSE(kw_args, level, fmt, *args, **my_kw_args):
    if kw_args.get(QUIET_FOR_GETMAIL_p):
        return
    pfunk = my_kw_args.get("verbose_pfunk", vprintf)
    if KW_VERBOSE_p(kw_args, level):
        pfunk(fmt, *args)

# anomaly
def ANOMALY(kw_args, msg_fmt, *msg_args, **my_kw_args):
    ostream = (my_kw_args.get("anomaly_ostream", False)
               or
               kw_args.get("anomaly_ostream", sys.stderr))
    if (kw_args.get(QUIET_FOR_GETMAIL_p)
        and
        getmail_sensitive_ostream_p(ostream)):
        return
    if ostream and kw_args.get("print_anomalies_p", False):
        fprintf(ostream, "ANOMALY detected: " + msg_fmt, *msg_args)

def file_obj_name(fo):
    if type(fo) == types.StringType:
        return fo
    if not fo:
        return "!!!no name for file object!!!!"
    return fo.name

def parse_message(file_obj, headersonly=False, **kw_args):
    return email.message_from_file(file_obj)

#
# Find last field in the headers (which is the first field chronologically)
# eg: with SMTP for <davep@meduseld.net>; Fri, 25 Jul 2008 03:27:41 +0000
# Since GoDaddy fucks up Delivered-To: headers, I look for the earliest
# E?SMTP for field which always seems to have the name I use to deliver mail.

WITH_SMTP_FOR_REGEXP = re.compile("E?SMTP\s+for\s+<(?P<with_SMTP_for>[^>]*)>",
                                  re.IGNORECASE)

def parse_msg_if_needed(file_obj, msg=None, **kw_args):
    if msg:
        return msg
    close_file_p = False
    if type(file_obj) == types.StringType:
        file_obj = open(file_obj, "r")
        close_file_p = True
    msg = msg or parse_message(file_obj, **kw_args)
    if close_file_p:
        file_obj.close()
    if not msg:
        return None
    return msg

class Iter_return_c(object):
    def __init__(self, result=None, done_p=None, func_context=None,
                 success_p=False):
        self.result = result
        self.done_p = done_p
        self.func_context = func_context
        self.success_p = success_p

    def ok(self):
        return self.success_p

    def bad(self):
        return not self.ok()

    def __nonzero__(self):
        """for if X:  and if not X: """
        return not not self.success_p

    def __str__(self):
        return "<irc:= result: %s, done_p: %s, func_context: %s, success_p: %s>" % (
            self.result, self.done_p, self.func_context, self.success_p)

    def __repr__(self):
        return self.__str__()

def apply_to_each_header_instance(file_obj, header_name, func,
                                  msg=None, func_context=None,
                                  result=None, done_p=False,
                                  success_p=None, flags=NO_FLAGS,
                                  **kw_args):
    """Return (result, done_p, func_context, success_p)"""
    msg = parse_msg_if_needed(file_obj, msg, **kw_args)
    if msg == None:
        return None
    # result=None, done_p=None, func_context=None, success_p=False):
    ret_val = Iter_return_c(result=result, done_p=done_p,
                            func_context=func_context,
                            success_p=success_p)
    headers = msg.get_all(header_name)
    if not headers:
        ANOMALY(kw_args, "No %s headers in message.\n", header_name)
        return ret_val
    for header in headers:
        KW_VERBOSE(kw_args, 10, "A1: header>%s<\n", header)
        KW_VERBOSE(kw_args, 7,
                      "apply_to_each_header_instance, kw_args: %s", kw_args)
        ret_val = func(header=header, func_context=ret_val.func_context,
                       flags=flags, **kw_args)
        KW_VERBOSE(kw_args, 0, "ret_val: %s\n", ret_val)
        if done_p:
            KW_VERBOSE(kw_args, 0, "apply... done_p, returning: %s\n", ret_val)
            return ret_val

    if fall_off_end_ok_p(flags):
        KW_VERBOSE(kw_args, 0, "apply... falling off and returning: %s\n",
                   ret_val)
        return ret_val
    ret_val.success_p = False
    return ret_val

def get_earliest_with_SMTP_for(file_obj, msg=None, **kw_args):
    # Lambda ;-)
    def get_earliest(header, func_context=None, func_args=None, flags=None,
                     **kw_args):
        flags = flags or []   # Don't nuke the [] by using it as default arg.
        m = WITH_SMTP_FOR_REGEXP.search(header)
        KW_VERBOSE(kw_args, 9, "m: %s, A2: header>%s<\n", m, header)
        if m:
            # Just keep overwriting... we want the last one.
            with_SMTP_for = m.groupdict()["with_SMTP_for"]
            KW_VERBOSE(kw_args, 4, "with_SMTP_for: >%s<\n",
                       with_SMTP_for)
            func_context = with_SMTP_for
        # result=None, done_p=None, func_context=None, success_p=False):
        return Iter_return_c(result=func_context, done_p=False,
                             func_context=func_context,
                             success_p= SET_FLAG(NO_FLAGS,
                                                 DP_EL_FLAG_FALL_OFF_END_OK))

    KW_VERBOSE(kw_args, 7,
               "get_earliest_with_SMTP_for, kw_args: %s\n", kw_args)
    flags = SET_FLAG(kw_args.get("flags", NO_FLAGS),
                     DP_EL_FLAG_FALL_OFF_END_OK)
    return apply_to_each_header_instance(file_obj, RECEIVED_HEADER_NAME,
                                         func=get_earliest, msg=msg,
                                         flags=flags, **kw_args)


##!<@todo This should all go into a single config file. Northern vers.
MY_DOMAINS = ("meduseld.net", "mvsik.org",
              "crickhollow.org", "crickhollow.org")
MY_DOMAINS_RE = "(meduseld\.net|(withywindle|crickhollow|mvsik)\.org)"
MY_DOMAINS_EMAIL_RE = "(@" + MY_DOMAINS_RE + "$)"
MY_CATCHALL_address_RE = "(catch-?all" + MY_DOMAINS_EMAIL_RE + ")"
MY_CATCHALL_address_RE_cre = re.compile(MY_CATCHALL_address_RE, re.IGNORECASE)
BAD_DELIVERED_TO_REGEXP =  "(unknown|" + MY_CATCHALL_address_RE + ")"
BAD_DELIVERED_TO_REGEXP_cre = re.compile(BAD_DELIVERED_TO_REGEXP,
                                         re.IGNORECASE)
##!<@todo This all should go into a single config file. Southern vers.

def catchall_delivered_to(file_obj, msg=None, **kw_args):
    msg = parse_msg_if_needed(file_obj, msg, **kw_args)
    m = None
    # Are all `DELIVERED_TO_HEADER_NAME's OK?
    dts = msg.get_all(DELIVERED_TO_HEADER_NAME)
    if not dts:
	return False

    for dt in dts:
        # Some messages (? mostly spam ?) have fucked up headers that seem to
        # confuse Python's email module.
        if not dt:
            ANOMALY(kw_args, "None element in %s headers:\n  %s\n",
                    DELIVERED_TO_HEADER_NAME, """``""" +
                    string.join([ "%s" % x for x in dts ], """'''\n ```""") +
                    """''""")
            continue
        # Do we need to make a good one?
        # Does it suck?
        KW_VERBOSE(kw_args, 9, "dt>%s<\n", dt)
        m = MY_CATCHALL_address_RE_cre.search(dt)
        if m:
            if kw_args.get("print_catchall_delivered_to", False):
                vprintf("fo: %s, has a catchall %s: %s\n",
                        file_obj_name(file_obj), DELIVERED_TO_HEADER_NAME,
                        dt)
            return dt
    if kw_args.get("print_catchall_delivered_to", False):
        vprintf("fo: %s is clean.\n", file_obj_name(file_obj))
    return False

def fix_delivered_to(file_obj, msg=None, **kw_args):
    msg = parse_msg_if_needed(file_obj, msg, **kw_args)

    KW_VERBOSE(kw_args, 13, "%s\nOriginal message:\n%s\n", '=' * 77, msg)

    m = None
    # Is the newest delivered to OK?
    dts = msg.get_all(DELIVERED_TO_HEADER_NAME)
    if dts and len(dts) > 0:
        # Do we need to make a good one?
        dt0 = string.lower(dts[0])
        # Does it suck?
        m = BAD_DELIVERED_TO_REGEXP_cre.search(dt0)
        if not m:
            KW_VERBOSE(kw_args, 7, "GASP! A good one! >%s<\n", dt0)
            return msg
        # Yep...
    else:
        # No delivered tos at all... add a good one.
        ANOMALY(kw_args, "No %s headers in message.\n",
                DELIVERED_TO_HEADER_NAME)

    # Get a good one and add it (if no others) or replace newest one.
    good_one = get_earliest_with_SMTP_for(None, msg=msg, **kw_args).result
    if not good_one:
        ANOMALY(kw_args, """No "with E?SMTP for" headers.  Nothing to do.""")
        return msg
    KW_VERBOSE(kw_args, 3, "bad Delivered-To>%s<\nto be replaced by>%s<\n",
               (m and m.groups()[0]) or "**NO SMTP FORS**", good_one)
    if dts:
        msg.replace_header(DELIVERED_TO_HEADER_NAME, good_one)
    else:
        msg.add_header(DELIVERED_TO_HEADER_NAME, good_one)

    annotate_imperfections(msg, X_ANNOTATION_Header,
                           "%s: changed from >%s< to >%s<",
                           DELIVERED_TO_HEADER_NAME,
                           (dts and dts[0]) or
                           ("**No %s headers found." % DELIVERED_TO_HEADER_NAME),
                           good_one)
    if KW_VERBOSE_p(kw_args, 3):
        vprintf("file name: %s\n", file_obj_name(file_obj))
        vprintf("received: %s\n", msg.get_all(RECEIVED_HEADER_NAME))
        vprintf("%s:\n  Orig: %s\n  New:  %s\n",
                DELIVERED_TO_HEADER_NAME, dts,
                msg.get_all(DELIVERED_TO_HEADER_NAME))
        vprintf("%s\n", "=" * 77)
    KW_VERBOSE(kw_args, 13, "%s\nNew (and improved) message:\n%s\n",
               '=' * 77, msg)
    return msg

CATCHALL_ANNO = "**CATCH-ALL**"
CATCHALL_ANNO_RE = "\*+CATCH-?ALL\*+"
CATCHALL_ANNO_CRE = re.compile(CATCHALL_ANNO_RE, re.IGNORECASE)
def rewrite_catchall_subject(file_obj, msg=None, **kw_args):
    ## An `apply_to_each_header_instance' called function.
    """If we see a delivered to header for catch-?all, add an annotation
to the Subject header."""
    msg = parse_msg_if_needed(file_obj, msg, **kw_args)
    cadt_p = catchall_delivered_to(file_obj, msg=msg, **kw_args)
    if cadt_p:
        KW_VERBOSE(kw_args, 9, "B: fobj: %s\n subj headers>%s<\n",
                   file_obj_name(file_obj),
                   msg.get_all(SUBJECT_HEADER_NAME))
        # Get subject line if present.  Otherwise use an informative
        # surrogate.
        subject = msg.get(SUBJECT_HEADER_NAME, "** NO SUBLECT LINE PRESENT **")
        # Annotate and replace the subject header if not already annotated.
        if not CATCHALL_ANNO_CRE.search(subject):
            msg.replace_header(SUBJECT_HEADER_NAME,
                               CATCHALL_ANNO + " " + subject)
            KW_VERBOSE(kw_args, 9, "A: fobj: %s\n subj headers>%s<\n",
                       file_obj_name(file_obj),
                       msg.get_all(SUBJECT_HEADER_NAME))
        else:
            ## Doubly annotate?
            KW_VERBOSE(kw_args, 99,
                       "%s: subject line is already annotated:\n%s",
                       file_obj_name(file_obj), subject)
            # Nay, X-Delivered...
            annotate_imperfections(msg, X_ANNOTATION_Header,
                                   "Subject: already annotated: %s",
                                   subject)
    KW_VERBOSE(kw_args, 9, "%s", file_obj_name(file_obj))
    # It's polite to return something (hopefully) useful.
    return cadt_p

def subject_already_rewritten_catchall_p(file_obj, msg=None, **kw_args):
    # Lambda ;-)
    def ca_p(header, func_args=None, func_context=None, **kw_args):
        m = re.search("CATCH.?ALL", header)
        if m:
            # Done on the first one we find.
            vprintf(1, "found one in: %s\n  header: %s.\n",
                    kw_args["file_obj_name"], header)
            return Iter_return_c(header, True, header, False)
        return Iter_return_c(None, False, None, False)

    # Useful for debugging.
    kw_args["func_context"] = file_obj_name(file_obj)
    kw_args["file_obj_name"] = file_obj_name(file_obj)
    zuzz = apply_to_each_header_instance(file_obj, SUBJECT_HEADER_NAME,
                                         func=ca_p,
                                         msg=msg,
                                         **kw_args)
    return zuzz.result

def add_last_header(file_obj, msg=None, **kw_args):
    msg = parse_msg_if_needed(file_obj, msg, **kw_args)
    msg.add_header(X_INFO_Header,
                   "-- dp_email_lib.py: End of headers. --")

def print_msg(file_obj, msg=None, ostream=sys.stdout, **kw_args):
    msg = parse_msg_if_needed(file_obj, msg=msg, **kw_args)
    close_p = False
    if type(ostream) == types.StringType:
        ostream = open(ostream, "w")
        close_p = True
    ostream.write("X-dp-info: -- dp_email_lib.py: Beginning of output.\n")
    ostream.write("%s" % msg)
    if close_p:
        ostream.close()

def process_msg(file_obj, funcs, **kw_args):
    msg = parse_msg_if_needed(file_obj, msg=None, **kw_args)
    # Apply a series of functions to this message, e.g.  fix delivered to,
    # rewrite subject if catchall, print All functions will be applied to the
    # message parsed above.  We'll pass file_obj in to all calls.  It isn't
    # needed to parse, but it can be used to print the file name if that is
    # needed.
    for func in funcs:
        if kw_args.get("process_msg_print_file_name_p", False):
            vprintf("process_msg: file name>%s<\n", file_obj_name(file_obj))
        func(file_obj, msg=msg, **kw_args)

def process_msgs(args, funcs, **kw_args):
    """Parse args and run.  Put parser here so we can be called from a
program that wants to be able to pass thru (parts of) a command line."""
    KW_VERBOSE(kw_args, 8, "args: %s\nfuncs: %s\nfunc_args: %s\n",
               args, funcs,
               kw_args.get("func_args", "NO func_args passed."))
    if len(args) < 1:
        process_msg(sys.stdin, funcs, **kw_args)
    else:
        for file_name in args:
            process_msg(file_name, funcs, **kw_args)
            if kw_args.get("process_msgs_print_sep"):
                printf("\n%s\n", "=" * 77)

def fixup_for_godaddy_catchall(args, **kw_args):
    """Make things backtrace proof, but still return a failure code if
    needed."""
    try:
        # Make sure that none of the streams that getmail cares about are
        # ever written to.
        dp_io.purge_streams(GETMAIL_SENSITIVE_OSTREAMS)
        funcs = [fix_delivered_to, rewrite_catchall_subject,
                 add_last_header, print_msg]
        kw_args.update(GETMAIL_RUNTIME_KW_ARGS)
        process_msgs(args, funcs, **kw_args)
        sys.exit(0)
    except Exception, e:
        if kw_args.get("fixup_reraise"):
            raise
        dp_io.reset_eprint_file()
        eprintf("dp_email_lib.fix_delivered_to: exception: %s.", e)
        sys.exit(1)
    sys.exit(len("WTF! Over?"))         # *Something* non-zero

# Add some abbrevs for selecting functions on the command line.
#FUNC_NAME_MAP = {

def main(argv):
    """Parse args and run.  Put parser here so we can be called from a
program that wants to be able to pass thru (parts of) a command line."""
    import getopt
    options, args = getopt.getopt(sys.argv[1:],
                                  'sfcd:n:vV:opP:SrCFa' + GODADDY_CL_FLAG)
    ##print 'options>%s<' % options
    funcs = []
    func_args = None
    new_recipient = None
    verbose = 0
    headersonly = False
    ostream=sys.stdout
    close_ostream_p = False
    kw_args = {}
    GODADDY_FIXUP_p = False
    for o, v in options:
        ##print 'o>%s<, v>%s<' % (o, v)
        if o == '-s':
            funcs.append(get_earliest_with_SMTP_for)
            continue
        if o == '-c':
            funcs.append(subject_already_rewritten_catchall_p)
            continue
        if o == '-n':
            new_recipient = v
            continue
        if o == '-v':
            dp_io.vprint_on()           # Enable verbose printing
            verbose += 1
            continue
        if o == '-V':
            dp_io.vprint_on()           # Enable verbose printing
            verbose = eval(v)
            continue
        if o == '-o':
            headersonly = True
            continue
        if o == '-f':
            funcs.append(fix_delivered_to)
            continue
        if o == '-p':
            funcs.append(print_msg)
            continue
        if o == '-P':
            ostream = open(v, "w")
            continue
        if o == '-r':
            funcs.append(rewrite_catchall_subject)
            continue
        if o == '-S':
            funcs = [fix_delivered_to, rewrite_catchall_subject, print_msg]
            continue
        if o == '-g':
            # Same basic thing as -S but catches all exceptions and exits
            # with a failure code.
            GODADDY_FIXUP_p = True
            continue

        if o == '-C':
            kw_args["print_catchall_delivered_to"] = True
            funcs.append(catchall_delivered_to)
            continue
        if o == '-F':
            kw_args["process_msg_print_file_name_p"] = True
            continue
        if o == '-a':
            kw_args["print_anomalies_p"] = True
            continue

        # <:add new option cases :>

    if GODADDY_FIXUP_p:
        fixup_for_godaddy_catchall(args, **kw_args)
    else:
        dp_io.v_vprint_files = [sys.stderr]
        # We'll use dp_io's verbose printing.
        dp_io.set_verbose_level(verbose)
        dp_io.set_vprint(True)
        if not funcs:
            funcs = [get_earliest_with_SMTP_for]
        process_msgs(args, funcs,
                     func_args=func_args,
                     new_recipient=new_recipient,
                     ostream=ostream,
                     headersonly=headersonly,
                     **kw_args)
    if close_ostream_p:
        ostream.close()


# Mainly (heh, heh) for testing.
if __name__ == "__main__":
    # Ick...
    try:
        main(sys.argv)
    except Exception, e:
        if GODADDY_FIX_p(sys.argv):
            eprintf("Caught exception in __main__. Exception: %s.", e)
            sys.exit(1)
        else:
            raise
