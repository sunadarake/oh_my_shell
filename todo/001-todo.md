# 002-todo.md: unix/ への移植（POSIX sh）

## 方針

- shebang: `#!/bin/sh`
- bash固有構文は使わない
- 元ファイルを読み込み → 動作を理解 → POSIX sh で書き直す
- ファイル冒頭に元ファイル名と用途をコメントで記載する

## タスク: shell/ → unix/

- [x] `shell/ccc.sh`       → `unix/ccc.sh`
- [x] `shell/dd.sh`        → `unix/dd.sh`
- [x] `shell/ggc.sh`       → `unix/ggc.sh`
- [x] `shell/ggf.sh`       → `unix/ggf.sh`
- [x] `shell/ggp.sh`       → `unix/ggp.sh`
- [x] `shell/memo.sh`      → `unix/memo.sh`
- [x] `shell/oo.sh`        → `unix/oo.sh`
- [x] `shell/open-webui.sh` → `unix/open-webui.sh`
- [x] `shell/tre.sh`       → `unix/tre.sh`
- [x] `shell/tt.sh`        → `unix/tt.sh`
- [x] `shell/update-chrome.sh` → `unix/update-chrome.sh`
- [x] `shell/vv.sh`        → `unix/vv.sh`
- [x] `shell/vvp.sh`       → `unix/vvp.sh`
- [x] `shell/vvu.sh`       → `unix/vvu.sh`

## タスク: perl/ → unix/

- [x] `perl/az.pl`         → `unix/az.sh`
- [x] `perl/init_claude.pl` → `unix/init_claude.sh`
- [x] `perl/nt.pl`         → `unix/nt.sh`
- [x] `perl/ntv.pl`        → `unix/ntv.sh`

Perlでは Xライブラリを使っている。 doc/X.md を見ること。

## 完了条件

- `unix/` 配下に全スクリプトが存在する
- 各スクリプトが `#!/bin/sh` で始まる
- bash固有構文が含まれていない
