#@+leo-ver=5-thin
#@+node:iggu.20190925103932.1: * @file  ltools.py
#@@language python
#@@tabwidth -4

import datetime
import itertools
import re
from typing import NamedTuple


c = None
g = None


#@+others
#@+node:iggu.20201130193707.4: ** aux
class fakeset:
    def __contains__(self, key):
        return False
    def add(self, key):
        pass


class ColorScheme(NamedTuple):
    error:str = 'orange'
    message:str = None
    service:str = 'cyan'
    notice:str = 'yellow'

#@+node:iggu.20201130193707.8: ** class TabPrinter

class TabPrinter:

    _instancesByTabName = {}
    _nowTimestampKeyword = "$$now$$"
    _timeElapsedKeyword = "$$elapsed$$"

    def __init__(self, tabName, *,
                 colors=ColorScheme(), # colorsheme for output
                 dhead=True, # wrap header into default message if True
                 head=None,  # str, with $$..$$ keywords (see class-level constants)
                 foot=None,  # str to print given text, True to print default
                 withDateTime='%H:%M:%S %d/%m/%Y',  # format of time strings
                 clear=False,  # clear the tab
                 setAsGlobal=False,  # if True - reg self as global instance
                 exceptionPolicy=False,  # None: do not print on exception, True: print and swallow, False: print and reraise
               ):
        self.tabName = tabName
        self.headerText = None if not dhead and head is None else head if not dhead else self.defaultHeaderText(head)
        self.footerText = foot if type(foot)==str else self.defaultFooterText() if foot==True else None
        self.colors = colors
        self.withDateTime = withDateTime
        self.begin = None
        self.exceptionPolicy = exceptionPolicy
        if setAsGlobal:  # FIXME= remove this
            self.__class__.set_global(tabName, self)
        if clear:
            c.frame.log.clearTab(tabName)

    #@+others
    #@+node:iggu.20201130193707.12: *3* generator
    def __enter__(self):
        self.begin = datetime.datetime.now()
        if self.headerText:
            sBegin = self.begin.strftime(self.withDateTime)
            ht = self.headerText.replace(self._nowTimestampKeyword, sBegin)
            self.__notice(ht)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type and self.exceptionPolicy is not None:
            import traceback
            self.error(traceback.format_exc())
        if self.footerText:
            end = datetime.datetime.now()
            sEnd = end.strftime(self.withDateTime)
            ft = self.footerText.replace(self._nowTimestampKeyword, sEnd)
            ft = ft.replace(self._timeElapsedKeyword, str(end-self.begin))
            self.__notice(ft)
        return self.exceptionPolicy

    #@+node:iggu.20201130193707.14: *3* print
    def __print(self,
              *what,  # what to print
              color=None,  # color to print with (or use fallback one)
             ):
        g.es(" ".join(map(str, what)), tabName=self.tabName, color=color or self.colors.message)

    def __notice(self, *what):
        self.__print(*what, color=self.colors.notice)
    def service(self, *what):
        self.__print(*what, color=self.colors.service)
    def error(self, *what):
        self.__print(*what, color=self.colors.error)
    def message(self, *what):
        self.__print(*what, color=self.colors.message)
    #@+node:iggu.20201130193707.10: *3* helpers

    @classmethod
    def set_global(cls, tabName, theInstance):
        cls._instancesByTabName[tabName] = theInstance
    @classmethod
    def get_global(cls, tabName, dontThrow=False):
        if dontThrow and tabName not in cls._instancesByTabName:
            return None
        return cls._instancesByTabName[tabName]

    @staticmethod
    def defaultHeaderText(userDefinedText=None):
        if userDefinedText:
            return 4*"*\n" + f'* {userDefinedText}\n* $$now$$\n' + 80*"="
        else:
            return 4*"*\n" + '* Starting\n* $$now$$\n' + 80*"="
    @staticmethod
    def defaultFooterText():
        return 80*"=" + f"\n* Finished at $$now$$, elapsed: $$elapsed$$"
    #@-others
