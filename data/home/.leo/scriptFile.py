#@+leo-ver=5
#@+node:@button run mycherrypy1.py
#@@language python

import subprocess

p = subprocess.Popen('start cmd /c v:\ide\python34\python mycherrypy1.py', shell=True)

p.wait()

print ('done')
#@-leo

