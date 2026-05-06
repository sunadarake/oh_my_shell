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
    param([string]$Dir, [string]$Prefix, [string[]]$Ignore)

    $items = Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue |
        Where-Object { $name = $_.Name; -not ($Ignore | Where-Object { $name -like $_ }) } |
        Sort-Object Name

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $last   = $i -eq ($items.Count - 1)
        $branch = if ($last) { "└── " } else { "├── " }
        $ext    = if ($last) { "    " } else { "│   " }
        Write-Host "$Prefix$branch$($item.FullName)"
        if ($item.PSIsContainer) {
            Show-Tree -Dir $item.FullName -Prefix "$Prefix$ext" -Ignore $Ignore
        }
    }
}

$root = (Resolve-Path $Path).Path
Write-Host $root
Show-Tree -Dir $root -Prefix "" -Ignore $ignore
