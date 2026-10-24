#!/bin/sh
# unix/ にある .sh / .pl スクリプトを .bin/ へ拡張子なしでコピーし実行可能にする。
# templates/ も .bin/templates へコピーする。
# 使い方: ./build_unix.sh
script_dir=$(cd "$(dirname "$0")" && pwd)
unix_dir="${script_dir}/unix"
bdir="${script_dir}/.bin"

mkdir -p "$bdir" || exit 1

for f in "$unix_dir"/*.sh "$unix_dir"/*.pl; do
  [ -e "$f" ] || continue
  name=$(basename "$f" | sed 's/\.[^.]*$//')
  cp "$f" "${bdir}/${name}" && chmod +x "${bdir}/${name}"
done

# スクリプトが読み込むテンプレートも .bin/ にコピーする
rm -rf "${bdir}/templates"
cp -R "${script_dir}/templates" "${bdir}/templates"

echo "完了: ${bdir}"

cat <<MSG

~/.bashrc に以下を追加してください(未追加の場合):
  export PATH="${bdir}:\$PATH"
  source "${unix_dir}/shell/functions.sh"
反映するには: source ~/.bashrc
MSG
