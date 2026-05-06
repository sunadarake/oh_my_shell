# nt - todoディレクトリに連番のtodoファイルを作成
# 元ファイル: perl/nt.pl
# 使い方: nt [ファイル名 [枚数]]  または  nt [枚数]

$baseFile = $null
$count = 1

if ($args.Count -ge 1 -and $args[0] -notmatch '^\d+$') {
    # ファイル名モード
    $baseFile = $args[0]
    $count = 3
    if ($args.Count -eq 2) {
        if ($args[1] -notmatch '^\d+$' -or [int]$args[1] -eq 0) {
            Write-Error "エラー: 正の整数を指定してください。"
            exit 1
        }
        $count = [int]$args[1]
    } elseif ($args.Count -gt 2) {
        Write-Error "Usage: nt [ファイル名 [枚数]]"
        exit 1
    }
} else {
    # todoディレクトリモード
    if ($args.Count -eq 1) {
        if ($args[0] -notmatch '^\d+$' -or [int]$args[0] -eq 0) {
            Write-Error "エラー: 正の整数を指定してください。"
            exit 1
        }
        $count = [int]$args[0]
    } elseif ($args.Count -gt 1) {
        Write-Error "Usage: nt [枚数]"
        exit 1
    }
}

if ($baseFile) {
    # ファイル名モード: 拡張子の前に -001 -002 ... を挿入
    if ($baseFile -match '^(.*?)(\.[^.\\]+)?$') {
        $stem = $Matches[1]
        $ext  = if ($Matches[2]) { $Matches[2] } else { '' }
    }
    for ($i = 1; $i -le $count; $i++) {
        $filename = "{0}-{1:D3}{2}" -f $stem, $i, $ext
        New-Item -ItemType File -Path $filename -Force | Out-Null
        Write-Output "Created: $filename"
    }
} else {
    # todoディレクトリモード
    $cwd = (Get-Location).Path
    $todoDir = $null

    if ((Split-Path $cwd -Leaf) -eq 'todo') {
        $todoDir = $cwd
    } elseif (Test-Path (Join-Path $cwd 'todo') -PathType Container) {
        $todoDir = Join-Path $cwd 'todo'
    }

    if (-not $todoDir) {
        Write-Error "エラー: todoディレクトリが見つかりません。`nカレントディレクトリが todo、または１つ上に todo ディレクトリが必要です。"
        exit 1
    }

    $existing = Get-ChildItem -Path $todoDir -Recurse -File |
        Where-Object { $_.Name -match '^\d{3}-todo\.md$' } |
        ForEach-Object { [int]($_.Name -replace '-todo\.md', '') }

    $next = 1
    if ($existing) {
        $next = ($existing | Measure-Object -Maximum).Maximum + 1
    }

    for ($i = 0; $i -lt $count; $i++) {
        $filename = Join-Path $todoDir ("{0:D3}-todo.md" -f ($next + $i))
        New-Item -ItemType File -Path $filename -Force | Out-Null
        Write-Output "Created: $filename"
    }
}
