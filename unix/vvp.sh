#!/bin/sh
# 元ファイル: shell/vvp.sh - プロファイルをvimで開く

case "$(uname -s)" in
    Linux*)
        vim ~/.bashrc
        ;;
    Darwin*)
        vim ~/.zshrc
        ;;
    *)
        echo "unknown OS" >&2
        exit 1
        ;;
esac
