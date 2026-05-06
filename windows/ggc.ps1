# ggc - git add . && git commit
# 元ファイル: shell/ggc.sh
# 使い方: ggc  または  ggc "メッセージ1" "メッセージ2"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: git is not installed"
    exit 1
}

if ($args.Count -eq 0) {
    $msg = "update"
} else {
    $msg = $args -join "`n"
}

git add .
git commit -m $msg
