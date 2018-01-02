import atexit
#import os
#import readline
#import rlcompleter

def goodbye(name, adjective):
    print 'Goodbye, %s, it was %s to meet you.' % (name, adjective)

atexit.register(goodbye, 'Dave', 'ambiguous')

# historyPath = os.path.expanduser("~/.pyhistory")

#def save_history(historyPath=historyPath):
#    import readline
#    readline.write_history_file(historyPath)

#def load_history(historyPath=historyPath):
#    print "in load_history()>%s<" % (historyPath,)
#    if os.path.exists(historyPath):
#        print "loading..."
#        readline.read_history_file(historyPath)

#atexit.register(save_history)
#load_history(historyPath)

#del os, atexit, readline, rlcompleter, save_history, historyPath, load_history
