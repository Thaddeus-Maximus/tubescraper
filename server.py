from config import *
import config

import sys
sys.path.insert(0, server_location)
import json
import os
import hmac
import itertools
import multiprocessing
import downloader
import re
import bottle
bottle.debug(True)
from bottle import route, request, post, run, template, response, redirect
bottle.TEMPLATE_PATH.insert(0, server_location)

# Single-user HTTP Basic auth on every route. Credentials live in config.py
# (auth_user / auth_password); refuse to start without them rather than run open.
if not getattr(config, 'auth_user', None) or not getattr(config, 'auth_password', None):
    sys.exit("config.py must define auth_user and auth_password")

def check_auth(user, password):
    if user is None or password is None:
        return False
    user_ok = hmac.compare_digest(user.encode(), config.auth_user.encode())
    pass_ok = hmac.compare_digest(password.encode(), config.auth_password.encode())
    return user_ok and pass_ok

bottle.install(bottle.auth_basic(check_auth, realm="tubescraper"))

pool     = multiprocessing.Pool(8)
manager  = multiprocessing.Manager()
progress = manager.dict()   # job id -> live state, written by downloader workers
jobs     = []               # [{'id', 'pkg', 'result'}] in submission order
job_ids  = itertools.count(1)

def enqueue(pkg):
    job_id = next(job_ids)
    progress[job_id] = {'status': 'queued'}
    jobs.append({
        'id': job_id,
        'pkg': pkg,
        'result': pool.apply_async(downloader.download, (pkg, progress, job_id)),
    })

def json_response(obj, status=200):
    response.status = status
    response.content_type = 'application/json'
    return json.dumps(obj)

def script_json(obj):
    # Safe to drop inside a <script> block.
    return json.dumps(obj).replace('</', '<\\/')

@route('/get_downloads', method='GET')
def get_downloads():
    snapshot = progress.copy()
    out = []
    for job in jobs:
        state = dict(snapshot.get(job['id'], {}))
        if job['result'].ready():
            ok = job['result'].get() == 'success'
            state['status'] = 'done' if ok else 'failed'
            if ok:
                state['percent'] = 100
        pkg = job['pkg']
        out.append(dict(state, id=job['id'], title=pkg['title'], artist=pkg['artist'],
                        album=pkg['album'], vid=pkg['vid']))
    return json_response({'jobs': out})

@post('/clear_finished')
def clear_finished():
    for job in jobs[:]:
        if job['result'].ready():
            jobs.remove(job)
            progress.pop(job['id'], None)
    return json_response({'ok': True})

@route('/', method='GET')
def index_GET():
    creators = sorted(filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename)))
    url = request.query.get('url', '')
    return template('index.tpl', base_url=base_url,
                    creators_json=script_json(creators), url_json=script_json(url))

@post('/scrape')
def scrape():
    url = request.forms.getunicode('url')
    if not url:
        return json_response({'error': 'no url provided'}, 400)
    try:
        return json_response(downloader.scrape(url))
    except Exception as e:
        return json_response({'error': str(e)}, 500)

def make_pkg(data, title, vid, track):
    artist = data.getunicode('artist')
    album  = data.getunicode('album')
    return {
       "artist": artist,
       "genre":  data.getunicode('genre') or "unspecified",
       "album":  album,
       "title":  title,
       "img":    data.getunicode('img'),
       "root":   os.path.join(os.path.join(library_location, artist), album),
       "vid":    vid,
       "track":  track
    }

def bad_name(name):
    # artist/album/title each become a single path component under the library
    return (not name or name.strip() in ('.', '..')
            or any(c in name for c in ('/', '\\', '\0')))

def inside_library(path):
    lib = os.path.realpath(library_location)
    return os.path.commonpath([lib, os.path.realpath(path)]) == lib

def check_common(data):
    if not data.getunicode('artist'):
        return 'No artist specified'
    if not data.getunicode('album'):
        return 'No album specified'
    if not data.getunicode('id'):
        return 'No video ID specified'
    if bad_name(data.getunicode('artist')) or bad_name(data.getunicode('album')):
        return 'Artist/album may not contain path separators'
    if not inside_library(os.path.join(library_location, data.getunicode('artist'), data.getunicode('album'))):
        return 'Artist/album resolve outside the library'

@post('/download_playlist')
def download_playlist():
    data = request.forms
    err = check_common(data)
    if err:
        return json_response({'error': err}, 400)

    pkgs = []
    for i in range(int(data.get('n_videos') or 0)):
        if not data.get('include_%d' % i):
            continue
        title = data.getunicode('title_%d' % i)
        if bad_name(title):
            return json_response({'error': 'Bad title for track %d' % (i+1)}, 400)
        pkgs.append(make_pkg(data, title, data.get('id_%d' % i), i+1))
    for pkg in pkgs:
        enqueue(pkg)
    return json_response({'queued': len(pkgs)})

@post('/download_video')
def download_video():
    data = request.forms
    err = check_common(data)
    if not err and not data.getunicode('title'):
        err = "No title specified"
    if not err and bad_name(data.getunicode('title')):
        err = "Title may not contain path separators"
    if err:
        return json_response({'error': err}, 400)

    enqueue(make_pkg(data, data.getunicode('title'), data.get('id'), 1))
    return json_response({'queued': 1})


#application = bottle.default_app()
run(host='localhost', port=http_port)
