#!/usr/bin/env python
# $Id: dir_tree.py,v 1.5 2004/09/11 08:20:03 davep Exp $
#

import os, sys, string, dp_io

dp_io.debug_on()
dp_io.set_debug_level(0)

NEEDNT_EXIST = True

def node_list_to_name_list(node_list):
    cdl = []
    for cd in node_list:
        cdl.append(cd.get_name())
    return cdl

def name_list_to_name_lines(name_list, istr="  ", sep_str="\n  "):
    if istr == None:
        istr = ''
    return istr + string.join(name_list, sep_str)

def node_list_to_name_lines(node_list, istr="  ", sep_str="\n  "):
    return name_list_to_name_lines(node_list_to_name_list(node_list),
                                   istr, sep_str)

def node_list_to_path_name(node_list, root_path='', sep=None):
    if root_path and sep == None:
        sep = os.path.sep
    if sep == None:
        sep = ''
    ret = root_path + sep + os.path.join(*node_list_to_name_list(node_list))
    return os.path.normpath(ret)
    #return node_list_to_name_lines(node_list, None, os.path.sep)
    
class DirTree:
    def __init__(self, name, visit=None):
        self.name = name
        self.dir_dict = {}             # lookups by pathname
        dp_io.cdebug(2, "type(dir_dict)>%s<\n", type(self.dir_dict))
        self.dir_nodes = []             # simple list
        self.root_node = self.new_dir_node(None, name, visit)
        dp_io.cdebug(2, "root_node(%s)\n", self.root_node)
        

    def get_name(self):
        return self.name

    def add_dir_node(self, node):
        name = node.get_name()
        self.dir_dict[name] = node # index self
        dp_io.cdebug(2, "add_dir_node(%s)\n", name)
        self.dir_nodes.append(node)     # enlist self
        return node

    def new_dir_node(self, parent, name, visit=None):
        dp_io.cdebug(2, "type(dir_dict)>%s<\n", type(self.dir_dict))
        return self.add_dir_node(DirNode(parent, name, self.dir_dict, visit))

    def get_dir_node(self, dir_name, neednt_exist=None):
        # would we like an error on no name?
        if neednt_exist:
            return self.dir_dict.get(dir_name, None)
        else:
            return self.dir_dict[dir_name]

    def get_or_create_dir_node(self, parent, dir_name, visit=None):
        try:
            return self.get_dir_node(dir_name)
        except KeyError:
            return self.new_dir_node(parent, dir_name, visit)

    def dir_node_full_path_name(self, dir_node):
        return os.path.join(self.name, dir_node.full_path_name)


    def build(self):
        for dir_path, dirs, files in os.walk(self.name):
            dp_io.cdebug(1,
                         "\ndir_path>%s<\ndirs:\n  >%s<\nfiles:\n  [%s]\n",
                        dir_path,
                        string.join(dirs, "<\n  >"),
                        string.join(files, "]\n  ["))
            dp_io.cdebug(1, "============\n")
            parent_path = os.path.dirname(dir_path)
            dir_name = os.path.basename(dir_path)
            dir_node = self.get_dir_node(dir_name, NEEDNT_EXIST)
            if not dir_node:
                dp_io.cdebug(1, "build(), parent_path>%s<\n", parent_path)
                dp_io.cdebug(1, "build(), dir_path>%s<\n", dir_path)
                parent_node = self.get_dir_node(parent_path)
                dir_node = DirNode(parent_node, dir_path, self.dir_dict)
                dp_io.cdebug(2, "dir_node(%s)\n", dir_node)
            else:
                dp_io.cdebug(2, 'Existing node(%s)\n', dir_node.get_name())
                
            for dname in dirs:
                dnode = DirNode(dir_node, dname, self.dir_dict)
                dp_io.cdebug(1, "tree, add(%s)\n", dname)
                dir_node.add_child_dir(dnode)

            dir_node.add_child_files(files)


    # <:tree-walk:>
    def walk(self, dir_visit=None, file_visit=None, leaf_visit=None):
        """Walk tree producing a list of component lists of each path"""
        if dir_visit:
            ret = dir_visit(self.root_node)
        else:
            dp_io.cdebug(1, "DirTree.walk()\n")
            dp_io.cdebug(1, "root_node>%s<\n", self.root_node)
            dp_io.cdebug(1, "root_node_name>%s<\n",
                         self.root_node.get_name())
            ret = self.root_node.walk(file_visit, leaf_visit)

        return ret

    # <:tree-walkl:>
    def walkl(self, dir_visit=None, file_visit=None, leaf_visit=None):
        """Walk tree producing a list of component lists of each path"""
        if dir_visit:
            ret = dir_visit(self.root_node)
        else:
            ret = self.root_node.walkl(file_visit, leaf_visit)

        dp_io.cdebug(2, 'TreeNode: len-file_lists: %d\n', len(ret))
        return ret
        

