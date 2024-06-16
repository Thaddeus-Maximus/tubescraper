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

import videodb
videodb.load(os.path.join(library_location, 'videos.md'))

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

@post('/download_playlist')
def download_playlist():
    data = request.forms

    vid    = data.get('id')
    artist = data.get('artist')
    album  = data.get('album')
    img    = data.get('img')
    n_videos = data.get('n_videos')

    if not artist:
        return 'No artist specified'
    if not album:
        return 'No album specified'
    if not vid:
        return 'No video ID specified'

    for i in range(int(n_videos)):
        title = data.get('title_%d' % i);
        vid   = data.get('id_%d' % i)
        videodb.add(artist, album, title, vid)

        pkg = {
           "artist": artist,
           "album":  album,
           "title":  title,
           "img":    img,
           "root":   os.path.join(os.path.join(library_location, artist), album),
           "vid":    vid,
           "track":  i+1
        }

        runners.append((pkg, pool.apply_async(downloader.download, (pkg,))))

    videodb.commit()

    redirect(base_url)

@post('/download_video')
def download_video():
    data = request.forms

    # print({i:data.get(i) for i in data.keys()})

    title  = data.get('title')
    vid    = data.get('id')
    artist = data.get('artist')
    album  = data.get('album')
    img    = data.get('img')

    if not artist:
        return 'No artist specified'
    if not album:
        return 'No album specified'
    if not vid:
        return 'No video ID specified'
    if not title:
        return "No title specified"

    # print(library_location, artist, album)
    videodb.add(artist, album, title, vid)

    pkg = {
       "artist": artist,
       "album":  album,
       "title":  title,
       "img":    img,
       "root":   os.path.join(os.path.join(library_location, artist), album),
       "vid":    vid,
       "track":  len(videodb.db[artist][album])
    }

    runners.append((pkg, pool.apply_async(downloader.download, (pkg,))))

    videodb.commit()

    redirect(base_url)


#application = bottle.default_app()
run(host='localhost', port=8080)
