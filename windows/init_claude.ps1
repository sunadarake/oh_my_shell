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

# .claude\commands にスラッシュコマンドを追加する
$commandsDir = '.claude\commands'
New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null

$commands = @{
    'update-claude-md.md' = @'
# CLAUDE.md をこれまでの変更を踏まえて更新

このセッションでの変更を踏まえて、CLAUDE.md を実態に合わせて更新して。
- 変わった仕様・コマンド・ディレクトリ構成を反映
- 古くなった記述は削除・修正
- 既存の構成やトーンは維持し、差分を最小限に
変更前に何を直すか要点を一覧で見せてから編集して。
'@
    'git-commit.md' = @'
# git commitでここまでの修正を書くこと。

ここまでの変更を git commit して。
コミットログは簡潔にかつ分かりやすく書いて。
'@
}
foreach ($name in $commands.Keys) {
    $file = Join-Path $commandsDir $name
    if (-not (Test-Path $file)) {
        Set-Content $file $commands[$name] -Encoding UTF8NoBOM
        Write-Output "Created: $file"
    }
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
