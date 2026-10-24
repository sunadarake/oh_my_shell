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

$settingsFile = '.claude\settings.json'
if (-not (Test-Path $settingsFile)) {
    New-Item -ItemType Directory -Path '.claude' -Force | Out-Null

    # Bash用の許可コマンド
    $bashAllow = foreach ($cmd in $commands) { "Bash(${cmd}:*)" }

    # PowerShell（Windows環境）用の許可コマンド
    $psAllow = foreach ($cmd in $commands) { "PowerShell(${cmd}:*)" }
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
            # 危険な操作と機密ファイルの読み取りを拒否する
            deny  = @(
                'Bash(rm -rf:*)', 'Bash(git push --force:*)',
                'Read(~/.ssh/**)', 'Read(./.env)'
            )
        }
        # 署名(Co-Authored-By等)をコミット・PRに付けない
        attribution = @{ commit = ''; pr = '' }
        includeCoAuthoredBy = $false
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
- `Co-Authored-By: Claude ...` や `🤖 Generated with Claude Code` などの署名・クレジット行は、コミットメッセージに含めないでください。
'@
    'update-agents-and-git.md' = @'
---
description: AGENTS.mdを更新してからgit commitする
---

次の順に実行してください。

1. このセッションでの変更を踏まえて、`AGENTS.md` を実態に合わせて更新する(既存の構成やトーンは維持し、差分は最小限にする)
2. `AGENTS.md` を含むここまでの変更を `git commit` する

- コミットメッセージは、日本語で簡潔かつ分かりやすく書いてください。1行目は50文字程度にしてください。
- `Co-Authored-By: Claude ...` や `🤖 Generated with Claude Code` などの署名・クレジット行は、コミットメッセージに含めないでください。
'@
    'todo.md' = @'
---
description: 実装計画を立てて todo/ に連番のTODOファイルを作成する
argument-hint: <実装したい内容>
allowed-tools: Bash(ls:*), Bash(tail:*), Read, Glob, Grep, Write, AskUserQuestion
---

## 依頼内容
$ARGUMENTS

## 最新のTODOファイル（最大5件）
!`ls todo/ | tail -5`

## 手順
1. 依頼内容を理解し、関連するコードを Glob / Grep / Read で調査する
2. 仕様・方針・範囲などで不明点や判断が分かれる点があれば、AskUserQuestion で質問して回答を待つ（推測で進めない）
3. 回答を踏まえて実装計画を立てる
4. 既存ファイルの最大番号に +1 した番号を3桁ゼロ埋めで決める（ファイルがなければ 001）
5. `todo/NNN-todo.md` を作成する（例: 既存が 002 までなら `todo/003-todo.md`）

## TODOファイルの形式
# <タイトル>

## 概要
何を・なぜ実装するか

## 調査結果
関連ファイルと現状の構成

## 実装計画
- [ ] ステップ1: 具体的な作業内容（対象ファイル）
- [ ] ステップ2: ...

## テスト・確認方法
- [ ] ...

## 決定事項
質問への回答で決まったこと

## 懸念点・未決事項
- ...

## 注意
- 計画の作成のみ行い、コードの実装はしないこと
- 質問は調査後にまとめて行い、コードを読めば分かることは聞かないこと
- 作成後、ファイルパスと計画の要約を報告すること
'@
}
foreach ($name in $slashCommands.Keys) {
    $file = Join-Path $commandsDir $name
    if (-not (Test-Path $file)) {
        Set-Content $file $slashCommands[$name] -Encoding UTF8NoBOM
        Write-Output "Created: $file"
    }
}

# OpenCode: .opencode\commands に同じコマンドを追加する(argument-hint / allowed-tools は未対応のため除く)
$ocCommandsDir = '.opencode\commands'
New-Item -ItemType Directory -Path $ocCommandsDir -Force | Out-Null
foreach ($name in $slashCommands.Keys) {
    $file = Join-Path $ocCommandsDir $name
    if (-not (Test-Path $file)) {
        $body = $slashCommands[$name] -replace '(?m)^(argument-hint|allowed-tools):.*\r?\n', '' -replace 'CLAUDE\.md', 'AGENTS.md'
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

if (-not (Test-Path 'AGENTS.md')) {
    Set-Content 'AGENTS.md' $mdContent -Encoding UTF8NoBOM
    Write-Output "Created: AGENTS.md"
}

Write-Output "Finish Complete"
