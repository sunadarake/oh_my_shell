# oh_my_shell

## 目的

日常で使う小さなコマンドを、bash / Perl (Linux・Mac) と PowerShell (Windows) でまとめた便利スクリプト集。
各スクリプトは独立しており、ビルドして PATH に通すだけで使える。

## セットアップ

```bash
# Linux / macOS
./build_unix.sh   # unix/ のスクリプトを .bin/ へコピー

# ~/.bashrc に追加
export PATH="$HOME/Documents/oh_my_shell/.bin:$PATH"
source "$HOME/Documents/oh_my_shell/unix/shell/functions.sh"  # mkcd / cd N / cdd など
```

```powershell
# Windows
.\build_win.ps1   # windows\ のスクリプトを .bin_win\ へコピー

# PowerShell プロファイルに追加
$env:PATH = "C:\path\to\oh_my_shell\.bin_win;$env:PATH"
. "C:\path\to\oh_my_shell\windows\shell\functions.ps1"  # mkcd / cd N / cdd など
```

## 使い方

各コマンドの詳細は `-h` / `--help` を参照。

```bash
tt .claude/settings.json src/main.js  # ファイルを親ディレクトリごと作成
ggc "メッセージ"                      # git add . と git commit (省略時は日時と変更ファイル一覧)
ggp                                   # git push origin main
init_claude                           # AGENTS.md / .claude/settings.json / .claude/skills/ / .opencode/skills/ / opencode.json の雛形を作成
oo /path/to/open                      # ファイルマネージャーで開く
```

`init_claude` は旧版の `.claude/commands/` を削除しない。同名の skill と重複するので手動で削除すること。

## 仕様

シェル関数 (`functions.sh` / `functions.ps1`):

| 関数 | 説明 |
|:-|:-|
| `mkcd <dir>` | ディレクトリを作成して移動 |
| `cd 2` | `cd ../..` と同じ |
| `cdd` / `cdp` / `cdv` / `cdl` | Documents / Pictures / Videos / Downloads へ移動 |

その他のコマンド:

| コマンド | 説明 |
|:-|:-|
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
