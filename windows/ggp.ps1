# ggp - git push origin main
# 元ファイル: shell/ggp.sh

if ($args.Count -gt 0 -and $args[0] -in '-h', '--help') {
    @'
使い方: ggp [git push の引数...] [-h|--help]

git push を実行する。引数を省略すると git push origin main になる。

  ggp
  ggp origin develop
  -h, --help  このヘルプを表示する
'@
    return
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: git is NOT installed"
    exit 1
}

if ($args.Count -eq 0) {
    git push origin main
} else {
    git push $args
}
