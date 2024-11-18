import re
from collections import OrderedDict

"""
artist
album
vid
title

# artist
## album
[title](https://www.youtube.com/watch?v=vid)
"""

db = {}
fn = ''

def load(filename):
    global fn
    artist = ''
    album  = ''
    fn = filename
    with open(fn, 'r') as f:
        for line in f.readlines():
            #print(line)

            match = re.search(r"##\s*([\w\s]+)", line.strip())
            if match:
                album = match[1]
                #print('album: ', album)
                db[artist][album] = OrderedDict()
                
                continue

            match = re.search(r"#\s*([\w\s]+)", line.strip())
            if match:
                artist = match[1]
                #print('artist: ', artist)
                db[artist] = OrderedDict()
                
                continue

            match = re.search(r"\[([\w\s,+&!.'\"-]*)\][\S]*watch\?v=([\w+-]*)\)", line.strip())
            if match:
                title = match[1]
                vid   = match[2]
                db[artist][album][title] = vid

def add(artist, album, title, vid):
    global fn
    if not artist in db:
        db[artist] = OrderedDict()
    if not album in db[artist]:
        db[artist][album] = OrderedDict()
    db[artist][album][title] = vid

def commit():
    global fn
    with open(fn, 'w') as f:
        for artist in db:
            f.write('# %s\n' % artist)
            for album in db[artist]:
                f.write('## %s\n' % album)
                for title in db[artist][album]:
                    vid = db[artist][album][title]
                    f.write('[%s](https://www.youtube.com/watch?v=%s)\n' % (title, vid))
            f.write('\n')

if __name__ == '__main__':
    load()
    add('Jack', 'Album', 'Cool Talk', 'fancyurl')
    add('Jack', 'The Best', 'Talk Ever', 'wtf')