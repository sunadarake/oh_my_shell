#!/bin/bash
# 元ファイル: shell/ggp.sh - git push origin main をするコマンド

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: ggp [git push の引数...] [-h|--help]

git push を実行する。引数を省略すると git push origin main になる。

  ggp
  ggp origin develop
  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is NOT installed" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    git push origin main
else
    git push "$@"
fi
