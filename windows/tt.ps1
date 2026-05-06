# tt - ディレクトリごとファイルを作成するコマンド
# 元ファイル: shell/tt.sh
# 使い方: tt .claude/settings.json bin/oreore/

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
