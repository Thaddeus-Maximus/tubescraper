<script>
    creator_names = {{! creators}};

    function init() {
            let select = document.getElementById('creator');
            let i=0;
            let opt = null;
            for(creator in creator_names.sort()) {
                i++;
                opt = document.createElement('option');
                opt.innerHTML = creator_names[creator];
                opt.value = creator_names[creator];
                select.appendChild(opt);
            }

            opt = document.createElement('option');
            opt.innerHTML = "New..."
            opt.value = '';
            select.appendChild(opt);
    }

    function creatorSelectChange() {
        let creator = document.getElementById('creator').value;
        if (creator) {
            document.getElementById('newCreatorRow').style.display = 'none';
        } else {
            document.getElementById('newCreatorRow').style.display = 'table-row';
        }
    }
</script>

<body onload="init()">

<h2>{{msg}}</h2>

<h1>Download YouTube Video as Podcast</h1>
<form method="POST">
<table>
    <tr><th><label for="url">URL</label></th><td><input id="url" name="url" type="text"/></td></tr>
    <tr><th><label for="creator">Creator</label></th><td><select name="creator" id="creator" onchange="creatorSelectChange();"></select></td></tr>
    
    <tr id='newCreatorRow'><th><label for="url">New:</label></th><td><input id="creator_new" name="creator_new" type="text"/></td></tr>
    <tr><th><label for="url">Title:</label></th><td><input id="title" name="title" type="text"/></td></tr>
    <tr><th><label for="submit"></label></th><td><button id="submit" name="submit">submit</button></td></tr>
</table>
</form>
</body>