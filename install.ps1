param(
    [string]$ProfileDir = "$env:USERPROFILE\.dsh\profiles\web"
)

$ErrorActionPreference = "Stop"
$nodeModules = Join-Path $ProfileDir "..\node_modules"
$plugins = @(
    @{ Name = "dsh-command-retry-count"; Repo = "xiaoxingdelabi1/dsh-command-retry-count" },
    @{ Name = "dsh-command-check-update"; Repo = "xiaoxingdelabi1/dsh-command-check-update" }
)

Write-Host "DSH Profile Pack Installer" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if profile directory exists
if (-not (Test-Path $ProfileDir)) {
    Write-Host "Creating profile directory: $ProfileDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# Ensure node_modules/@deepseek-ai exists
$targetDir = Join-Path $nodeModules "@deepseek-ai"
if (-not (Test-Path $targetDir)) {
    Write-Host "Creating node_modules directory: $targetDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Download and install each plugin
foreach ($plugin in $plugins) {
    $pluginName = $plugin.Name
    $repo = $plugin.Repo
    $dest = Join-Path $targetDir $pluginName

    Write-Host "Installing: $pluginName" -ForegroundColor Green
    Write-Host "  From: github.com/$repo" -ForegroundColor Gray

    # Download from GitHub using the API
    $apiUrl = "https://api.github.com/repos/$repo/contents"

    # Get the file list from the repo
    try {
        $files = @(
            "package.json",
            "LICENSE",
            "README.md",
            "README.zh.md",
            "lib/index.js",
            "lib/types/index.d.ts"
        )

        # Create target directory
        New-Item -ItemType Directory -Path "$dest\lib\types" -Force | Out-Null

        # Download each file
        foreach ($file in $files) {
            $fileUrl = "$apiUrl/$($file -replace '\\', '/')"
            Write-Host "  Downloading: $file" -ForegroundColor Gray
            try {
                $response = Invoke-WebRequest -Uri $fileUrl -UseBasicParsing -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $data = $response.Content | ConvertFrom-Json
                    if ($data.content) {
                        $bytes = [Convert]::FromBase64String($data.content)
                        $outPath = Join-Path $dest $file
                        $outDir = Split-Path $outPath -Parent
                        if (-not (Test-Path $outDir)) {
                            New-Item -ItemType Directory -Path $outDir -Force | Out-Null
                        }
                        [System.IO.File]::WriteAllBytes($outPath, $bytes)
                    }
                }
            }
            catch {
                Write-Host "  [SKIP] $file not found" -ForegroundColor DarkYellow
            }
        }
        Write-Host "  Done!" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Failed to download $pluginName" -ForegroundColor Red
    }
    Write-Host ""
}

# Check if cordis.patch.yml exists
$patchFile = Join-Path $ProfileDir "cordis.patch.yml"
if (Test-Path $patchFile) {
    Write-Host "cordis.patch.yml already exists at: $patchFile" -ForegroundColor Yellow
    Write-Host "Make sure it contains the plugin entries from profile-pack/cordis.patch.yml" -ForegroundColor Yellow
}
else {
    Write-Host "Creating cordis.patch.yml..." -ForegroundColor Yellow
    @"
# Your patch layer for this dsh profile, applied after every bundle layer:
# a top-level YAML array of loader patch entries (id-targeted config
# overrides, disables, and insert lists; `!!js` expressions allowed).
- insert:
    - id: retry-count
      name: '@deepseek-ai/dsh-command-retry-count'
    - id: check-update
      name: '@deepseek-ai/dsh-command-check-update'
"@ | Set-Content -Path $patchFile -Encoding Utf8
    Write-Host "Created: $patchFile" -ForegroundColor Green
}

Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Restart DSH to load the new plugins." -ForegroundColor Cyan
Write-Host ""
Write-Host "Available commands after restart:" -ForegroundColor White
Write-Host "  /version                      - Show current DSH version" -ForegroundColor Gray
Write-Host "  /check-update                 - Check for updates" -ForegroundColor Gray
Write-Host "  /check-update to <version>    - Upgrade to a specific version" -ForegroundColor Gray
Write-Host "  /retry-count <provider> <n>   - Set retry count (0-20)" -ForegroundColor Gray