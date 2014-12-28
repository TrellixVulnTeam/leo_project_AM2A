<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<?xml-stylesheet ekr_test?>
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2" tnodes="0" max_tnode_index="0" clone_windows="0"/>
<globals body_outline_ratio="0.5" body_secondary_ratio="0.5">
	<global_window_position top="50" left="50" height="500" width="700"/>
	<global_log_window_position top="0" left="0" height="0" width="0"/>
</globals>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="2015.20141228115431.2239" a="E"><vh>leo 與 cherrypy 程式開發</vh>
<v t="2014fall.20141226225539.1696"><vh>@file mycherrypy1.py</vh></v>
<v t="2014fall.20141226225539.1698"><vh>how to use @button</vh></v>
<v t="2014fall.20141226225539.1697"><vh>@button run mycherrypy1.py</vh></v>
</v>
<v t="2015.20141228115431.2238" a="E"><vh>pandoc 與報告</vh>
<v t="2015.20141228115431.2216"><vh>@edit myfile.md</vh></v>
<v t="2015.20141228115431.2220"><vh>@button run myfile.md</vh></v>
</v>
</vnodes>
<tnodes>
<t tx="2014fall.20141226225539.1697">@language python

import subprocess

p = subprocess.Popen('start cmd /c v:\ide\python34\python mycherrypy1.py', shell=True)

p.wait()

print ('done')
</t>
<t tx="2014fall.20141226225539.1698">Using @button nodes

@button nodes create script buttons in Leo’s icon area.

Each @button node also creates a corresponding minibuffer command.

Pressing the script button (or executing the command from the minibuffer) applies the script in the @button node to the presently selected outline node.

Script buttons bring scripts to outlines a powerful pattern. Creating an @button script should be your first thought whenever you want to automate any task.

The mod_scripting.py plugins must be enabled to create @button nodes.

Script buttons execute the present body text of the @button node. 
You can modify a script button’s script at any time.

You can bind keys to the commands created by script buttons:

@button my-button @key=Alt-8
Right-clicking a script button deletes it.</t>
<t tx="2015.20141228115431.2220">@language python

import subprocess

p = subprocess.Popen('start cmd /c v:\\apps\\pandoc\\pandoc myfile.md -o myfile.html', shell=True)

p.wait()

print ('done')
</t>
<t tx="2015.20141228115431.2238">先利用 pandoc 將 myfile.md 轉為 html
隨後再利用  LateX 轉為 pdf 與其他格式</t>
<t tx="2015.20141228115431.2239"></t>
</tnodes>
</leo_file>
