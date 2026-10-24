# oo - 指定したディレクトリをエクスプローラーで開く
# 元ファイル: shell/oo.sh
# 使い方: oo [path]  引数省略時はカレントディレクトリ

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: oo [パス] [-h|--help]

指定したディレクトリをエクスプローラーで開く。
引数を省略するとカレントディレクトリを開く。

  oo C:\path\to\dir
  oo .
  -h, --help  このヘルプを表示する
'@
    return
}

if ($args.Count -eq 0) {
    $d = (Get-Location).Path
} else {
    $d = $args[0]
}

explorer.exe $d
