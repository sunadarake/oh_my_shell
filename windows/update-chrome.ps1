# update-chrome - Google Chrome をアップデートするスクリプト (Windows)
# 元ファイル: shell/update-chrome.sh

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Error: winget が見つかりません"
    exit 1
}

winget upgrade Google.Chrome
