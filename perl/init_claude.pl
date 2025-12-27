#!/usr/bin/env perl
# init_claude.pl - Claude設定ファイルを初期化
# 使い方: perl init_claude.pl

use strict;
use warnings;
use utf8;
use X;

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
my $agent_md = 'AGENTS.md';
my $content = <<'MD';
<<ここにプロジェクトの名前を入れる>>

<<ここにプロジェクトの概要を２，３行程度で入れる>>

## プロジェクトの取り組み方について

* なるべくコードやコメントをシンプルに簡潔にすること。 
* コメントはUTF-8の日本語で書くこと。 
* 問題に取り組む前に、コードや仕様を読んで理解すること。 

## Bashについて

bashを使わずにbusyboxを使う様にしてください。
MD

unless (-f $claude_md) {
    fp($claude_md, $content);
    print "Created: $claude_md\n";
}

unless (-f $agent_md) {
    fp($agent_md, $content);
    print "Created: $agent_md\n";
}

print "Finish Complete\n"
