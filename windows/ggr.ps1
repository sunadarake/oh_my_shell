# 現在のgit変更をすべて破棄し、直前のコミット状態に戻す
# 未追跡ファイルは削除されない（git clean が必要）
#
# 使い方:
#   ./ggr.ps1

# git リポジトリ内かチェック
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "エラー: gitリポジトリではありません"
    exit 1
}

# 変更一覧を表示
Write-Host "=== 変更されたファイル ==="
git status --short
Write-Host ""

# 変更がなければ終了
$diff = git diff
$diffCached = git diff --cached
if (-not $diff -and -not $diffCached) {
    Write-Host "変更はありません"
    exit 0
}

# 確認
$ans = Read-Host "すべての変更を破棄しますか？ [yes/N]"

# yes / y / YES / Y 以外はキャンセル
if ($ans -notmatch '^(y|yes)$') {
    Write-Host "キャンセルしました"
    exit 0
}

# 元に戻す
git checkout .
Write-Host "完了: 変更を元に戻しました"

