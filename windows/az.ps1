# az - CLI上で暗算ができるスクリプト
# 元ファイル: perl/az.pl
# 使い方: az 14 a 54  az 91 m 32  (a=+ s=- m=* d=/)

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: az <数> <演算子> <数> [-h|--help]

CLI 上で暗算をする。演算子は英字で指定する (a=+ s=- m=* d=/)。

  az 14 a 54
  az 91 m 32
  -h, --help  このヘルプを表示する
'@
    return
}

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
