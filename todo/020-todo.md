# ggc: 引数なし時の1行目に docs / chore を付ける

## 概要
`unix/ggc.sh` と `windows/ggc.ps1` を引数なしで実行したとき、1行目の先頭を `Update:` ではなく `docs:` または `chore:` にする。コミット履歴で変更の種類を見分けやすくするため。

## 調査結果
- `unix/ggc.sh`: 1行目を `printf "Update: %s (%s files)..."` で作る。一覧は `awk` で `Create:` / `Update:` / `Delete:` / `Rename:` に変換している
- `windows/ggc.ps1`: 同じ形式を `"Update: " + (Get-Date ...)` で作る。一覧は `switch -Regex` で変換している
- 両方のヘルプ文に「1行目が "Update: 日時 (N files)"」とある
- `README.md:34` の ggc の説明は「日時と変更ファイル一覧」なので、1行目の接頭辞には触れておらず変更不要
- 変更ファイルの一覧(`git diff --cached --name-status`)は既に取得しているので、そのパスから種類を判定できる

## 実装計画
- [x] ステップ1: 変更ファイルが全部 `.md` なら `docs`、それ以外(1つでも別の拡張子があれば)は `chore` と判定する。リネームは新しいパスで判定する。拡張子の大文字小文字は区別しない(`unix/ggc.sh`)
- [x] ステップ2: 1行目を `<docs|chore>: YYYY-MM-DD HH:MM:SS (N files)` にする。2行目以降の `Create:` / `Update:` などの一覧は変えない(`unix/ggc.sh`)
- [x] ステップ3: ステップ1・2と同じ判定を PowerShell で実装する。`Where-Object { $_ -notmatch '\.md$' }` のようにネイティブのコマンドレットで書く(`windows/ggc.ps1`)
- [x] ステップ4: 両方のヘルプ文と冒頭コメントの「Update: 日時 (N files)」を新しい形式の説明に更新する(`unix/ggc.sh`, `windows/ggc.ps1`)

## テスト・確認方法
- [x] 一時リポジトリで `.md` だけを変更して `ggc` を実行し、1行目が `docs:` になることを確認する
- [x] `.json` だけの場合は `chore:` になることを確認する
- [x] `.md` と `.sh` が混ざる場合は `chore:` になることを確認する
- [x] 削除・リネームだけの場合も正しく判定されることを確認する
- [x] 引数ありの挙動が変わっていないことを確認する
- [x] `ggc -h` の表示を確認する(unix のみ。windows は pwsh が環境になく未実行)

## 決定事項
- 種類は `docs` と `chore` の2つだけ
- `docs` は変更ファイルが全部 `.md` のとき(`.json` は設定ファイルが多いので含めない)。それ以外は `chore`
- 2行目以降の一覧(`Create:` / `Update:` / `Delete:` / `Rename:`)は今までどおり
- 対象は `unix/ggc.sh` と `windows/ggc.ps1` の両方
- 日時と `(N files)` の形式は変えない

## 懸念点・未決事項
- 変更が0件のときは `chore:` になるが、どのみち commit が「nothing to commit」で終わる
- `windows/ggc.ps1` は pwsh がこの環境になく、動作未確認(コードの確認のみ)
