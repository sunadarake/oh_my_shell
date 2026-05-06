#!/bin/sh
# unix/ にある .sh / .pl スクリプトを .bin/ へ拡張子なしでコピーし実行可能にする。
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

echo "完了: ${bdir}"
