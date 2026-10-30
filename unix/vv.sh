#!/bin/bash
# 元ファイル: shell/vv.sh - ファイルを別ターミナルでvimで開く
#   vv <file>

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOT'
使い方: vv <ファイル> [-h|--help]

ファイルを別ターミナルで vim で開く。

  -h, --help  このヘルプを表示する
EOT
        exit 0
    fi

    if [ $# -eq 0 ]; then
        echo "Usage: $0 <file>" >&2
        exit 1
    fi

    FILE="$1"

    if command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal -e "vim $FILE"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- vim "$FILE"
    else
        echo "ERROR: xfce4-terminal または gnome-terminal が見つかりません" >&2
        exit 1
    fi
}

main "$@"
