#!/bin/sh
# vvu - プロファイルをリロード

case "$(uname -s)" in
    Linux*)
        . ~/.bashrc
        ;;
    Darwin*)
        . ~/.zshrc
        ;;
    MINGW*|Windows*)
        . "$PROFILE"
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
