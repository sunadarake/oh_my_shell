#!/usr/bin/env perl
# ntv.pl - todoディレクトリの最新todoファイルをvimで開く
# 使い方: perl ntv.pl
#         todoディレクトリ内の最新（最大連番）のtodoファイルを開く
#         そのファイルが空の場合はそのファイルを開き、空でない場合は次の連番のファイルを開く

use strict;
use warnings;
use utf8;
use X;

# vimの存在チェック
my $vim_path = which('vim');
unless ($vim_path) {
    die "エラー: vim が見つかりません。vim がインストールされていることを確認してください。\n";
}

# todoディレクトリを探す
my $cwd = pwd();
my $todo_dir;

if (bn($cwd) eq 'todo') {
    $todo_dir = $cwd;
} elsif (-d $cwd . '/todo') {
    $todo_dir = $cwd . '/todo';
}

unless ($todo_dir) {
    die "エラー: todoディレクトリが見つかりません。\n" .
        "カレントディレクトリが todo、または1つ上に todo ディレクトリが必要です。\n";
}

# 既存のtodoファイルを取得（サブディレクトリも含む）
my @todo_files;
my @dirs = ($todo_dir);
while (my $dir = shift @dirs) {
    opendir(my $dh, $dir) or die "ディレクトリを開けません: $!\n";
    for my $entry (readdir($dh)) {
        next if $entry eq '.' || $entry eq '..';
        my $path = "$dir/$entry";
        if (-d $path) {
            push @dirs, $path;
        } elsif ($entry =~ /^\d{3}-todo\.md$/) {
            push @todo_files, $path;
        }
    }
    closedir($dh);
}

# 連番でソート
my @sorted = sort {
    my ($num_a) = $a =~ /(\d{3})-todo\.md$/;
    my ($num_b) = $b =~ /(\d{3})-todo\.md$/;
    $num_a <=> $num_b
} @todo_files;

my $target_file;

if (@sorted) {
    my $latest_file = $sorted[-1];
    my $content = fg($latest_file);
    
    # 最新ファイルが空（または空白のみ）の場合
    if ($content !~ /\S/) {
        $target_file = $latest_file;
        print "最新のtodoファイルが空のため、それを開きます: $latest_file\n";
    } else {
        # 次の連番を作成
        my ($latest_num) = $latest_file =~ /(\d{3})-todo\.md$/;
        my $next_num = $latest_num + 1;
        $target_file = sprintf("%s/%03d-todo.md", $todo_dir, $next_num);
        fp($target_file, "");
        print "新しいtodoファイルを作成しました: $target_file\n";
    }
} else {
    # todoファイルが一つもない場合
    $target_file = sprintf("%s/001-todo.md", $todo_dir);
    fp($target_file, "");
    print "新しいtodoファイルを作成しました: $target_file\n";
}

# vimで開く
print "vim で開きます: $target_file\n";
exec($vim_path, $target_file);
