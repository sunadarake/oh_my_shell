# vv - ファイルを別ターミナルでvimで開く
# 元ファイル: shell/vv.sh
# 使い方: vv <file>

param([string]$File)

if (-not $File) {
    Write-Error "Usage: vv <file>"
    exit 1
}

if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: vim が見つかりません"
    exit 1
}

# Windows Terminal → cmd の順でフォールバック
if (Get-Command wt -ErrorAction SilentlyContinue) {
    Start-Process wt -ArgumentList "vim `"$File`""
} else {
    Start-Process cmd -ArgumentList "/c vim `"$File`""
}
