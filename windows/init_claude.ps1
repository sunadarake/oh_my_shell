# init_claude - Claude Code / OpenCode設定ファイルを初期化
# 元ファイル: perl/init_claude.pl
# 使い方: .\init_claude.ps1 [-Update]  (-Update: 設定・コマンドを上書き。AGENTS.md は変更しない)
param([switch]$Update)

# 未作成または -Update のときのみ書き込む
function Write-IfNeeded($file, $content) {
    $exists = Test-Path $file
    if ($exists -and -not $Update) { return }
    Set-Content $file $content -Encoding UTF8NoBOM
    Write-Output ("{0}: {1}" -f $(if ($exists) { 'Updated' } else { 'Created' }), $file)
}

$commands = @(
    'rg','grep','egrep','fgrep',
    'mkdir','cp','mv','touch','chmod','chown','find',
    'cat','head','tail','less','more','wc','sort','uniq','cut','awk','sed','tee',
    'ls','stat','file','diff','du','df',
    'which','whereis','pwd',
    'echo','curl','base64'
)

$settingsFile = '.claude\settings.json'
if ($true) {
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
    Write-IfNeeded $settingsFile ($settings | ConvertTo-Json -Depth 5)
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
    Write-IfNeeded (Join-Path $commandsDir $name) $slashCommands[$name]
}

# OpenCode: .opencode\commands に同じコマンドを追加する(argument-hint / allowed-tools は未対応のため除く)
$ocCommandsDir = '.opencode\commands'
New-Item -ItemType Directory -Path $ocCommandsDir -Force | Out-Null
foreach ($name in $slashCommands.Keys) {
    $body = $slashCommands[$name] -replace '(?m)^(argument-hint|allowed-tools):.*\r?\n', '' -replace 'CLAUDE\.md', 'AGENTS.md'
    Write-IfNeeded (Join-Path $ocCommandsDir $name) $body
}

# OpenCode: opencode.json に permission を設定する(後勝ちのため "*" を先頭に置く)
$opencodeFile = 'opencode.json'
if ($true) {
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
    Write-IfNeeded $opencodeFile ($config | ConvertTo-Json -Depth 5)
}

if (-not (Test-Path 'AGENTS.md')) {
    Set-Content 'AGENTS.md' (Get-Content "$tplDir\AGENTS.md" -Raw -Encoding UTF8) -Encoding UTF8NoBOM
    Write-Output "Created: AGENTS.md"
}

Write-Output "Finish Complete"