#@+node:iggu.20201130193707.21: ** class ONode
class ONode:

    kCompiledReType = type(re.compile('a'))
    kReFlagType = type(re.IGNORECASE)
    is_iterable = lambda obj: hasattr(obj,'__iter__') or hasattr(obj,'__getitem__')

    #@+others
    #@+node:iggu.20201130193707.22: *3* acquire

    @classmethod
    def create(cls, posParent, *, header=None, body=None, insertFirst=True):
        """Create new node as a child of given root."""

        if posParent:
            node = posParent.insertAsNthChild(0) if insertFirst else posParent.insertAsLastChild()
        else:
            node = c.rootPosition().insertBefore() if insertFirst else cls.last_node().insertAfter()
        if header:
            node.h = header
        if body:
            node.b = body

        return node


    @classmethod
    def acquire(cls, posParent, wantedNodeExactHeader, *, insertFirst=True):
        """Return existing node with given attrs or create new one."""

        posMaybeNodeIt = cls.find(parents=posParent,
                                  header=lambda h: h==wantedNodeExactHeader,
                                  deepness=1, uniq=True)

        try:
            return (next(posMaybeNodeIt), False)
        except StopIteration:
            return (cls.create(posParent, insertFirst=insertFirst, header=wantedNodeExactHeader), True)

    #@+node:iggu.20201130193707.26: *3* find

    @classmethod
    def find(cls,
             *,
             parents=None,  # Single Position or PosList or any Sequence of parent node(s)
                                # or None if desire to search thru all the outline
             header=None,   # str|str-regex+flags|compiled-re|callable or None if that doesnt matter
             body=None,     # str|str-regex+flags|compiled-re|callable or None if that doesnt matter
             deepness=-1,   # deepness of children to search (<0 for unlimited, 0 to test only parents)
             dfs=True,      # True for depth-first search, False for breadth-first search
             uniq=False,    # only unique nodes, no clones
            ):  # return generator for all nodes matching the find criterias

        """Find node with given attr(s).

        regex+flag means that param mey be either:
            - single string value: treated as regex string with default flags re.IGNORECASE
            - (str, flags) pair, where str is same as above and flags - re flags to be applied
            - already compiled re (for speed)
            - callable which accepts single string arg and returns True or False
        For other purposes may be used other functions like:
            - g.findNodeAnywhere(c, header)
            - c.find_h(header)
            - c.find_b(header)

        pl = c.find_h('@file.*py').children().filter_h('class.*').filter_b('import (.*)')
        """

        trace = set() if uniq else fakeset()  # trace:set prevents clones to be included
        isGoodH = cls.matcher_from_arg(header)
        isGoodB = cls.matcher_from_arg(body)
        parents = cls.root_nodes() if parents is None else parents if cls.is_iterable(parents) else [parents]
        pp1, pp2 = itertools.tee(parents)  # one iter to test parents and another - to search in children

        def good(pp):
            if isGoodH(pp.h) and isGoodB(pp.b) and not pp.v.fileIndex in trace:
                trace.add(pp.v.fileIndex)
                return True
            return False

        yield from (pp for pp in pp1 if good(pp))

        if deepness != 0:
            yield from cls._find_in_children(pp2, trace, isGoodH, isGoodB, deepness-1, dfs)
    #@+node:iggu.20201130193708.1: *4* _find_in_children

    @classmethod
    def _find_in_children(cls,
                          parents,   # try children of these nodes only
                          trace,     # set of already matched nodes
                          isGoodH,   # tester for header
                          isGoodB,   # tester for body
                          stopWhen0, # 0 - try direct children and stop, no recursion
                          dfs=True,  # True for depth-first search, False for breadth-first search
                         ):

        isDepthFirstSearch = dfs and stopWhen0 != 0
        isBreadthFirstSearch = not dfs and stopWhen0 != 0

        for parent in parents:

            for child in parent.children():

                if isGoodH(child.h) and isGoodB(child.b) and child.v.fileIndex not in trace:
                    trace.add(child.v.fileIndex)
                    yield child

                if isDepthFirstSearch and child.hasChildren():
                    yield from cls._find_in_children([child], trace, isGoodH, isGoodB, stopWhen0-1, dfs)

            if isBreadthFirstSearch:
                yield from cls._find_in_children((cc for cc in parent.children() if cc.hasChildren()),
                                                 trace, isGoodH, isGoodB, stopWhen0-1, dfs)

    #@+node:iggu.20201130193708.2: *3* path

    @staticmethod
    def opath(pos, *, join=None):
        """Return OutlinePath of the node with given position.

        OutlinePath is self and all the parents till the root.
        """

        if not pos:
            return "" if join else []

        thePath = [p.h for p in pos.self_and_parents(copy=True)][::-1] \
                    if pos else None
        return join.join(thePath) if join else thePath


    @staticmethod
    def fspath(pos, *, ofAnyParent=False):
        """Return os filesystem path of the node with given position.

        Node must be one of the file at-directived (@file, @clean, ...)
        All @path at-directives of parents are taken into account.
        If the node is not a file-one - None is returned.
        """

        if ofAnyParent:
            while pos and not pos.isAnyAtFileNode():
                pos.moveToParent()

        if pos:
            return g.os_path_finalize_join(c.getNodePath(pos), name) \
                    if (name := pos.anyAtFileNodeName()) else None
    #@+node:iggu.20201205034134.1: *3* clones

    @classmethod
    def find_clones_under(cls, what, where):
        if not what or not where:
            return
        v, p = what.v, where.copy()
        p.moveToThreadNext()
        while 1:
            if p and p.v == v:
                yield p
            elif p:
                p.moveToThreadNext()
            else:
                return
    #@+node:iggu.20201130193707.25: *3* util

    @classmethod
    def root_nodes(cls, doPosCopy=True):
        if p := c.rootPosition():
            yield p.copy() if doPosCopy else p
            while (p := p.moveToNext()):
                yield p.copy() if doPosCopy else p

    @classmethod
    def last_node(cls):
        last = c.rootPosition()
        while last and last.hasNext():
            last.moveToNext()
        return last


    @classmethod
    def matcher_from_arg(cls,
                         descr,  # callable | str | (str, reflags) | compiled-re
                         reflags=re.IGNORECASE,  # apply this re flags when constructing re from str
                         ):  # 

        if descr is None:
            return lambda x: True
        elif callable(descr):
            return descr
        elif isinstance(descr, str):
            rxH = re.compile(descr, reflags)
        elif isinstance(descr, cls.kCompiledReType):
            rxH = descr
        elif len(descr) == 2 and isinstance(descr[0], str) and isinstance(descr[1], cls.kReFlagType):
            rxH = re.compile(descr[0], descr[1])
        else:
            raise ValueError(f'{descr=}: not RegEx description, but {type(descr)}')
        return lambda x: rxH.match(x)
    #@-others
