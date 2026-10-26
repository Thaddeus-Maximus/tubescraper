<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>tubescraper</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600&display=swap" rel="stylesheet">
<style>
:root {
    --bg:        #1d252c;
    --surface:   #252f38;
    --surface-2: #2d3943;
    --border:    #3a4752;
    --text:      #e0dbd5;
    --muted:     #9aa3ab;
    --accent:    #fece0b;
    --accent-fg: #1d252c;
    --ok:        #5cc98a;
    --info:      #6cb2f0;
    --err:       #f06c6c;
    --radius:    8px;
}

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Lexend", "Readex Pro", system-ui, sans-serif;
    font-weight: 300;
    font-size: 15px;
    background: var(--bg);
    color: var(--text);
}

.page {
    max-width: 64rem;
    margin: 0 auto;
    padding: 24px 16px 64px;
}

header {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 24px;
}
header h1 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    white-space: nowrap;
}
header h1 span { color: var(--accent); }
#url_form { display: flex; gap: 8px; flex: 1; }

.card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 20px;
    margin-bottom: 24px;
}
.card-head {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
}
.card-head h2 {
    margin: 0;
    font-size: 1rem;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
}
.card-head .spacer { flex: 1; }

input[type=text], input:not([type]) {
    width: 100%;
    font: inherit;
    color: var(--text);
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 8px 10px;
}
input:focus { outline: 2px solid var(--accent); outline-offset: -1px; border-color: transparent; }
input:invalid { border-color: var(--err); }
input[type=checkbox] { accent-color: var(--accent); width: 16px; height: 16px; }

button {
    font: inherit;
    font-weight: 500;
    border-radius: 6px;
    padding: 8px 16px;
    cursor: pointer;
    white-space: nowrap;
    border: 1px solid var(--accent);
    background: var(--accent);
    color: var(--accent-fg);
}
button.ghost {
    background: transparent;
    color: var(--muted);
    border-color: var(--border);
}
button.ghost:hover { color: var(--text); }
button:disabled { opacity: 0.5; cursor: default; }
button.small { padding: 2px 10px; font-size: 0.8rem; }

.notice { color: var(--muted); margin: 0 0 24px; }
.notice.error { color: var(--err); }

/* Preview */
.preview-grid {
    display: grid;
    grid-template-columns: 280px 1fr;
    gap: 24px;
    align-items: start;
}
.thumb { margin: 0; }
.thumb img {
    width: 100%;
    aspect-ratio: 16 / 9;
    object-fit: cover;
    border-radius: 6px;
    background: var(--bg);
    cursor: pointer;
    display: block;
}
.thumb figcaption { font-size: 0.8rem; color: var(--muted); margin-top: 6px; }

table.fields { width: 100%; border-collapse: collapse; }
table.fields th {
    text-align: left;
    font-weight: 400;
    color: var(--muted);
    padding: 6px 12px 6px 0;
    width: 1%;
    white-space: nowrap;
}
table.fields td { padding: 6px 0; }
.actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 12px; }

/* Data tables */
.table-wrap { overflow-x: auto; }
table.data { width: 100%; border-collapse: collapse; }
table.data th {
    text-align: left;
    font-weight: 400;
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
    padding: 8px 10px;
    border-bottom: 1px solid var(--border);
}
table.data td {
    padding: 8px 10px;
    border-bottom: 1px solid var(--border);
    vertical-align: middle;
}
table.data tr:last-child td { border-bottom: none; }
table.data tbody tr:hover { background: var(--surface-2); }
table.data .num { text-align: right; font-variant-numeric: tabular-nums; color: var(--muted); white-space: nowrap; }
table.data .sub { color: var(--muted); font-size: 0.85rem; }
table.data .mono { font-family: ui-monospace, monospace; font-size: 0.8rem; color: var(--muted); }
table.data tr.excluded td:not(:first-child) { opacity: 0.4; }
#tracks { margin-top: 20px; }
#tracks th:nth-child(-n+2), #tracks td:nth-child(-n+2) { width: 1%; }

