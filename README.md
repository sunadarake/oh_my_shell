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

### oo - exploerを開く(OSに適した形で)

```bash
oo /path/to/open
```

### ggc - Gitコミット

`git add .` と `git commit` をまとめて実行します。

```bash
# デフォルトメッセージ "update" でコミット
ggc

# カスタムメッセージでコミット
ggc "READMEの修正" "バグ修正"
```

### ggp - Git プッシュ

`git push origin main` を実行します。

```bash
# origin main にプッシュ
ggp

# カスタムオプション指定
ggp origin feature-branch
```
