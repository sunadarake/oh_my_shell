#!/usr/bin/env perl
# 元ファイル: perl/init_claude.pl - Claude Code / OpenCode設定ファイルを初期化
# 使い方: perl init_claude.pl [--update]  (--update: 設定・コマンドを上書き。AGENTS.md は変更しない)

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use File::Path qw(make_path);
use JSON::PP;
use FindBin qw($Bin);
use File::Basename qw(basename);
use File::Glob qw(bsd_glob);

sub fread {
    my ($file) = @_;
    open(my $fh, '<:encoding(UTF-8)', $file) or die "読み込みエラー: $file: $!\n";
    local $/;
    my $content = <$fh>;
    close($fh);
    return $content;
}

sub fwrite {
    my ($file, $content) = @_;
    open(my $fh, '>:encoding(UTF-8)', $file) or die "書き込みエラー: $file: $!\n";
    print $fh $content;
    close($fh);
}

my $update = grep { $_ eq '--update' } @ARGV;

# 未作成または --update のときのみ書き込む
sub put {
    my ($file, $content) = @_;
    my $exists = -f $file;
    return if $exists && !$update;
    fwrite($file, $content);
    print(($exists ? "Updated" : "Created"), ": $file\n");
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
make_path('.claude');
{

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
    put($settings_file, JSON::PP->new->utf8->pretty->encode($settings));
}

# .claude/commands にスラッシュコマンドを追加する
# テンプレートを読み込む(build後は .bin/templates、開発時は ../templates)
my ($tpl) = grep { -d } ("$Bin/templates/init_claude", "$Bin/../templates/init_claude");
die "テンプレートが見つかりません\n" unless $tpl;
my %commands = map { basename($_) => fread($_) } bsd_glob("$tpl/commands/*.md");
make_path('.claude/commands');
for my $name (sort keys %commands) {
    my $file = ".claude/commands/$name";
    put($file, $commands{$name});
}

# OpenCode: .opencode/commands に同じコマンドを追加する(argument-hint / allowed-tools は未対応のため除く)
make_path('.opencode/commands');
for my $name (sort keys %commands) {
    my $file = ".opencode/commands/$name";
    (my $body = $commands{$name}) =~ s/^(?:argument-hint|allowed-tools):.*\n//mg;
    $body =~ s/CLAUDE\.md/AGENTS.md/g;
    put($file, $body);
}

# OpenCode: opencode.json に permission を設定する(後勝ちのため "*" を先頭に置く)
my $opencode_file = 'opencode.json';
{
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
    put($opencode_file, JSON::PP->new->utf8->pretty->canonical->encode($config));
}

# 未作成のときのみ生成する
unless (-f 'AGENTS.md') {
    fwrite('AGENTS.md', fread("$tpl/AGENTS.md"));
    print "Created: AGENTS.md\n";
}

print "Finish Complete\n";
