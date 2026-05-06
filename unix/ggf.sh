#!/bin/sh
# 元ファイル: shell/ggf.sh - git pull origin main をするコマンド

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is NOT installed" >&2
    exit 1
fi

if [ $# -ne 0 ]; then
    echo "ERROR: ggf は引数を受け取りません" >&2
    echo "もしかして ggc と間違えていませんか？" >&2
    exit 1
fi

git pull origin main
