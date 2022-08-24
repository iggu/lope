#@+leo-ver=5-thin
#@+node:iggu.20191102223420.1: * @file commands.py
#@@language python
#@@tabwidth -4


c = None
g = None

import subprocess
import sys
from ltools import ONode

#@+others
#@+node:iggu.20201130225522.1: ** run script by ext

class CmdRunScriptByExt:

    LauncherByExtensionMapping = {
        '.js': 'node',
        '.py': 'python',
        '.html': 'dragon' if sys.platform == 'win32' else 'firefox',
    }

    def __init__(self, **launcherByExtensionMapping):
        fileNode = c.p.copy()
        while fileNode and not fileNode.isAnyAtFileNode():
            fileNode.moveToParent()

        filePath = p if fileNode and (p := ONode.fspath(fileNode)) else None
        _, fileExt = g.os_path_splitext(filePath)
        cliargs = (ca.h[8:].strip() if ca.h.startswith('@cliargs') else '') \
                    if (ca := fileNode.copy().moveToParent()) else ''

        launcher = { **CmdRunScriptByExt.LauncherByExtensionMapping,
                     **launcherByExtensionMapping }[fileExt]
        self.cmdline = f"{launcher} {filePath} {cliargs}"


    def __call__(self, tabPrinter):
        tabPrinter.service("@", ONode.opath(c.p, join=" // "),
                           "\n$", self.cmdline)

        proc = subprocess.Popen(self.cmdline,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                                shell=True)

        for out, color in zip(proc.communicate(), ['message', 'error']):
            for line in out.decode('UTF-8').split('\n'):
                if line:
                    getattr(tabPrinter, color)(line)

        tabPrinter.service("?", proc.returncode)
#@+node:iggu.20201201150706.1: ** work in progress

