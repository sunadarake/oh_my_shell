#!/bin/sh
# tre - OS判別してtree/gtreeを実行する（ビルドディレクトリを自動除外）
#   -I <pattern> で除外パターンを追加できる（複数指定可）

# よく使われるビルド・依存関係ディレクトリを除外
IGNORE="
node_modules|.dart_tool|.flutter-plugins*|
__pycache__|.venv|venv|env|*.egg-info|.pytest_cache|
vendor|
blib|.build|
build|dist|out|target|cmake-build-*|
.next|.nuxt|.cache|
.gradle|Pods|DerivedData|
.git
"
# 改行・スペースを除去して1行の|区切りにする
IGNORE=$(printf '%s' "$IGNORE" | tr -d ' \n')

case "$(uname -s)" in
    Darwin) TREE_CMD="gtree" ;;
    *)      TREE_CMD="tree"  ;;
esac

# 引数を解析して -I を抽出、残りはtreeに渡す
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

# 先頭の空白を除去してからtreeに渡す
REST=$(printf '%s' "$REST" | sed 's/^ //')
# shellcheck disable=SC2086
$TREE_CMD -f -I "$IGNORE" $REST