.empty { color: var(--muted); text-align: center; padding: 24px 0; }

/* Status pills */
.pill {
    display: inline-block;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 2px 8px;
    border-radius: 999px;
    border: 1px solid currentColor;
    white-space: nowrap;
}
.pill.queued      { color: var(--muted); }
.pill.probing,
.pill.converting  { color: var(--info); }
.pill.downloading,
.pill.retrying    { color: var(--accent); }
.pill.done        { color: var(--ok); }
.pill.failed      { color: var(--err); cursor: help; }

.counts { display: flex; gap: 8px; }

/* Progress bar */
.bar {
    width: 100%;
    min-width: 120px;
    height: 6px;
    border-radius: 3px;
    background: var(--bg);
    overflow: hidden;
}
.bar .fill {
    height: 100%;
    background: var(--accent);
    transition: width 0.4s ease;
}
.bar.done .fill   { background: var(--ok); }
.bar.failed .fill { background: var(--err); }
.bar.busy .fill {
    width: 100% !important;
    background: repeating-linear-gradient(45deg, var(--info) 0 8px, transparent 8px 16px);
    background-size: 22.6px 100%;
    animation: slide 0.8s linear infinite;
}
@keyframes slide { from { background-position: 0 0; } to { background-position: 22.6px 0; } }

.toast {
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 10px 18px;
    opacity: 0;
    transition: opacity 0.2s;
    pointer-events: none;
}
.toast.show { opacity: 1; }

@media (max-width: 700px) {
    header { flex-direction: column; align-items: stretch; }
    .preview-grid { grid-template-columns: 1fr; }
}
</style>
</head>

<body>
<div class="page">

<header>
    <h1>tube<span>scraper</span></h1>
    <form id="url_form">
        <input id="url" name="url" type="text" placeholder="Paste a YouTube video or playlist URL" autocomplete="off">
        <button id="fetch_btn" type="submit">Fetch</button>
    </form>
</header>

<p id="notice" class="notice" hidden></p>

<section id="preview" class="card" hidden>
    <div class="card-head">
        <h2 id="preview_heading">Confirm details</h2>
    </div>
    <form id="meta_form">
        <input name="id" id="f_id" type="hidden">
        <input name="img" id="f_img" type="hidden">
        <input name="n_videos" id="f_n_videos" type="hidden">
        <div class="preview-grid">
            <figure class="thumb">
                <img id="thumb" alt="Thumbnail" title="Click to cycle thumbnails">
                <figcaption id="thumb_caption"></figcaption>
            </figure>
            <div>
                <table class="fields">
                    <tr id="title_row">
                        <th><label for="f_title">Title</label></th>
                        <td><input id="f_title" name="title" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"></td>
                    </tr>
                    <tr>
                        <th><label for="f_artist">Artist</label></th>
                        <td><input id="f_artist" name="artist" type="text" list="creators" required pattern="[a-zA-Z0-9\s\-\+_]+"></td>
                    </tr>
                    <tr>
                        <th><label for="f_album">Album</label></th>
                        <td><input id="f_album" name="album" type="text" required pattern="[a-zA-Z0-9\s\-\+_]+"></td>
                    </tr>
                    <tr>
                        <th><label for="f_genre">Genre</label></th>
                        <td><input id="f_genre" name="genre" type="text" pattern="[a-zA-Z0-9\s\-\+_]+"></td>
                    </tr>
                </table>
                <datalist id="creators"></datalist>
                <div class="actions">
                    <button type="button" class="ghost" id="cancel_btn">Cancel</button>
                    <button type="submit" id="download_btn">Download</button>
                </div>
            </div>
        </div>
        <div class="table-wrap">
            <table class="data" id="tracks" hidden>
                <thead>
                    <tr>
                        <th><input type="checkbox" id="toggle_all" checked title="Select all"></th>
                        <th class="num">#</th>
                        <th>Title</th>
                        <th>Video ID</th>
                    </tr>
                </thead>
                <tbody id="tracks_body"></tbody>
            </table>
        </div>
    </form>
