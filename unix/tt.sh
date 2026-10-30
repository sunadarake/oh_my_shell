#!/bin/bash
# 元ファイル: shell/tt.sh - ディレクトリごとファイルを作成するコマンド
#   tt .claude/settings.json bin/oreore/
#   .claude/settings.json のファイルと bin/oreore/ ディレクトリが作成される

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOT'
使い方: tt <パス>... [-h|--help]

親ディレクトリごとファイルやディレクトリを作成する。
末尾が / ならディレクトリ、それ以外はファイルを作成する。

  tt .claude/settings.json bin/oreore/
  -h, --help  このヘルプを表示する
EOT
        exit 0
    fi

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
}

main "$@"
