#!/bin/sh
# 元ファイル: shell/oo.sh - 指定したディレクトリをファイルマネージャーで開く
#   oo /path/to/dir  oo ./
#   引数を省略した場合はカレントディレクトリを開く

if [ $# -eq 0 ]; then
    d=$(pwd)
else
    d="$1"
fi

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
        echo "unknown OS" >&2
        exit 1
        ;;
esac
