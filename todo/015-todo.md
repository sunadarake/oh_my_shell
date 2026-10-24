# init_claude に --update オプションを追加する

## 概要
`init_claude --update` を指定したとき、既存の設定・コマンドファイルを上書きして最新テンプレートに更新する。`AGENTS.md` はユーザーが編集する前提のため上書きしない。

## 調査結果
- `unix/init_claude.pl` / `windows/init_claude.ps1` の2本。現状 `--update` 等の引数処理は無い。
- 各ファイルは `unless (-f ...)` / `if (-not (Test-Path ...))` で「未作成のときのみ」生成している。対象:
  - `.claude/settings.json`
  - `.claude/commands/*.md`（`templates/init_claude/commands/` から）
  - `.opencode/commands/*.md`（argument-hint / allowed-tools 除去、CLAUDE.md→AGENTS.md 置換）
  - `opencode.json`
  - `AGENTS.md`（`templates/init_claude/AGENTS.md`）
- ビルドで `.bin/init_claude`、`.bin/templates` にコピーされる（ビルド成果物は直接編集しない）。

## 実装計画
- [x] ステップ1: Perl に引数処理を追加。`my $update = grep { $_ eq '--update' } @ARGV;`（`unix/init_claude.pl`）
- [x] ステップ2: settings.json / .claude/commands / .opencode/commands / opencode.json の存在チェックを `unless (-f $file)` → `if ($update || !-f $file)` に変更。上書き時は `Updated:`、新規時は `Created:` と表示を分ける（`unix/init_claude.pl`）
- [x] ステップ3: AGENTS.md は従来どおり未作成時のみ生成（`--update` でも変更しない）（`unix/init_claude.pl`）
- [x] ステップ4: PowerShell に `param([switch]$Update)` を追加し、同じ条件に変更（`windows/init_claude.ps1`）
- [x] ステップ5: 使い方コメントを更新（`# 使い方: init_claude [--update]`）（両ファイル）
- [x] ステップ6: AGENTS.md / README に使い方の記載があれば追記（要確認）

## テスト・確認方法
- [ ] 空ディレクトリで `init_claude` → 全ファイルが Created になる
- [ ] 既存ファイルを書き換えて `init_claude`（引数なし）→ 上書きされない
- [ ] 同状態で `init_claude --update` → settings.json / commands / opencode.json が Updated で元に戻る
- [ ] `AGENTS.md` を編集して `--update` → 内容が保持される
- [ ] テンプレートに無い独自コマンドファイルが `--update` 後も残る
- [ ] Windows 側も同様に確認（PowerShell 5.1 / 7.x）

## 決定事項
- `opencode.json` も `--update` で上書きする
- テンプレートに存在しない古いコマンドファイルは削除せず残す
- `AGENTS.md` は `--update` でも変更しない

## 懸念点・未決事項
- settings.json を上書きするとユーザーが追加した allow/deny が消える（依頼どおり完全上書き。マージはしない）
- `--update` 以外の不明な引数はエラーにするか無視するか（簡潔さ優先で無視、または usage 表示）