</section>

<section class="card">
    <div class="card-head">
        <h2>Downloads</h2>
        <div class="counts" id="counts"></div>
        <div class="spacer"></div>
        <button class="ghost" id="retry_all_btn" type="button">Retry failed</button>
        <button class="ghost" id="clear_btn" type="button">Clear finished</button>
    </div>
    <div class="table-wrap">
        <table class="data">
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Artist / Album</th>
                    <th>Status</th>
                    <th style="width: 22%">Progress</th>
                    <th class="num">Speed</th>
                    <th class="num">ETA</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="jobs_body"></tbody>
        </table>
    </div>
</section>

</div>

<div id="toast" class="toast"></div>

<script>
const BASE     = '{{base_url}}';
const CREATORS = {{! creators_json}};
const INIT_URL = {{! url_json}};
const NAME_RE  = /[^a-zA-Z0-9\s\-\+_]+/g;
const ACTIVE   = ['queued', 'probing', 'downloading', 'retrying', 'converting'];

const $ = id => document.getElementById(id);
// Resolve against origin so a user:pass@ URL in the address bar doesn't break fetch().
const api = path => new URL(BASE + path, location.origin);
const clean = s => (s ?? '').replace(NAME_RE, '').trim();

// Playlist tracks are often titled "Song - Playlist Name" (or the reverse);
// drop the playlist name plus its separator from either end of the title.
function stripPlaylistName(title, name) {
    if (!name) return title;
    const pat = name.replace(/[.*+?^$()|[\]\\-]/g, '\\$&').replace(/\s+/g, '\\s+');
    const re = new RegExp(`^\\s*${pat}[\\s\\-_+]*|[\\s\\-_+]*${pat}\\s*$`, 'gi');
    const out = title.replace(re, '').replace(/\s{2,}/g, ' ').trim();
    return out || title;
}

let thumbnails = [];
let thumbIndex = 0;
let previewType = null;
let pollTimer = null;

function el(tag, attrs, ...children) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs || {})) {
        if (k === 'class') e.className = v;
        else if (k in e) e[k] = v;
        else e.setAttribute(k, v);
    }
    for (const c of children) e.append(c ?? '');
    return e;
}

function toast(msg) {
    const t = $('toast');
    t.textContent = msg;
    t.classList.add('show');
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.remove('show'), 2500);
}

function notice(msg, isError) {
    const n = $('notice');
    n.hidden = !msg;
    n.textContent = msg || '';
    n.classList.toggle('error', !!isError);
}

async function postForm(path, formData) {
    const r = await fetch(api(path), { method: 'POST', body: formData });
    let body = {};
    try { body = await r.json(); } catch (e) {}
    if (!r.ok) throw new Error(body.error || `${r.status} ${r.statusText}`);
    return body;
}

/* ---------- Fetch & preview ---------- */

async function fetchInfo(url) {
    $('url').value = url;
    history.replaceState(null, '', BASE + '?url=' + encodeURIComponent(url));
    $('preview').hidden = true;
    $('fetch_btn').disabled = true;
    notice('Fetching video info…');
    try {
        const fd = new FormData();
        fd.append('url', url);
        showPreview(await postForm('scrape', fd));
        notice('');
    } catch (e) {
        notice('Could not fetch info: ' + e.message, true);
    } finally {
        $('fetch_btn').disabled = false;
    }
}

