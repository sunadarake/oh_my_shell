#!/bin/sh
# 元ファイル: shell/tre.sh - OS判別してtree/gtreeを実行する（ビルドディレクトリを自動除外）
#   -I <pattern> で除外パターンを追加できる（複数指定可）

IGNORE="
node_modules|.dart_tool|.flutter-plugins*|
__pycache__|.venv|venv|env|*.egg-info|.pytest_cache|
vendor|
blib|.build|local|
build|dist|out|target|cmake-build-*|
.next|.nuxt|.cache|
.gradle|Pods|DerivedData|
.git|
.vscode|.claude|.zed|
android|linux|ios|win|web|
todo
"
# スペースと改行を除去して1行のパターン文字列にまとめる
IGNORE=$(printf '%s' "$IGNORE" | tr -d ' \n')

case "$(uname -s)" in
    Darwin) TREE_CMD="gtree" ;;
    *)      TREE_CMD="tree"  ;;
esac

# -I オプションは除外パターンに追記、それ以外はtreeへ渡す引数として蓄積
REST=""
while [ $# -gt 0 ]; do
    case "$1" in
        -I)
            shift
            IGNORE="${IGNORE}|${1}"
            ;;
        *)
            REST="$REST $1"
            ;;
    esac
    shift
done

# 先頭の余分なスペースを除去
REST=$(printf '%s' "$REST" | sed 's/^ //')
# shellcheck disable=SC2086
$TREE_CMD -f -I "$IGNORE" $REST
