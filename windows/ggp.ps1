# ggp - git push origin main
# 元ファイル: shell/ggp.sh

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: git is NOT installed"
    exit 1
}

if ($args.Count -eq 0) {
    git push origin main
} else {
    git push $args
}
