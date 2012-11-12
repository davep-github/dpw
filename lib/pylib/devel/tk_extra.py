
from Tkinter import *


def tkx_scrollbox(parent, font=None, take_focus=None, sel_mode=EXTENDED, bindings={}):
    sb = Frame(parent)
    yscroll = Scrollbar(sb)
    yscroll['takefocus'] = 0
    xscroll = Scrollbar(sb, orient='horizontal')
    xscroll['takefocus'] = 0
    listbox = Listbox(sb, 
                      selectmode=sel_mode,
                      selectborderwidth=1,
                      yscroll=yscroll.set,
                      xscroll=xscroll.set,
                      font=font)
    xscroll.pack(side=BOTTOM, fill=X)
    listbox.pack(side=LEFT, expand=TRUE, fill=BOTH)
    yscroll.pack(side=RIGHT, fill=Y)
    yscroll['command'] = listbox.yview
    xscroll['command'] = listbox.xview
    if take_focus:
        listbox.focus()

    for k in bindings.keys():
        # tuple = (func, [add])
        binding_tuple = bindings[k]
        if len(binding_tuple) == 1:
            add = None
        elif binding_tuple[1]:
            add = '+'
        else:
            add = None
        
        func = binding_tuple[0]
        listbox.bind('<%s>'%k, func, add=add)

    return listbox, sb
