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
    echo curl base64
);

my $settings_file = '.claude/settings.json';
# settings.json が未作成のときのみ初期化する
unless (-f $settings_file) {
    make_path('.claude');

    my @allow = map { "Bash($_:*)" } @commands;
    push @allow, "Bash(git:*)", "List(*)", "Edit(*)", "Write(*)", "mcp__voicevox__speak";

    # 危険な操作と機密ファイルの読み取りを拒否する
    my @deny = (
        "Bash(rm -rf:*)", "Bash(git push --force:*)",
        "Read(~/.ssh/**)", "Read(./.env)",
    );

    # 署名(Co-Authored-By等)をコミット・PRに付けない
    my $settings = {
        permissions => { allow => \@allow, deny => \@deny },
        attribution => { commit => '', pr => '' },
        includeCoAuthoredBy => JSON::PP::false,
    };
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
    'update-agents-md.md' => <<'MD',
---
description: これまでの変更を踏まえてAGENTS.mdを更新する
---

このセッションでの変更を踏まえて、`AGENTS.md` を実態に合わせて更新してください。

- 変更された仕様・コマンド・ディレクトリ構成を反映する
- 古くなった記述は削除または修正する
- 既存の構成やトーンは維持し、差分は最小限にする

MD
    'git-commit.md' => <<'MD',
---
description: ここまでの変更をgit commitする
---

ここまでの変更を `git commit` してください。

- コミットメッセージは、日本語で簡潔かつ分かりやすく書いてください。
- 変更内容が一目で分かる1行目(50文字程度)にしてください。必要な場合のみ、空行のあとに補足を書いてください。
- `Co-Authored-By: Claude ...` や `🤖 Generated with Claude Code` などの署名・クレジット行は、コミットメッセージに含めないでください。
MD
    'update-agents-and-git.md' => <<'MD',
---
description: AGENTS.mdを更新してからgit commitする
---

次の順に実行してください。

1. このセッションでの変更を踏まえて、`AGENTS.md` を実態に合わせて更新する(既存の構成やトーンは維持し、差分は最小限にする)
2. `AGENTS.md` を含むここまでの変更を `git commit` する

- コミットメッセージは、日本語で簡潔かつ分かりやすく書いてください。1行目は50文字程度にしてください。
- `Co-Authored-By: Claude ...` や `🤖 Generated with Claude Code` などの署名・クレジット行は、コミットメッセージに含めないでください。
MD
    'todo.md' => <<'MD',
---
description: 実装計画を立てて todo/ に連番のTODOファイルを作成する
argument-hint: <実装したい内容>
allowed-tools: Bash(ls:*), Bash(tail:*), Read, Glob, Grep, Write, AskUserQuestion
---

## 依頼内容
$ARGUMENTS

## 最新のTODOファイル（最大5件）
!`ls todo/ | tail -5`

## 手順
1. 依頼内容を理解し、関連するコードを Glob / Grep / Read で調査する
2. 仕様・方針・範囲などで不明点や判断が分かれる点があれば、AskUserQuestion で質問して回答を待つ（推測で進めない）
3. 回答を踏まえて実装計画を立てる
4. 既存ファイルの最大番号に +1 した番号を3桁ゼロ埋めで決める（ファイルがなければ 001）
5. `todo/NNN-todo.md` を作成する（例: 既存が 002 までなら `todo/003-todo.md`）

## TODOファイルの形式
# <タイトル>

## 概要
何を・なぜ実装するか

## 調査結果
関連ファイルと現状の構成

## 実装計画
- [ ] ステップ1: 具体的な作業内容（対象ファイル）
- [ ] ステップ2: ...

## テスト・確認方法
- [ ] ...

## 決定事項
質問への回答で決まったこと

## 懸念点・未決事項
- ...

## 注意
- 計画の作成のみ行い、コードの実装はしないこと
- 質問は調査後にまとめて行い、コードを読めば分かることは聞かないこと
- 作成後、ファイルパスと計画の要約を報告すること
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

# OpenCode: .opencode/commands に同じコマンドを追加する(argument-hint / allowed-tools は未対応のため除く)
make_path('.opencode/commands');
for my $name (sort keys %commands) {
    my $file = ".opencode/commands/$name";
    unless (-f $file) {
        (my $body = $commands{$name}) =~ s/^(?:argument-hint|allowed-tools):.*\n//mg;
        $body =~ s/CLAUDE\.md/AGENTS.md/g;
        fwrite($file, $body);
        print "Created: $file\n";
    }
}

# OpenCode: opencode.json に permission を設定する(後勝ちのため "*" を先頭に置く)
my $opencode_file = 'opencode.json';
unless (-f $opencode_file) {
    my $config = {
        '$schema'  => 'https://opencode.ai/config.json',
        permission => {
            '*'                => 'allow',
            edit               => 'allow',
            webfetch           => 'allow',
            external_directory => 'ask',
            bash               => { '*' => 'allow', 'rm *' => 'ask', 'rmdir *' => 'ask' },
        },
    };
    fwrite($opencode_file, JSON::PP->new->utf8->pretty->canonical->encode($config));
    print "Created: $opencode_file\n";
}

# AGENTS.md のテンプレート
my $content = <<'MD';
<<ここにプロジェクトの名前を入れる>>

<<ここにプロジェクトの概要を２，３行程度で入れる>>

## プロジェクトの取り組み方について

* なるべくコードやコメントをシンプルに簡潔にすること。
* コメントはUTF-8の日本語で書くこと。
* 問題に取り組む前に、コードや仕様を読んで理解すること。
MD

# 未作成のときのみ生成する
unless (-f 'AGENTS.md') {
    fwrite('AGENTS.md', $content);
    print "Created: AGENTS.md\n";
}

print "Finish Complete\n";
