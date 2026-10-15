# init_claude - Claude Code / OpenCode設定ファイルを初期化
# 元ファイル: perl/init_claude.pl
# 使い方: .\init_claude.ps1

$commands = @(
    'rg','grep','egrep','fgrep',
    'mkdir','cp','mv','touch','chmod','chown','find',
    'cat','head','tail','less','more','wc','sort','uniq','cut','awk','sed','tee',
    'ls','stat','file','diff','du','df',
    'which','whereis','pwd',
    'echo','curl','base64'
)
$prefixes = @('', 'busybox ', 'busybox64u ')

$settingsFile = '.claude\settings.json'
if (-not (Test-Path $settingsFile)) {
    New-Item -ItemType Directory -Path '.claude' -Force | Out-Null

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

    $allow = @($bashAllow) + @($psAllow) + @('Bash(git:*)', 'PowerShell(git:*)', 'List(*)', 'Edit(*)', 'Write(*)', 'mcp__voicevox__speak')

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

$slashCommands = @{
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

'@
    'update-agents-md.md' = @'
---
description: これまでの変更を踏まえてAGENTS.mdを更新する
---

このセッションでの変更を踏まえて、`AGENTS.md` を実態に合わせて更新してください。

- 変更された仕様・コマンド・ディレクトリ構成を反映する
- 古くなった記述は削除または修正する
- 既存の構成やトーンは維持し、差分は最小限にする

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
foreach ($name in $slashCommands.Keys) {
    $file = Join-Path $commandsDir $name
    if (-not (Test-Path $file)) {
        Set-Content $file $slashCommands[$name] -Encoding UTF8NoBOM
        Write-Output "Created: $file"
    }
}

# OpenCode: .opencode\commands に同じコマンドを追加する(argument-hint は未対応のため除く)
# update-claude-md は update-agents-md に改名し、AGENTS.md を更新対象にする
$ocCommandsDir = '.opencode\commands'
New-Item -ItemType Directory -Path $ocCommandsDir -Force | Out-Null
foreach ($name in $slashCommands.Keys) {
    $file = Join-Path $ocCommandsDir ($name -replace 'claude-md', 'agents-md')
    if (-not (Test-Path $file)) {
        $body = $slashCommands[$name] -replace '(?m)^argument-hint:.*\r?\n', '' -replace 'CLAUDE\.md', 'AGENTS.md'
        Set-Content $file $body -Encoding UTF8NoBOM
        Write-Output "Created: $file"
    }
}

# OpenCode: opencode.json に permission を設定する(後勝ちのため "*" を先頭に置く)
$opencodeFile = 'opencode.json'
if (-not (Test-Path $opencodeFile)) {
    $config = [ordered]@{
        '$schema'  = 'https://opencode.ai/config.json'
        permission = [ordered]@{
            '*'                = 'allow'
            edit               = 'allow'
            webfetch           = 'allow'
            external_directory = 'ask'
            bash               = [ordered]@{ '*' = 'allow'; 'rm *' = 'ask'; 'rmdir *' = 'ask' }
        }
    }
    $config | ConvertTo-Json -Depth 5 | Set-Content $opencodeFile -Encoding UTF8NoBOM
    Write-Output "Created: $opencodeFile"
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
