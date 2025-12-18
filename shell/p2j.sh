#!/bin/sh
# p2j PNGをJPGに変換するツール (ImageMagick v7必須)
#   p2j image.png  p2j photos/

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

# PNG→JPG変換
convert_png() {
    input="$1"
    output="$2"
    
    echo "Converting: $input"
    magick "$input" -quality 95 "$output"
}

for target in "$@"; do
  if [ -f "$target" ]; then
      # ファイル処理
      case "$target" in
          *.png|*.PNG)
              output="${target%.*}.jpg"
              convert_png "$target" "$output"
              ;;
          *)
              echo "Error: Not a PNG file"
              exit 1
              ;;
      esac
  elif [ -d "$target" ]; then
      # ディレクトリ処理（再帰的）
      output_dir="${target%/}_jpg"
      
      find "$target" -type f \( -name "*.png" -o -name "*.PNG" \) | while read -r file; do
          # 相対パスを保持
          rel_path="${file#$target/}"
          output_file="$output_dir/${rel_path%.*}.jpg"
          
          # 出力ディレクトリ作成
          mkdir -p "$(dirname "$output_file")"
          
          convert_png "$file" "$output_file"
      done
      
      echo "Saved to: $output_dir"
  else
      echo "Error: Not a file or directory"
      exit 1
  fi
  done
