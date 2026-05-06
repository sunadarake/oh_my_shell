#!/bin/sh
# 元ファイル: shell/ggp.sh - git push origin main をするコマンド

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is NOT installed" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    git push origin main
else
    git push "$@"
fi
