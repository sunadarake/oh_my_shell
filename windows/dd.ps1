# dd - ターミナル画面をクリア
# 元ファイル: shell/dd.sh

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: dd [-h|--help]

ターミナル画面をクリアする。

  -h, --help  このヘルプを表示する
'@
    return
}

Clear-Host
