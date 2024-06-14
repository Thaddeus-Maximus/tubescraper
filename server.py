
import sys

sys.path.insert(0, "/Library/WebServer/Documents/hello_app")

import bottle
from bottle import route, run, template

@route('/hello')
def index(name):
    return "Hello there, kenobi"

application = bottle.default_app()