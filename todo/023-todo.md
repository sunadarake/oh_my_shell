# unix/ の Perl スクリプトを main 関数から実行する

## 概要
`unix/` 配下の Perl スクリプト (`*.pl`) の処理本体を `sub main` にまとめ、ファイル末尾の `main();` から実行する。トップレベルに処理が散在している構成を揃え、見通しを良くするため。動作・出力は変えない。

## 調査結果
対象は5ファイル。いずれもトップレベルに直接処理を書いている。

- `unix/az.pl` (33行): `-h` 処理 → 式の置換 → `eval` → 出力。サブルーチンなし
- `unix/nt.pl` (97行): `-h` 処理、引数解析、todo/ファイル作成。`fwrite` / `find_files` あり
- `unix/ntv.pl` (94行): `-h` 処理、vim 探索、todo ディレクトリ特定、`exec`。`fwrite` / `fread` / `find_files` あり
- `unix/init_claude.pl` (127行): `$update`(`put` から参照されるファイルスコープ変数)、`-h` 処理、settings.json / skills / opencode.json / AGENTS.md の生成。`fread` / `fwrite` / `put` あり
- `unix/claude_stash.pl` (184行): `$HOME` / `$STASH_DIR` / `$MANIFEST` が各サブルーチンから参照される。`@ARGV` の UTF-8 デコード、サブコマンド振り分け、`usage`、`do_stash` / `do_restore` / `do_list` あり

注意点
- `-h` のヘルプ内の `use Cwd` などの `use` 文は、トップレベルに残す (`sub main` には入れない)
- ファイルスコープ変数をサブルーチンが参照している箇所 (`$update`、`$STASH_DIR` 等) は、`main` 内の `my` にするとスコープから外れる
- `ntv.pl` は最後に `exec` するので、`main` 内でそのまま呼べば動作は変わらない
- `build_unix.sh` は拡張子なしでコピーするだけなので、ビルド側の変更は不要

## 実装計画
- [x] ステップ1: `az.pl` — `-h` 処理から出力までを `sub main` に移し、末尾に `main();` を置く
- [x] ステップ2: `nt.pl` — トップレベルの処理 (`-h`、引数解析、作成処理) を `sub main` に移す。`use` とヘルパー (`fwrite` / `find_files`) はそのまま
- [x] ステップ3: `ntv.pl` — 同様に `sub main` へ移す。`exec` は `main` の最後で呼ぶ
- [x] ステップ4: `init_claude.pl` — `$update` は `our`/ファイルスコープ変数として宣言だけ残し、`main` 内で代入する (または `put` に引数で渡す。コード量が少ない方を選ぶ)。残りの処理を `main` へ移す
- [x] ステップ5: `claude_stash.pl` — `$HOME` / `$STASH_DIR` / `$MANIFEST` の定義は定数的なのでファイルスコープに残す。`@ARGV` のデコード、`-h` 処理、サブコマンド振り分けを `main` に移す
- [x] ステップ6: 各ファイル末尾に `main();` を置く。`usage` など途中で `exit` するものはそのまま
- [x] ステップ7: AGENTS.md の「unix/ (bash)」節に「Perl スクリプトは `sub main` を定義して末尾の `main();` から実行する」を1行追記する

## テスト・確認方法
- [x] 全5ファイルで `perl -c unix/<名>.pl` が通る
- [x] 全5ファイルで `-h` / `--help` の出力が変更前と同じ (`git stash` 前後で `diff`)
- [x] `az 1 a 2` → `3`、`az 6 m 7` → `42`
- [x] 一時ディレクトリで `nt` / `nt foo 2` が連番ファイルを作る
- [x] 一時ディレクトリで `init_claude` を実行し、`--update` 有無で `Created` / `Updated` / スキップの挙動が変更前と同じ。生成物が変更前と `diff` で一致する
- [x] `HOME` を一時ディレクトリにして `claude_stash stash` / `list` / `restore` が往復できる (日本語名を含める)
- [x] `ntv` は vim を起動するので、`PATH` にダミーの `vim` を置いて引数を確認する

## 決定事項
- 対象は `unix/` 直下の `*.pl` 5ファイルのみ。`windows/` の PowerShell は対象外
- 呼び出しは `main();` とし、`@ARGV` はグローバルのまま `main` 内で参照する (引数渡しにしない。既存コードの `@ARGV` 参照を変えないため)
- 質問なしで進める (依頼文だけで仕様が決まるため)

## 懸念点・未決事項
- `init_claude.pl` の `$update` の扱いはステップ4で最小変更の方を選ぶ
- `claude_stash.pl` は `sub` が末尾に定義されているので、`main();` を最後に置いても、先頭近くに置いてもよい。他ファイルと揃えて末尾にする
- ヘルプ表示の `exit` が `main` 内になるため、`END` ブロックなど後処理がある場合は挙動を確認する (現状は見当たらない)
