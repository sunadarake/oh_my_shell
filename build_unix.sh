#!/bin/sh
# oh_my_shell ビルドスクリプト
# bin/ のシェルスクリプトを build/unix/ にコピーして実行可能にする

# ディレクトリ設定
script_dir=$(cd "$(dirname "$0")" && pwd)
src_dir="${script_dir}/scripts"
bdir="${script_dir}/.bin"

# ビルドディレクトリ作成
mkdir -p "$bdir" || exit 1

# シェルスクリプトを処理
for sh_file in "$src_dir"/*.sh; do
  [ -e "$sh_file" ] || continue

  basename=$(basename "$sh_file" .sh)
  target="${bdir}/${basename}"

  cp "$sh_file" "$target" && chmod +x "$target"
done

# 結果表示
echo ""
echo "ビルド完了"
echo ""
echo "使用するには以下を ~/.bashrc または ~/.zshrc に追加してください:"
echo ""
echo "  export PATH=\"${bdir}:\$PATH\""
echo ""
