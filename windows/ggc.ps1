# ggc - git add . && git commit
# 元ファイル: shell/ggc.sh
# 使い方: ggc  または  ggc "メッセージ1" "メッセージ2"

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: ggc [コミットメッセージ...] [-h|--help]

git add . && git commit を実行する。
メッセージを省略すると、1行目が "docs|chore: 日時 (N files)"、3行目以降が
変更ファイル一覧 (Create/Update/Delete/Rename) になる。
変更が .md だけなら docs、それ以外は chore。複数指定すると改行区切りで結合する。

  ggc "readmeの修正" "jsの改善"
  -h, --help  このヘルプを表示する
'@
    return
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: git is not installed"
    exit 1
}

git add .

if ($args.Count -eq 0) {
    # ステージ済みの変更から「種類: 日時 (N files)」と変更ファイル一覧を作る
    # TODO: PowerShell 5.1 で日本語ファイル名が文字化けする場合は [Console]::OutputEncoding の設定が必要
    $files = @(git -c core.quotepath=false diff --cached --name-status | ForEach-Object {
        $f = $_ -split "`t"
        switch -Regex ($f[0]) {
            '^A' { "Create: $($f[1])" }
            '^M' { "Update: $($f[1])" }
            '^D' { "Delete: $($f[1])" }
            '^R' { "Rename: $($f[1]) -> $($f[2])" }
            default { "Update: $($f[1])" }
        }
    })
    # .md 以外が1つでもあれば chore、.md だけなら docs
    $names = @(git -c core.quotepath=false diff --cached --name-only)
    $kind = if ($names.Count -eq 0 -or @($names | Where-Object { $_ -notmatch '\.md$' }).Count -gt 0) { 'chore' } else { 'docs' }
    $msg = "${kind}: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " ($($files.Count) files)`n`n" + ($files -join "`n")
} else {
    $msg = $args -join "`n"
}

git commit -m $msg
