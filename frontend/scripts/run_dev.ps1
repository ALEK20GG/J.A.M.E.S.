# Convenience script to start SvelteKit using the local CLI (works even if npm/npx are not on PATH)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir/..
try {
    Write-Host "Starting SvelteKit (local CLI) ..."
    $node = Join-Path -Path (Get-ChildItem -Path .\node_modules -Filter node.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
    if (-not $node) {
        # Fallback to 'node' on PATH
        $nodeCmd = "node"
    } else {
        $nodeCmd = "`"$node`""
    }
    & $nodeCmd ./node_modules/@sveltejs/kit/svelte-kit.js dev
} finally {
    Pop-Location
}
