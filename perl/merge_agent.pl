#!/usr/bin/env perl
# CLAUDE.mdとAGENTS.mdを比較して大きい方を小さい方にコピーする
# 例: perl merge_agent.pl

use strict;
use warnings;
use X;

my $claude_file = 'CLAUDE.md';
my $agents_file = 'AGENTS.md';

# ファイルの存在確認
my $claude_exists = -f $claude_file;
my $agents_exists = -f $agents_file;

if (!$claude_exists && !$agents_exists) {
    die "Error: Both files do not exist\n";
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