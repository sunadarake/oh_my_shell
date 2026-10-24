#!/bin/bash
# 元ファイル: shell/ggc.sh - git add . && git commit をするコマンド
#   ggc "readmeの修正" "jsの改善" のように引数でコミットメッセージを追加できる

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: ggc [コミットメッセージ...] [-h|--help]

git add . && git commit を実行する。
メッセージを省略すると "update 日時" になる。複数指定すると改行区切りで結合する。

  ggc "readmeの修正" "jsの改善"
  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is not installed" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    msg="update $(date '+%Y-%m-%d %H:%M:%S')"
else
    # 複数引数を改行区切りで結合してコミットメッセージにする
    msg=$(printf "%s\n" "$@")
fi

git add . && git commit -m "$msg"
