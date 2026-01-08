<script>
  import { onMount } from 'svelte';
  import Player from '$lib/Player.svelte';
  let songs = [];
  let token = localStorage.getItem('token') || '';
  let username = '';
  let password = '';
  let fileToUpload = null;
  let title = '';

  async function loadSongs() {
    const res = await fetch('/api/songs');
    const json = await res.json();
    songs = json.songs || [];
  }

  onMount(() => {
    loadSongs();
  });

  async function login() {
    const fd = new URLSearchParams();
    fd.append('username', username);
    fd.append('password', password);
    const res = await fetch('/api/token', { method: 'POST', body: fd });
    if (res.ok) {
      const json = await res.json();
      token = json.access_token;
      localStorage.setItem('token', token);
      alert('Login ok');
    } else {
      alert('Login failed');
    }
  }

  function onFileChange(e) {
    fileToUpload = e.target.files[0];
  }

  let uploadProgress = 0;

  async function presignAndUpload() {
    if (!fileToUpload) { alert('Scegli un file'); return; }
    const fd = new FormData();
    fd.append('filename', fileToUpload.name);
    fd.append('title', title || fileToUpload.name);
    const res = await fetch('/api/presign_upload', { method: 'POST', body: fd, headers: { 'Authorization': `Bearer ${token}` } });
    if (!res.ok) { alert('Presign failed'); return; }
    const json = await res.json();
    const presigned_url = json.presigned_url;

    // Upload via XHR to get progress
    await new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('PUT', presigned_url);
      xhr.setRequestHeader('Content-Type', 'audio/mpeg');
      xhr.upload.onprogress = (e) => {
        if (e.lengthComputable) {
          uploadProgress = Math.round((e.loaded / e.total) * 100);
        }
      };
      xhr.onload = async () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          // confirm with backend
          const conf = await fetch('/api/confirm_upload', { method: 'POST', body: new URLSearchParams({ song_id: json.id }), headers: { 'Authorization': `Bearer ${token}` } });
          if (!conf.ok) { alert('Confirm failed'); reject(); return; }
          uploadProgress = 0;
          await loadSongs();
          resolve();
        } else {
          reject(new Error('Upload failed'));
        }
      };
      xhr.onerror = () => reject(new Error('Network error'));
      xhr.send(fileToUpload);
    }).catch((err) => { alert('Upload error: ' + err.message); uploadProgress = 0; });
  }
</script>

<svelte:head>
  <link rel="stylesheet" href="/src/app.css">
</svelte:head>

<main class="container">
  <h1 class="text-2xl font-bold mb-4">James — Music</h1>

  <section class="mb-6">
    <h2 class="font-semibold">Login</h2>
    <input placeholder="username" bind:value={username} class="border p-2 mr-2" />
    <input placeholder="password" type="password" bind:value={password} class="border p-2 mr-2" />
    <button on:click={login} class="bg-blue-600 text-white px-3 py-1 rounded">Login</button>
  </section>

  <section class="mb-6">
    <h2 class="font-semibold">Upload (presigned, requires login)</h2>
    <input type="text" placeholder="Title (optional)" bind:value={title} class="border p-2 mr-2" />
    <input type="file" on:change={onFileChange} class="mr-2" />
    <button on:click={presignAndUpload} class="bg-green-600 text-white px-3 py-1 rounded">Upload</button>

    {#if uploadProgress > 0}
      <div class="mt-2">
        <div class="h-2 bg-gray-200 rounded">
          <div class="h-2 bg-blue-500 rounded" style="width:{uploadProgress}%"></div>
        </div>
        <div class="text-sm mt-1">{uploadProgress}%</div>
      </div>
    {/if}
  </section>

  <section>
    <h2 class="font-semibold mb-2">Brani</h2>
    <button on:click={loadSongs} class="bg-gray-200 px-2 py-1 rounded mb-2">Ricarica</button>
    <ul>
      {#each songs as s}
        <li class="mb-3">
          <div class="font-medium">{s.title} {#if s.size}<span class="text-sm text-gray-500">({Math.round(s.size/1024)} KB)</span>{/if}</div>
          {#if s.stream_url}
            <Player src={s.stream_url} />
          {:else}
            <div class="text-sm text-gray-500">Not ready for streaming yet</div>
          {/if}
        </li>
      {/each}
    </ul>
  </section>
</main>
