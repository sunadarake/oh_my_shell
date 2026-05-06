#!/usr/bin/env perl
# 元ファイル: perl/nt.pl - todoディレクトリに連番のtodoファイルを作成
# 使い方: nt [ファイル名 [枚数]] または nt [枚数]

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use Cwd qw(cwd);
use File::Basename qw(basename);
use File::Find qw(find);

sub fwrite {
    my ($file, $content) = @_;
    open(my $fh, '>:encoding(UTF-8)', $file) or die "書き込みエラー: $file: $!\n";
    print $fh $content;
    close($fh);
}

# 000-todo.md 形式のファイルだけを収集する
sub find_files {
    my ($dir) = @_;
    my @files;
    find(sub { push @files, $File::Find::name if /^\d{3}-todo\.md$/ }, $dir);
    return @files;
}

my ($base_file, $count);

# 第1引数が数字でなければファイル名モード、数字なら枚数モード
if (@ARGV >= 1 && $ARGV[0] !~ /^\d+$/) {
    $base_file = shift @ARGV;
    $count = 3;
    if (@ARGV == 1) {
        die "エラー: 正の整数を指定してください。\n" if $ARGV[0] !~ /^\d+$/ || $ARGV[0] == 0;
        $count = int($ARGV[0]);
    } elsif (@ARGV > 1) {
        die "Usage: nt [ファイル名 [枚数]]\n";
    }
} else {
    $count = 1;
    if (@ARGV == 1) {
        die "エラー: 正の整数を指定してください。\n" if $ARGV[0] !~ /^\d+$/ || $ARGV[0] == 0;
        $count = int($ARGV[0]);
    } elsif (@ARGV > 1) {
        die "Usage: nt [枚数]\n";
    }
}

if (defined $base_file) {
    # ファイル名を stem と拡張子に分割して連番を挿入
    my ($stem, $ext) = $base_file =~ /^(.*?)(\.[^.\/]+)?$/;
    $ext //= '';
    for my $i (1 .. $count) {
        my $filename = sprintf('%s-%03d%s', $stem, $i, $ext);
        fwrite($filename, "");
        print "Created: $filename\n";
    }
} else {
    my $pwd = cwd();
    my $todo_dir;
    if (basename($pwd) eq 'todo') {
        $todo_dir = $pwd;
    } elsif (-d "$pwd/todo") {
        $todo_dir = "$pwd/todo";
    }
    unless ($todo_dir) {
        die "エラー: todoディレクトリが見つかりません。\n" .
            "カレントディレクトリが todo、または１つ上に todo ディレクトリが必要です。\n";
    }

    my @existing = find_files($todo_dir);
    my $next = 1;
    if (@existing) {
        # 既存ファイルの連番を数値ソートして最大値の次を使う
        my @nums = sort { $a <=> $b } map { /(\d{3})-todo\.md$/; $1 + 0 } @existing;
        $next = $nums[-1] + 1;
    }

    for my $i (0 .. $count - 1) {
        my $filename = sprintf('%s/%03d-todo.md', $todo_dir, $next + $i);
        fwrite($filename, "");
        print "Created: $filename\n";
    }
}
