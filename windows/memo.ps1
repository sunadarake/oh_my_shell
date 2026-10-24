# memo - memomemoをVSCodeで開く
# 元ファイル: shell/memo.sh

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: memo [-h|--help]

Documents\memomemo を VSCode で開く。

  -h, --help  このヘルプを表示する
'@
    return
}

$rootdir = Join-Path $env:USERPROFILE 'Documents\memomemo'

if (Test-Path $rootdir -PathType Container) {
    code $rootdir
} else {
    Write-Error "not exists memomemo dir: $rootdir"
    exit 1
}
