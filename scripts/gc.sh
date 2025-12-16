#!/bin/sh
# gc - git add . && git commit -m "update"をするコマンド
#   gc "readmeの修正" "jsの改善" などのように
#   引数を入れることでコミットメッセージを追加できる

if ! command -v  git >/dev/null 2>&1; then
  echo "ERROR: git is not installed" >&2
  exit 1
fi

if [ $# -eq 0 ]; then
  msg="update"
else
  msg=$(printf "%s\n" "$@")
fi

git add . && git commit -m "$msg"
