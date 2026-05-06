# tre - ディレクトリツリーを表示（ビルドディレクトリを自動除外）
# 元ファイル: shell/tre.sh
# 使い方: tre [-I <pattern>] [path]
param(
    [string[]]$I = @(),
    [string]$Path = "."
)
$ignore = @(
    'node_modules', '.dart_tool', '.flutter-plugins', '.flutter-plugins-dependencies',
    '__pycache__', '.venv', 'venv', 'env', '*.egg-info', '.pytest_cache',
    'vendor',
    'blib', '.build', 'local',
    'build', 'dist', 'out', 'target', 'cmake-build-*',
    '.next', '.nuxt', '.cache',
    '.gradle', 'Pods', 'DerivedData',
    '.git',
    '.vscode', '.claude', '.zed',
    'android', 'linux', 'ios', 'win', 'web',
    'todo'
) + $I

function Show-Tree {
    param([string]$Dir, [string]$Prefix, [string[]]$Ignore, [string]$Root)
    $items = Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue |
        Where-Object { $name = $_.Name; -not ($Ignore | Where-Object { $name -like $_ }) } |
        Sort-Object Name
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $last   = $i -eq ($items.Count - 1)
        $branch = if ($last) { "└── " } else { "├── " }
        $ext    = if ($last) { "    " } else { "│   " }
        $rel    = [System.IO.Path]::GetRelativePath($Root, $item.FullName)
        if ($item.PSIsContainer) {
            Write-Host "$Prefix$branch$rel" -ForegroundColor Blue
            Show-Tree -Dir $item.FullName -Prefix "$Prefix$ext" -Ignore $Ignore -Root $Root
        } else {
            Write-Host "$Prefix$branch$rel"
        }
    }
}

$root = (Resolve-Path $Path).Path
Write-Host $root -ForegroundColor Cyan
Show-Tree -Dir $root -Prefix "" -Ignore $ignore -Root $root
