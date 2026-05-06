# init_claude - Claude設定ファイルを初期化
# 元ファイル: perl/init_claude.pl
# 使い方: .\init_claude.ps1

$settingsFile = '.claude\settings.json'
if (-not (Test-Path $settingsFile)) {
    New-Item -ItemType Directory -Path '.claude' -Force | Out-Null

    $commands = @(
        'rg','grep','egrep','fgrep',
        'mkdir','cp','mv','touch','chmod','chown','find',
        'cat','head','tail','less','more','wc','sort','uniq','cut','awk','sed','tee',
        'ls','stat','file','diff','du','df',
        'which','whereis','pwd'
    )
    $prefixes = @('', 'busybox ', 'busybox64u ')

    $allow = foreach ($prefix in $prefixes) {
        foreach ($cmd in $commands) { "Bash($prefix${cmd}:*)" }
    }
    $allow = @($allow) + @('Bash(git add:*)', 'List(*)', 'Edit(*)', 'Write(*)', 'mcp__voicevox__speak')

    $settings = @{
        permissions = @{
            allow = $allow
            deny  = @()
        }
    }
    $settings | ConvertTo-Json -Depth 5 | Set-Content $settingsFile -Encoding UTF8NoBOM
    Write-Output "Created: $settingsFile"
}

$mdContent = @'
<<ここにプロジェクトの名前を入れる>>

<<ここにプロジェクトの概要を２，３行程度で入れる>>

## プロジェクトの取り組み方について

* なるべくコードやコメントをシンプルに簡潔にすること。
* コメントはUTF-8の日本語で書くこと。
* 問題に取り組む前に、コードや仕様を読んで理解すること。

## Bashについて

bashを使わずにbusyboxを使う様にしてください。
'@

foreach ($file in @('CLAUDE.md', 'AGENTS.md')) {
    if (-not (Test-Path $file)) {
        Set-Content $file $mdContent -Encoding UTF8NoBOM
        Write-Output "Created: $file"
    }
}

Write-Output "Finish Complete"
