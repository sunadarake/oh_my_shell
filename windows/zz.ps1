# zz - 指定パス(省略時はカレントディレクトリ)を Zed エディタで開く (zed <path>)
param([string]$Path = '.')

if (-not (Get-Command zed -ErrorAction SilentlyContinue)) {
    Write-Error "zed がインストールされていません"
    exit 1
}

zed $Path
