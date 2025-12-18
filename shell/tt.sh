#1/bin/sh
# tt - ディレクトリごとファイルを作成するコマンド
#   tt .claude/settings.json bin/oreore/
#   .claude/settings.json のファイルと bin/oreore dir が作成される
for f in "$@"
do
  case "$f" in
    */)
      mkdir -p "$f"
      echo "mkdir $f"
      ;;
    *)
      d=$(dirname "$f")
      mkdir -p "$d" && touch "$f"
      echo "touch $f"
      ;;
  esac
done
