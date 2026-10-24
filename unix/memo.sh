#!/bin/bash
# 元ファイル: shell/memo.sh - memomemoをVSCodeで開く

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: memo [-h|--help]

~/Documents/memomemo を VSCode で開く。

  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

rootdir="$HOME/Documents/memomemo"

if [ -d "$rootdir" ]; then
    code "$rootdir/."
else
    echo "not exists memomemo dir: $rootdir" >&2
    exit 1
fi
