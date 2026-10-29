# update-agents-and-git: コミット方法を git-commit に揃える

## 概要
`update-agents-and-git` skill のコミットメッセージ規約と注意事項を、`git-commit` skill と同じ内容にする。2つの skill でコミットの書式が食い違わないようにするため。

## 調査結果
- 対象は `templates/init_claude/skill/update-agents-and-git.md` のみ
- `templates/init_claude/skill/git-commit.md` との差分は「コミットメッセージ」節
  - git-commit: 1行目は50文字以内で prefix(feat/fix/refactor/docs/test/chore)必須、2行目は空行、3行目以降は「なぜ」を `- ` の箇条書きで1〜3項目(1項目1行)
  - update-agents-and-git: 1行目は50文字程度、prefix の指定なし、補足は必要な場合のみ自由記述
- 「注意」節(秘密情報の除外、無関係な変更の分離、push しない)と `allowed-tools` のコミット関連部分は両者で同一
- `.claude/skills/*` と `.opencode/skills/*` は init_claude の生成物(`name:` が補われるだけ)なので直接編集しない

## 実装計画
- [x] ステップ1: 「コミットメッセージ」節を git-commit.md と同じ文面に置き換える(`templates/init_claude/skill/update-agents-and-git.md`)
- [x] ステップ2: 手順3の「`AGENTS.md` を含む変更を `git add` して、1つのコミットにまとめる」はそのまま維持する(AGENTS.md 更新が主目的のため)
- [x] ステップ3: 「注意」「報告」節・`allowed-tools` は変更しない

## テスト・確認方法
- [x] `diff` で両ファイルの「コミットメッセージ」節が一致することを確認する
- [ ] 変更後に `init_claude --update` で生成物に反映されることを確認する(必要なら build)

## 決定事項
- 修正は `update-agents-and-git.md` の「コミットメッセージ」節のみ
- 手順(AGENTS.md の更新→1コミット)は update-agents-and-git 固有のため残す

## 懸念点・未決事項
- 「1つのコミットにまとめる」と git-commit の「関係ない変更は分ける」が競合する場面がある。現状は注意節の「分けるか確認する」で足りる想定
- 既存の生成物(`.claude/skills/update-agents-and-git`)は `--update` するまで古いまま
