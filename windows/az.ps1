# az - CLI上で暗算ができるスクリプト
# 元ファイル: perl/az.pl
# 使い方: az 14 a 54  az 91 m 32  (a=+ s=- m=* d=/)

$expr = $args -join ' '
$expr = $expr -replace '\ba\b', '+'
$expr = $expr -replace '\bs\b', '-'
$expr = $expr -replace '\bm\b', '*'
$expr = $expr -replace '\bd\b', '/'

try {
    $result = Invoke-Expression $expr
    Write-Output $result
} catch {
    Write-Error "エラー: $_"
    exit 1
}