class DirNode:
    def __init__(self, parent_node, name, tree_dir_dict, visit=None):

        if parent_node:
            pname = parent_node.get_name()
        else:
            pname = 'None'
        dp_io.cdebug(2, 'DirNode(parent=%s, name=%s)\n', pname, name)

        self.name = name
        self.parent_node = parent_node
        if parent_node:
            pname = parent_node.get_name()
        else:
            pname = ''
        self.path_name = os.path.join(pname, name)
        self.visit = visit              # visit function
        self.dir_children = []          # dirs
        self.file_children = []
        dp_io.cdebug(2, "type(tree_dir_dict)>%s<\n", type(tree_dir_dict))
        tree_dir_dict[name] = self

    def get_name(self):
        return self.name

    def set_name(self, new_name):
        self.name = new_name

    def add_child_dir(self, dir_node):
        dp_io.cdebug(1, "add_child_dir(%s to %s)\n",
                     dir_node.get_name(), self.get_name());
        self.dir_children.append(dir_node)
        dp_io.cdebug(5, "type(dir_children)>%s<\n",
                     type(self.dir_children))

        cdl = node_list_to_name_list(self.dir_children)
        dp_io.cdebug(5, "%s: dir_children:\n%s\n---\n",
                     self,
                     node_list_to_name_lines(self.dir_children))
            
    def add_child_files(self, file_list):
        for fname in file_list:
            fnode = FileNode(self, fname)
            self.file_children.append(fnode)
            dp_io.cdebug(4, 'add fname>%s< to %s\n',
                         fname, self.get_name())

    def full_path_name(self):
        if self.parent_node == None:
            p1 = ''
        else:
            p1 = self.parent_node.full_path_name()
        return os.path.join(p1, self.name)

    def full_path_list(self):
        dp_io.cdebug(2, 'DN.fpl, name>%s<, pnode>%s<\n',
                     self.get_name(), self.parent_node)
        if self.parent_node == None:
            p1 = []
        else:
            p1 = self.parent_node.full_path_list()
        dp_io.cdebug(3, "p1>%s<, self[%s]\n", p1, self)
        p1.append(self)
        return p1

    def walk(self, file_visit=None, leaf_visit=None):
        dp_io.cdebug(1, "DirNode.walk(%s)\n", self.get_name());
        dp_io.cdebug(5, "%s: dir_children:\n%s\n-------\n",
                     self,
                     node_list_to_name_lines(self.dir_children))
        
        for d in self.dir_children:
            dp_io.cdebug(1, "start d.walk(%s)\n", d.get_name());
            d.walk()
            dp_io.cdebug(1, "finis d.walk(%s)\n", d.get_name());

        dp_io.cdebug(1, "files d.walk(%s)\n", self.get_name());
        for f in self.file_children:
            fn = f.full_path_name()
            #print 'fpn>%s<\n' % fn
            print(fn)
        dp_io.cdebug(1, "done d.walk(%s)\n", self.get_name());

    def walkl(self, file_visit=None, leaf_visit=None):
        dp_io.cdebug(1, "DirNode.walkl(%s)\n", self.get_name());
        dp_io.cdebug(5, "%s: dir_children:\n%s\n-------\n",
                     self,
                     node_list_to_name_lines(self.dir_children))

        file_lists = []
        for d in self.dir_children:
            dp_io.cdebug(1, "start d.walkl(%s)\n", d.get_name());
            file_lists.extend(d.walkl())
            dp_io.cdebug(1, "finis d.walkl(%s)\n", d.get_name());

        for f in self.file_children:
            dp_io.cdebug(1, "process child(%s)\n", f.get_name())
            fl = f.full_path_list()
            dp_io.cdebug(2, 'fn>%s<\n',
                         os.path.join(*node_list_to_name_list(fl)))
            file_lists.append(fl)

        dp_io.cdebug(2, 'DirNode: len-file_lists: %d\n', len(file_lists))
        return file_lists


class FileNode:
    def __init__(self, parent_node, name):
        dp_io.cdebug(2, 'FileNode(%s, %s)\n',
                     parent_node.get_name(), name)
        self.name = name
        self.parent_node = parent_node

    def get_name(self):
        return self.name

    def set_name(self, new_name):
        self.name = new_name

    def full_path_name(self):
        return os.path.join(self.parent_node.full_path_name(),
                            self.get_name())

    def full_path_list(self):
        p1 = self.parent_node.full_path_list()
        return p1 + [self]


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        tree = DirTree(arg)
        dp_io.eprintf("about to build\n")
        tree.build()
#         dp_io.eprintf("about to walk\n")
#         tree.walk()
        dp_io.eprintf("about to walkl\n")
        path_lists = tree.walkl()
        dp_io.cdebug(3, 'path_lists(%s)\n', path_lists)
        for pl in path_lists:
            fmt = 'path>%s<\n'
            fmt = '%s\n'
            dp_io.printf(fmt, node_list_to_path_name(pl, os.getcwd()))
