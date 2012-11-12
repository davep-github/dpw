class A_class(object):
    def __init__(self, name, rank, snum):
        self.name = name
        self.rank = rank
        self.snum = snum
        self.aval = 0

    def __str__(self):
        return "<name: %s, rank: %s, snum: %s, aval: %s>" % (self.name,
                                                             self.rank,
                                                             self.snum,
                                                             self.aval)

    def __repr__(self):
        return self.__str__()

class Cons_tor_a(object):
    def __init__(self, ctor, *args, **kw_args):
        self.ctor = ctor
        self.args = args
        self.kw_args = kw_args

    def cons(self):
        return self.ctor(*args, **kw_args)
    
    def __call__(self):
        return self.cons()
