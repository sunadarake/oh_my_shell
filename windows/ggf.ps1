# ggf - git pull origin main
# 元ファイル: shell/ggf.sh

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: git is NOT installed"
    exit 1
}

if ($args.Count -ne 0) {
    Write-Error "ERROR: ggf は引数を受け取りません`nもしかして ggc と間違えていませんか？"
    exit 1
}

git pull origin main
