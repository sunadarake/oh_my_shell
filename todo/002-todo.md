# 003-todo.md: windows/ への移植（PowerShell）

## 方針

- 拡張子: `.ps1`
- PowerShell 5.1 / 7.x 両対応
- Unix系コマンドは使わず PowerShell ネイティブで実装する
- 文字コード: UTF-8 (BOM なし)
- ファイル冒頭に元ファイル名と用途をコメントで記載する

## タスク: shell/ → windows/

- [x] `shell/ccc.sh`       → `windows/ccc.ps1`
- [x] `shell/dd.sh`        → `windows/dd.ps1`
- [x] `shell/ggc.sh`       → `windows/ggc.ps1`
- [x] `shell/ggf.sh`       → `windows/ggf.ps1`
- [x] `shell/ggp.sh`       → `windows/ggp.ps1`
- [x] `shell/memo.sh`      → `windows/memo.ps1`
- [x] `shell/oo.sh`        → `windows/oo.ps1`
- [x] `shell/open-webui.sh` → `windows/open-webui.ps1`
- [x] `shell/tre.sh`       → `windows/tre.ps1`
- [x] `shell/tt.sh`        → `windows/tt.ps1`
- [x] `shell/update-chrome.sh` → `windows/update-chrome.ps1`
- [x] `shell/vv.sh`        → `windows/vv.ps1`
- [x] `shell/vvp.sh`       → `windows/vvp.ps1`
- [x] `shell/vvu.sh`       → `windows/vvu.ps1`

## タスク: perl/ → windows/

- [x] `perl/az.pl`         → `windows/az.ps1`
- [x] `perl/init_claude.pl` → `windows/init_claude.ps1`
- [x] `perl/nt.pl`         → `windows/nt.ps1`
- [x] `perl/ntv.pl`        → `windows/ntv.ps1`

Perlでは Xライブラリを使っている。 doc/X.md を見ること。

## 完了条件

- `windows/` 配下に全スクリプトが存在する
- 各ファイルの拡張子が `.ps1` である
- Unix系コマンドが使われていない
- 文字コードが UTF-8 (BOM なし) である
