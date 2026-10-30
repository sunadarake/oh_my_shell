#!/bin/bash
# 元ファイル: shell/memo.sh - memomemoをZed(なければVSCode)で開く

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOT'
使い方: memo [-h|--help]

~/Documents/memomemo を Zed で開く。Zed が無ければ VSCode で開く。

  -h, --help  このヘルプを表示する
EOT
        exit 0
    fi

    rootdir="$HOME/Documents/memomemo"

    if [ ! -d "$rootdir" ]; then
        echo "not exists memomemo dir: $rootdir" >&2
        exit 1
    fi

    # zed を優先し、なければ code を使う
    if command -v zed >/dev/null 2>&1; then
        zed "$rootdir"
    elif command -v code >/dev/null 2>&1; then
        code "$rootdir/."
    else
        echo "Error: zed or code is not installed" >&2
        exit 1
    fi
}

main "$@"
