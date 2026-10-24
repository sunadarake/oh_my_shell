# dcp - コピー元と同じディレクトリにファイルをコピーする
# 使い方: dcp C:\path\to\sample.py 001_oreore.py
#   コピー先の拡張子を省略した場合は、コピー元の拡張子を自動的に付加する
#   例: dcp C:\path\to\sample.py 001_oreore  ->  C:\path\to\001_oreore.py

param(
    [string]$Source,
    [string]$NewName,
    [Alias('h')][switch]$Help
)

if ($Help -or $Source -eq '--help') {
    @'
使い方: dcp <コピー元ファイル> <新しい名前> [-h|--help]

コピー元と同じディレクトリにファイルをコピーする。
新しい名前に拡張子が無ければ、コピー元の拡張子を付ける。

  dcp C:\path\to\sample.py 001_oreore.py
  dcp C:\path\to\sample.py 001_oreore   (-> C:\path\to\001_oreore.py)
  -h, --help  このヘルプを表示する
'@
    return
}

if (-not $Source -or -not $NewName) {
    Write-Error "使い方: dcp <コピー元ファイル> <新しい名前>"
    exit 1
}

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    Write-Error "dcp: no such file: $Source"
    exit 1
}

$srcItem = Get-Item -LiteralPath $Source
$dir = $srcItem.DirectoryName
$srcExt = $srcItem.Extension

# 新しい名前に拡張子が無ければ、コピー元の拡張子を付ける
if (-not [System.IO.Path]::HasExtension($NewName) -and $srcExt) {
    $NewName = "$NewName$srcExt"
}

$dest = Join-Path $dir $NewName

if (Test-Path -LiteralPath $dest) {
    $answer = Read-Host "overwrite $dest? [y/N]"
    if ($answer -ne "y") {
        exit 1
    }
}

Copy-Item -LiteralPath $Source -Destination $dest
Write-Host "copied: $Source -> $dest"
