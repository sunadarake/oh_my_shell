#!/bin/sh
# open-webui - Open WebUIを起動する

if ! command -v uvx > /dev/null 2>&1; then
    echo "uvx is not installed"
    exit 1
fi

cd "$HOME" || exit 1

case "$(uname -s)" in
    Linux*|Darwin*)
        DATA_DIR=~/.open-webui uvx --python 3.11 open-webui@latest serve
        ;;
    MINGW*|Windows*)
        DATA_DIR="C:\\open-webui\\data" uvx --python 3.11 open-webui@latest serve
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
