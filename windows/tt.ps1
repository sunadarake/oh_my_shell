# tt - ディレクトリごとファイルを作成するコマンド
# 元ファイル: shell/tt.sh
# 使い方: tt .claude/settings.json bin/oreore/

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: tt <パス>... [-h|--help]

親ディレクトリごとファイルやディレクトリを作成する。
末尾が / または \ ならディレクトリ、それ以外はファイルを作成する。

  tt .claude/settings.json bin/oreore/
  -h, --help  このヘルプを表示する
'@
    return
}

foreach ($f in $args) {
    if ($f.EndsWith('/') -or $f.EndsWith('\')) {
        New-Item -ItemType Directory -Path $f -Force | Out-Null
        Write-Host "mkdir $f"
    } else {
        $dir = Split-Path $f -Parent
        if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        New-Item -ItemType File -Path $f -Force | Out-Null
        Write-Host "touch $f"
    }
}
