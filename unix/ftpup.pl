#!/usr/bin/env perl
# ftpup.pl - lftpを使ってFTPサーバーにファイルを同期する
# 使い方: ftpup.pl [オプション] / ftpup.pl -f ftpsync.json

use strict;
use warnings;
use utf8;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use JSON::PP;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my $version = '1.0.0';

my %opt = (
    host      => '',
    port      => 21,
    user      => '',
    password  => '',
    localdir  => '',
    serverdir => '',
    passive   => 1,
    file      => 'ftpup.json',
);

sub print_version {
    print "ftpup.pl version $version\n";
    exit 0;
}

sub print_help {
    print <<'END';
使い方: ftpup.pl [オプション]

オプション:
  --host,      -h  FTPサーバーホスト名
  --port,      -p  ポート番号 (デフォルト: 21)
  --user,      -u  ユーザー名 (デフォルト: anonymous)
  --password,  -P  パスワード
  --localdir,  -l  ローカルディレクトリ (デフォルト: .)
  --serverdir, -s  サーバー上のディレクトリ (デフォルト: /)
  --passive        パッシブモード 1=有効 0=無効 (デフォルト: 1)
  --file, -f  設定ファイルパス (デフォルト: ftpup.json)
  --version   バージョン表示
  --help      このヘルプを表示

設定ファイル (JSON):
  実行ディレクトリの ftpsync.json を自動的に読み込む。
  コマンドライン引数は設定ファイルより優先される。

  例 ftpup.json:
  {
    "host":      "ftp.example.com",
    "port":      21,
    "user":      "myuser",
    "password":  "mypassword",
    "localdir":  "./public",
    "serverdir": "/var/www/html",
    "passive":   1
  }
END
    exit 0;
}

sub json_read {
    my ($file) = @_;
    open my $fh, '<:utf8', $file or die "Cannot open $file: $!";
    local $/;
    return JSON::PP->new->decode(<$fh>);
}

sub load_config {
    my ($file) = @_;
    return unless -f $file;
    my $cfg = json_read($file);
    for my $key (keys %$cfg) {
        $opt{$key} = $cfg->{$key} unless defined $opt{$key} && $opt{$key} ne '';
    }
}

sub check_lftp {
    unless (system('which lftp > /dev/null 2>&1') == 0) {
        die "エラー: lftpが見つかりません。以下のコマンドでインストールしてください:\n  sudo apt install lftp\n";
    }
}

sub run_lftp {
    my $passive = $opt{passive} ? 'set ftp:passive-mode on' : 'set ftp:passive-mode off';
    my $cmd = sprintf(
        'lftp -c "%s; open -u %s,%s -p %d %s; mirror --reverse --delete %s %s"',
        $passive,
        $opt{user},
        $opt{password},
        $opt{port},
        $opt{host},
        $opt{localdir},
        $opt{serverdir},
    );
    print "実行中: lftp mirror $opt{localdir} => $opt{host}:$opt{serverdir}\n";
    system($cmd) == 0 or die "lftpの実行に失敗しました: $?\n";
}

sub main {
    GetOptions(
        'host|h=s'      => \$opt{host},
        'port|p=i'      => \$opt{port},
        'user|u=s'      => \$opt{user},
        'password|P=s'  => \$opt{password},
        'localdir|l=s'  => \$opt{localdir},
        'serverdir|s=s' => \$opt{serverdir},
        'passive=i'     => \$opt{passive},
        'file|f=s'      => \$opt{file},
        'version'       => \&print_version,
        'help'          => \&print_help,
    ) or print_help();

    load_config($opt{file});

    die "エラー: --host が指定されていません\n"      unless $opt{host};
    die "エラー: --user が指定されていません\n"      unless $opt{user};
    die "エラー: --localdir が指定されていません\n"  unless $opt{localdir};
    die "エラー: --serverdir が指定されていません\n" unless $opt{serverdir};

    check_lftp();
    run_lftp();
}

main();
