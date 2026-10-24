#!/bin/bash
# 元ファイル: shell/ggc.sh - git add . && git commit をするコマンド
#   ggc "readmeの修正" "jsの改善" のように引数でコミットメッセージを追加できる

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: ggc [コミットメッセージ...] [-h|--help]

git add . && git commit を実行する。
メッセージを省略すると、1行目が "Update: 日時 (N files)"、3行目以降が
変更ファイル一覧 (Create/Update/Delete/Rename) になる。複数指定すると改行区切りで結合する。

  ggc "readmeの修正" "jsの改善"
  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is not installed" >&2
    exit 1
fi

git add . || exit

if [ $# -eq 0 ]; then
    # ステージ済みの変更から「Update: 日時 (N files)」と変更ファイル一覧を作る
    files=$(git -c core.quotepath=false diff --cached --name-status | awk -F'\t' '
        $1 == "A" { print "Create: " $2 }
        $1 == "M" { print "Update: " $2 }
        $1 == "D" { print "Delete: " $2 }
        $1 ~ /^R/ { print "Rename: " $2 " -> " $3 }
        $1 !~ /^[AMDR]/ { print "Update: " $2 }')
    count=$(printf "%s\n" "$files" | grep -c .)
    msg=$(printf "Update: %s (%s files)\n\n%s" "$(date '+%Y-%m-%d %H:%M:%S')" "$count" "$files")
else
    # 複数引数を改行区切りで結合してコミットメッセージにする
    msg=$(printf "%s\n" "$@")
fi

git commit -m "$msg"
