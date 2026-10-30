#!/bin/bash
# 元ファイル: shell/ggf.sh - git pull origin main をするコマンド

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: ggf [-h|--help]

git pull origin main を実行する。引数は受け取らない。

  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

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