#@+node:iggu.20201130193708.4: ** class Helpers
class Helpers:


    #@+others
    #@+node:iggu.20201130193708.5: *3* Helpers.node_find_results_placeholder
    @staticmethod
    def node_find_results_placeholder(resultsRootNodeHeader, leoTabPrinter):

        resultRootNode = c.find_h(resultsRootNodeHeader)

        if not resultRootNode:
            leoTabPrinter.error("Cannot find placeholder node for results!",
                    f"\nPlease create single node with name '{resultsRootNodeHeader}'",
                    "anywhere in the outline")
            raise RuntimeException("No placeholder node for results is found")

        if len(resultRootNode) != 1:
            leoTabPrinter.error("There should be only one node with name",
                   f"'{resultsRootNodeHeader}' in the outline",
                   f"\nNow {len(resultRootNode)} found (see log pane for references)")
            g.es("Duplicated results nodes:")
            for i,n in enumerate(resultRootNode):
                g.es_clickable_link(c, n, 1, f"{i+1}: {resultsRootNodeHeader}\n")
            raise RuntimeException("Too many placeholder nodes for results found")

        return resultRootNode[0]

    #@+node:iggu.20201130193708.6: *3* Helpers.exec_filenode_as_external_py
    @staticmethod
    def exec_filenode_as_external_py(pos,  # position of a filenode where script lives
                                     *args,  # cliargs of the script
                                    ):  # (fspath, returncode, stdout, stderr) or None

        scriptAbsFilepath = ONode.fspath(pos)
        if scriptAbsFilepath is None:
            raise ValueError('Failed to execute node as ext-py:',
                             ONode.opath(pos, join=" / "))

        import subprocess
        proc = subprocess.Popen("python %s %s" % (scriptAbsFilepath,
                                                  " ".join([str(a) for a in args])),
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                                shell=True)
        stdout, stderr = proc.communicate()

        return scriptAbsFilepath, proc.returncode, \
                stdout.decode('UTF-8').split('\n'), stderr.decode('UTF-8').split('\n')
    #@-others
#@-others
#@-leo
