#!/bin/sh
# pir PNGのメタデータを削除するツール (ImageMagick v7必須)
#   pir image.png sample.png :  pir photos/

# ImageMagick v7チェック
if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick version 7 is required"
    echo "Install: apt install imagemagick (or brew install imagemagick)"
    exit 1
fi

# 使い方チェック
if [ $# -eq 0 ]; then
    echo "Usage: $0 <png_file_or_directory>"
    exit 1
fi

# メタデータ削除
rm_metadata() {
    input="$1"
    temp="${input}.tmp"
    
    echo "Removing metadata: $input"
    magick "$input" -strip "$temp" && mv "$temp" "$input"
}

for target in "$@"; do
  if [ -f "$target" ]; then
      # ファイル処理
      case "$target" in
          *.png|*.PNG)
              rm_metadata "$target"
              ;;
          *)
              echo "Error: Not a PNG file"
              exit 1
              ;;
      esac
  elif [ -d "$target" ]; then
      # ディレクトリ処理（再帰的）
      find "$target" -type f \( -name "*.png" -o -name "*.PNG" \) | while read -r file; do
          rm_metadata "$file"
      done
      
      echo "Done"
  else
      echo "Error: Not a file or directory"
      exit 1
  fi
  done
