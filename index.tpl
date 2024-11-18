<style>
.fullwidth {
    width: 100%;
}
input {
    width: 500px;
}

body {
    font-family: "Lexend", "Readex Pro", sans-serif;
    background-size: 100% auto;
    /*background-repeat: no-repeat;*/
    background-color: #1d252cff;
    color: #e0dbd5ff;
    font-size: 1.25rem;
}

h1 {
    font-size: 2rem;
    padding: 0.2rem 0 0.1rem 0;
    margin: 1rem 0 1rem 0;
}
h2 {
    font-size: 1.5rem;
    padding: 0.2rem 0 0.2rem 0;
    margin: 0.1rem 0 0.2rem 0;
    font-style: italic;
}
h3 {
    font-size: 1.5rem;
    padding: 0.1rem 0 0.2rem 0;
    margin: 0.1rem 0 0.4rem 0;
    color: #d0cbc5dd;
    font-size: 1rem;
}

p {
    padding: 0.1rem 0 0.5rem 0;
    margin: 0.1rem 0 1rem 0;
    color: #d0cbc5dd;
    font-size: 1rem;
}

ul {
    list-style-type: none; 
    padding: 0.1rem 0 0.5rem 0;
    margin: 0.1rem 0 1rem 0;
    font-size: 1rem;
}

.page {
    text-align: center;
    width: 100%;
    max-width: 60rem;
    margin-left: auto;
    margin-right: auto;
}

a {
    color: #fece0bff;
}

img {
    width: 100%;
}

.column {
  float: left;
  width: 47%;
}

.divider {
    float: left;
    width: 6%;
}

.row div:first-child {
    text-align: right;
}
.row div:last-child {
    text-align: left;
}


.row {
    margin-left: auto;margin-right: auto;
  width: 80%;
  max-width: 40rem;
  margin-bottom: 1rem;
}

/* Clear floats after the columns */
.row:after {
  content: "";
  display: table;
  clear: both;
}
</style>

<script type="text/javascript">

let url = '{{! url}}';
let creator_names = {{! creators}};
let intervalId = 0;

function refreshState(){ 
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '{{base_url}}get_downloads', true);
    xhr.send();

    // 4. This will be called after the response is received
    xhr.onload = function() {
      if (xhr.status != 200) { // analyze HTTP status of the response
        alert(`Error ${xhr.status}: ${xhr.statusText}`); // e.g. 404: Not Found
      } else { // show the result
        //alert(`Done, got ${xhr.response.length} bytes`); // response is the server response
        console.log(xhr.responseText);
        data = JSON.parse(xhr.responseText);
        console.log(data);

        let list = document.getElementById("status_downloads");
        while( list.firstChild ){ list.removeChild( list.firstChild ); }
        for (i = 0; i < data['downloading'].length; ++i) {
            let li = document.createElement('li');
            li.innerText = data['downloading'][i]['title'] + ' by ' + data['downloading'][i]['artist'] + ' (' + data['downloading'][i]['vid'] + ')';
            list.appendChild(li);
        }

        list = document.getElementById("status_completed");
        while( list.firstChild ){ list.removeChild( list.firstChild ); }
        for (i = 0; i < data['completed'].length; ++i) {
            let li = document.createElement('li');
            li.innerText = data['completed'][i]['title'] + ' by ' + data['completed'][i]['artist'] + ' (' + data['completed'][i]['vid'] + ')';
            list.appendChild(li);
        }

        list = document.getElementById("status_failed");
        while( list.firstChild ){ list.removeChild( list.firstChild ); }
        for (i = 0; i < data['failed'].length; ++i) {
            let li = document.createElement('li');
            li.innerText = data['failed'][i]['title'] + ' by ' + data['failed'][i]['artist'] + ' (' + data['failed'][i]['vid'] + ')';
            list.appendChild(li);
        }

        if (data['downloading'].length == 0) {
            console.log("no more downloads in queue, stopping interval")
            clearInterval(intervalId);
        }
      }
    };
}

let thumbnails = [];
let active_thumbnail = 0;

