#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('stash', 'restore', 'list')]
    [string]$Command,

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Paths
)

$ErrorActionPreference = 'Stop'

$StashDir = Join-Path $HOME '.claude_stash'
$Manifest = Join-Path $StashDir 'manifest.tsv'

function Show-Usage {
    @"
使い方:
  claude_stash.ps1 stash <dir1> [dir2 ...]   # ディレクトリを退避
  claude_stash.ps1 restore [dir1 ...]        # 退避したディレクトリを元に戻す（省略時は全部）
  claude_stash.ps1 list                      # 退避中の一覧を表示

退避先: $StashDir

例:
  claude_stash.ps1 stash secrets\ node_modules\
  claude_stash.ps1 restore secrets\
  claude_stash.ps1 restore
"@ | Write-Host
    exit 1
}

function ConvertTo-StashName {
    param([string]$FullPath)
    $name = $FullPath -replace ':', '_'
    $name = $name -replace '[\\/]', '__'
    return $name
}

function Read-Manifest {
    $entries = @()
    if (-not (Test-Path -LiteralPath $Manifest)) { return $entries }
    Get-Content -LiteralPath $Manifest | ForEach-Object {
        if ($_.Trim().Length -eq 0) { return }
        $parts = $_ -split "`t", 2
        $entries += [PSCustomObject]@{ Stash = $parts[0]; Orig = $parts[1] }
    }
    return $entries
}

function Write-Manifest {
    param([array]$Entries)
    if (-not (Test-Path -LiteralPath $StashDir)) {
        New-Item -ItemType Directory -Path $StashDir -Force | Out-Null
    }
    $lines = $Entries | ForEach-Object { "$($_.Stash)`t$($_.Orig)" }
    Set-Content -LiteralPath $Manifest -Value $lines
}

function Invoke-Stash {
    param([string[]]$Dirs)

    if (-not (Test-Path -LiteralPath $StashDir)) {
        New-Item -ItemType Directory -Path $StashDir -Force | Out-Null
    }
    $entries = Read-Manifest
    $alreadyOrig = @{}
    foreach ($e in $entries) { $alreadyOrig[$e.Orig] = $true }

    foreach ($dir in $Dirs) {
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
            Write-Warning "スキップ（ディレクトリではありません）: $dir"
            continue
        }
        $absOrig = (Resolve-Path -LiteralPath $dir).ProviderPath
        if ($alreadyOrig.ContainsKey($absOrig)) {
            Write-Warning "スキップ（既に退避済み）: $dir"
            continue
        }
        $name = ConvertTo-StashName $absOrig
        $dest = Join-Path $StashDir $name
        if (Test-Path -LiteralPath $dest) {
            Write-Warning "スキップ（退避先が既に存在）: $dest"
            continue
        }
        try {
            Move-Item -LiteralPath $absOrig -Destination $dest -Force
        } catch {
            Write-Warning "移動に失敗しました: $absOrig -> $dest ($($_.Exception.Message))"
            continue
        }
        $entries += [PSCustomObject]@{ Stash = $dest; Orig = $absOrig }
        Write-Host "退避しました: $absOrig -> $dest"
    }
    Write-Manifest $entries
}

function Invoke-Restore {
    param([string[]]$Targets)

    $entries = Read-Manifest
    if ($entries.Count -eq 0) {
        Write-Host "退避中のディレクトリはありません。"
        return
    }

    $remaining = @()
    foreach ($e in $entries) {
        $shouldRestore = $true
        if ($Targets -and $Targets.Count -gt 0) {
            $shouldRestore = $false
            foreach ($t in $Targets) {
                $absT = $null
                if (Test-Path -LiteralPath $t) {
                    $absT = (Resolve-Path -LiteralPath $t).ProviderPath
                }
                if (($absT -and $e.Orig -eq $absT) -or $e.Orig.EndsWith($t.TrimEnd('\', '/'))) {
                    $shouldRestore = $true
                    break
                }
            }
        }

        if ($shouldRestore) {
            if (Test-Path -LiteralPath $e.Orig) {
                Write-Warning "スキップ（復元先に既に何かあります）: $($e.Orig)"
                $remaining += $e
                continue
            }
            if (-not (Test-Path -LiteralPath $e.Stash)) {
                Write-Warning "警告: 退避先が見つかりません: $($e.Stash)（マニフェストから削除します）"
                continue
            }
            $parent = Split-Path -Parent $e.Orig
            if ($parent -and -not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            try {
                Move-Item -LiteralPath $e.Stash -Destination $e.Orig -Force
            } catch {
                Write-Warning "復元に失敗しました: $($e.Stash) -> $($e.Orig) ($($_.Exception.Message))"
                $remaining += $e
                continue
            }
            Write-Host "復元しました: $($e.Stash) -> $($e.Orig)"
        } else {
            $remaining += $e
        }
    }
    Write-Manifest $remaining
}

function Show-List {
    $entries = Read-Manifest
    if ($entries.Count -eq 0) {
        Write-Host "退避中のディレクトリはありません。"
        return
    }
    foreach ($e in $entries) {
        Write-Host $e.Orig
        Write-Host "  -> $($e.Stash)"
    }
}

switch ($Command) {
    'stash' {
        if (-not $Paths -or $Paths.Count -eq 0) { Show-Usage }
        Invoke-Stash -Dirs $Paths
    }
    'restore' { Invoke-Restore -Targets $Paths }
    'list'    { Show-List }
    default   { Show-Usage }
}

