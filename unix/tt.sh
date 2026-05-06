#!/bin/sh
# 元ファイル: shell/tt.sh - ディレクトリごとファイルを作成するコマンド
#   tt .claude/settings.json bin/oreore/
#   .claude/settings.json のファイルと bin/oreore/ ディレクトリが作成される

for f in "$@"; do
    # 末尾が / ならディレクトリ作成、それ以外はファイル作成（親ディレクトリも含む）
    case "$f" in
        */)
            mkdir -p "$f"
            echo "mkdir $f"
            ;;
        *)
            d=$(dirname "$f")
            mkdir -p "$d" && touch "$f"
            echo "touch $f"
            ;;
    esac
done