function init() {
    let select = document.getElementById('video_preview_creatorselect');
    let i=0;
    let opt = null;
    for(creator in creator_names.sort()) {
        i++;
        opt = document.createElement('option');
        opt.innerHTML = creator_names[creator];
        opt.value = creator_names[creator];
        select.appendChild(opt);
    }

    
    intervalId = setInterval(refreshState, 10000);

    /*opt = document.createElement('option');
    opt.innerHTML = "New..."
    opt.value = '';*/
    select.appendChild(opt);

    if (url) {
        //document.getElementById('url_input').style.display = 'none';
        document.getElementById('placeholder').innerText = 'Getting Video Data...';
        document.getElementById('url').value = url;

        var data = new FormData();
        data.append('url', url);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', '{{base_url}}scrape', true);
        xhr.send(data);

        // 4. This will be called after the response is received
        xhr.onload = function() {
          if (xhr.status != 200) { // analyze HTTP status of the response
            document.getElementById('placeholder').innerText = `Error Fetching Video Data: ${xhr.status}: ${xhr.statusText}`;
          } else { // show the result
            //alert(`Done, got ${xhr.response.length} bytes`); // response is the server response
            console.log(xhr.responseText);
            data = JSON.parse(xhr.responseText);
            console.log(data);

            document.getElementById('placeholder').innerText = '';

            if (data['type'] == 'video') {
                thumbnails = data.thumbnails;
                active_thumbnail = 0;
                document.getElementById('video_preview').style.display = 'block';
                document.getElementById('playlist_preview').style.display = 'none';
                document.getElementById('video_preview_title').value  = (data['title'] ?? '').replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('video_preview_artist').value = (data['uploader'] ?? '').replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('video_preview_album').value  = (data['uploader'] ?? '').replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('video_preview_thumbnail').src = thumbnails[0];
                document.getElementById('video_preview_img').value = thumbnails[0];
                document.getElementById('video_preview_id').value = (data['id'] ?? '');
            } else if (data['type'] == 'playlist') {
                thumbnails = data.thumbnails;
                active_thumbnail = 0;
                document.getElementById('playlist_preview').style.display = 'block';
                document.getElementById('video_preview').style.display = 'none';
                //document.getElementById('playlist_preview_title').value   = data['title'].replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('playlist_preview_artist').value   = (data['uploader'] ?? '').replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('playlist_preview_album').value    = (data['title'] ?? '').replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('playlist_preview_thumbnail').src  = thumbnails[0];
                document.getElementById('playlist_preview_img').value      = thumbnails[0];
                document.getElementById('playlist_preview_id').value       = data['id'] ?? '';
                document.getElementById('playlist_preview_n_videos').value = data['videos'].length;

                let table = document.getElementById('playlist_preview_table');
                while( table.firstChild ){ table.removeChild( table.firstChild ); }
                for (i=0; i<data['videos'].length; i++) {
                    let video = data['videos'][i];
                    console.log('video', i, video);
                    let tr = document.createElement('tr');
                    let title = video.title.replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                    tr.innerHTML = `<td><label>${i}</label></td><td><input name="id_${i}" value="${video.id}" hidden/><input type="text" name="title_${i}" value="${title}"/></td>`;
                    table.appendChild(tr);
                }
            } else {
                alert("weird type of thing");
            }
          }
        };

        xhr.onprogress = function(event) {
          if (event.lengthComputable) {
            //alert(`Received ${event.loaded} of ${event.total} bytes`);
          } else {
            //alert(`Received ${event.loaded} bytes`); // no Content-Length
          }
        };

        xhr.onerror = function() {
          alert("Request failed");
          document.getElementById('placeholder').innerText = 'Failed to get video data';
        };
    }

    refreshState();
}

function cycleThumbnail() {
    active_thumbnail++;
    if (active_thumbnail >= thumbnails.length)
        active_thumbnail = 0;
    newThumb = thumbnails[active_thumbnail];
    document.getElementById('video_preview_img').value        = newThumb;
    document.getElementById('video_preview_thumbnail').src    = newThumb;
    document.getElementById('playlist_preview_img').value     = newThumb;
    document.getElementById('playlist_preview_thumbnail').src = newThumb;
}

function creatorSelectChange() {
    let creator = document.getElementById('video_preview_creatorselect').value;
    document.getElementById('video_preview_artist').value = creator;
    creator = document.getElementById('playlist_preview_creatorselect').value;
    document.getElementById('playlist_preview_artist').value = creator;
}

</script>

<body onload="init()">
<div class="page">
<div id="url_input" class="fullwidth">
    <h1>Insert URL</h1>
    <form method="GET" id='form'>
        <label for="url" hidden>URL</label> <input id="url" name="url" type="text"/>
        <button id="submit" type="submit">Fetch Info...</button></td></tr>
    </form>
</div>
<div class="fullwidth">
    <h2 id="placeholder"></h2>
</div>
<div id="video_preview" style="display: none;">
    <h1>Confirm Video Details</h1>
    <form method="POST" id="video_preview_form" action="{{base_url}}download_video">
        <img id="video_preview_thumbnail" onclick="cycleThumbnail();"/>
        <input id="video_preview_id" name="id" type="text" hidden/>
        <input id="video_preview_img" name="img" type="text" hidden/>
        <table>
            <tr>
                <td><label for="title">Title</label></td>
                <td><input id="video_preview_title" name="title" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
            </tr>
            <tr>
                <td><label for="artist">Artist</label></td>
                <td><input id="video_preview_artist" name="artist" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
                <td><select id="video_preview_creatorselect" onchange="creatorSelectChange();"></select></td>
            </tr>
            <tr>
                <td><label for="album">Album</label></td>
                <td><input id="video_preview_album" name="album" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
            </tr>
            <tr>
                <td><label for="genre">Genre</label></td>
                <td><input id="video_preview_genre" name="genre" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
            </tr>
            <tr>   
                <td></td>
                <td><button id="submit" type="submit">Download!</button></td>
            </tr>
        </table>
    </form>
</div>
<div id="playlist_preview" style="display: none;">
    <h1>Confirm Playlist Details</h1>
    <form method="POST" id="playlist_preview_form" action="{{base_url}}download_playlist">
        <img id="playlist_preview_thumbnail" onclick="cycleThumbnail();"/>
        <input id="playlist_preview_id" name="id" type="text" hidden/>
        <input id="playlist_preview_img" name="img" type="text" hidden/>
        <input id="playlist_preview_n_videos" name="n_videos" type="text" hidden/>
        <table>
            <tr>
                <td><label for="artist">Artist</label></td>
                <td><input id="playlist_preview_artist" name="artist" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
                <td><select id="playlist_preview_creatorselect" onchange="creatorSelectChange();"></select></td>
            </tr>
            <tr>
                <td><label for="album">Album</label></td>
                <td><input id="playlist_preview_album" name="album" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
            </tr>
            <tr>
                <td><label for="genre">Genre</label></td>
                <td><input id="playlist_preview_genre" name="genre" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"/></td>
            </tr>
        </table>
        <table id="playlist_preview_table"></table>
        <button id="submit" type="submit">Download!</button>
</div>
<div>
    <br/>
    <h2>Ongoing Processes:</h2>
    <h3>Downloading:</h3>
    <ul id='status_downloads'></ul>
    <h3>Completed:</h3>
    <ul id='status_completed'></ul>
    <h3>Failed:</h3>
    <ul id='status_failed'></ul>

</div>
</div>
</body>