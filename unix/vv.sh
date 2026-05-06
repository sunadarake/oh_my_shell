#!/bin/sh
# 元ファイル: shell/vv.sh - ファイルを別ターミナルでvimで開く
#   vv <file>

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
