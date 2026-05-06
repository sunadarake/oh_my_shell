#!/bin/sh
# 元ファイル: shell/update-chrome.sh - Google Chrome をアップデートする

os=$(uname -s)
case "$os" in
    Linux*)
        sudo apt-get update
        sudo apt upgrade google-chrome-stable -y
        ;;
    *)
        echo "Error: このスクリプトは Linux でのみ実行できます (検出されたOS: $os)" >&2
        exit 1
        ;;
esac
