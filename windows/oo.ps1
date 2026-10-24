# oo - 指定したディレクトリをエクスプローラーで開く
# 元ファイル: shell/oo.sh
# 使い方: oo [path]  引数省略時はカレントディレクトリ
#   ファイルを指定した場合は、そのファイルがあるディレクトリを開く

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: oo [パス] [-h|--help]

指定したディレクトリをエクスプローラーで開く。
引数を省略するとカレントディレクトリを開く。
ファイルを指定すると、そのファイルがあるディレクトリを開く。

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

# ファイルが指定された場合は、そのファイルがあるディレクトリを開く
if (Test-Path -LiteralPath $d -PathType Leaf) {
    $d = Split-Path -LiteralPath (Resolve-Path -LiteralPath $d).Path -Parent
}

explorer.exe $d
