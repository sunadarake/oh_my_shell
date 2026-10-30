# init_claude - Claude Code / OpenCode設定ファイルを初期化
# 元ファイル: perl/init_claude.pl
# 使い方: .\init_claude.ps1 [-Update]  (-Update: 設定・skill を上書き。AGENTS.md は変更しない)
param([switch]$Update, [Alias('h')][switch]$Help)

# 未作成または -Update のときのみ書き込む
function Write-IfNeeded($file, $content) {
    $exists = Test-Path $file
    if ($exists -and -not $Update) { return }
    Set-Content $file $content -Encoding UTF8NoBOM
    Write-Output ("{0}: {1}" -f $(if ($exists) { 'Updated' } else { 'Created' }), $file)
}

function Main {
    if ($Help -or $args -contains '--help') {
        @'
使い方: init_claude [-Update] [-h|-Help|--help]

Claude Code / OpenCode の設定ファイルをカレントディレクトリに作成する。

  -Update     settings.json / skills / opencode.json を上書きする
              (AGENTS.md は変更しない)
  -h, -Help, --help  このヘルプを表示する
'@
        return
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

    $settings = [ordered]@{
        # 署名(Co-Authored-By等)をコミット・PRに付けない
        attribution = [ordered]@{ commit = ''; pr = '' }
        includeCoAuthoredBy = $false
        permissions = [ordered]@{
            allow = $allow
            # 危険な操作と機密ファイルの読み取りを拒否する
            deny  = @(
                'Bash(rm -rf:*)', 'Bash(git push --force:*)',
                'Read(~/.ssh/**)', 'Read(./.env)'
            )
        }
    }
    Write-IfNeeded $settingsFile ($settings | ConvertTo-Json -Depth 5)

    # テンプレートを読み込む(build後は .bin_win\templates、開発時は ..\templates)
    $tplDir = @("$PSScriptRoot\templates\init_claude", "$PSScriptRoot\..\templates\init_claude") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $tplDir) { throw 'テンプレートが見つかりません' }

    # .claude\skills\<名>\SKILL.md に skill を追加する(frontmatter 先頭に name: を差し込む)
    $skills = [ordered]@{}
    foreach ($f in Get-ChildItem "$tplDir\skill" -Filter '*.md') {
        $skills[$f.BaseName] = (Get-Content $f.FullName -Raw -Encoding UTF8) -replace '\A---\r?\n', "---`nname: $($f.BaseName)`n"
    }
    foreach ($name in $skills.Keys) {
        New-Item -ItemType Directory -Path ".claude\skills\$name" -Force | Out-Null
        Write-IfNeeded ".claude\skills\$name\SKILL.md" $skills[$name]
    }

    # OpenCode: .opencode\skills に同じ skill を追加する(argument-hint / allowed-tools は未対応のため除く)
    # TODO: OpenCode の skill で $ARGUMENTS が展開されるか未確認
    foreach ($name in $skills.Keys) {
        $body = $skills[$name] -replace '(?m)^(argument-hint|allowed-tools):.*\r?\n', '' -replace 'CLAUDE\.md', 'AGENTS.md'
        New-Item -ItemType Directory -Path ".opencode\skills\$name" -Force | Out-Null
        Write-IfNeeded ".opencode\skills\$name\SKILL.md" $body
    }

    # OpenCode: opencode.json に permission を設定する(後勝ちのため "*" を先頭に置く)
    $opencodeFile = 'opencode.json'
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

    if (-not (Test-Path 'AGENTS.md')) {
        Set-Content 'AGENTS.md' (Get-Content "$tplDir\AGENTS.md" -Raw -Encoding UTF8) -Encoding UTF8NoBOM
        Write-Output "Created: AGENTS.md"
    }

    Write-Output "Finish Complete"
}

Main @args