class CmdWip:

    """Clone current node under given Work-In-Progress top-level node.
       Node cannot be top-level one; it must be a child of at least any other node.

       Custom hierarchy provider can be used to calculate final Node's OPath;
       default one is to clone Node to the path 'fileExtension -> fileName'

       Resulting root node and subnodes may not exist - they would be created automatically
       
       Example:
           - cloning node `@path src / @file example.py / setup`
           - resulting node is: `WIP / [[ .py ]] / example / setup`
       """


    # TODO make an universal matcher instead of parent= and body=
    #       let it accept traversed node and tests it in any way
    #       so ONode.find_clones_under can be deleted

    # self._clonedNode = next(ONode.find_clones_under(sourceNode, parent), None) if parent else None


    #@+others
    #@+node:iggu.20201219001322.1: *3* init

    def __init__(self,
                 sourceNode, # which node to operate on
                 *,
                 rootHeader=None, # root node - header text uniq in the outline
                 subpath=None, # function to return list of subsections of the node
                ):

        if not rootHeader:
            try:
                rootHeader = c.config.getConfig("wip-root-node-header")
            except:
                rootHeader = "~~~~ WORK IN PROGRESS ~~~~"
        if not subpath:
            subpath = CmdWip.subpathExtAndFn

        self._sanity_checks(rootHeader, sourceNode)

        self._pathInHeaders = [rootHeader] + subpath(sourceNode)
        self._pathInNodes = [None] * len(self._pathInHeaders)
        self._sourceNode = sourceNode
        self._clonedNode = None

        def hm(h):
            return lambda x: x == h

        parents = None
        for i, h in enumerate(self._pathInHeaders):
            parent = next(ONode.find(parents=parents, header=hm(h), deepness=0), None)
            self._pathInNodes[i] = parent
            if parent: parents = parent.children()
            else: break

        if parent:
            for n in ONode.find(parents=parent.children(), header=hm(sourceNode.h), deepness=0):
                if n.v == sourceNode.v:
                    self._clonedNode = n
                    break
    #@+node:iggu.20201225002429.1: *3* checks

    def _sanity_checks(self, rootHeader, sourceNode):
        theRoot = list(ONode.find(header=lambda h: h==rootHeader))
        if len(theRoot) > 1:
            raise ValueError("WIP node must single (" + str(len(theRoot)) + " candidates found)")
        if len(theRoot) and theRoot[0].parent():
            raise ValueError("WIP node must be top level")
        if sourceNode.isAnyAtFileNode():
            raise ValueError("Operating on file nodes is prohibited")
        # we do not operate on top-level nodes since there undoing damages entire outline
        if not sourceNode.parent():
            raise ValueError("Operating on toplevel nodes is prohibited")
        if list(sourceNode.self_and_parents(copy=True))[-1].h == rootHeader:
            raise ValueError("Cannot operate on WIP children")
    #@+node:iggu.20201205193309.1: *3* push

    def push(self, *, undo=True, insertFirst=False, expand=True):

        if self._clonedNode:
            return False

        u, p, cloned = c.undoer, self._sourceNode, False
        if undo: u.beforeChangeGroup(p, 'clone-wip-push')

        hh, hhl = self._pathInHeaders, len(self._pathInHeaders)
        tt = self._pathInNodes # target nodes - root if all, extension, clone
        cc = [False] * hhl # flags for which nodes were created
        for i, hh in enumerate(hh):
            if not tt[i]:
                if undo: undoData = u.beforeInsertNode(p)
                tt[i], cc[i] = ONode.acquire(None if i==0 else tt[i-1], hh, insertFirst=insertFirst)
                if expand: tt[i].expand()
                if cc[i] and undo: u.afterInsertNode(tt[i], 'Insert Node To Group', undoData)

        prev = p.copy()
        c.endEditing()  # Capture any changes to the headline.

        if undo: undoData = c.undoer.beforeCloneNode(p)
        clone = p.clone()
        if insertFirst: clone.moveToFirstChildOf(tt[2])
        else: clone.moveToLastChildOf(tt[2])
        clone.setDirty()
        c.setChanged()
        cloned = True

        if cloned:
            if undo:
                msg = 'Clone Node To ' + ('First' if insertFirst else 'Last')
                c.undoer.afterCloneNode(clone, msg, undoData)
                u.afterChangeGroup(p, 'clone-wip-push')
            c.redraw(prev)

        return True
    #@+node:iggu.20201219004039.1: *3* pop

    def pop(self, *, undo=True):

        if not self._clonedNode:
            return False

        u = c.undoer
        if undo: u.beforeChangeGroup(self._sourceNode, 'clone-wip-pop')
        c.endEditing()

        def rm(p):
            if undo: undoData = u.beforeDeleteNode(p)
            p.setDirty()
            p.doDelete()
            if undo: u.afterDeleteNode(p, "Remove Node from Group", undoData)

        ps = self._clonedNode.self_and_parents(copy=True)
        root = self._pathInNodes[0]

        rm(next(ps)) # delete the clone
        for pp in ps: # delete empty parents of clone but not WIP itself
            try:
                if pp.v == root.v or next(pp.children()):
                    break
            except:
                rm(pp)

        if undo: u.afterChangeGroup(self._sourceNode, 'clone-wip-pop')
        c.setChanged()
        c.redraw(self._sourceNode)
        return True
    #@+node:iggu.20201205222306.1: *3* util

    @staticmethod
    def subpathExtAndFn(p):
        dirs = []
        if filePath := ONode.fspath(p.copy(), ofAnyParent=True):
            dirs.append('')
            fileDir, fileNameExt = g.os_path_split(filePath)
            fileName, fileExt = g.os_path_splitext(fileNameExt)
            while True:
                fileDir, d = g.os_path_split(fileDir)
                if d: dirs.append(d)
                else: break
            dirs.append(fileDir)
        else:
            fileName, fileExt = "**", None
        tag = "[[ ?? ]]" if fileExt is None or not len(fileExt) else fileExt
        return [ f"[[ {tag} ]]", fileName + " / ".join(dirs[:2]) ]


    def exists(self):
        return True if self._clonedNode else False
    #@-others
#@-others
#@-leo
