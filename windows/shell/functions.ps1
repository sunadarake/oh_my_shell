# 元ファイル: unix/shell/functions.sh - mkcd と cd 拡張などのシェル関数を定義する($PROFILE から dot-source して使う)
# . "C:\path\to\oh_my_shell\windows\shell\functions.ps1"

# ディレクトリを作成して移動する
function mkcd {
    if ($args.Count -ne 1) {
        Write-Error "使い方: mkcd <dir>"
        return
    }
    New-Item -ItemType Directory -Path $args[0] -Force | Out-Null
    Set-Location -LiteralPath $args[0]
}

# cd N で ../ を N 回上る(同名ディレクトリがあればそちらを優先)
# エイリアス cd は関数より優先されるため、先に削除する
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
function cd {
    if ($args.Count -eq 1 -and $args[0] -match '^\d+$' -and -not (Test-Path -LiteralPath $args[0] -PathType Container)) {
        $up = '..\' * [int]$args[0]
        if ($up) { Set-Location $up }
    } else {
        Set-Location @args
    }
}

# よく使うディレクトリへ移動
function cdd { Set-Location ~\Documents }
function cdp { Set-Location ~\Pictures }
function cdv { Set-Location ~\Videos }
function cdl { Set-Location ~\Downloads }
