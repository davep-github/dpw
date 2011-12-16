#!/usr/bin/env python

import sys, os, re, types
import dp_utils

## ick, ick.
Globals = {}

CurrentItem = {}

def numAndNumPlusUnits(num, fracOk=None):
    if fracOk == None:
        fracOk = Globals["rateRound"]
    return dp_utils.sizePlusUnits(num, fracOk=fracOk, asParts=True)
    
def regexpPred(stateObj, line, regexp):
    #print "regexpPred, line>%s<, regexp>%s<" % (line, regexp)
    return re.search(regexp, line)

def truePred(*args, **keys):
    return True;

def handleRegexp(stateObj, line, match, matchKeys, dictOut):
    if type(matchKeys) not in (types.tupleType, types.ListType):
        matchKeys = (matchKeys,)
    for matchKey in matchKeys:
        dictOut[matchKey] = match.groupdict()[matchKey]
    return stateObj.next()

def handleBand(stateObj, data, handlerData, predResults):
    # data is line with band info in it
    CurrentItem["band"] = predResults.groupdict()["val"]
    return stateObj.next()

def handlePercent(stateObj, data, handlerData, predResults):
    # data is line with percent info in it
    CurrentItem["percent"] = predResults.groupdict()["val"]
    return stateObj.next()

def handleRate(stateObj, data, handlerData, predResults):
    # data is line with rate info in it
    rate = predResults.groupdict()["val"]
    result = numAndNumPlusUnits(eval(rate))[0:2]
    CurrentItem["rate"] = "%s, %s%s" % (rate,
                                        result[0],
                                        result[1])
    print "(%s, %s, %s)" % (CurrentItem["band"],
                            CurrentItem["percent"],
                            CurrentItem["rate"])
    return stateObj.next()


class State(object):
    def __init__(self, name, pred, handler, nextState,
                 predData=None, handlerData=None):
        self.d_name = name
        self.d_pred = pred
        self.d_handler = handler
        self.d_nextState = nextState
        self.d_predData = predData
        self.d_handlerData = handlerData

    def __call__(self, data):
        predResults = self.d_pred(self, data, self.d_predData)
        if predResults:
            return self.d_handler(self, data, self.d_handlerData,
                                  predResults)
        return self.d_name

    def name(self):
        return self.d_name

    def next(self):
        return self.d_nextState

class Seq(object):
    def __init__(self):
        self.d_states = {}
        self.d_currentState = None

    def start(self, startingStateName):
        self.d_currentState = startingStateName

    def addState(self, state):
        #print "addState: state:", state, "name:", state.name()
        self.d_states[state.name()] = state
        #print "addState: d_states:", self.d_states

    def currentState(self, data):
        #print "currentState: d_states:", self.d_states
        #print "currentState: d_currentState:", self.d_currentState
        return self.d_states[self.d_currentState](data)
    
    def proc(self, data):
        #print "proc: state:", self.d_currentState
        self.d_currentState = self.currentState(data)
        return self.d_currentState

    def __call__(self, data):
        return self.proc(data)

def makeFieldRegexp(name):
    return '''"dedupe perf %s" : (?P<val>\d+(\.\d+)?)''' % (name,)

# Some examples of fields of interest:
# "dedupe perf band length" : 4096
# "dedupe perf requested percentage" : 10
# "dedupe perf adjusted percentage" : 10
# "dedupe perf actual percentage" : 10.000000
# "dedupe perf scan rate" : 329966782.840167

PERF_BAND_PAT = makeFieldRegexp("band length")
PERF_PERCENT_PAT = makeFieldRegexp("requested percentage")
PERF_RATE_PAT = makeFieldRegexp("scan rate")

MainSequence = Seq()

STATE_NAME_BAND    = 'band'
STATE_NAME_PERCENT = 'percent'
STATE_NAME_RATE    = 'rate'

STATE_NAME_START = STATE_NAME_BAND

a = State(STATE_NAME_BAND, regexpPred, handleBand, STATE_NAME_PERCENT,
          predData=PERF_BAND_PAT)
b = State(STATE_NAME_PERCENT, regexpPred, handlePercent, STATE_NAME_RATE,
          predData=PERF_PERCENT_PAT)
c = State(STATE_NAME_RATE, regexpPred, handleRate, STATE_NAME_BAND,
          predData=PERF_RATE_PAT)

MainSequence.addState(a)
MainSequence.addState(b)
MainSequence.addState(c)
MainSequence.start(a.name())

def procFile(fobj):
    for line in fobj:
        line = line[:-1]
        #print "line>%s<" % (line,)
        MainSequence(line)
    print "exit procFile"

def main(argv):
    import getopt
    opt_string = "r:"
    Globals["rateRound"] = 4
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-r':
            # Handle opt
            Globals["rateRound"] = eval(v)
            continue
        
    print "len args:", len(args)
    if len(args) == 0:
        procFile(sys.stdin)
    else:
        for arg in args:
            # Handle arg
            fobj = open(arg)
            procFile(fobj)
            fobj.close()

if __name__ == "__main__":
    main(sys.argv)


