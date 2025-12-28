#!/usr/bin/env perl
# CLAUDE.mdとAGENTS.mdを比較して大きい方を小さい方にコピーする
# 例: perl merge_agent.pl [c|a]
# 引数: c = CLAUDE.md -> AGENTS.md, a = AGENTS.md -> CLAUDE.md, なし = サイズ比較

use strict;
use warnings;
use utf8;
use X;

my $claude_file = 'CLAUDE.md';
my $agents_file = 'AGENTS.md';

# 引数の取得と処理
my $arg = shift @ARGV;
my $force_direction = undef;

if (defined $arg) {
    my $first_char = lc(substr($arg, 0, 1));
    if ($first_char eq 'c') {
        $force_direction = 'claude_to_agents';
    } elsif ($first_char eq 'a') {
        $force_direction = 'agents_to_claude';
    } else {
        die "Error: Invalid argument. Use 'c' for CLAUDE->AGENTS or 'a' for AGENTS->CLAUDE\\n";
    }
}

# ファイルの存在確認
my $claude_exists = -f $claude_file;
my $agents_exists = -f $agents_file;

if (!$claude_exists && !$agents_exists) {
    die "Error: Both files do not exist\n";
}

# 引数で方向が指定されている場合は強制的にコピー
if (defined $force_direction) {
    if ($force_direction eq 'claude_to_agents') {
        if (!$claude_exists) {
            die "Error: CLAUDE.md does not exist\n";
        }
        cp($claude_file, $agents_file);
        my $size = -s $claude_file;
        print "Copied CLAUDE.md to AGENTS.md ($size bytes)\n";
        exit 0;
    } elsif ($force_direction eq 'agents_to_claude') {
        if (!$agents_exists) {
            die "Error: AGENTS.md does not exist\n";
        }
        cp($agents_file, $claude_file);
        my $size = -s $agents_file;
        print "Copied AGENTS.md to CLAUDE.md ($size bytes)\n";
        exit 0;
    }
}

if (!$claude_exists || !$agents_exists) {
    # 片方だけ存在する場合は単純にコピー
    my $src = $claude_exists ? $claude_file : $agents_file;
    my $dest = $claude_exists ? $agents_file : $claude_file;
    
    cp($src, $dest);
    print "File copied: $src -> $dest\n";
    exit 0;
}

# 両方存在する場合はサイズ比較
my $claude_size = -s $claude_file;
my $agents_size = -s $agents_file;

if ($claude_size > $agents_size) {
    cp($claude_file, $agents_file);
    print "Copied CLAUDE.md ($claude_size bytes) to AGENTS.md ($agents_size bytes)\n";
} else {
    cp($agents_file, $claude_file);
    print "Copied AGENTS.md ($agents_size bytes) to CLAUDE.md ($claude_size bytes)\n";
}