function showPreview(data) {
    if (data.type !== 'video' && data.type !== 'playlist') {
        notice('Unrecognized response type: ' + data.type, true);
        return;
    }
    previewType = data.type;
    const isList = data.type === 'playlist';

    thumbnails = [];
    thumbIndex = 0;
    setThumb();
    loadThumbnails(data.thumbnails || []);

    $('preview_heading').textContent = isList
        ? `Playlist · ${data.videos.length} tracks`
        : 'Video';
    $('f_id').value     = data.id ?? '';
    $('f_title').value  = isList ? '' : clean(data.title);
    $('f_artist').value = clean(data.uploader);
    $('f_album').value  = clean(isList ? data.title : data.uploader);
    $('f_genre').value  = '';
    $('title_row').hidden = isList;
    $('f_title').required = !isList;

    const body = $('tracks_body');
    body.replaceChildren();
    $('tracks').hidden = !isList;
    $('toggle_all').checked = true;
    if (isList) {
        $('f_n_videos').value = data.videos.length;
        data.videos.forEach((v, i) => {
            const cb = el('input', { type: 'checkbox', name: `include_${i}`, value: '1', checked: true });
            const row = el('tr', {},
                el('td', {}, cb),
                el('td', { class: 'num' }, String(i + 1)),
                el('td', {},
                    el('input', { type: 'hidden', name: `id_${i}`, value: v.id }),
                    el('input', { type: 'text', name: `title_${i}`, value: stripPlaylistName(clean(v.title), clean(data.title)), pattern: '[a-zA-Z0-9\\s\\-\\+_]+' })),
                el('td', { class: 'mono' }, v.id));
            cb.addEventListener('change', () => row.classList.toggle('excluded', !cb.checked));
            body.append(row);
        });
    }
    $('preview').hidden = false;
}

// Load every candidate image, drop ones that fail, and order largest first so
// the highest-resolution one is selected by default. Listed sizes aren't
// trusted: YouTube serves a 120x90 placeholder for missing maxres images.
let thumbLoad = 0;
async function loadThumbnails(urls) {
    const load = ++thumbLoad;
    $('thumb_caption').textContent = `Checking ${urls.length} images…`;
    $('download_btn').disabled = true;  // cover art URL isn't chosen yet
    const measured = await Promise.all(urls.map(src => new Promise(resolve => {
        const img = new Image();
        img.onload  = () => resolve({ src, w: img.naturalWidth, h: img.naturalHeight });
        img.onerror = () => resolve(null);
        img.src = src;
    })));
    if (load !== thumbLoad) return;  // a newer fetch superseded this one
    thumbnails = measured.filter(t => t && t.w > 0)
        .sort((a, b) => b.w * b.h - a.w * a.h);
    thumbIndex = 0;
    setThumb();
    $('download_btn').disabled = false;
}

function setThumb() {
    const t = thumbnails[thumbIndex];
    $('thumb').src = t ? t.src : '';
    $('f_img').value = t ? t.src : '';
    $('thumb_caption').textContent = !t ? 'No images found'
        : `${t.w}×${t.h}` + (thumbnails.length > 1
            ? ` · ${thumbIndex + 1} of ${thumbnails.length} · click to cycle` : '');
}

function closePreview() {
    $('preview').hidden = true;
    $('url').value = '';
    history.replaceState(null, '', BASE);
}

/* ---------- Downloads table ---------- */

function fmtSpeed(bps) {
    if (!bps) return '';
    const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    let i = 0;
    while (bps >= 1024 && i < units.length - 1) { bps /= 1024; i++; }
    return bps.toFixed(i ? 1 : 0) + ' ' + units[i];
}

function fmtEta(s) {
    if (s == null) return '';
    s = Math.round(s);
    return Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0');
}

