# zz - カレントディレクトリを Zed エディタで開く (zed .)

if (-not (Get-Command zed -ErrorAction SilentlyContinue)) {
    Write-Error "zed がインストールされていません"
    exit 1
}

zed .
