
import sys
sys.path.insert(0, "/var/www/tubescraper/")
import json
import os
import multiprocessing
import downloader
import re
import bottle
from bottle import route, request, post, run, template


library_location = '/home/navidromeuser/library/'

pool = multiprocessing.Pool(8)

@route('/hello')
def index():
    return "Hello there, kenobi"

@route('/', method='GET')
def index_GET():
    creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]
    #creators = ["Jonathan Pageau", "Jordan Peterson", "Alex Jones"]
    return template('/var/www/tubescraber/index.tpl', creators=json.dumps(creators), msg="...")

@post('/')
def index_POST():
    data = request.forms
    print(data.get('creator'))
    print(data.get('url'))
    print(data.get('creator_new'))

    creator = data.get('creator') if data.get('creator') else data.get('creator_new')
    if not creator:
        return 'You need to specify a creator'
    if not data.get('url'):
        return 'You need to specify a URL'
    if not data.get('title'):
        return "You need to specify a title"

    print(repr(data.get('url')))

    match = re.search(r"watch\?v=([\w+-]*)", str(data.get('url')))
    print(match)
    vid = match[1]

    pkg = {
       "artist": creator,
       "title":  data.get('title'),
       "root":  os.path.join(library_location, creator),
       "vid": vid
    }

    pool.apply_async(downloader.download, (pkg,))

    creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]

    return template('/var/www/tubescraber/index.tpl', creators=json.dumps(creators), msg="DOWNLOADING!")



application = bottle.default_app()
#run(host='localhost', port=1313)