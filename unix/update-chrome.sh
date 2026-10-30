#!/bin/bash
# 元ファイル: shell/update-chrome.sh - Google Chrome をアップデートする

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOT'
使い方: update-chrome [-h|--help]

Google Chrome をアップデートする (Linux のみ)。

  -h, --help  このヘルプを表示する
EOT
        exit 0
    fi

    os=$(uname -s)
    case "$os" in
        Linux*)
            sudo apt-get update
            sudo apt upgrade google-chrome-stable -y
            ;;
        *)
            echo "Error: このスクリプトは Linux でのみ実行できます (検出されたOS: $os)" >&2
            exit 1
            ;;
    esac
}

main "$@"
