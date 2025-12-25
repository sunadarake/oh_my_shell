#!/bin/bash
# oo - 指定したディレクトリをエクスプローラーで開く
# oo /path/to/dir oo ./
# 引数を省略した場合はカレントディレクトリを開く

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
        echo "unknown OS"
        exit 1
        ;;
esac

