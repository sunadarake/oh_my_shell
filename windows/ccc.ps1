# ccc - クリップボードにコピーするスクリプト (Windows PowerShell)
# 元ファイル: shell/ccc.sh
# 使い方: Get-Content file.txt | ccc  または  ccc file.txt

param([string]$FilePath, [Alias('h')][switch]$Help)

if ($Help -or $FilePath -eq '--help') {
    @'
使い方: ccc [ファイル] [-h|--help]

ファイルまたはパイプで渡した内容をクリップボードにコピーする。

  Get-Content file.txt | ccc
  ccc file.txt
  -h, --help  このヘルプを表示する
'@
    return
}

$piped = @($input)
if ($piped.Count -gt 0) {
    $piped | Set-Clipboard
} elseif ($FilePath) {
    if (-not (Test-Path $FilePath -PathType Leaf)) {
        Write-Error "Error: File not found: $FilePath"
        exit 1
    }
    Get-Content $FilePath | Set-Clipboard
} else {
    Write-Error "Error: No file specified"
    exit 1
}
