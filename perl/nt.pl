#!/usr/bin/env perl
# create_todo.pl - todoディレクトリに連番のtodoファイルを作成
# 使い方: perl create_todo.pl [枚数]

use strict;
use warnings;
use utf8;
use X;

# todoディレクトリを探す（カレントが todo、または１つ上に todo がある）
my $cwd = pwd();
my $todo_dir;

if (bn($cwd) eq 'todo') {
    $todo_dir = $cwd;
} elsif (-d $cwd . '/todo') {
    $todo_dir = $cwd . '/todo';
}

unless ($todo_dir) {
    die "エラー: todoディレクトリが見つかりません。\n" .
        "カレントディレクトリが todo、または１つ上に todo ディレクトリが必要です。\n";
}

# 引数チェック
my $count = 1;
if (@ARGV == 1) {
    die "エラー: 正の整数を指定してください。\n" if $ARGV[0] !~ /^\d+$/ || $ARGV[0] == 0;
    $count = int($ARGV[0]);
} elsif (@ARGV > 1) {
    die "Usage: create_todo.pl [枚数]\n";
}

# 既存の連番ファイルから次の番号を決める
opendir(my $dh, $todo_dir) or die "ディレクトリを開けません: $!\n";
my @existing = grep { /^\d{3}-todo\.md$/ } readdir($dh);
closedir($dh);

my $next = 1;
if (@existing) {
    my @nums = sort { $a <=> $b } map { /^(\d{3})-todo\.md$/; $1 + 0 } @existing;
    $next = $nums[-1] + 1;
}

# 指定枚数分ファイルを作成
for my $i (0 .. $count - 1) {
    my $filename = sprintf('%s/%03d-todo.md', $todo_dir, $next + $i);
    fp($filename, "");
    print "Created: $filename\n";
}
