#!/usr/bin/env perl
# 元ファイル: perl/ntv.pl - todoディレクトリの最新todoファイルをvimで開く
# 最新（最大連番）のtodoファイルが空なら開き、空でなければ次の連番を作成して開く

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

sub fread {
    my ($file) = @_;
    open(my $fh, '<:encoding(UTF-8)', $file) or die "読み込みエラー: $file: $!\n";
    my $content = do { local $/; <$fh> };  # ファイル全体を一括読み込み
    close($fh);
    return $content;
}

# 000-todo.md 形式のファイルだけを収集する
sub find_files {
    my ($dir) = @_;
    my @files;
    find(sub { push @files, $File::Find::name if /^\d{3}-todo\.md$/ }, $dir);
    return @files;
}

# vimのパスを探す
my $vim_path;
for my $dir (split /:/, ($ENV{PATH} // '')) {
    if (-x "$dir/vim") { $vim_path = "$dir/vim"; last; }
}
die "エラー: vim が見つかりません。vim がインストールされていることを確認してください。\n"
    unless $vim_path;

my $pwd = cwd();
my $todo_dir;
if (basename($pwd) eq 'todo') {
    $todo_dir = $pwd;
} elsif (-d "$pwd/todo") {
    $todo_dir = "$pwd/todo";
}
die "エラー: todoディレクトリが見つかりません。\n" .
    "カレントディレクトリが todo、または1つ上に todo ディレクトリが必要です。\n"
    unless $todo_dir;

# ファイル名の連番で昇順ソート
my @sorted = sort {
    my ($na) = $a =~ /(\d{3})-todo\.md$/;
    my ($nb) = $b =~ /(\d{3})-todo\.md$/;
    $na <=> $nb;
} find_files($todo_dir);

my $target_file;
if (@sorted) {
    my $latest = $sorted[-1];
    # \S: 空白以外の文字がなければ空ファイルと判定
    if (fread($latest) !~ /\S/) {
        $target_file = $latest;
        print "最新のtodoファイルが空のため、それを開きます: $latest\n";
    } else {
        my ($num) = $latest =~ /(\d{3})-todo\.md$/;
        $target_file = sprintf("%s/%03d-todo.md", $todo_dir, $num + 1);
        fwrite($target_file, "");
        print "新しいtodoファイルを作成しました: $target_file\n";
    }
} else {
    $target_file = "$todo_dir/001-todo.md";
    fwrite($target_file, "");
    print "新しいtodoファイルを作成しました: $target_file\n";
}

print "vim で開きます: $target_file\n";
exec($vim_path, $target_file);  # 現在のプロセスをvimに置き換える
