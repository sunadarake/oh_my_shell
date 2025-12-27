#!/bin/sh
# ccc - クリップボードにコピーするスクリプト（Linux/Mac/Windows対応）
#  cat sample.md | ccc
#  ccc sample.md

# OSを判定
case "$(uname -s)" in
    Linux*)
        # xclipがインストールされているか確認
        if ! command -v xclip >/dev/null 2>&1; then
            echo "Error: xclip is not installed" >&2
            echo "Prease install: sudo apt install xclip -y" >&2
            exit 1
        fi
        cmd="xclip -selection clipboard"
        ;;
    Darwin*)
        # macOSはpbcopyが標準搭載
        cmd="pbcopy"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        # Windowsはclip.exeが標準搭載
        cmd="clip.exe"
        ;;
    *)
        echo "Error: Unsupported OS" >&2
        exit 1
        ;;
esac

# 標準入力からか引数からかを判定
if [ -t 0 ]; then
    # パイプなし、引数を使用
    printf '%s' "$*" | $cmd
else
    # パイプから読み込み
    $cmd
fi
