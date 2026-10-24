# todo-refine コマンドの追加

## 概要
`/todo-plan` で作った TODO ファイルを元に、質問したり、仕様・計画をさらに詰めたりするコマンド `/todo-refine` を追加する。引数で TODO 番号またはファイルパスを指定でき、省略時は直前に更新された TODO ファイルを対象にする。

## 調査結果
- コマンドは `templates/init_claude/commands/*.md` に置くだけで、`todo-` を前置きしたファイル名がそのままコマンド名になる（`todo-plan.md` → `/todo-plan`）
- `windows/init_claude.ps1` は `commands` 配下の `*.md` を全部コピーするため、スクリプトの修正は不要（`unix` 側は build で `.bin*/templates` にコピーされる）
- `templates/init_claude/commands/todo-do.md` に「番号 / パス / 省略」の3通りで対象を決める手順がある。同じ形式を使える
- `templates/init_claude/commands/todo-plan.md` の上書きモードは、計画を新規に立て直す用途。今回は「既存計画の質問・追記」で用途が違う
- `templates/init_claude/AGENTS.md` の `todo/` の説明に `/todo-plan` のみ記載。必要なら追記を検討する

## 実装計画
- [x] ステップ1: `templates/init_claude/commands/todo-refine.md` を作成する。frontmatter は `description` / `argument-hint: [TODO番号 | TODOファイルパス（省略時は直前に更新したもの）]` / `allowed-tools: Bash(ls:*), Read, Glob, Grep, Edit, AskUserQuestion`
- [x] ステップ2: 対象の決め方を書く。パス指定ならそのファイル、番号なら `todo/NNN-todo.md`（3桁ゼロ埋め）、省略なら `ls -t todo/` の先頭（更新日時が最新）。一覧は `` !`ls -t todo/ | head -5` `` で渡す
- [x] ステップ3: 手順を書く。TODO を読む → ユーザーの質問に答える／不明点を AskUserQuestion で聞く → 決まったことを「決定事項」に追記し、「実装計画」「テスト・確認方法」「懸念点・未決事項」を必要な範囲で修正する
- [x] ステップ4: ルールを書く。コードは実装しない。チェック済み `[x]` は保持する。決まっていないことは書かない。解決した懸念点は「決定事項」に移す
- [x] ステップ5: 報告の形式を書く（対象ファイル、変更した箇所の要約、残った未決事項）
- [x] ステップ6: `templates/init_claude/AGENTS.md` の `todo/` の説明に `/todo-refine` を追記するか確認し、必要なら修正する

## テスト・確認方法
- [x] frontmatter と本文の構成が `todo-do.md` / `todo-plan.md` と揃っていることを目視で確認する
- [x] `init_claude` を一時ディレクトリで実行し、`.claude/commands/todo-refine.md` が作成されることを確認する（unix のみ確認済み。windows は pwsh がなく未実行）
- [ ] `/todo-refine`（引数なし・番号・パス）で対象ファイルが期待どおり選ばれることを確認する

## 決定事項
- コマンド名は `todo-refine`
- 引数なしの対象は、更新日時が最新のファイル（`ls -t todo/` の先頭）
- TODO は、決まった内容だけを追記・修正する（`[x]` は保持、コードは実装しない）

## 懸念点・未決事項
- `ls -t | head` を使うため、`allowed-tools` に `Bash(head:*)` を追加した（計画のステップ1にはなかった）
- `ls -t` は更新日時で選ぶため、git checkout などでファイルの日時が変わると、直前の todo-plan 対象とずれる可能性がある
- OpenCode 向けにコピーされるコマンドは `argument-hint` / `allowed-tools` が除かれる。動作に問題ないかは未確認
