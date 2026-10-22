#!/bin/bash
# zz - カレントディレクトリを Zed エディタで開く (zed .)

if ! command -v zed >/dev/null 2>&1; then
    echo "Error: zed is not installed" >&2
    exit 1
fi

zed .
