#!/usr/bin/env python

import os, sys, re, string
sys.path.insert(0, "/home/davep/lib/pylib")
os.environ["dp_io_no_term_init"] = "True"
import dp_email_lib

log_file = '/home/davep/log/auto-rotate-c10-50K/mail_header_rewriter.log'
catch_all_tag = '**CATCH-ALL**'
catch_all_tag_padded = ' ' + catch_all_tag + ' '

def rewriter(istream=sys.stdin, ostream=sys.stdout, rules=None):
    # Hard code for now.
    # find this:
    # Delivered-To: catch-all@meduseld.net
    # and mark it in the subject field.
    # New fuck up uses catchall... what an improvement.
    cre_delivered_to = re.compile('^[Dd]elivered-[Tt]o:\s*catch-?all[^@]*@')
    cre_sub = re.compile('^([Ss]ubject:)(.*)$')
    delivered_match = None
    subject_match = None
    subject_line = None

    log = open(log_file, 'a')
    log.write(
'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> begin\n')


    triggered = False
    while 1:
        line = istream.readline()
        if not line:
            break
        # end o' headers? A blank line says so as per RFC822.
        if line == '\n':
            if triggered:               # Anything to change?
                if not subject_line:
                    subject_line = 'Subject: <Synthetic subject line> ' + catch_all_tag
                    log.write('synthetic subj>%s<' % subject_line)
                else:
                    subject_line = subject_match.groups()[0] + \
                                   catch_all_tag_padded + \
                                   subject_match.groups()[1] + '\n'
                    log.write('new subj>%s<' % subject_line)
            else:
                log.write('unchanged subj>%s<' % subject_line)

            if subject_line != None:
                ostream.write(subject_line)
            
            ostream.write(line)
            log.write(line)
            break
            
        if not delivered_match:
            delivered_match = cre_delivered_to.search(line)
            if delivered_match:
                log.write('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^---trigger\n')
                triggered = True

        if not subject_match:
            tmatch = cre_sub.search(line)
            if tmatch:
                subject_line = line
                subject_match = tmatch
                log.write('orig subj>%s<\n' % line)
                continue

        ostream.write(line)
        log.write(line)

    if line:
        while 1:
            line = istream.readline()
            if not line:
                break
            ostream.write(line)
            log.write(line)

    log.write(
'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end\n')
    log.close()

def new_rewriter(args, istream, ostream):
    return dp_email_lib.fixup_for_godaddy_catchall(args, fixup_reraise=True)

if __name__ == "__main__":
    if os.environ.get("mail_header_rewriter_old"):
        rewriter()
        sys.exit(0)
    sys.exit(new_rewriter(sys.argv[1:], sys.stdin, sys.stdout))
