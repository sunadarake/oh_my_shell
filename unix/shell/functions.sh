#!/bin/bash
# 元ファイル: なし(新規) - mkcd と cd 拡張などのシェル関数を定義する(~/.bashrc から source して使う)
# source "$HOME/Documents/oh_my_shell/unix/shell/functions.sh"

# ディレクトリを作成して移動する
mkcd() {
    if [ $# -ne 1 ]; then
        echo "使い方: mkcd <dir>" >&2
        return 1
    fi
    mkdir -p -- "$1" && builtin cd -- "$1"
}

# cd N で ../ を N 回上る(同名ディレクトリがあればそちらを優先)
cd() {
    if [ $# -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]] && [ ! -d "$1" ]; then
        local up="" i
        for ((i = 0; i < $1; i++)); do up+="../"; done
        [ -n "$up" ] && builtin cd "$up"
    else
        builtin cd "$@"
    fi
}
