#!/bin/sh
# oh_my_shell ビルドスクリプト
# bin/ のシェルスクリプトを build/unix/ にコピーして実行可能にする

# ディレクトリ設定
script_dir=$(cd "$(dirname "$0")" && pwd)
shell_dir="${script_dir}/shell"
perl_dir="${script_dir}/perl"
bdir="${script_dir}/.bin"

# ビルドディレクトリ作成
mkdir -p "$bdir" || exit 1

# シェルスクリプトを処理
for sh_file in "$shell_dir"/*.sh; do
  [ -e "$sh_file" ] || continue

  basename=$(basename "$sh_file" .sh)
  target="${bdir}/${basename}"

  cp "$sh_file" "$target" && chmod +x "$target"
done

# Perlスクリプトを処理（拡張子なし）
for pl_file in "$perl_dir"/*.pl; do
  [ -e "$pl_file" ] || continue

  basename=$(basename "$pl_file" .pl)
  target="${bdir}/${basename}"

  cp "$pl_file" "$target" && chmod +x "$target"
done

# 結果表示
echo ""
echo "ビルド完了"
echo ""
echo "使用するには以下を ~/.bashrc または ~/.zshrc に追加してください:"
echo ""
echo "  export PATH=\"${bdir}:\$PATH\""
echo ""
