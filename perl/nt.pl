#!/usr/bin/env perl
# nt.pl - todoディレクトリに連番のtodoファイルを作成
# 使い方: perl nt.pl [ファイル名 [枚数]]
#         ファイル名を指定した場合はそのファイル名の末尾に -001 -002 ... と連番を付けたファイルを作成
#         ファイル名を省略した場合は todo ディレクトリに 001-todo.md 形式で作成

use strict;
use warnings;
use utf8;
use X;

# 第一引数がファイル名かどうか判定（数字のみなら枚数指定）
my ($base_file, $count);

if (@ARGV >= 1 && $ARGV[0] !~ /^\d+$/) {
    # ファイル名モード
    $base_file = shift @ARGV;
    $count = 3;
    if (@ARGV == 1) {
        die "エラー: 正の整数を指定してください。\n" if $ARGV[0] !~ /^\d+$/ || $ARGV[0] == 0;
        $count = int($ARGV[0]);
    } elsif (@ARGV > 1) {
        die "Usage: nt.pl [ファイル名 [枚数]]\n";
    }
} else {
    # todoディレクトリモード
    $count = 1;
    if (@ARGV == 1) {
        die "エラー: 正の整数を指定してください。\n" if $ARGV[0] !~ /^\d+$/ || $ARGV[0] == 0;
        $count = int($ARGV[0]);
    } elsif (@ARGV > 1) {
        die "Usage: nt.pl [枚数]\n";
    }
}

if (defined $base_file) {
    # ファイル名モード: 拡張子の前に -001 -002 ... を挿入
    my ($stem, $ext) = $base_file =~ /^(.*?)(\.[^.\/]+)?$/;
    $ext //= '';
    for my $i (1 .. $count) {
        my $filename = sprintf('%s-%03d%s', $stem, $i, $ext);
        fp($filename, "");
        print "Created: $filename\n";
    }
} else {
    # todoディレクトリモード
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

    # 既存の連番ファイルから次の番号を決める（サブディレクトリも含む）
    my @existing;
    my @dirs = ($todo_dir);
    while (my $dir = shift @dirs) {
        opendir(my $dh, $dir) or die "ディレクトリを開けません: $!\n";
        for my $entry (readdir($dh)) {
            next if $entry eq '.' || $entry eq '..';
            my $path = "$dir/$entry";
            push @dirs, $path if -d $path;
            push @existing, $entry if $entry =~ /^\d{3}-todo\.md$/;
        }
        closedir($dh);
    }

    my $next = 1;
    if (@existing) {
        my @nums = sort { $a <=> $b } map { /^(\d{3})-todo\.md$/; $1 + 0 } @existing;
        $next = $nums[-1] + 1;
    }

    for my $i (0 .. $count - 1) {
        my $filename = sprintf('%s/%03d-todo.md', $todo_dir, $next + $i);
        fp($filename, "");
        print "Created: $filename\n";
    }
}
