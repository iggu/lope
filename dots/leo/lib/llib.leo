<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2"/>
<globals/>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="iggu.20210415154452.1"><vh>@settings</vh>
<v t="iggu.20210415154452.2"><vh>@data free-layout-layout</vh></v>
</v>
<v t="iggu.20191102225227.1"><vh>Code</vh>
<v t="iggu.20190925103932.1"><vh>@file  ltools.py</vh></v>
<v t="iggu.20191102223420.1"><vh>@file commands.py</vh></v>
</v>
<v t="iggu.20191102225237.1"><vh>Commands &amp; Buttons</vh>
<v t="iggu.20190925125042.1"><vh>@command exec-actaul-testcase  @key=Alt-+</vh>
<v t="iggu.20201205222841.1"><vh>&lt;&lt; load and import &gt;&gt;</vh></v>
</v>
<v t="iggu.20191102181359.1"><vh>@command run-code-file  @key=Ctrl-Shift-b</vh>
<v t="iggu.20201205222841.1"></v>
</v>
<v t="iggu.20201205222841.1"></v>
</v>
<v t="iggu.20191026004302.1"><vh>Tests</vh>
<v t="iggu.20191031235628.1"><vh>test ONode.find</vh>
<v t="iggu.20191031235508.1"><vh>Find Me!</vh>
<v t="iggu.20191031235508.2"><vh>Find Me!</vh>
<v t="iggu.20191031235508.3"><vh>Find Me!</vh></v>
<v t="iggu.20191031235508.4"><vh>Find Me!</vh>
<v t="iggu.20191031235508.5"><vh>Find Me!</vh>
<v t="iggu.20191031235508.6"><vh>Find Me!</vh></v>
</v>
</v>
<v t="iggu.20191031235508.7"><vh>Find Me!</vh></v>
</v>
</v>
<v t="iggu.20191031235551.1"><vh>Find Me!</vh>
<v t="iggu.20191031235551.2"><vh>Find Me!</vh>
<v t="iggu.20191031235551.3"><vh>Find Me!</vh></v>
<v t="iggu.20191031235551.4"><vh>Find Me!</vh>
<v t="iggu.20191031235551.5"><vh>Find Me!</vh>
<v t="iggu.20191031235551.6"><vh>Find Me!</vh></v>
</v>
</v>
<v t="iggu.20191031235551.7"><vh>Find Me!</vh></v>
</v>
</v>
<v t="iggu.20191026093501.1"><vh>Find Me!</vh>
<v t="iggu.20191031234522.1"><vh>Find Me!</vh>
<v t="iggu.20191031234537.1"><vh>Find Me!</vh></v>
<v t="iggu.20191031234643.1"><vh>Find Me!</vh>
<v t="iggu.20191031234741.1"><vh>Find Me!</vh>
<v t="iggu.20191031234807.1"><vh>Find Me!</vh></v>
<v t="iggu.20191031234807.1"></v>
</v>
</v>
<v t="iggu.20191031234644.1"><vh>Find Me!</vh></v>
</v>
</v>
</v>
<v t="iggu.20191026004316.1"><vh>@path /tmp</vh>
<v t="iggu.20191102181206.1"><vh>@cliargs a b</vh>
<v t="iggu.20190925124839.1"><vh>@clean echo.py</vh></v>
<v t="iggu.20191102181206.2"><vh>@clean hello.js</vh></v>
</v>
<v t="iggu.20191106121336.1"><vh>@clean hello.html</vh></v>
</v>
<v t="iggu.20191026012710.1"><vh>@test ONode</vh></v>
</v>
</vnodes>
<tnodes>
<t tx="iggu.20190925124839.1">@others
@language python
@tabwidth -4

import sys

print("cliargs to stdout:", sys.argv)
print("cliargs to stderr:", sys.argv, file=sys.stderr)
</t>
<t tx="iggu.20190925125042.1">
&lt;&lt; load and import &gt;&gt;
from ltools import ONode, TabPrinter

import re

with TabPrinter('TEST', head="Testing", dhead=True, foot=True) as ltp:

    for n in ONode.find(parents=None,
                        header=('Find.*!', re.IGNORECASE),
                        #body=lambda x: x.find('1.1.1')!=-1,
                        deepness=-4,
                        dfs=True,
                        uniq=not True,
                       ):
        ltp.message("  &gt;&gt;", n.b, ":", ONode.opath(n, join=" / "), "|", n.b[:100].replace("\n", '\\n'))

    # +" : "+ONode.opath(n)
    # ltp.message(ONode.opath(c.p))
    # ltp.message(ONode.fspath(c.p))
