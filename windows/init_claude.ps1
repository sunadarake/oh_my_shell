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

    # Bash（busybox経由も含む）用の許可コマンド
    $bashAllow = foreach ($prefix in $prefixes) {
        foreach ($cmd in $commands) { "Bash($prefix${cmd}:*)" }
    }

    # PowerShell（Windows環境）用の許可コマンド。busyboxはPowerShellからも実行できるため同じ組み合わせを許可
    $psAllow = foreach ($prefix in $prefixes) {
        foreach ($cmd in $commands) { "PowerShell($prefix${cmd}:*)" }
    }
    # 上記に対応するPowerShellネイティブのコマンドレットも許可
    $psNativeCommands = @(
        'Get-ChildItem','Get-Content','Select-String','Get-Item','Test-Path',
        'Copy-Item','Move-Item','New-Item','Remove-Item',
        'Sort-Object','Get-Location','Set-Location','Measure-Object','Compare-Object'
    )
    $psAllow = @($psAllow) + $(foreach ($cmd in $psNativeCommands) { "PowerShell(${cmd}:*)" })

    $allow = @($bashAllow) + @($psAllow) + @('Bash(git add:*)', 'PowerShell(git add:*)', 'List(*)', 'Edit(*)', 'Write(*)', 'mcp__voicevox__speak')

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
    'ask.md' = @'
---
description: Claudeに質問する(日本語で簡潔に回答)
argument-hint: [質問内容]
---

次の質問に、日本語でわかりやすく簡潔に答えてください。
専門用語は必要最小限にし、必要なら短い例を添えてください。
コードの変更やファイル編集はせず、回答のみ行ってください。

質問: $ARGUMENTS
'@
    'update-claude-md.md' = @'
---
description: これまでの変更を踏まえてCLAUDE.mdを更新する
---

このセッションでの変更を踏まえて、`CLAUDE.md` を実態に合わせて更新してください。

- 変更された仕様・コマンド・ディレクトリ構成を反映する
- 古くなった記述は削除または修正する
- 既存の構成やトーンは維持し、差分は最小限にする

編集する前に、何を直すかの要点を一覧で見せてください。
'@
    'git-commit.md' = @'
---
description: ここまでの変更をgit commitする
---

ここまでの変更を `git commit` してください。

- コミットメッセージは、日本語で簡潔かつ分かりやすく書いてください。
- 変更内容が一目で分かる1行目(50文字程度)にしてください。必要な場合のみ、空行のあとに補足を書いてください。
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


'@

foreach ($file in @('CLAUDE.md', 'AGENTS.md')) {
    if (-not (Test-Path $file)) {
        Set-Content $file $mdContent -Encoding UTF8NoBOM
        Write-Output "Created: $file"
    }
}

Write-Output "Finish Complete"