function renderJobs(jobs) {
    const body = $('jobs_body');
    body.replaceChildren();
    if (!jobs.length) {
        body.append(el('tr', {}, el('td', { class: 'empty', colSpan: 7 }, 'No downloads yet')));
    }
    // Newest first
    for (const j of [...jobs].reverse()) {
        const busy = j.status === 'probing' || j.status === 'converting' || j.status === 'queued';
        const pct = j.status === 'failed' ? 100 : (j.percent ?? 0);
        const label = j.status === 'retrying' ? `retrying (${j.attempt})` : j.status;
        const pill = el('span', { class: 'pill ' + j.status, title: j.error || '' }, label);
        const bar = el('div', { class: 'bar ' + (busy && j.status !== 'queued' ? 'busy' : j.status) },
            el('div', { class: 'fill', style: `width: ${j.status === 'queued' ? 0 : pct}%` }));
        body.append(el('tr', {},
            el('td', {}, j.title, el('div', { class: 'mono' }, j.vid)),
            el('td', {}, j.artist, el('div', { class: 'sub' }, j.album)),
            el('td', {}, pill),
            el('td', {}, bar),
            el('td', { class: 'num' }, j.status === 'downloading' ? fmtSpeed(j.speed) : ''),
            el('td', { class: 'num' }, j.status === 'downloading' ? fmtEta(j.eta) : ''),
            el('td', { class: 'num' }, j.status === 'failed'
                ? el('button', { class: 'ghost small', type: 'button', onclick: () => retry(`retry/${j.id}`) }, 'Retry')
                : '')));
    }

    const counts = $('counts');
    counts.replaceChildren();
    const active = jobs.filter(j => ACTIVE.includes(j.status)).length;
    const done   = jobs.filter(j => j.status === 'done').length;
    const failed = jobs.filter(j => j.status === 'failed').length;
    if (active) counts.append(el('span', { class: 'pill downloading' }, `${active} active`));
    if (done)   counts.append(el('span', { class: 'pill done' }, `${done} done`));
    if (failed) counts.append(el('span', { class: 'pill failed' }, `${failed} failed`));
    $('clear_btn').disabled = !(done + failed);
    $('retry_all_btn').disabled = !failed;
    return active;
}

async function retry(path) {
    try {
        const res = await postForm(path, new FormData());
        toast(`Retrying ${res.queued} download${res.queued === 1 ? '' : 's'}`);
    } catch (err) {
        toast('Error: ' + err.message);
    }
    poll();
}

async function poll() {
    clearTimeout(pollTimer);
    let active = 0;
    try {
        const r = await fetch(api('get_downloads'));
        active = renderJobs((await r.json()).jobs);
    } catch (e) {
        console.error('poll failed', e);
    }
    // Poll fast while something is running, lazily otherwise.
    pollTimer = setTimeout(poll, active ? 1000 : 10000);
}

/* ---------- Wiring ---------- */

function init() {
    for (const c of CREATORS) $('creators').append(el('option', { value: c }));

    $('url_form').addEventListener('submit', e => {
        e.preventDefault();
        const url = $('url').value.trim();
        if (url) fetchInfo(url);
    });

    $('thumb').addEventListener('click', () => {
        if (!thumbnails.length) return;
        thumbIndex = (thumbIndex + 1) % thumbnails.length;
        setThumb();
    });

    $('toggle_all').addEventListener('change', e => {
        for (const cb of $('tracks_body').querySelectorAll('input[type=checkbox]')) {
            cb.checked = e.target.checked;
            cb.dispatchEvent(new Event('change'));
        }
    });

    $('cancel_btn').addEventListener('click', closePreview);

    $('meta_form').addEventListener('submit', async e => {
        e.preventDefault();
        $('download_btn').disabled = true;
        try {
            const path = previewType === 'playlist' ? 'download_playlist' : 'download_video';
            const res = await postForm(path, new FormData($('meta_form')));
            toast(`Queued ${res.queued} download${res.queued === 1 ? '' : 's'}`);
            closePreview();
            poll();
        } catch (err) {
            toast('Error: ' + err.message);
        } finally {
            $('download_btn').disabled = false;
        }
    });

    $('clear_btn').addEventListener('click', async () => {
        await postForm('clear_finished', new FormData());
        poll();
    });

    $('retry_all_btn').addEventListener('click', () => retry('retry_failed'));

    if (INIT_URL) fetchInfo(INIT_URL);
    poll();
}

init();
</script>
</body>
</html>
