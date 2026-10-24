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

# テンプレートを読み込む(build後は .bin_win\templates、開発時は ..\templates)
$tplDir = @("$PSScriptRoot\templates\init_claude", "$PSScriptRoot\..\templates\init_claude") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $tplDir) { throw 'テンプレートが見つかりません' }
$slashCommands = @{}
foreach ($f in Get-ChildItem "$tplDir\commands" -Filter '*.md') {
    $slashCommands[$f.Name] = Get-Content $f.FullName -Raw -Encoding UTF8
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

if (-not (Test-Path 'AGENTS.md')) {
    Set-Content 'AGENTS.md' (Get-Content "$tplDir\AGENTS.md" -Raw -Encoding UTF8) -Encoding UTF8NoBOM
    Write-Output "Created: AGENTS.md"
}

Write-Output "Finish Complete"
