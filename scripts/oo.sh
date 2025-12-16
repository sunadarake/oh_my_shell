#!/bin/bash
# oo - クロスプラットフォームでエクスプローラーを開く

# 引数チェック
if [ $# -eq 0 ]; then
    echo "使い方: oo <ディレクトリ>"
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
    CYGWIN*|MINGW*|MSYS*)
        explorer.exe "$(cygpath -w "$d" 2>/dev/null || echo "$d")"
        ;;
    *)
        echo "未対応のOS"
        exit 1
        ;;
esac
