
import sys
sys.path.insert(0, "/var/www/tubescraper/")
import json
import os
import multiprocessing
import downloader
import re
import bottle
bottle.debug(True)
from bottle import route, request, post, run, template, response
bottle.TEMPLATE_PATH.insert(0, "/var/www/tubescraper/")


library_location = './library' # '/home/navidromeuser/library/pods/'

pool = multiprocessing.Pool(8)

@route('/hello')
def index():
    return "Hello there, kenobi"

@route('/', method='GET')
def index_GET():
    #creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]
    #creators = ["Jonathan Pageau", "Jordan Peterson", "Alex Jones"]
    #return template('index.tpl', creators=json.dumps(creators), msg="...")

    creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]

    if 'url' in request.query:
        url = request.query['url']
        return template('index.tpl', creators=creators, url=url)
    return template('index.tpl', creators=creators, url='')

@post('/scrape')
def scrape():
    if 'url' in request.forms:
        url = request.forms['url']
        scraped = downloader.scrape(url)
        return json.dumps(scraped)
    return json.dumps({'error': 'no url provided'})

@post('/download_video')
def download_video():
    data = request.forms

    if not data.get('channel'):
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
       "artist": data.get('channel'),
       "title":  data.get('title'),
       "root":  os.path.join(library_location, data.get('channel')),
       "vid": vid
    }

    pool.apply_async(downloader.download, (pkg,))

    creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]

    return "Your request has been submitted."



#application = bottle.default_app()
run(host='localhost', port=8080)