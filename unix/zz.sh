#!/bin/bash
# zz - 指定パス(省略時はカレントディレクトリ)を Zed エディタで開く (zed <path>)

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: zz [パス] [-h|--help]

指定したパスを Zed エディタで開く。省略するとカレントディレクトリを開く。

  zz
  zz ~/project
  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

if ! command -v zed >/dev/null 2>&1; then
    echo "Error: zed is not installed" >&2
    exit 1
fi

zed "${1:-.}"
