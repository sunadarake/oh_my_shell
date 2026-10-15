#!/usr/bin/env perl
# 元ファイル: perl/init_claude.pl - Claude Code / OpenCode設定ファイルを初期化
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

my @commands = qw(
    rg grep egrep fgrep
    mkdir cp mv touch chmod chown find
    cat head tail less more wc sort uniq cut awk sed tee
    ls stat file diff du df
    which whereis pwd
);
# コマンド × プレフィックス(busybox等)の全組み合わせで許可リストを生成
my @prefixes = ('', 'busybox ', 'busybox64u ');

my $settings_file = '.claude/settings.json';
# settings.json が未作成のときのみ初期化する
unless (-f $settings_file) {
    make_path('.claude');

    my @allow = map { my $p = $_; map { "Bash(${p}$_:*)" } @commands } @prefixes;
    push @allow, "Bash(git add:*)", "List(*)", "Edit(*)", "Write(*)", "mcp__voicevox__speak";

    my $settings = { permissions => { allow => \@allow, deny => [] } };
    fwrite($settings_file, JSON::PP->new->utf8->pretty->encode($settings));
    print "Created: $settings_file\n";
}

# .claude/commands にスラッシュコマンドを追加する
my %commands = (
    'ask.md' => <<'MD',
---
description: Claudeに質問する(日本語で簡潔に回答)
argument-hint: [質問内容]
---

次の質問に、日本語でわかりやすく簡潔に答えてください。
専門用語は必要最小限にし、必要なら短い例を添えてください。
コードの変更やファイル編集はせず、回答のみ行ってください。

質問: $ARGUMENTS
MD
    'update-claude-md.md' => <<'MD',
---
description: これまでの変更を踏まえてCLAUDE.mdを更新する
---

このセッションでの変更を踏まえて、`CLAUDE.md` を実態に合わせて更新してください。

- 変更された仕様・コマンド・ディレクトリ構成を反映する
- 古くなった記述は削除または修正する
- 既存の構成やトーンは維持し、差分は最小限にする

編集する前に、何を直すかの要点を一覧で見せてください。
MD
    'git-commit.md' => <<'MD',
---
description: ここまでの変更をgit commitする
---

ここまでの変更を `git commit` してください。

- コミットメッセージは、日本語で簡潔かつ分かりやすく書いてください。
- 変更内容が一目で分かる1行目(50文字程度)にしてください。必要な場合のみ、空行のあとに補足を書いてください。
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

# OpenCode: .opencode/commands に同じコマンドを追加する(argument-hint は未対応のため除く)
# update-claude-md は update-agents-md に改名し、AGENTS.md を更新対象にする
make_path('.opencode/commands');
for my $name (sort keys %commands) {
    (my $ocname = $name) =~ s/claude-md/agents-md/;
    my $file = ".opencode/commands/$ocname";
    unless (-f $file) {
        (my $body = $commands{$name}) =~ s/^argument-hint:.*\n//m;
        $body =~ s/CLAUDE\.md/AGENTS.md/g;
        fwrite($file, $body);
        print "Created: $file\n";
    }
}

# OpenCode: opencode.json に permission を設定する(後勝ちのため "*" を先頭に置く)
my $opencode_file = 'opencode.json';
unless (-f $opencode_file) {
    my %bash = ('*' => 'ask');
    for my $p (@prefixes) {
        for my $c (@commands) {
            # 引数なし・引数ありの両方を許可する
            $bash{"$p$c"} = $bash{"$p$c *"} = 'allow';
        }
    }
    $bash{'git add *'} = 'allow';
    # TODO: mcp__voicevox__speak 相当の許可は OpenCode のMCP設定に依存するため未対応
    my $config = {
        '$schema'  => 'https://opencode.ai/config.json',
        permission => { bash => \%bash, edit => 'allow' },
    };
    fwrite($opencode_file, JSON::PP->new->utf8->pretty->canonical->encode($config));
    print "Created: $opencode_file\n";
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
