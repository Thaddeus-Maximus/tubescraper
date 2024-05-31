import web
import json
import os
import multiprocessing
import downloader
import re

render = web.template.render('templates/')

urls = (
    '/', 'index'
)

library_location = './library'

pool = multiprocessing.Pool(8)

class index:
    def GET(self):
        creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]
        #creators = ["Jonathan Pageau", "Jordan Peterson", "Alex Jones"]
        return render.index(json.dumps(creators), "...")

    def POST(self):
        data = web.input()
        creator = data.creator if data.creator else data.creator_new
        if not creator:
            return 'You need to specify a creator'
        if not data.url:
            return 'You need to specify a URL'
        if not data.title:
            return "You need to specify a title"

        print(repr(data.url))

        match = re.search(r"watch\?v=([\w+-]*)", str(data.url))
        print(match)
        vid = match[1]

        pkg = {
           "artist": creator,
           "title":  data.title,
           "root":  os.path.join(library_location, creator),
           "vid": vid
        }

        pool.apply_async(downloader.download, (pkg,))

        creators = [filename for filename in os.listdir(library_location) if os.path.isdir(os.path.join(library_location,filename))]

        return render.index(json.dumps(creators), "DOWNLOADING!")



if __name__ == '__main__':
    app = web.application(urls, globals())
    app.run()
