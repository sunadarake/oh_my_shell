#!/bin/bash
# oo - クロスプラットフォームでエクスプローラーを開く

# 引数チェック
if [ $# -eq 0 ]; then
    echo "usage: oo <dir>"
    exit 1
fi

d="$1"

case "$(uname -s)" in
    Linux*)
        xdg-open "$d"
        ;;
    Darwin*)
        open "$d"
        ;;
    MINGW*|Windows*)
        explorer.exe "$d"
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
