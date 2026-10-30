#!/bin/bash
# 元ファイル: shell/dd.sh - ターミナル画面をクリア

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOT'
使い方: dd [-h|--help]

ターミナル画面をクリアする。

  -h, --help  このヘルプを表示する
EOT
        exit 0
    fi

    clear
}

main "$@"
