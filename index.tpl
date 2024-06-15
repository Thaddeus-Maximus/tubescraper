<script type="text/javascript">

let url = '{{! url}}';
let creator_names = {{! creators}};

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

    /*opt = document.createElement('option');
    opt.innerHTML = "New..."
    opt.value = '';*/
    select.appendChild(opt);

    if (!url) return;

    document.getElementById('url').value = url;
    document.getElementById('video_preview_url').value = url;

    var data = new FormData();
    data.append('url', url);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'scrape', true);
    xhr.onload = function () {
        // do something to response
        console.log(this.responseText);
    };
    xhr.send(data);

    // 4. This will be called after the response is received
    xhr.onload = function() {
      if (xhr.status != 200) { // analyze HTTP status of the response
        alert(`Error ${xhr.status}: ${xhr.statusText}`); // e.g. 404: Not Found
      } else { // show the result
        //alert(`Done, got ${xhr.response.length} bytes`); // response is the server response
        data = JSON.parse(xhr.responseText);
        console.log(data);

        document.getElementById('video_preview').style.display = 'block';
        document.getElementById('placeholder').style.display = 'none';

        if (data['type'] == 'video') {
            document.getElementById('video_preview_title').value = data['title'];
            document.getElementById('video_preview_channel').value = data['uploader'];
            document.getElementById('video_preview_thumbnail').src = data['thumbnail'];
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
    };
}


function creatorSelectChange() {
    let creator = document.getElementById('video_preview_creatorselect').value;
    document.getElementById('video_preview_channel').value = creator;
}

</script>

<body onload="init()">
<h1>Insert URL</h1>
<form method="GET" id='form'>
    <label for="url">URL</label> <input id="url" name="url" type="text"/>
    <button id="submit" type="submit">Get...</button></td></tr>
</form>
<div id="placeholder">
    Fetching video data...
</div>
<div id="video_preview" style="display: none;">
    <form method="POST" id="video_preview_form" action="/download_video">
        <img id="video_preview_thumbnail"/>
        <input id="video_preview_url" name="url" type="text"/>
        <table>
            <tr>
                <td><label for="">Title</label></td>
                <td><input id="video_preview_title" name="title" type="text" pattern="[a-zA-Z0-9\s\-\+]+"/></td>
            </tr>
            <tr>
                <td><label for="">Channel</label></td>
                <td><input id="video_preview_channel" name="channel" type="text" pattern="[a-zA-Z0-9\s\-\+]+"/></td>
                <td><select id="video_preview_creatorselect" onchange="creatorSelectChange();"></select></td>
            </tr>
            <tr>   
                <td></td>
                <td><button id="submit" type="submit">Download!</button></td>
            </tr>
        </table>
    </form>
</div>
</body>