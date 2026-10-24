# oh_my_shell

bash / Perl (Linux・Mac) と PowerShell (Windows) のユーティリティコマンド集

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

`mkcd` / `cd N` はシェル関数のため、`~/.bashrc` に source を追加：

```bash
source "$HOME/Documents/oh_my_shell/unix/shell/functions.sh"
```

- `mkcd <dir>` : ディレクトリを作成して移動
- `cd 2` : `cd ../..` と同じ（同名ディレクトリがあればそちらを優先）
- `cdd` / `cdp` / `cdv` / `cdl` : Documents / Pictures / Videos / Downloads へ移動

### Windows

```powershell
.\build_win.ps1
```

PATHに追加（PowerShellプロファイルに追加）：

```powershell
$env:PATH = "C:\path\to\oh_my_shell\.bin_win;$env:PATH"
```

`mkcd` / `cd N` はシェル関数のため、PowerShellプロファイルに dot-source を追加：

```powershell
. "C:\path\to\oh_my_shell\windows\shell\functions.ps1"
```

## コマンド一覧

### tt - ディレクトリ付きファイル作成

ファイルとその親ディレクトリを一度に作成します。

```bash
# ファイル作成（親ディレクトリも自動作成）
tt .claude/settings.json src/main.js

# ディレクトリ作成
tt bin/oreore/
```

### oo - エクスプローラー(ファイルマネージャー)を開く(OSに適した形で)

```bash
oo /path/to/open
```

### ggc - Gitコミット

`git add .` と `git commit` をまとめて実行します。

```bash
# "Update: 日時 (N files)" と変更ファイル一覧のメッセージでコミット
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


### init_claude Claudeの雛形を作成する

現在のディレクトリに AGENTS.mdや .claude/settings.json、.claude/skills/ を作成する

旧版の `.claude/commands/` は削除されない。同名の skill と重複するので手動で削除すること。

```bash
init_claude
```

### その他のコマンド

詳細は各コマンドの `-h` / `--help` を参照。

| コマンド | 内容 |
|---|---|
| `ggf` | `git pull origin main` |
| `ggr` | 変更を破棄して直前のコミットに戻す (Windows のみ) |
| `ccc` | 標準入力 / ファイルをクリップボードへコピー |
| `dcp` | コピー元と同じディレクトリにファイルをコピー |
| `dd` | 画面クリア |
| `az` | 暗算 (`az 14 a 54`) |
| `nt` / `ntv` | `todo/` に連番ファイルを作成 / 最新を vim で開く |
| `tre` | tree (ビルドディレクトリを自動除外) |
| `memo` | memomemo を Zed (なければ VSCode) で開く |
| `vv` | ファイルを別ターミナルの vim で開く |
| `zz` | パスを Zed で開く |
| `claude_stash` | ディレクトリを `~/.claude_stash` へ退避 / 復元 |
| `open-webui` | Open WebUI を起動 |
| `update-chrome` | Google Chrome を更新 |
| `install-fonts` | フォントを `~/.local/share/fonts/` へ導入 (Unix のみ) |
