import yt_dlp
import re
from pathlib import Path
import requests
import subprocess
from multiprocessing import Pool
import sys
import os

from yt_dlp.postprocessor import FFmpegPostProcessor
FFmpegPostProcessor._ffmpeg_location.set('./')

def scrape(url):
    with yt_dlp.YoutubeDL() as ydl:
        info_dict = ydl.extract_info(url, download=False)
        if 'entries' in info_dict.keys():
            # it's a playlist
            return {
                'type': 'playlist',
                'id': info_dict.get('id'),
                'title': info_dict.get('title'),
                'uploader': info_dict.get('uploader'),
                'thumbnail': info_dict.get('thumbnails')[-1].get('url'),
                'thumbnails': info_dict.get('thumbnails'),
                'videos': [{
                    'id': video.get('id'),
                    'title': video.get('title'),
                    'uploader': video.get('uploader'),
                    'thumbnail': video.get('thumbnail'),
                    'thumbnails': info_dict.get('thumbnails')
                } for video in info_dict.get('entries')]
            }
        else:
            return {
                'type': 'video',
                'id': info_dict.get('id'),
                'title': info_dict.get('title'),
                'uploader': info_dict.get('uploader'),
                'thumbnail': info_dict.get('thumbnail'),
                'thumbnails': info_dict.get('thumbnails')
            }


def download(pkg):

    artist = pkg["artist"]
    #album  = pkg["album"]
    title = pkg["title"]
    #track = pkg["track"]
    root   = pkg["root"]
    vid    = pkg["vid"]

    url = "https://youtube.com/watch?v=%s" % vid

    print(artist, title, url)

    ydl_opts = {
        "format": "bestaudio", # see https://pypi.org/project/yt-dlp/#format-selection
        "outtmpl": '%(id)s',
        "quiet": True,
        "no_warnings": True
        #"user_agent": "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/111.0"
    }



    attempts = 0
    while attempts < 30:
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                error_code = ydl.download(url)
            break
        except:
            attempts += 1
    else:
        print("FAILURE: %s (%s)" % (vid, title))
        return False

    oldfn = [filename for filename in os.listdir('.') if filename.startswith(vid)][0]
    newfn = '%s/%s.mp3' % (root, title)
    """newvidfn = '%s/%s.mp4' % (root, title)

    subprocess.run(["ffmpeg", "-y", "-i", oldfn,
        "-metadata", "title=%s"%title,
        "-metadata", "artist=%s"%artist,
        #"-metadata", "album=%s"%album,
        #"-metadata", "track=%d"%track,
        newvidfn], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)"""

    subprocess.run(["ffmpeg", "-y", "-i", oldfn,
        #"-i", root+'/album.jpg',
        #"-c:v", "copy",
        #"-map", "0:a", "-map", "1:v",
        "-b:a", "128k",

        #"-metadata:s:t", "mimetype=image/jpeg", "-metadata:s:t", "filename=%s"%(root+"/album.jpg"),
        
        "-id3v2_version", "3",
        
        "-metadata:s:v", "title=\"Album cover\"", "-metadata:s:v", "comment=\"Cover (front)\"",
        "-metadata", "title=%s"%title,
        "-metadata", "artist=%s"%artist,
        #"-metadata", "album=%s"%album,
        #"-metadata", "track=%d"%track,
        newfn], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

    print("CONVERTED!", oldfn, newfn)

    Path(oldfn).unlink()

    print("Success: %s (%s)" % (vid, title))
    return True

if __name__ == "__main__":

    failures = []

    artist = ""
    root   = ""
    Path(root).mkdir(parents=True, exist_ok=True)

    pkg = []

    with open("./videos.md", "r") as f:
        for line in f.readlines():

            match = re.search(r"#+\s*([\w\s]+)", line.strip())
            if match:
                artist = match[1]
                root   = "%s" % artist
                Path(root).mkdir(parents=True, exist_ok=True)
                continue

            match = re.search(r"\[([\w\s,+&!.'\"-]*)\][\S]*watch\?v=([\w+-]*)\)", line.strip())
            if match:
                if Path("%s/%s.mp3" % (artist, match[1])).exists():
                    pass
                    #print("Already Exists; Skipping: ", artist, match[1], match[2])
                else:
                    print("Queueing ", artist, match[1])
                    pkg.append({
                        "artist": artist,
                        "title": match[1],
                        "root": root,
                        "vid": match[2]
                    })
            elif line.strip():
                print("PARSING FAILURE: ", repr(line))

    if len(pkg):

        with Pool(min(8, len(pkg))) as p:
            perfect = True
            for success, dat in zip(p.map(download, pkg), pkg):
                if not success:
                    print("FAILED to download      %s (%s)" % (dat["vid"], dat["title"]))
                    perfect = False
            if perfect:
                print("Downloaded all successfully!")
            else:
                failures.append("%s, %s" % (album, artist))

        print("Failed to download these: ", failures)
    else:
        print("All files already downloaded.")