#!/usr/bin/env perl
# az - CLI上で暗算ができるスクリプト
# az 14 a 54  az 91 m 32

use strict;
use warnings;
use utf8;
use X;

# 引数を受け取って演算子に変換
my $expr = join(' ', @ARGV);

# 特殊文字を演算子に変換
$expr =~ s/\ba\b/+/g;  # a → +
$expr =~ s/\bs\b/-/g;  # s → -
$expr =~ s/\bm\b/*/g;  # m → *
$expr =~ s/\bd\b/\//g; # d → /

# evalで評価して結果を出力
my $result = eval $expr;
if ($@) {
    die "エラー: $@";
}

print "$result\n";
