# memo - memomemoをZed(なければVSCode)で開く
# 元ファイル: shell/memo.sh

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: memo [-h|--help]

Documents\memomemo を Zed で開く。Zed が無ければ VSCode で開く。

  -h, --help  このヘルプを表示する
'@
    return
}

$rootdir = Join-Path $env:USERPROFILE 'Documents\memomemo'

if (-not (Test-Path $rootdir -PathType Container)) {
    Write-Error "not exists memomemo dir: $rootdir"
    exit 1
}

# zed を優先し、なければ code を使う
if (Get-Command zed -ErrorAction SilentlyContinue) {
    zed $rootdir
} elseif (Get-Command code -ErrorAction SilentlyContinue) {
    code $rootdir
} else {
    Write-Error "Error: zed or code is not installed"
    exit 1
}
