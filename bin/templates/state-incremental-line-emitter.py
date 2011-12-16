class State:
    def __init__(self, sep_str=' ', flush_nl='\n'):
        self.infiles = []
        self.eval_input = 1
        self.indicate_EOF = 0
        self.EOL_function = None
        self.EOL_expression = None
        self.field_nums = []
        self.sep_str = sep_str
        self.flush_nl = flush_nl
        self.reset()

    def reset(self):
        self.oline = ''
        self.sep = ''
        self.e = []

    def emit(self, fmt, *rest):
        if rest:
            fmt = fmt % rest
        self.oline = self.oline + self.sep + fmt
        self.sep = self.sep_str

    def flush(self, ofiles):
        dp_io.fprintf(ofiles, '%s%s', self.oline, self.flush_nl)
        self.reset()

    def add_e(self, e):
        self.e.append(eval(e))
        #print 'add_e, e>%s<' % self.e

state = State()
