#!/usr/bin/env pwsh
# oh_my_shell Windows ビルドスクリプト
# shell/ のシェルスクリプトを .bin_win/ にコピーし、busybox64u 経由で実行する .ps1 ファイルを生成
# perl/ の Perl スクリプトを .bin_win/ にコピーし、perl -CAS 経由で実行する .ps1 ファイルを生成

# ディレクトリ設定
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$shellDir = Join-Path $scriptDir "shell"
$perlDir = Join-Path $scriptDir "perl"
$binDir = Join-Path $scriptDir ".bin_win"

# ビルドディレクトリ作成
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

# シェルスクリプトを処理
$shFiles = Get-ChildItem -Path $shellDir -Filter "*.sh" -ErrorAction SilentlyContinue

if ($shFiles.Count -eq 0) {
    Write-Host "警告: $shellDir に .sh ファイルが見つかりません" -ForegroundColor Yellow
}

foreach ($shFile in $shFiles) {
    $basename = $shFile.BaseName
    $targetSh = Join-Path $binDir "$basename.sh"
    $targetPs1 = Join-Path $binDir "$basename.ps1"

    # .sh ファイルをコピー
    Copy-Item -Path $shFile.FullName -Destination $targetSh -Force

    # .ps1 ファイルを生成（busybox64u 経由で .sh を実行）
    $ps1Content = @"
`$scriptPath = Join-Path `$PSScriptRoot "$basename.sh"
busybox64u sh `$scriptPath @args
"@

    Set-Content -Path $targetPs1 -Value $ps1Content -Encoding UTF8 

    Write-Host "生成: $basename.ps1 -> $basename.sh"
}

# Perlスクリプトを処理
$plFiles = Get-ChildItem -Path $perlDir -Filter "*.pl" -ErrorAction SilentlyContinue

if ($plFiles.Count -eq 0) {
    Write-Host "警告: $perlDir に .pl ファイルが見つかりません" -ForegroundColor Yellow
}

foreach ($plFile in $plFiles) {
    $basename = $plFile.BaseName
    $targetPl = Join-Path $binDir "$basename.pl"
    $targetPs1 = Join-Path $binDir "$basename.ps1"

    # .pl ファイルをコピー
    Copy-Item -Path $plFile.FullName -Destination $targetPl -Force

    # .ps1 ファイルを生成（perl -CAS 経由で .pl を実行）
    $ps1Content = @"
`$scriptPath = Join-Path `$PSScriptRoot "$basename.pl"
perl -CAS `$scriptPath @args
"@

    Set-Content -Path $targetPs1 -Value $ps1Content -Encoding UTF8

    Write-Host "生成: $basename.ps1 -> $basename.pl"
}

# 結果表示
Write-Host ""
Write-Host "ビルド完了" -ForegroundColor Green
Write-Host ""
Write-Host "使用するには以下を環境変数 PATH に追加してください:"
Write-Host ""
Write-Host "  $binDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "または PowerShell プロファイルに以下を追加:"
Write-Host ""
Write-Host "  `$env:PATH = `"$binDir;`$env:PATH`"" -ForegroundColor Cyan
Write-Host ""
