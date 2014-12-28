#@+leo-ver=5-thin
#@+node:2014fall.20141226225539.1696: * @file mycherrypy1.py
import cherrypy
class HelloWorld(object):
    @cherrypy.expose
    def index(self):
        return "Hello World, 可以開始開發 Cherrypy 程式!"

cherrypy.quickstart(HelloWorld())
#@-leo
