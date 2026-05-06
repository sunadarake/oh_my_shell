# memo - memomemoをVSCodeで開く
# 元ファイル: shell/memo.sh

$rootdir = Join-Path $env:USERPROFILE 'Documents\memomemo'

if (Test-Path $rootdir -PathType Container) {
    code $rootdir
} else {
    Write-Error "not exists memomemo dir: $rootdir"
    exit 1
}
