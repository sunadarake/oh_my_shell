#!/bin/sh
# 元ファイル: shell/ggc.sh - git add . && git commit をするコマンド
#   ggc "readmeの修正" "jsの改善" のように引数でコミットメッセージを追加できる

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is not installed" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    msg="update"
else
    # 複数引数を改行区切りで結合してコミットメッセージにする
    msg=$(printf "%s\n" "$@")
fi

git add . && git commit -m "$msg"
