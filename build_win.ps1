# windows/ にある .ps1 スクリプトを .bin_win/ へコピーする。
# 使い方: .\build_win.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$winDir    = Join-Path $scriptDir "windows"
$binDir    = Join-Path $scriptDir ".bin_win"

if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

foreach ($f in Get-ChildItem -Path $winDir -Filter "*.ps1") {
    $dest = Join-Path $binDir $f.Name
    Copy-Item -Path $f.FullName -Destination $dest -Force
}

Write-Host "完了: $binDir"
