#!/usr/bin/env python


# Very trivial completion.
class C(object):
 def __init__(self):
  pass

 def __dir__(self):
  return ["yadda", "foad", "lsatyd", "iftrlky"]

#
c = C()

print("HI!")

###


class Trivial_completion_object(object):
 def __init_(arg, completions):
  self.completions = completions

 def __dir__(self):
  return self.completions


class TCO_basic(Trivial_completion_object)
 


