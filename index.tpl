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

            document.getElementById('video_preview').style.display = 'block';
            document.getElementById('placeholder').innerText = '';

            if (data['type'] == 'video') {
                document.getElementById('video_preview_title').value  = data['title'].replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('video_preview_artist').value = data['uploader'].replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('video_preview_album').value  = data['uploader'].replace(/[^a-zA-Z0-9\s\-\+_]+/g, '');
                document.getElementById('video_preview_thumbnail').src = data['thumbnail'];
                document.getElementById('video_preview_img').value = data['thumbnail'];
                document.getElementById('video_preview_id').value = data['id'];
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


function creatorSelectChange() {
    let creator = document.getElementById('video_preview_creatorselect').value;
    document.getElementById('video_preview_artist').value = creator;
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
        <img id="video_preview_thumbnail"/>
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
                <td></td>
                <td><button id="submit" type="submit">Download!</button></td>
            </tr>
        </table>
    </form>
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