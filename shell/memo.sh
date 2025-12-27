#!/bin/sh
# memomemoをVSCodeで開く

rootdir="$HOME/Documents/memomemo"

if [ -d "$rootdir" ]; then
  code "$HOME/Documents/memomemo/."
else
  echo "not exists memomemo dir: $rootdir"
  exit 1
fi

