#!/usr/bin/env perl
# ggw - Git worktreeを簡単に管理するツール
#
# 使い方:
#   ggw add feature-login     # worktreeを作成
#   ggw ls                    # 一覧表示
#   ggw cd feature-login      # ターミナルで開く
#   ggw merge feature-login   # mainにマージ
#   ggw rm feature-login      # 削除

use strict;
use warnings;
use Cwd qw(getcwd abs_path);
use File::Basename;
use File::Spec;

# Gitリポジトリのルートを取得
sub get_repo_root {
    my $root = `git rev-parse --show-toplevel 2>/dev/null`;
    chomp $root;
    die "エラー: Gitリポジトリ内で実行してください\n" unless $root;
    return $root;
}

# worktreeディレクトリのパスを取得
sub get_worktree_path {
    my ($branch) = @_;
    my $root = get_repo_root();
    return File::Spec->catdir($root, '.worktrees', $branch);
}

# worktreeを追加
sub cmd_add {
    my ($branch) = @_;
    die "使い方: ggw add <branch-name>\n" unless $branch;
    
    my $root = get_repo_root();
    my $worktrees_dir = File::Spec->catdir($root, '.worktrees');
    my $path = get_worktree_path($branch);
    
    # .worktreesディレクトリを作成
    mkdir $worktrees_dir unless -d $worktrees_dir;
    
    # ブランチが存在するか確認
    my $branch_exists = system("git show-ref --verify --quiet refs/heads/$branch") == 0;
    
    if ($branch_exists) {
        system("git worktree add '$path' '$branch'") == 0
            or die "エラー: worktree作成に失敗しました\n";
    } else {
        system("git worktree add -b '$branch' '$path'") == 0
            or die "エラー: worktree作成に失敗しました\n";
    }
    
    print "worktreeを作成しました: $path\n";
}

# worktree一覧を表示
sub cmd_list {
    system('git worktree list');
}

# ブランチをmainにマージ
sub cmd_merge {
    my ($branch) = @_;
    die "使い方: ggw merge <branch-name>\n" unless $branch;
    
    # 現在のブランチを保存
    my $current = `git branch --show-current`;
    chomp $current;
    
    # mainにチェックアウト
    system('git checkout main') == 0
        or die "エラー: mainブランチへの切り替えに失敗しました\n";
    
    # マージ実行
    if (system("git merge '$branch'") != 0) {
        # マージ失敗時は元のブランチに戻す
        system("git checkout '$current'") if $current;
        die "エラー: マージに失敗しました\n";
    }
    
    print "マージ完了: $branch -> main\n";
    
    # 元のブランチに戻す
    system("git checkout '$current'") if $current;
}

# worktreeを削除
sub cmd_remove {
    my ($branch) = @_;
    die "使い方: ggw remove <branch-name>\n" unless $branch;
    
    my $path = get_worktree_path($branch);
    
    unless (-d $path) {
        die "エラー: worktreeが見つかりません: $path\n";
    }
    
    # 確認プロンプト
    print "worktreeを削除しますか? $path [y/N]: ";
    my $answer = <STDIN>;
    chomp $answer;
    
    unless ($answer =~ /^[yY]$/) {
        print "キャンセルしました\n";
        return;
    }
    
    # worktreeを削除
    system("git worktree remove '$path'") == 0
        or die "エラー: worktree削除に失敗しました\n";
    
    print "worktreeを削除しました: $path\n";
}

# ターミナルでworktreeを開く
sub cmd_open {
    my ($branch) = @_;
    die "使い方: ggw open <branch-name>\n" unless $branch;
    
    my $path = get_worktree_path($branch);
    die "エラー: worktreeが見つかりません: $path\n" unless -d $path;
    
    # macOS
    if ($^O eq 'darwin') {
        system("open -a Terminal '$path'");
    }
    # Windows
    elsif ($^O eq 'MSWin32') {
        system("wt.exe -w 0 nt -d '$path' pwsh.exe");
    }
    # Linux
    elsif ($^O eq 'linux') {
        # 利用可能なターミナルを検索
        if (system('which xfce4-terminal >/dev/null 2>&1') == 0) {
            system("xfce4-terminal --working-directory='$path' &");
        } elsif (system('which gnome-terminal >/dev/null 2>&1') == 0) {
            system("gnome-terminal --working-directory='$path' &");
        } elsif (system('which konsole >/dev/null 2>&1') == 0) {
            system("konsole --workdir='$path' &");
        } elsif (system('which xterm >/dev/null 2>&1') == 0) {
            system("cd '$path' && xterm &");
        } else {
            die "エラー: 利用可能なターミナルが見つかりません\n";
        }
    }
    else {
        die "エラー: このOSはサポートされていません\n";
    }
    
    print "ターミナルを開きました: $path\n";
}

# ヘルプ表示
sub show_help {
    print <<'HELP';
使い方: ggw <command> [args]

コマンド:
  add <branch>      worktreeを作成 (alias: create)
  list              worktree一覧を表示 (alias: ls)
  merge <branch>    ブランチをmainにマージ
  remove <branch>   worktreeを削除 (alias: rm)
  open <branch>     worktreeをターミナルで開く (alias: cd)
  help              このヘルプを表示 (alias: usage)
HELP
}

# メイン処理
sub main {
    my $command = shift @ARGV || 'help';
    
    # エイリアスを正規化
    my %aliases = (
        'rm'       => 'remove',
        'cd'       => 'open',
        'ls'       => 'list',
        'create'   => 'add',
        'usage'    => 'help',
    );
    
    $command = $aliases{$command} if exists $aliases{$command};
    
    if ($command eq 'add') {
        cmd_add(shift @ARGV);
    } elsif ($command eq 'list') {
        cmd_list();
    } elsif ($command eq 'merge') {
        cmd_merge(shift @ARGV);
    } elsif ($command eq 'remove') {
        cmd_remove(shift @ARGV);
    } elsif ($command eq 'open') {
        cmd_open(shift @ARGV);
    } elsif ($command eq 'help') {
        show_help();
    } else {
        print "エラー: 不明なコマンド: $command\n\n";
        show_help();
        exit 1;
    }
}

main();
