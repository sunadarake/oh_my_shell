# init_claude のコマンド生成を skill 生成に変更

## 概要
`init_claude` は現在 `templates/init_claude/commands/*.md` から `.claude/commands/*.md` と `.opencode/commands/*.md` を生成している。これを skill 形式に変更する。`templates/init_claude/skill/todo-plan.md` があれば `.claude/skills/todo-plan/SKILL.md` として生成する。

## 調査結果
- `unix/init_claude.pl` : `%commands` に `commands/*.md` を読み込み、`.claude/commands/` と `.opencode/commands/` に `put` で書く。OpenCode 側は `argument-hint` / `allowed-tools` 行を除き `CLAUDE.md`→`AGENTS.md` に置換している
- `windows/init_claude.ps1` : 同じ処理を PowerShell で実装（`$slashCommands`、`$commandsDir`、`$ocCommandsDir`）
- テンプレートは `templates/init_claude/commands/` に15ファイル。frontmatter は `description` / `argument-hint` / `allowed-tools` のみで `name` がない（skill には `name` が必要）
- 本文の `$ARGUMENTS` や `` !`...` `` は skill でも同じ書き方で使える。テンプレート本文の変更は不要
- `build_unix.sh` / `build_win.ps1` は `templates` ディレクトリごとコピーするので変更不要（要確認）
- README.md 95行付近に init_claude の説明がある。`commands` の記述があれば更新する
- このリポジトリ自身の `.claude/commands/` と `.opencode/commands/` は init_claude の生成物（git 管理されている）

## 実装計画
- [x] ステップ1: `git mv templates/init_claude/commands templates/init_claude/skill` で15ファイルを移す（`commands/` は廃止）
- [x] ステップ2: `unix/init_claude.pl` を修正する。`skill/*.md` を読み込み、ファイル名（拡張子なし）を skill 名とする。frontmatter 先頭の `---` の直後に `name: <名>` を差し込んだ内容を、`.claude/skills/<名>/SKILL.md` に `make_path` してから `put` する。ヘルプ・冒頭コメントの「commands」を「skills」に直す
- [x] ステップ3: 同じく OpenCode 側を `.opencode/skills/<名>/SKILL.md` に変更する（`name` 付与、`argument-hint` / `allowed-tools` 除去、`CLAUDE.md`→`AGENTS.md` 置換は従来どおり）
- [x] ステップ4: `windows/init_claude.ps1` に同じ変更を行う（`Get-ChildItem "$tplDir\skill" -Filter '*.md'`、`.claude\skills\<名>\SKILL.md`、`.opencode\skills\<名>\SKILL.md`、ヘルプ文言）。UTF-8 BOM なし・PS 5.1/7.x 両対応を保つ
- [x] ステップ5: `README.md` の init_claude の説明に skill 生成と、旧 `.claude/commands/` は自動削除されない旨を追記する
- [x] ステップ6: `templates/init_claude/AGENTS.md` と、このリポジトリの `AGENTS.md` に `commands` への言及があれば skill に直す
- [x] ステップ7: このリポジトリで `perl unix/init_claude.pl --update` を実行して `.claude/skills/` と `.opencode/skills/` を生成し、旧 `.claude/commands/` と `.opencode/commands/` を `git rm` する

## テスト・確認方法
- [x] 一時ディレクトリで `init_claude` を実行し、`.claude/skills/todo-plan/SKILL.md` が作られ、先頭に `name: todo-plan` があることを確認する
- [x] `.opencode/skills/todo-plan/SKILL.md` に `argument-hint` / `allowed-tools` が無く、`CLAUDE.md` が `AGENTS.md` になっていることを確認する
- [x] `--update` ありで `Updated:` になることを確認（なしの再実行は未確認）
- [x] `.claude/commands` / `.opencode/commands` が新規には作られないことを確認する
- [ ] Claude Code で `/todo-plan` が skill として呼び出せることを確認する
- [x] windows 版は pwsh がなく未実行。目視で unix 版と突き合わせた

## 決定事項
- テンプレートは `templates/init_claude/skill/` に `git mv` し、`commands/` は廃止する
- `name:` はテンプレートに書かず、生成時にファイル名から差し込む
- OpenCode 側も `.opencode/skills/<名>/SKILL.md` に変更する
- 既存プロジェクトの古い `.claude/commands/*.md` は `--update` でも削除しない（手動削除。同名があると commands が優先される可能性を README に注記）

## 懸念点・未決事項
- テンプレートの frontmatter に `name` が既にある場合の扱い（現状は全ファイルに無いので、差し込みのみで足りる想定）
- OpenCode の skill が `argument-hint` 以外のキー（`description` 必須）を問題なく読めるか、実機で未確認
- `$ARGUMENTS` が OpenCode の skill で展開されるかは不明。展開されない場合は OpenCode 側の引数まわりに `TODO:` を残す
- windows 版は実行環境がなく動作確認できない可能性がある
