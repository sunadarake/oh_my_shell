#!/usr/bin/env perl
# init_python_scripts.pl - Pythonスクリプトプロジェクトの雛形を作成
# 使い方: perl init_python_scripts.pl <project_name>

use strict;
use warnings;
use utf8;
use X;

# 引数チェック
if (@ARGV != 1) {
    die "Usage: perl init_python_scripts.pl <project_name>\n";
}

my $project_name = $ARGV[0];

# uvコマンドの存在チェック
my $uv_path = which('uv');
unless ($uv_path) {
    die "Error: uv command not found. Please install uv first.\n";
}

print "Using uv: $uv_path\n";

# uv init --package を実行
print "Running: uv init --package $project_name\n";
sh('uv', 'init', '--package', $project_name);

# プロジェクトディレクトリに移動
unless (-d $project_name) {
    die "Error: Project directory '$project_name' was not created.\n";
}

chdir($project_name) or die "Cannot chdir to $project_name: $!\n";
print "Changed directory to: $project_name\n";

# .claude/settings.json の作成
my $settings_file = '.claude/settings.json';
unless (-f $settings_file) {
    md('.claude');

    my @commands = qw(rg mkdir grep cp chmod chown find cat head tail less more wc sort uniq cut awk sed ls);
    my @prefixes = ('', 'busybox', 'busybox64u');
    my @allow = map {
        my $prefix = $_;
        map { "Bash($prefix $_:*)" } @commands;
    } @prefixes;

    push @allow, "Bash(git add:*)", "List(*)", "Edit(*)", "mcp__voicevox__speak";

    my $settings = {
        permissions => {
            allow => \@allow,
            deny => []
        }
    };
    jp($settings_file, $settings);
    print "Created: $settings_file\n";
}

# CLAUDE.md の作成
my $claude_md = 'CLAUDE.md';
unless (-f $claude_md) {
    my $content = <<'MD';
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
MD
    fp($claude_md, $content);
    print "Created: $claude_md\n";
}

# python3.12をインストール
sh('uv', 'python', 'install', '3.12');
sh('uv', 'python', 'pin', '3.12');

# 基本的なモジュールをインストールしておく
sh('uv', 'add', 'requests', 'pillow');

print "Finish Complete\n"
