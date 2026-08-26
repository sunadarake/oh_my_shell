#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Encode qw(decode encode);
use File::Spec;
use File::Path qw(make_path);
use Cwd qw(abs_path getcwd);

# 標準出力・標準エラーをUTF-8として扱う（Wide character警告対策）
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

# コマンドライン引数（バイト列）をUTF-8としてデコード
@ARGV = map { decode('UTF-8', $_) } @ARGV;

# ファイルシステム呼び出し用の変換ヘルパー
sub to_fs   { encode('UTF-8', $_[0]) }  # Perl文字列 -> OSに渡すバイト列
sub from_fs { decode('UTF-8', $_[0]) }  # OSから受け取ったバイト列 -> Perl文字列

my $HOME_bytes = $ENV{HOME} // (getpwuid($<))[7] // die "HOMEディレクトリが取得できません\n";
my $HOME       = from_fs($HOME_bytes);
my $STASH_DIR  = File::Spec->catdir($HOME, '.claude_stash');
my $MANIFEST   = File::Spec->catfile($STASH_DIR, 'manifest.tsv');

sub usage {
    print <<"USAGE";
使い方:
  $0 stash <dir1> [dir2 ...]   # ディレクトリを退避
  $0 restore [dir1 ...]        # 退避したディレクトリを元に戻す（省略時は全部）
  $0 list                      # 退避中の一覧を表示

退避先: $STASH_DIR

例:
  $0 stash secrets/ node_modules/
  $0 restore secrets/
  $0 restore
USAGE
    exit 1;
}

my $cmd = shift @ARGV or usage();

if ($cmd eq 'stash') {
    usage() unless @ARGV;
    do_stash(@ARGV);
} elsif ($cmd eq 'restore') {
    do_restore(@ARGV);
} elsif ($cmd eq 'list') {
    do_list();
} else {
    usage();
}

sub read_manifest {
    my @entries;
    return @entries unless -e to_fs($MANIFEST);
    open my $fh, '<:encoding(UTF-8)', to_fs($MANIFEST)
        or die "manifestが読めません: $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        next unless length $line;
        my ($stash_path, $orig_path) = split /\t/, $line, 2;
        push @entries, { stash => $stash_path, orig => $orig_path };
    }
    close $fh;
    return @entries;
}

sub write_manifest {
    my (@entries) = @_;
    make_path(to_fs($STASH_DIR)) unless -d to_fs($STASH_DIR);
    open my $fh, '>:encoding(UTF-8)', to_fs($MANIFEST)
        or die "manifestに書けません: $!\n";
    for my $e (@entries) {
        print $fh "$e->{stash}\t$e->{orig}\n";
    }
    close $fh;
}

sub encode_name {
    my ($path) = @_;
    my $abs_bytes = abs_path(to_fs($path));
    die "パスが見つかりません: $path\n" unless defined $abs_bytes;
    my $abs = from_fs($abs_bytes);
    (my $name = $abs) =~ s{^/}{};
    $name =~ s{/}{__}g;
    return ($abs, $name);
}

sub do_stash {
    my (@dirs) = @_;
    make_path(to_fs($STASH_DIR)) unless -d to_fs($STASH_DIR);
    my @entries = read_manifest();
    my %already_orig = map { $_->{orig} => 1 } @entries;

    for my $dir (@dirs) {
        unless (-d to_fs($dir)) {
            warn "スキップ（ディレクトリではありません）: $dir\n";
            next;
        }
        my ($abs_orig, $name) = encode_name($dir);
        if ($already_orig{$abs_orig}) {
            warn "スキップ（既に退避済み）: $dir\n";
            next;
        }
        my $dest = File::Spec->catdir($STASH_DIR, $name);
        if (-e to_fs($dest)) {
            warn "スキップ（退避先が既に存在）: $dest\n";
            next;
        }
        rename(to_fs($abs_orig), to_fs($dest)) or do {
            warn "移動に失敗しました: $abs_orig -> $dest ($!)\n";
            next;
        };
        push @entries, { stash => $dest, orig => $abs_orig };
        print "退避しました: $abs_orig -> $dest\n";
    }
    write_manifest(@entries);
}

sub do_restore {
    my (@targets) = @_;
    my @entries = read_manifest();
    unless (@entries) {
        print "退避中のディレクトリはありません。\n";
        return;
    }

    my @remaining;
    for my $e (@entries) {
        my $should_restore = 1;
        if (@targets) {
            $should_restore = 0;
            for my $t (@targets) {
                my $abs_t_bytes = abs_path(to_fs($t));
                my $abs_t = defined $abs_t_bytes ? from_fs($abs_t_bytes) : File::Spec->rel2abs($t);
                if ($e->{orig} eq $abs_t || $e->{orig} =~ m{/\Q$t\E$}) {
                    $should_restore = 1;
                    last;
                }
            }
        }

        if ($should_restore) {
            if (-e to_fs($e->{orig})) {
                warn "スキップ（復元先に既に何かあります）: $e->{orig}\n";
                push @remaining, $e;
                next;
            }
            unless (-e to_fs($e->{stash})) {
                warn "警告: 退避先が見つかりません: $e->{stash}（マニフェストから削除します）\n";
                next;
            }
            my $parent = (File::Spec->splitpath($e->{orig}))[1];
            make_path(to_fs($parent)) if $parent && !-d to_fs($parent);
            rename(to_fs($e->{stash}), to_fs($e->{orig})) or do {
                warn "復元に失敗しました: $e->{stash} -> $e->{orig} ($!)\n";
                push @remaining, $e;
                next;
            };
            print "復元しました: $e->{stash} -> $e->{orig}\n";
        } else {
            push @remaining, $e;
        }
    }
    write_manifest(@remaining);
}

sub do_list {
    my @entries = read_manifest();
    unless (@entries) {
        print "退避中のディレクトリはありません。\n";
        return;
    }
    for my $e (@entries) {
        print "$e->{orig}\n  -> $e->{stash}\n";
    }
}

