# ccc - クリップボードにコピーするスクリプト (Windows PowerShell)
# 元ファイル: shell/ccc.sh
# 使い方: Get-Content file.txt | ccc  または  ccc file.txt

param([string]$FilePath)

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
