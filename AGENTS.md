# CLAUDE.md

## プロジェクト概要

便利スクリプト集。

- `unix/` : Linux/Mac向け、bash  or Perlで記述
- `windows/` : Windows向け、PowerShell7 で記述

## ディレクトリ構成

```
.
├── templates/   # init_claude が読み込む雛形 (build で .bin*/templates にコピー)
├── unix/        # bash スクリプト or perlスクリプト
│   └── shell/   # ~/.bashrc から source するシェル関数 (build_unix.sh の対象外)
└── windows/     # PowerShell スクリプト
    └── shell/   # $PROFILE から dot-source する関数 (build_win.ps1 の対象外)
```

### 共通

- 各スクリプトは独立している（相互依存なし）。ただし init_claude は `templates/` を読み込む（build で `.bin*/templates` にコピーされる）
- skill の雛形は `templates/init_claude/skill/<名>.md` に置く。init_claude が `name:` を補って `.claude/skills/<名>/SKILL.md` と `.opencode/skills/<名>/SKILL.md` を生成する
- init_claude は `--update` (PowerShell は `-Update`) で settings.json / skills / opencode.json を上書きする。AGENTS.md は上書きしない
- 機能・動作は元スクリプトと同等にすること
- スクリプト冒頭にコメントで説明を3行程度記載すること(概要1行 + 使い方の例。元ファイルがある場合は元ファイル名も)
- すべてのスクリプトに `-h` / `--help` オプションを実装すること

### unix/ (bash)

- bash スクリプトの shebang は `#!/bin/bash` を使用(`build_unix.sh` は `#!/bin/sh`)
- 文字列処理は `sed` / `awk` / `cut` などの標準ツールを使う
- Perl スクリプト(`.pl`)も `unix/` に置き、`build_unix.sh` が拡張子なしで `.bin/` へコピーする
- `cd` のように親シェルへ作用する関数は `unix/shell/functions.sh` に定義し、`~/.bashrc` で source する(bash のみ対応)

### windows/ (PowerShell)

- 拡張子は `.ps1`
- PowerShell 5.1 および 7.x 両対応を意識する
- Unix系コマンド（`grep`, `awk` 等）は使わず、PowerShell ネイティブのコマンドレットで実装する
- 文字コードは UTF-8 (BOM なし) を基本とする
- `cd` のように親シェルへ作用する関数は `windows/shell/functions.ps1` に定義し、`$PROFILE` で dot-source する

## 作業上の注意

- 移植できない・判断が難しい箇所があれば、コメントに `TODO:` を残す
- 移植元(コメントの「元ファイル」)はこのリポジトリにない。移植時は元の動作を変えない

## プロジェクトの取り組み方について

* なるべくコードやコメントをシンプルに簡潔にすること。 
* コメントはUTF-8の日本語で書くこと。 
* 問題に取り組む前に、コードや仕様を読んで理解すること。
