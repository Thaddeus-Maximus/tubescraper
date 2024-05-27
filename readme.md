# TUBESCRAPER

`downloader.py` will make sure that all the videos in `videos.md` are downloaded (it doesn't download existing videos)

# Limitations
`downloader.py` only checks the presence of a file. It does not check if that file is uncorrupted, or if the file matches the URL (if, say, you changed the URL in `videos.md`). So, if you made a mistake, you'll have to delete the downloaded file.