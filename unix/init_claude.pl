#!/usr/bin/env perl
# 元ファイル: perl/init_claude.pl - Claude設定ファイルを初期化
# 使い方: perl init_claude.pl

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use File::Path qw(make_path);
use JSON::PP;

sub fwrite {
    my ($file, $content) = @_;
    open(my $fh, '>:encoding(UTF-8)', $file) or die "書き込みエラー: $file: $!\n";
    print $fh $content;
    close($fh);
}

my $settings_file = '.claude/settings.json';
# settings.json が未作成のときのみ初期化する
unless (-f $settings_file) {
    make_path('.claude');

    my @commands = qw(
        rg grep egrep fgrep
        mkdir cp mv touch chmod chown find
        cat head tail less more wc sort uniq cut awk sed tee
        ls stat file diff du df
        which whereis pwd
    );
    # コマンド × プレフィックス(busybox等)の全組み合わせで許可リストを生成
    my @prefixes = ('', 'busybox ', 'busybox64u ');
    my @allow = map { my $p = $_; map { "Bash(${p}$_:*)" } @commands } @prefixes;
    push @allow, "Bash(git add:*)", "List(*)", "Edit(*)", "Write(*)", "mcp__voicevox__speak";

    my $settings = { permissions => { allow => \@allow, deny => [] } };
    fwrite($settings_file, JSON::PP->new->utf8->pretty->encode($settings));
    print "Created: $settings_file\n";
}

# .claude/commands にスラッシュコマンドを追加する
my %commands = (
    'update-claude-md.md' => <<'MD',
# CLAUDE.md をこれまでの変更を踏まえて更新

このセッションでの変更を踏まえて、CLAUDE.md を実態に合わせて更新して。
- 変わった仕様・コマンド・ディレクトリ構成を反映
- 古くなった記述は削除・修正
- 既存の構成やトーンは維持し、差分を最小限に
変更前に何を直すか要点を一覧で見せてから編集して。
MD
    'git-commit.md' => <<'MD',
# git commitでここまでの修正を書くこと。

ここまでの変更を git commit して。
コミットログは簡潔にかつ分かりやすく書いて。
MD
);
make_path('.claude/commands');
for my $name (sort keys %commands) {
    my $file = ".claude/commands/$name";
    unless (-f $file) {
        fwrite($file, $commands{$name});
        print "Created: $file\n";
    }
}

# CLAUDE.md / AGENTS.md のテンプレート
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

# 両ファイルとも未作成のときのみ生成する
for my $md ('CLAUDE.md', 'AGENTS.md') {
    unless (-f $md) {
        fwrite($md, $content);
        print "Created: $md\n";
    }
}

print "Finish Complete\n";
