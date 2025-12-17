#!/bin/sh
# vvc mp4の動画を 4k →  FHD に変換したり、品質を保ちつつサイズを圧縮するツール
#   vvc sample.mp4  vvc /sample/mp4_dir

if ! command -v ffmpeg >/dev/null 2&>1; then
  echo "ERROR: ffmpeg is NOT installed"
  exit 1
fi

# 使い方チェック
if [ $# -eq 0 ]; then
    echo "Usage: $0 <mp4_file_or_directory>"
    exit 1
fi

# 500MB in bytes
MAX_SIZE=524288000

# mp4ファイルを処理する関数
process_mp4() {
    input="$1"
    
    # ファイルサイズを取得（バイト）
    filesize=$(stat -f%z "$input" 2>/dev/null || stat -c%s "$input" 2>/dev/null)
    
    # 500MB以下ならスキップ
    if [ "$filesize" -lt "$MAX_SIZE" ]; then
        echo "Skipping $input ($(echo "scale=2; $filesize/1048576" | bc)MB < 500MB)"
        return
    fi
    
    # 出力ファイル名
    dir=$(dirname "$input")
    base=$(basename "$input" .mp4)
    output="${dir}/${base}_compressed.mp4"
    
    echo "Processing $input ($(echo "scale=2; $filesize/1048576" | bc)MB)..."
    
    # 動画情報を取得
    height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$input")
    
    # スケールフィルター設定（4K以上なら1080pに）
    if [ "$height" -gt 1080 ]; then
        scale_filter="-vf scale=-2:1080"
        echo "  Resizing from ${height}p to 1080p"
    else
        scale_filter=""
        echo "  Keeping original resolution (${height}p)"
    fi
    
    # エンコード実行（高品質設定）
    ffmpeg -i "$input" $scale_filter \
        -c:v libx264 -preset slow -crf 23 \
        -c:a aac -b:a 128k \
        -movflags +faststart \
        "$output"
    
    if [ $? -eq 0 ]; then
        new_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)
        echo "  Complete: $(echo "scale=2; $new_size/1048576" | bc)MB"
    else
        echo "  Error processing $input"
    fi
}

# メイン処理
for target in "$@"; do
  if [ -f "$target" ]; then
      # ファイルが指定された場合
      case "$target" in
          *.mp4|*.MP4)
              process_mp4 "$target"
              ;;
          *)
              echo "Error: Not an mp4 file"
              exit 1
              ;;
      esac
  elif [ -d "$target" ]; then
      # ディレクトリが指定された場合
      find "$target" -type f \( -name "*.mp4" -o -name "*.MP4" \) | while read -r file; do
          process_mp4 "$file"
      done
  else
      echo "Error: $target is not a file or directory"
      exit 1
  fi
  done
