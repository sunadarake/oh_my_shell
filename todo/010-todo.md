# unix/init_claude.pl と windows/init_claude.ps1 の変更

これらのコマンドは
.claude/commands にコマンドを追加できるようになっている。

以下のように変更してほしい


## ask.md の追加

```markdown
---
description: Claudeに質問する(日本語で簡潔に回答)
argument-hint: [質問内容]
---

次の質問に、日本語でわかりやすく簡潔に答えてください。
専門用語は必要最小限にし、必要なら短い例を添えてください。
コードの変更やファイル編集はせず、回答のみ行ってください。

質問: $ARGUMENTS
```

## .claude/commands/update-claude-md.md の変更

```markdown
---
description: これまでの変更を踏まえてCLAUDE.mdを更新する
---

このセッションでの変更を踏まえて、`CLAUDE.md` を実態に合わせて更新してください。

- 変更された仕様・コマンド・ディレクトリ構成を反映する
- 古くなった記述は削除または修正する
- 既存の構成やトーンは維持し、差分は最小限にする

編集する前に、何を直すかの要点を一覧で見せてください。
```

## .claude/commands/git-commit.md の変更

```markdown
---
description: ここまでの変更をgit commitする
---

ここまでの変更を `git commit` してください。

- コミットメッセージは、日本語で簡潔かつ分かりやすく書いてください。
- 変更内容が一目で分かる1行目(50文字程度)にしてください。必要な場合のみ、空行のあとに補足を書いてください。

```
