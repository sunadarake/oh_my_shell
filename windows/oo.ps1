# oo - 指定したディレクトリをエクスプローラーで開く
# 元ファイル: shell/oo.sh
# 使い方: oo [path]  引数省略時はカレントディレクトリ

if ($args.Count -eq 0) {
    $d = (Get-Location).Path
} else {
    $d = $args[0]
}

explorer.exe $d
