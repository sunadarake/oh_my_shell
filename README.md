# oh_my_shell

シェルスクリプトベースのユーティリティコマンド集

## ビルド方法

### Linux / macOS

```bash
./build_unix.sh
```

PATHに追加：

```bash
# ~/.bashrc または ~/.zshrc に追加
export PATH="$HOME/Documents/oh_my_shell/.bin:$PATH"
```

### Windows

```powershell
.\build_win.ps1
```

PATHに追加（PowerShellプロファイルに追加）：

```powershell
$env:PATH = "C:\path\to\oh_my_shell\.bin_win;$env:PATH"
```

**注意**: Windows版は `busybox64u` が必要です。

## コマンド一覧

### tt - ディレクトリ付きファイル作成

ファイルとその親ディレクトリを一度に作成します。

```bash
# ファイル作成（親ディレクトリも自動作成）
tt .claude/settings.json src/main.js

# ディレクトリ作成
tt bin/oreore/
```

### gc - Gitコミット

`git add .` と `git commit` をまとめて実行します。

```bash
# デフォルトメッセージ "update" でコミット
gc

# カスタムメッセージでコミット
gc "READMEの修正" "バグ修正"
```

### gp - Git プッシュ

`git push origin main` を実行します。

```bash
# origin main にプッシュ
gp

# カスタムオプション指定
gp origin feature-branch
```
