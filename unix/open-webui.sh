#!/bin/bash
# 元ファイル: shell/open-webui.sh - Open WebUIを起動する

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: open-webui [-h|--help]

Open WebUI を起動する。
初回のみ ~/open-webui-server を作成し、依存パッケージを追加する。

  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

if ! command -v uv >/dev/null 2>&1; then
    echo "uv is not installed" >&2
    exit 1
fi

cd "$HOME" || exit 1

PROJECT_DIR="$HOME/open-webui-server"

# 初回のみプロジェクト作成・依存パッケージ追加
if [ ! -d "$PROJECT_DIR" ]; then
    uv init --vcs none --python 3.11 open-webui-server || exit 1
    cd "$PROJECT_DIR" || exit 1
    rm -f main.py
    uv add beautifulsoup4 || exit 1
    uv add open-webui || exit 1
else
    cd "$PROJECT_DIR" || exit 1
fi

# Execute open-werbui
DATA_DIR="$HOME/.open-webui" uv run open-webui serve
