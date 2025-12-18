#!/bin/sh
# ggf - git push pull main をするためのコマンド
if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is NOT installed"
  exit 1
fi

if [ $# -eq 0 ]; then
  git pull origin  main
else
  git pull "$@"
fi
