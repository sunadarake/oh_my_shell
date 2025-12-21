#!/bin/sh
# vvp - プロファイルをvimで開く

case "$(uname -s)" in
    Linux*)
        vim ~/.bashrc
        ;;
    Darwin*)
        vim ~/.zshrc
        ;;
    MINGW*|Windows*)
        vim "$PROFILE"
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
