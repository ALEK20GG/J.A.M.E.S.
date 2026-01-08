<script>
  export let src = null;
  let audioEl;
  let playing = false;
  let current = 0;
  let duration = 0;

  function toggle() {
    if (!audioEl) return;
    if (audioEl.paused) audioEl.play(); else audioEl.pause();
  }

  function onPlay() { playing = true; }
  function onPause() { playing = false; }
  function onTime() { current = audioEl.currentTime; }
  function onLoaded() { duration = audioEl.duration || 0; }

  $: progress = duration ? Math.floor((current / duration) * 100) : 0;
</script>

<div class="flex items-center space-x-4">
  <button on:click={toggle} class="bg-blue-600 text-white px-3 py-1 rounded">
    {#if playing}Pause{:else}Play{/if}
  </button>
  <div class="w-full">
    <div class="text-sm">{Math.floor(current)}/{Math.floor(duration)}s</div>
    <div class="h-2 bg-gray-200 rounded">
      <div class="h-2 bg-green-500 rounded" style="width:{progress}%"></div>
    </div>
  </div>
  <audio bind:this={audioEl} src={src} on:play={onPlay} on:pause={onPause} on:timeupdate={onTime} on:loadedmetadata={onLoaded} class="hidden"></audio>
</div>
