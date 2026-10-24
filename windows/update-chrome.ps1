# update-chrome - Google Chrome をアップデートするスクリプト (Windows)
# 元ファイル: shell/update-chrome.sh

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: update-chrome [-h|--help]

Google Chrome を winget でアップデートする。

  -h, --help  このヘルプを表示する
'@
    return
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Error: winget が見つかりません"
    exit 1
}

winget upgrade Google.Chrome
