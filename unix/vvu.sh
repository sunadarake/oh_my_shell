#!/bin/sh
# 元ファイル: shell/vvu.sh - プロファイルをリロード

case "$(uname -s)" in
    Linux*)
        . ~/.bashrc
        ;;
    Darwin*)
        . ~/.zshrc
        ;;
    *)
        echo "unknown OS" >&2
        exit 1
        ;;
esac
