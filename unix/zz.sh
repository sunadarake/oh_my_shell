#!/bin/bash
# zz - 指定パス(省略時はカレントディレクトリ)を Zed エディタで開く (zed <path>)

if ! command -v zed >/dev/null 2>&1; then
    echo "Error: zed is not installed" >&2
    exit 1
fi

zed "${1:-.}"
