#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket::INET;
use IPC::Open2;
use Getopt::Long;
use File::Spec;
use Cwd 'abs_path';

# デフォルト設定
my $server_addr = '127.0.0.1:8000';
my $doc_root = '.';

# コマンドライン引数処理
GetOptions(
    'server|s=s' => \$server_addr,
    'root|r=s'   => \$doc_root,
) or die "Usage: $0 [--server|-s addr:port] [--root|-r /path/to/dir]\n";

# アドレスとポート分離
my ($host, $port) = split /:/, $server_addr;
$port ||= 8000;

# ドキュメントルート正規化
$doc_root = abs_path($doc_root) || $doc_root;
print "Server: http://$host:$port\nRoot: $doc_root\n";

# サーバーソケット作成
my $server = IO::Socket::INET->new(
    LocalHost => $host,
    LocalPort => $port,
    Listen    => 5,
    Reuse     => 1,
) or die "Cannot create socket: $!\n";

# メインループ
while (my $client = $server->accept()) {
    my $request_line = <$client>;
    next unless $request_line;

    # リクエストパース
    my ($method, $uri, $protocol) = split /\s+/, $request_line;
    next unless $method && $uri;

    # ヘッダー読み込み
    my %headers;
    while (my $line = <$client>) {
        last if $line =~ /^\r?\n$/;
        if ($line =~ /^([^:]+):\s*(.+)/) {
            $headers{lc($1)} = $2;
            $headers{lc($1)} =~ s/\r?\n$//;
        }
    }

    # リクエストボディ読み込み（POST等）
    my $body = '';
    if ($headers{'content-length'}) {
        read($client, $body, $headers{'content-length'});
    }

    # パスとクエリ分離
    my ($path, $query) = split /\?/, $uri, 2;
    $path = '/index.html' if $path eq '/';
    $query ||= '';

    handle_request($client, $method, $path, $query, \%headers, $body);
    close $client;
}

sub handle_request {
    my ($client, $method, $uri_path, $query, $headers, $body) = @_;

    # パストラバーサル対策
    $uri_path =~ s/\.\.//g;
    my $file_path = File::Spec->catfile($doc_root, $uri_path);

    # ディレクトリの場合はindex探索
    if (-d $file_path) {
        for my $index ('index.cgi', 'index.html', 'index.htm') {
            my $idx = File::Spec->catfile($file_path, $index);
            if (-f $idx) {
                $file_path = $idx;
                last;
            }
        }
    }

    # ファイル存在確認
    unless (-f $file_path) {
        print $client "HTTP/1.1 404 Not Found\r\n\r\n404 Not Found\n";
        return;
    }

    # CGI判定と実行
    if ($file_path =~ /\.cgi$/ || -x $file_path) {
        execute_cgi($client, $file_path, $method, $uri_path, $query, $headers, $body);
    } else {
        serve_static($client, $file_path);
    }
}

sub execute_cgi {
    my ($client, $file_path, $method, $uri_path, $query, $headers, $body) = @_;

    # shebang読み取り
    open my $fh, '<', $file_path or do {
        print $client "HTTP/1.1 500 Internal Server Error\r\n\r\n";
        return;
    };
    my $shebang = <$fh>;
    close $fh;

    # インタプリタ決定
    my $interpreter = '';
    if ($shebang =~ /^#!\s*(.+)/) {
        $interpreter = $1;
        $interpreter =~ s/\s+$//;
        # Windows対応：/usr/bin/env perl → perl
        $interpreter =~ s|^.*/([^/]+)$|$1| if $^O eq 'MSWin32';
    }

    # CGI環境変数設定
    local %ENV = %ENV;
    $ENV{REQUEST_METHOD} = $method;
    $ENV{SCRIPT_NAME} = $uri_path;
    $ENV{QUERY_STRING} = $query;
    $ENV{SERVER_SOFTWARE} = 'hhd/1.0';
    $ENV{SERVER_NAME} = $host;
    $ENV{SERVER_PORT} = $port;
    $ENV{GATEWAY_INTERFACE} = 'CGI/1.1';
    $ENV{SERVER_PROTOCOL} = 'HTTP/1.1';
    $ENV{PATH_INFO} = '';
    $ENV{PATH_TRANSLATED} = '';
    $ENV{CONTENT_TYPE} = $headers->{'content-type'} || '';
    $ENV{CONTENT_LENGTH} = $headers->{'content-length'} || '';

    # CGI実行（標準入力にPOSTデータを渡す）
    my @cmd = $interpreter ? ($interpreter, $file_path) : ($file_path);
    my $output;

    if ($method eq 'POST' && $body) {
        # POSTデータを標準入力に渡す
        my ($cgi_in, $cgi_out);
        my $pid = eval { open2($cgi_out, $cgi_in, @cmd) };
        if (!$pid) {
            print $client "HTTP/1.1 500 Internal Server Error\r\n\r\n";
            return;
        }
        print $cgi_in $body;
        close $cgi_in;
        $output = do { local $/; <$cgi_out> };
        close $cgi_out;
        waitpid($pid, 0);
    } else {
        my $cmd = join(' ', map { "\"$_\"" } @cmd);
        $output = `$cmd 2>&1`;
    }

    # レスポンス送信
    if ($output =~ /^Content-Type:/i) {
        print $client "HTTP/1.1 200 OK\r\n$output";
    } else {
        print $client "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n$output";
    }
}

sub serve_static {
    my ($client, $file_path) = @_;

    # ファイル読み込み
    open my $fh, '<:raw', $file_path or do {
        print $client "HTTP/1.1 500 Internal Server Error\r\n\r\n";
        return;
    };
    my $content = do { local $/; <$fh> };
    close $fh;

    # Content-Type判定
    my $content_type = 'text/plain';
    $content_type = 'text/html' if $file_path =~ /\.html?$/i;
    $content_type = 'text/css' if $file_path =~ /\.css$/i;
    $content_type = 'application/javascript' if $file_path =~ /\.js$/i;
    $content_type = 'image/jpeg' if $file_path =~ /\.jpe?g$/i;
    $content_type = 'image/png' if $file_path =~ /\.png$/i;
    $content_type = 'image/gif' if $file_path =~ /\.gif$/i;

    # レスポンス送信
    print $client "HTTP/1.1 200 OK\r\n";
    print $client "Content-Type: $content_type\r\n";
    print $client "Content-Length: " . length($content) . "\r\n\r\n";
    print $client $content;
}
