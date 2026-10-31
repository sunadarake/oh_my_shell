# claude_stash のサブコマンドを1文字で指定可能にする

## 概要
`claude_stash` の `stash` / `restore` / `list` を、頭文字 `s` / `r` / `l` でも呼べるようにする（フル表記も従来通り使える）。

## 調査結果
- `unix/claude_stash.pl` : `main` 内の `if ($cmd eq 'stash') ... elsif 'restore' ... elsif 'list'` で分岐。usage もここ。
- `windows/claude_stash.ps1` : `param` の `[ValidateSet('stash','restore','list','--help')]` で検証し、`Main` の `switch` で分岐。
- 3コマンドの頭文字は重複しない（s / r / l）ため曖昧さはない。
- `.bin/claude_stash` はビルド成果物なので直接編集しない。
- README.md / AGENTS.md には引数の詳細記載なし（更新不要）。

## 実装計画
- [x] ステップ1: `unix/claude_stash.pl` の分岐を `stash|s` / `restore|r` / `list|l` で受けるようにし、usage に `stash|s` 等の別名を併記する
- [x] ステップ2: `windows/claude_stash.ps1` の `ValidateSet` に `'s','r','l'` を追加し、`switch` を `{ $_ -in 'stash','s' }` 等で受ける。Show-Usage にも別名を併記する
- [ ] ステップ3（不要と判断し未実施）: 冒頭コメントの使い方に別名の例を一言追記する（必要なら）

## テスト・確認方法
- [x] `claude_stash.pl s <dir>` / `l` / `r <dir>` が `stash` / `list` / `restore` と同じ動作をする
- [x] フル表記（stash/restore/list）が従来通り動く
- [x] 不正な引数（例: `x`）で usage が表示される
- [x] `-h` / `--help` に別名が表示される
- [ ] PowerShell 版でも同様に確認する

## 決定事項
- フル表記は残し、1文字は別名として追加する（後方互換）。
- 対象は Perl 版と PowerShell 版の両方。

## 懸念点・未決事項
- 特になし（`-h` との衝突もない）。
- この環境に pwsh がなく PowerShell 版は未実行。構文・分岐は目視のみで、実機での確認が必要。
