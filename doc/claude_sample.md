## Pythonのスクリプトを作成していくプロジェクト

これからPythonのスクリプトを作成していきます。以下のルールに従ってコードを書いてください。

## プロジェクトの取り組み方について

* なるべくコードやコメントをシンプルに簡潔にすること。 
* コメントはUTF-8の日本語で書くこと。 
* 問題に取り組む前に、コードや仕様を読んで理解すること。 

## Bashについて

bashを使わずにbusyboxを使う様にしてください。

## Pythonスクリプトの書き方


Pythonのスクリプトを作成する際には、以下のルールを守ってください。

- os.pathを使うこと。
- Never: Pathを使わない
- スクリプトの完了の時間計測を行う事。出力は HH:MM:SS の形式で行うこと。
- 詳細な日本語コメントと型ヒントを書くこと。
- 処理を関数に小分けすること。
- スクリプト内で設定できる値は、スクリプトから直接変数できたり、コマンドライン引数から指定できたりできること。
- main関数に相当する処理は、main関数に記述するのではなく、グローバル環境に書いて。

具体的には、コード全体は以下の様に書いてください。

```py
import os
import traceback
import argparse

# ここにスクリプトの内容を詳細に書いてください。これはargparseのdocumentにも渡します。
document = """

"""

# 入力先のディレクトリ (スクリプトの設定になるグローバル変数には、詳細なコメントを書いて。)
src_dir = r""

dest_dir = r""

crop_edge = 20

# 既にdest_pathにファイルが存在する場合は処理を飛ばす。
skip_if_exists = True

is_stop_process = False

# スクリプトを適切に途中で止めるために設定する。、
def handle_sigint(signum, frame):
    global is_stop_process
    is_stop_process = True

## ここに必要な関数たちを書いていく。

def main():
  try:
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("-s", "--src_dir", type=str, help="ソースファイルのパス")
    parser.add_argument(
        "-d",
        "--dest_dir",
        type=str,
        help="ファイルの更新先。指定なしの場合はsrc_dirと同じディレクトリで更新が行われる。",
    )

    parser.add_argument(
        "-t",
        "--threshold",
        type=int,
        help="閾値。色の距離がこの値以内なら完全透明に、それ以上ならそのまま。 50 ~ 150 くらいがよい？",
    )

    args = parser.parse_args()

    if args.src_dir is not None:
        src_dir = args.src_dir

    if args.dest_dir is not None:
        dest_dir = args.dest_dir


    print("")
    print("===== Start Renban Filename =====")
    print(f"src_dir: {src_dir}")
    print(f"dest_dir: {dest_dir}")
    print("")

    signal.signal(signal.SIGINT, handle_sigint)

    if not dest_dir:
        dest_dir = src_dir + "_rembg" + str(threshold)

    if not os.path.isdir(src_dir):
        print(f"src_dirが存在しません: {src_dir}")
        exit(1)

    os.makedirs(dest_dir, exist_ok=True)

    imgs = get_files_recursively(src_dir)

    count, total = 0, len(imgs)

    for img_path in imgs:
        count += 1

        if is_stop_process:
            print("Ctrl + C が押されたので、処理を中断しました")
            exit(2)

        # 主な処理が来る。

        print(f"Finish!! {abs_dest} {count} / {total}")

    print("")
    print("===== Finish =====")
    print(f"src_dir: {src_dir}")
    print(f"dest_dir: {dest_dir}")
    print()
    print(f"Time: HH:MM:SS")

    print("")
  except Exception as e:
    print(e)
    traceback.print_exc()


main()
```
