#!/usr/bin/env perl
# 元ファイル: perl/az.pl - CLI上で暗算ができるスクリプト
# 使い方: az 14 a 54  az 91 m 32  (a=+ s=- m=* d=/)

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

my $expr = join(' ', @ARGV);
# 英字演算子を記号に置換: a=+ s=- m=* d=/
$expr =~ s/\ba\b/+/g;
$expr =~ s/\bs\b/-/g;
$expr =~ s/\bm\b/*/g;
$expr =~ s/\bd\b/\//g;

# 式を評価して計算
my $result = eval $expr;
die "エラー: $@" if $@;
print "$result\n";
