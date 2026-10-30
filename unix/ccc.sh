#!/bin/bash
# 元ファイル: shell/ccc.sh - クリップボードにコピーする
#   cat sample.md | ccc
#   ccc sample.md

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'EOT'
使い方: ccc [ファイル] [-h|--help]

ファイルまたは標準入力の内容をクリップボードにコピーする。

  cat sample.md | ccc
  ccc sample.md
  -h, --help  このヘルプを表示する
EOT
        exit 0
    fi

    case "$(uname -s)" in
        Linux*)
            if ! command -v xclip >/dev/null 2>&1; then
                echo "Error: xclip is not installed" >&2
                echo "Prease install: sudo apt install xclip -y" >&2
                exit 1
            fi
            cmd="xclip -selection clipboard"
            ;;
        Darwin*)
            cmd="pbcopy"
            ;;
        *)
            echo "Error: Unsupported OS" >&2
            exit 1
            ;;
    esac

    # -t 0: 標準入力がターミナルか判定（パイプなら0、ターミナルなら1）
    if [ -t 0 ]; then
        if [ -z "$1" ]; then
            echo "Error: No file specified" >&2
            exit 1
        fi
        if [ ! -f "$1" ]; then
            echo "Error: File not found: $1" >&2
            exit 1
        fi
        cat "$1" | $cmd
    else
        $cmd
    fi
}

main "$@"
