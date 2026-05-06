#!/bin/sh
# 元ファイル: shell/ccc.sh - クリップボードにコピーする
#   cat sample.md | ccc
#   ccc sample.md

case "$(uname -s)" in
    Linux*)
        if ! command -v xclip >/dev/null 2>&1; then
            echo "Error: xclip is not installed" >&2
            echo "Prease install: sudo apt install xclip -y" >&2
            exit 1
        fi
        cmd="xclip -selection clipboard"
        ;;
    Darwin*)
        cmd="pbcopy"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        cmd="clip.exe"
        ;;
    *)
        echo "Error: Unsupported OS" >&2
        exit 1
        ;;
esac

# -t 0: 標準入力がターミナルか判定（パイプなら0、ターミナルなら1）
if [ -t 0 ]; then
    if [ -z "$1" ]; then
        echo "Error: No file specified" >&2
        exit 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1" >&2
        exit 1
    fi
    cat "$1" | $cmd
else
    $cmd
fi
