#!/bin/sh
# open-webui - Open WebUIを起動する

if ! command -v uv > /dev/null 2>&1; then
    echo "uv is not installed"
    exit 1
fi

cd "$HOME" || exit 1

case "$(uname -s)" in
    Linux*|Darwin*)
        PROJECT_DIR="$HOME/open-webui-server"

        if [ ! -d "$PROJECT_DIR" ]; then
            uv init --vcs none --python 3.11 open-webui-server || exit 1
            cd "$PROJECT_DIR" || exit 1
            rm -f main.py
            uv add beautifulsoup4 || exit 1
            uv add open-webui || exit 1
        else
            cd "$PROJECT_DIR" || exit 1
        fi

        DATA_DIR="$HOME/.open-webui" uv run open-webui serve
        ;;

    MINGW*|MSYS*|CYGWIN*|Windows*)
        PROJECT_DIR="$HOME/open-webui-server"

        if [ ! -d "$PROJECT_DIR" ]; then
            uv init --vcs none --python 3.11 open-webui-server || exit 1
            cd "$PROJECT_DIR" || exit 1
            rm -f main.py
            uv add beautifulsoup4 || exit 1
            uv add open-webui || exit 1
        else
            cd "$PROJECT_DIR" || exit 1
        fi

        DATA_DIR="C:\\open-webui\\data" uv run open-webui serve
        ;;

    *)
        echo "unknown OS"
        exit 1
        ;;
esac
