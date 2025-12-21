#!/bin/sh
# update-chrome - Google Chrome をアップデートするスクリプト
# ex) update-chrome

# Linux でのみ実行
os=$(uname -s)
case "$os" in
  Linux*)
    sudo apt upgrade google-chrome-stable -y
    ;;
  *)
    echo "Error: このスクリプトは Linux でのみ実行できます (検出されたOS: $os)" >&2
    exit 1
    ;;
esac
