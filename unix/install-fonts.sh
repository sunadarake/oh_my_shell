#!/usr/bin/env bash
#
# install-fonts.sh
# 指定したフォントファイル／ディレクトリを ~/.local/share/fonts/ にコピーし、
# fc-cache を更新するスクリプト
#

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
VERSION="1.0.0"
FONT_DIR="$HOME/.local/share/fonts"

# コピー対象とするフォントの拡張子
FONT_EXTS=("ttf" "otf" "ttc" "otc" "woff" "woff2")

# インストールしたフォント名を記録する配列
INSTALLED_FONTS=()

show_help() {
    cat <<EOF
使い方: $SCRIPT_NAME [オプション] <ファイルまたはディレクトリ> [...]

フォントファイル、またはフォントを含むディレクトリを指定して
${FONT_DIR}/ にコピーし、fc-cache を更新します。

引数:
  ファイルまたはディレクトリを1つ以上指定してください。
  ディレクトリを指定した場合、拡張子が (${FONT_EXTS[*]}) の
  ファイルのみを再帰的にコピーします。

オプション:
  -h, --help       このヘルプを表示して終了
  -v, --version    バージョン情報を表示して終了

例:
  $SCRIPT_NAME ~/Downloads/MyFont.ttf
  $SCRIPT_NAME ~/Downloads/fonts_folder
  $SCRIPT_NAME font1.ttf font2.otf ~/Downloads/fonts_folder
EOF
}

show_version() {
    echo "$SCRIPT_NAME version $VERSION"
}

# 拡張子がフォント形式かどうかチェック
is_font_file() {
    local file="$1"
    local ext="${file##*.}"
    ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
    for e in "${FONT_EXTS[@]}"; do
        if [[ "$ext" == "$e" ]]; then
            return 0
        fi
    done
    return 1
}

copy_font() {
    local file="$1"
    echo "コピー中: $file"
    cp -f "$file" "$FONT_DIR/"
    INSTALLED_FONTS+=("$(basename "$file")")
}

# --- 引数チェック ---
if [[ $# -eq 0 ]]; then
    echo "エラー: 引数がありません。" >&2
    show_help
    exit 1
fi

TARGETS=()

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        *)
            TARGETS+=("$arg")
            ;;
    esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "エラー: フォントファイルまたはディレクトリを指定してください。" >&2
    exit 1
fi

# --- フォントディレクトリ準備 ---
mkdir -p "$FONT_DIR"

# --- コピー処理 ---
for target in "${TARGETS[@]}"; do
    if [[ -f "$target" ]]; then
        if is_font_file "$target"; then
            copy_font "$target"
        else
            echo "スキップ (対象外の拡張子): $target"
        fi
    elif [[ -d "$target" ]]; then
        # ディレクトリ内を再帰的に検索し、対象拡張子のみコピー
        while IFS= read -r -d '' font_file; do
            copy_font "$font_file"
        done < <(find "$target" -type f \( \
            -iname "*.ttf" -o \
            -iname "*.otf" -o \
            -iname "*.ttc" -o \
            -iname "*.otc" -o \
            -iname "*.woff" -o \
            -iname "*.woff2" \
        \) -print0)
    else
        echo "警告: 見つかりません、スキップします: $target" >&2
    fi
done

# --- フォントキャッシュ更新 ---
echo "フォントキャッシュを更新しています..."
fc-cache -f -v

echo "完了しました。"

# --- インストールしたフォント一覧を表示 ---
if [[ ${#INSTALLED_FONTS[@]} -eq 0 ]]; then
    echo "インストールされたフォントはありませんでした。"
else
    echo ""
    echo "インストールしたフォント (${#INSTALLED_FONTS[@]} 件):"
    for f in "${INSTALLED_FONTS[@]}"; do
        echo "  - $f"
    done
fi

