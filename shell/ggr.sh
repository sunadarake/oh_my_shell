#!/bin/sh
# 現在のgit変更をすべて破棄し、直前のコミット状態に戻す
# 未追跡ファイルは削除されない（git clean が必要）
#
# 使い方:
#   ./ggr.sh

# git リポジトリ内かチェック
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || {
    echo "エラー: gitリポジトリではありません" >&2
    exit 1
}

# 変更一覧を表示
echo "=== 変更されたファイル ==="
git status --short
echo ""

# 変更がなければ終了
git diff --quiet && git diff --cached --quiet && {
    echo "変更はありません"
    exit 0
}

# 確認
printf "すべての変更を破棄しますか？ [yes/N]: "
read ANS

# yes / y / YES / Y 以外はキャンセル
case "$ANS" in
    [Yy]|[Yy][Ee][Ss]) ;;
    *) {
        echo "キャンセルしました"
        exit 0
    } ;;
esac

# 元に戻す
git checkout .
echo "完了: 変更を元に戻しました"

