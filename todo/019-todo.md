# git-commit テンプレートの本文を箇条書きにする

## 概要
`git-commit` skill のテンプレートで、コミットメッセージの本文（3行目以降）を `- ` で始まる箇条書きで書くよう指示する。

## 調査結果
- 雛形: `templates/init_claude/skill/git-commit.md`。「コミットメッセージ」節に「3行目以降に「なぜ」を1〜3行で書く」とある
- このリポジトリ自身の `.claude/skills/git-commit/SKILL.md` と `.opencode/skills/git-commit/SKILL.md` は init_claude の生成物（雛形に `name:` を足しただけ。OpenCode 側は `allowed-tools` 等が除かれる）
- `unix/init_claude.pl` / `windows/init_claude.ps1` は雛形を読むだけなので変更不要

## 実装計画
- [x] ステップ1: `templates/init_claude/skill/git-commit.md` の「3行目以降に「なぜ」を1〜3行で書く」を「3行目以降は「なぜ」を `- ` で始まる箇条書きで1〜3項目書く（1項目1行）」に変更する
- [x] ステップ2: `perl unix/init_claude.pl --update` を実行し、`.claude/skills/git-commit/SKILL.md` と `.opencode/skills/git-commit/SKILL.md` を再生成する（他の生成物に差分が出ないか `git diff` で確認）
- [x] ステップ3: README.md に git-commit のメッセージ形式の記述があれば合わせて直す（なければ変更なし）

## テスト・確認方法
- [x] 雛形と `.claude` / `.opencode` 側の skill で、該当行が同じ文言になっている
- [x] `diff templates/init_claude/skill/git-commit.md .claude/skills/git-commit/SKILL.md` の差が `name:` 行のみ
- [x] 他の skill に意図しない差分が出ていない

## 決定事項
- 1行目（prefix 付き要約）と2行目の空行は変更しない
- 項目数は従来の行数に合わせ 1〜3 項目とする

## 懸念点・未決事項
- 項目数の上限（1〜3）を変えたい場合は要調整
