#!/bin/bash
# dcp - コピー元と同じディレクトリにファイルをコピーする
# 使い方: dcp /path/to/sample.py 001_oreore.py
#   コピー先の拡張子を省略した場合は、コピー元の拡張子を自動的に付加する
#   例: dcp /path/to/sample.py 001_oreore  ->  /path/to/001_oreore.py

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOT'
使い方: dcp <コピー元ファイル> <新しい名前> [-h|--help]

コピー元と同じディレクトリにファイルをコピーする。
新しい名前に拡張子が無ければ、コピー元の拡張子を付ける。

  dcp /path/to/sample.py 001_oreore.py
  dcp /path/to/sample.py 001_oreore   (-> /path/to/001_oreore.py)
  -h, --help  このヘルプを表示する
EOT
    exit 0
fi

set -e

if [ $# -ne 2 ]; then
    echo "usage: dcp <source_file> <new_name>" >&2
    exit 1
fi

src="$1"
new_name="$2"

if [ ! -f "$src" ]; then
    echo "dcp: no such file: $src" >&2
    exit 1
fi

dir=$(dirname -- "$src")
base=$(basename -- "$src")

# 新しい名前に拡張子が無ければ、コピー元の拡張子を付ける
if [[ "$new_name" != *.* && "$base" == *.* ]]; then
    new_name="${new_name}.${base##*.}"
fi

dest="${dir}/${new_name}"
cp -i -- "$src" "$dest"
echo "copied: $src -> $dest"
