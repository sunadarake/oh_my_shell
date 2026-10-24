#!/bin/bash
# 元ファイル: shell/oo.sh - 指定したディレクトリをファイルマネージャーで開く
#   oo /path/to/dir  oo ./
#   引数を省略した場合はカレントディレクトリを開く

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: oo [ディレクトリ] [-h|--help]

指定したディレクトリをファイルマネージャーで開く。
引数を省略するとカレントディレクトリを開く。

  oo /path/to/dir
  oo ./
  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

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
    *)
        echo "unknown OS" >&2
        exit 1
        ;;
esac
