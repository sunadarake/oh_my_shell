# open-webui - Open WebUIを起動する
# 元ファイル: shell/open-webui.sh

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Error "uv is not installed"
    exit 1
}

$projectDir = Join-Path $env:USERPROFILE 'open-webui-server'

Set-Location $env:USERPROFILE

if (-not (Test-Path $projectDir -PathType Container)) {
    uv init --vcs none --python 3.11 open-webui-server
    if ($LASTEXITCODE -ne 0) { exit 1 }
    Set-Location $projectDir
    Remove-Item main.py -ErrorAction SilentlyContinue
    uv add beautifulsoup4
    if ($LASTEXITCODE -ne 0) { exit 1 }
    uv add open-webui
    if ($LASTEXITCODE -ne 0) { exit 1 }
} else {
    Set-Location $projectDir
}

$env:DATA_DIR = 'C:\open-webui\data'
uv run open-webui serve