</t>
<t tx="iggu.20191026004302.1"></t>
<t tx="iggu.20191026004316.1"></t>
<t tx="iggu.20191026012710.1">fileNode = p.parent()
assert(False)</t>
<t tx="iggu.20191026093501.1">3</t>
<t tx="iggu.20191031234522.1">3.1</t>
<t tx="iggu.20191031234537.1">3.1.1</t>
<t tx="iggu.20191031234643.1">3.1.2</t>
<t tx="iggu.20191031234644.1">3.1.3</t>
<t tx="iggu.20191031234741.1">3.1.2.1</t>
<t tx="iggu.20191031234807.1">3.1.2.1.1</t>
<t tx="iggu.20191031235508.1">1</t>
<t tx="iggu.20191031235508.2">1.1</t>
<t tx="iggu.20191031235508.3">1.1.1</t>
<t tx="iggu.20191031235508.4">1.1.2</t>
<t tx="iggu.20191031235508.5">1.1.2.1</t>
<t tx="iggu.20191031235508.6">1.1.2.1.1</t>
<t tx="iggu.20191031235508.7">1.1.3</t>
<t tx="iggu.20191031235551.1">2</t>
<t tx="iggu.20191031235551.2">2.1</t>
<t tx="iggu.20191031235551.3">2.1.1</t>
<t tx="iggu.20191031235551.4">2.1.2</t>
<t tx="iggu.20191031235551.5">2.1.2.1</t>
<t tx="iggu.20191031235551.6">2.1.2.1.1</t>
<t tx="iggu.20191031235551.7">2.1.3</t>
<t tx="iggu.20191031235628.1"></t>
<t tx="iggu.20191102181206.1"></t>
<t tx="iggu.20191102181206.2">@language javascript
@tabwidth -4

function hello()
{
    console.log("Hello JavaScript");
}


function goodbye()
{
    console.log("Good bye JavaScript");
}


hello();
goodbye();

</t>
<t tx="iggu.20191102181359.1">
&lt;&lt; load and import &gt;&gt;
from ltools import TabPrinter
from commands import CmdRunScriptByExt

@others

cmd = CmdRunScriptByExt()
with TabPrinter("RUN", head="Executing externally", dhead=True, foot=True) as ltp:
    cmd(ltp)

</t>
<t tx="iggu.20191102225227.1">@language md
Library code, tightly integrated with Leo core.
Every file is a dedicated module, which can be loaded with the following instructions:
@language python
    exec("\n".join(c.config.getData("import-and-init-leo-py-libs", strip_data=False)))
    import_leo_user_libs("ltools")
    from ltools import ONode, LeoTabPrinter
@language md
If file contains global variables `c` and `g` - then on load they are initialized with
leo's `g` and `c` globals.
@language python
</t>
<t tx="iggu.20191102225237.1">@language python
</t>
<t tx="iggu.20191106121336.1">@language html

&lt;!DOCTYPE html&gt;
&lt;html&gt;
&lt;head&gt;
	&lt;meta charset="utf-8"&gt;
	&lt;title&gt;Лабуда&lt;/title&gt;
   &lt;style&gt;
@language css
    #wrapper {
        border: 1px solid black;
        width: 800px;
        margin: auto;
    }
    #header {
        border: 1px solid black;
        height: 200px;
    }
    #sidebar {
        outline: 1px solid black;
        width: 200px;
        height: 500px;
        float: left;
    }

    #content {
        outline: 1px solid black;
        width: 600px;
        height: 500px;
        float: right;
    }
    #footer {
        border: 1px solid black;
        height: 200px;
    }
    .clearfix{
        clear: both;
    }
@language html
   &lt;/style&gt;
	&lt;link rel="stylesheet" href="styles.css"&gt;

&lt;/head&gt;
&lt;body&gt;

	&lt;div id="wrapper"&gt;
		&lt;div id="header"&gt;
			header
		&lt;/div&gt;
		&lt;div id="content"&gt;
			content
		&lt;/div&gt;
		&lt;div id="sidebar"&gt;
			sidebar
		&lt;/div&gt;
		&lt;div class="clearfix"&gt;&lt;/div&gt;
		&lt;div id="footer"&gt;
			footer
		&lt;/div&gt;
	&lt;/div&gt;

&lt;/body&gt;
&lt;/html&gt;
</t>
<t tx="iggu.20201205222841.1">
exec("\n".join(c.config.getData("import-and-init-leo-py-libs", strip_data=False)))
import_leo_user_libs("ltools", "commands", forceReload=True)
</t>
<t tx="iggu.20210415154452.1">@language md

_@if hostname_ compares with _g.es(g.computeMachineName())_</t>
<t tx="iggu.20210415154452.2">{
    "content": [
        "_leo_pane:outlineFrame",
        "_leo_pane:bodyFrame",
        {
            "content": [
                "_leo_pane:logFrame",
                "_leo_tab:Nav"
            ],
            "orientation": 2,
            "sizes": [
                187,
                721
            ]
        }
    ],
    "orientation": 1,
    "sizes": [
        293,
        1194,
        417
    ]
}</t>
</tnodes>
</leo_file>
