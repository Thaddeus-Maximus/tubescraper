from config import *

import sys
sys.path.insert(0, server_location)
import json
import os
import multiprocessing
import downloader
import re
import bottle
bottle.debug(True)
from bottle import route, request, post, run, template, response, redirect
bottle.TEMPLATE_PATH.insert(0, server_location)

pool  = multiprocessing.Pool(8)

"""
queue = multiprocessing.Queue()

active_downloads = {}

def update_downloader_state():
    try:
        while True:
            update = queue.get(False)
            print("got update: ", update)
            active_downloads[update[0]]['status'] = update[1]
    except:
        pass


def downloader_callback(result):
    global active_downloads
    print("thread finished", result)
    active_downloads[result['id']] = result
"""

runners = []
completed = []
failed = []

@route('/get_downloads', method='GET')
def scrape():
    for runner in runners[:]:
        if runner[1].ready():
            runners.remove(runner)
            result = runner[1].get()
            if result == 'error':
                failed.append(runner[0])
            else:
                completed.append(runner[0])
    return json.dumps({
        'completed': completed,
        'failed': failed,
        'downloading': [x[0] for x in runners]
    })

@route('/hello')
def index():
    return "Hello there, kenobi"

@route('/', method='GET')
def index_GET():
    #creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]
    #creators = ["Jonathan Pageau", "Jordan Peterson", "Alex Jones"]
    #return template('index.tpl', creators=json.dumps(creators), msg="...")

    #update_downloader_state()

    creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]

    if 'url' in request.query:
        url = request.query['url']
        return template('index.tpl', base_url=base_url, creators=creators, url=url)
    return template('index.tpl',     base_url=base_url, creators=creators, url='')

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
    if not data.get('id'):
        return 'You need to specify a video id'
    if not data.get('title'):
        return "You need to specify a title"

    pkg = {
       "artist": data.get('channel'),
       "title":  data.get('title'),
       "root":  os.path.join(library_location, data.get('channel')),
       "vid": data.get('id')
    }

    print("pkg: ", pkg)

    runners.append((pkg, pool.apply_async(downloader.download, (pkg,))))
    print("running downloader")


    #creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]
    #return template('index.tpl', base_url=base_url, creators=creators, url='', active_downloads=active_downloads)
    redirect('/')


#application = bottle.default_app()
run(host='localhost', port=8080)