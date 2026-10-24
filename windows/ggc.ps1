# ggc - git add . && git commit
# 元ファイル: shell/ggc.sh
# 使い方: ggc  または  ggc "メッセージ1" "メッセージ2"

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: ggc [コミットメッセージ...] [-h|--help]

git add . && git commit を実行する。
メッセージを省略すると "update 日時" になる。複数指定すると改行区切りで結合する。

  ggc "readmeの修正" "jsの改善"
  -h, --help  このヘルプを表示する
'@
    return
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: git is not installed"
    exit 1
}

if ($args.Count -eq 0) {
    $msg = "update " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
} else {
    $msg = $args -join "`n"
}

git add .
git commit -m $msg
