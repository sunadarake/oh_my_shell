# zz - 指定パス(省略時はカレントディレクトリ)を Zed エディタで開く (zed <path>)
param([string]$Path = '.', [Alias('h')][switch]$Help)

if ($Help -or $Path -eq '--help') {
    @'
使い方: zz [パス] [-h|--help]

指定したパスを Zed エディタで開く。省略するとカレントディレクトリを開く。

  zz
  zz ~/project
  -h, --help  このヘルプを表示する
'@
    return
}

if (-not (Get-Command zed -ErrorAction SilentlyContinue)) {
    Write-Error "zed がインストールされていません"
    exit 1
}

zed $Path
