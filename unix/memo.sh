#!/bin/sh
# 元ファイル: shell/memo.sh - memomemoをVSCodeで開く

rootdir="$HOME/Documents/memomemo"

if [ -d "$rootdir" ]; then
    code "$rootdir/."
else
    echo "not exists memomemo dir: $rootdir" >&2
    exit 1
fi
