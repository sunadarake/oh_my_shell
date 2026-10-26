# design-init: 現在のファイル構成からビルド関連を除外する

## 概要
`design-init` の「現在のファイル構成」で、`todo` とビルド関連のディレクトリ(`build` / `dist` など)も表示しないようにする。計画書からの設計に不要な項目を減らすため。

## 調査結果
- 対象は `templates/init_claude/skill/design-init.md:11` の1行のみ
  - `!`ls -A | grep -vxE 'node_modules|venv|\.venv|\.claude|\.opencode|\.git'``
- `.claude/skills/design-init/` と `.opencode/skills/design-init/` は init_claude が生成する物、`.bin/templates/...` は build のコピーなので直接編集しない
- 他の skill やスクリプトに同じ除外パターンはない(`grep node_modules templates` で確認済み)
- `grep -x` で行全体に一致させているため、ディレクトリ名は完全一致で書く

## 実装計画
- [x] ステップ1: 除外パターンに `todo` とビルド関連を追加する。候補は `todo|build|dist|out|target|\.next|__pycache__`(`templates/init_claude/skill/design-init.md`)
- [x] ステップ2: `allowed-tools` は `ls` / `grep` のままで足りるので変更しない

## テスト・確認方法
- [x] 一時ディレクトリに `todo` `build` `dist` `src` `node_modules` を作り、1行のコマンドを実行して `src` だけが残ることを確認する
- [x] `-x` の完全一致なので、`build.sh` のような名前は除外されないことを確認する
- [ ] 変更後に `init_claude --update` で生成物に反映されることを確認する(必要なら build)

## 決定事項
- 修正は `design-init.md` の1行だけ
- 除外名は、依頼の `todo` `build` `dist` に、主要言語の一般的な出力先(`out` `target` `.next` `__pycache__`)を加える

## 懸念点・未決事項
- 除外名の範囲は推測。追加・削除したい名前があれば `/todo-refine` で調整する
- `target` `out` は、ビルド出力ではなく普通のソース置き場として使うプロジェクトでも隠れてしまう
- 既存の生成物(`.claude/skills/design-init`)は `--update` するまで古いまま
