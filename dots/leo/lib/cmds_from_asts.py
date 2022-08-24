import ast
import os
import sys
from os.path import abspath



PATH = abspath(sys.argv[1])
astFilenames = [os.path.join(dp, f)
                    for dp, dn, filenames in os.walk(PATH)
                        for f in filenames if os.path.splitext(f)[1] == '.py']


commandsByFiles = {}

for astFilename in astFilenames:
    try:

        module = ast.parse(open(astFilename).read())
        classDefinitions = [node for node in module.body if isinstance(node, ast.ClassDef)]
        methodDefinitions = [ [node for node in classDef.body if isinstance(node, ast.FunctionDef)]
                                for classDef in classDefinitions ]
        commandsByFiles[astFilename] = {}

        for mdl in methodDefinitions:
            for md in mdl:
                if md.decorator_list:
                    try:
                        cmdAliases = ", ".join((cmd.args[0].s for cmd in filter(lambda d: d.func.id == "cmd", md.decorator_list)))
                        cmdDocs = []
                        for n in md.body:
                                if isinstance(n, ast.Expr) and hasattr(n.value, "s"):
                                        cmdDocs.append(n.value.s.strip())
                        commandsByFiles[astFilename][cmdAliases] = (md.lineno, md.name, cmdDocs)

                    except Exception as e:
                        #print(e)
                        pass

    except:
        pass


#print(commandsByFiles)

filesWithCmds = []
for filename, cmds in commandsByFiles.items():
    if cmds.items():
        filesWithCmds.append(filename)
        print("\n"+"="*len(filename))
        print(filename)
        print("-"*len(filename))

        for alias, info in cmds.items():
            print(alias, "::", info[0], "::", info[1], "\n", "\n".join([d.strip() for d in info[2]]), "\n")

print("\n\nTotally", len(filesWithCmds), "files with commands:\n", "\n ".join(filesWithCmds))
#print("\n".join(astFilenames), "\n", "\n".join([c for c,ii in commandsByFiles.items() if ii]))
