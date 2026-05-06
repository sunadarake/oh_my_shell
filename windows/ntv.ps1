# ntv - todoディレクトリの最新todoファイルをvimで開く
# 元ファイル: perl/ntv.pl
# 使い方: ntv

if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    Write-Error "エラー: vim が見つかりません。vim がインストールされていることを確認してください。"
    exit 1
}

$cwd = (Get-Location).Path
$todoDir = $null

if ((Split-Path $cwd -Leaf) -eq 'todo') {
    $todoDir = $cwd
} elseif (Test-Path (Join-Path $cwd 'todo') -PathType Container) {
    $todoDir = Join-Path $cwd 'todo'
}

if (-not $todoDir) {
    Write-Error "エラー: todoディレクトリが見つかりません。`nカレントディレクトリが todo、または1つ上に todo ディレクトリが必要です。"
    exit 1
}

$todoFiles = Get-ChildItem -Path $todoDir -Recurse -File |
    Where-Object { $_.Name -match '^\d{3}-todo\.md$' } |
    Sort-Object { [int]($_.Name -replace '-todo\.md', '') }

$targetFile = $null

if ($todoFiles) {
    $latest = $todoFiles[-1]
    $content = Get-Content $latest.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content -or $content -notmatch '\S') {
        $targetFile = $latest.FullName
        Write-Output "最新のtodoファイルが空のため、それを開きます: $targetFile"
    } else {
        $num = [int]($latest.Name -replace '-todo\.md', '')
        $targetFile = Join-Path $todoDir ("{0:D3}-todo.md" -f ($num + 1))
        New-Item -ItemType File -Path $targetFile -Force | Out-Null
        Write-Output "新しいtodoファイルを作成しました: $targetFile"
    }
} else {
    $targetFile = Join-Path $todoDir '001-todo.md'
    New-Item -ItemType File -Path $targetFile -Force | Out-Null
    Write-Output "新しいtodoファイルを作成しました: $targetFile"
}

Write-Output "vim で開きます: $targetFile"
& vim $targetFile
