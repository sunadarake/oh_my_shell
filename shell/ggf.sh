#!/bin/sh
# ggf - git push pull main をするためのコマンド
if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is NOT installed"
  exit 1
fi

if [ $# -ne 0 ]; then
  echo "ERROR: ggf は引数を受け取りません"
  echo "もしかして ggc と間違えていませんか？"
  exit 1
fi

git pull origin main
