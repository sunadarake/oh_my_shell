#!/bin/bash
# 元ファイル: shell/oo.sh - 指定したディレクトリをファイルマネージャーで開く
#   oo /path/to/dir  oo ./
#   引数を省略した場合はカレントディレクトリを開く
#   ファイルを指定した場合は、そのファイルがあるディレクトリを開く

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: oo [ディレクトリ] [-h|--help]

指定したディレクトリをファイルマネージャーで開く。
引数を省略するとカレントディレクトリを開く。
ファイルを指定すると、そのファイルがあるディレクトリを開く。

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

# ファイルが指定された場合は、そのファイルがあるディレクトリを開く
if [ -f "$d" ]; then
    d=$(dirname -- "$d")
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
